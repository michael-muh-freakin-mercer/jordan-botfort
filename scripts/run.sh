#!/usr/bin/env bash
# Runs one agent cycle headlessly (Alpaca PAPER instance). Usage: scripts/run.sh hourly|overnight|weekly|first-run|flatten
# Cron calls this. It never overlaps itself (flock), skips when HALT exists (except flatten),
# records token usage per run to logs/runs.jsonl, saves the agent's output, and commits state to git.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

# Cron has a minimal PATH. Adjust if `which claude` shows a different location.
export PATH="$HOME/.local/share/mise/installs/claude/latest:$HOME/.local/share/mise/shims:$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

RUN_TYPE="${1:?usage: run.sh hourly|overnight|weekly|first-run|flatten}"
SONNET="claude-sonnet-5-5"
OPUS="claude-opus-5-5"

case "$RUN_TYPE" in
  hourly)    PROMPT=prompts/hourly.md;            MODEL=$SONNET; MAX_TURNS=60  ;;
  overnight) PROMPT=prompts/overnight.md;         MODEL=$SONNET; MAX_TURNS=40  ;;
  weekly)    PROMPT=prompts/weekly-review.md;     MODEL=$OPUS;   MAX_TURNS=150 ;;
  first-run) PROMPT=prompts/first-run.md;         MODEL=$OPUS;   MAX_TURNS=150 ;;
  flatten)   PROMPT=prompts/emergency-flatten.md; MODEL=$SONNET; MAX_TURNS=60  ;;
  *) echo "unknown run type: $RUN_TYPE" >&2; exit 2 ;;
esac

# One-shot escalation: a previous run that hit something it could not resolve creates state/ESCALATE;
# the next scheduled run then uses the stronger model once.
if [[ -f state/ESCALATE && ( "$RUN_TYPE" == "hourly" || "$RUN_TYPE" == "overnight" ) ]]; then
  MODEL=$OPUS
  rm -f state/ESCALATE
fi
MODEL="${TB_MODEL:-$MODEL}"   # manual override: TB_MODEL=claude-opus-5-5 scripts/run.sh hourly

mkdir -p logs/run-output state
STARTED="$(date -u +%FT%TZ)"
T0=$(date +%s)
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$RUN_TYPE"
OUT_DIR="logs/run-output/$(date -u +%F)"
mkdir -p "$OUT_DIR"

log_run() {  # $1 exit code, $2 json result path or "", $3 skipped reason or ""
  local rc="$1" res="$2" skipped="$3" ended dur
  ended="$(date -u +%FT%TZ)"; dur=$(( $(date +%s) - T0 ))
  if [[ -n "$res" && -s "$res" ]] && jq -e . "$res" >/dev/null 2>&1; then
    jq -c --arg t "$RUN_TYPE" --arg m "$MODEL" --arg s "$STARTED" --arg e "$ended" --argjson d "$dur" --argjson rc "$rc" --arg id "$RUN_ID" \
      '{run_id:$id, run_type:$t, model:$m, started:$s, ended:$e, duration_s:$d, exit_code:$rc,
        num_turns:(.num_turns // null), total_cost_usd:(.total_cost_usd // null), is_error:(.is_error // null),
        usage:(.usage // null), skipped_reason:null}' "$res" >> logs/runs.jsonl
  else
    jq -nc --arg t "$RUN_TYPE" --arg m "$MODEL" --arg s "$STARTED" --arg e "$ended" --argjson d "$dur" --argjson rc "$rc" --arg id "$RUN_ID" --arg sk "$skipped" \
      '{run_id:$id, run_type:$t, model:$m, started:$s, ended:$e, duration_s:$d, exit_code:$rc,
        num_turns:null, total_cost_usd:null, is_error:null, usage:null, skipped_reason:($sk|select(length>0))}' >> logs/runs.jsonl
  fi
}

# Never overlap: the lock is released when this process exits.
exec 9>"state/.run.lock"
if ! flock -n 9; then
  echo "[$STARTED] $RUN_TYPE skipped: another run holds the lock" | tee -a logs/runs.log
  log_run 0 "" "lock_held"
  exit 0
fi

if [[ -f state/HALT && "$RUN_TYPE" != "flatten" && "$RUN_TYPE" != "first-run" ]]; then
  echo "[$STARTED] $RUN_TYPE skipped: state/HALT present ($(head -c 200 state/HALT | tr '\n' ' '))" | tee -a logs/runs.log
  log_run 0 "" "halt"
  exit 0
fi

# Tools the agent may use. Everything else is blocked (see .claude/settings.json for the deny list and the order guard hook).
ALLOWED="mcp__alpaca,WebSearch,WebFetch,Read,Glob,Grep,Write,Edit,Bash(python3:*),Bash(date:*),Bash(ls:*),Bash(cat:*),Bash(tail:*),Bash(head:*),Bash(wc:*),Bash(mkdir:*),Bash(jq:*),Bash(git status:*),Bash(git log:*),Bash(git diff:*)"
DISALLOWED="mcp__robinhood-trading,mcp__alpaca__place_option_order,mcp__alpaca__exercise_options_position,mcp__alpaca__do_not_exercise_options_position,mcp__alpaca__create_locate,mcp__alpaca__update_account_config,mcp__alpaca__close_position,mcp__alpaca__close_all_positions,mcp__alpaca__cancel_all_orders,mcp__alpaca__replace_order_by_id,mcp__alpaca__delete_watchlist_by_id,mcp__Mercury,mcp__mercury,mcp__Gmail,mcp__gmail,mcp__Google_Calendar,mcp__Google_Docs,mcp__Google_Drive,mcp__Google_Sheets,mcp__Notion,mcp__notion,mcp__Claude_Docs,mcp__github,mcp__stripe,mcp__Stripe,Bash(curl:*),Bash(wget:*),Bash(git push:*),Bash(rm -rf:*),Bash(sudo:*)"

RESULT_JSON="$(mktemp)"
echo "[$STARTED] $RUN_TYPE starting (model $MODEL, run $RUN_ID)" | tee -a logs/runs.log

set +e
RUN_ID="$RUN_ID" TB_RUN_TYPE="$RUN_TYPE" claude -p "Run id: $RUN_ID. $(cat "$PROMPT")" \
  --model "$MODEL" \
  --output-format json \
  --max-turns "$MAX_TURNS" \
  --strict-mcp-config --mcp-config .mcp.json \
  --allowedTools "$ALLOWED" \
  --disallowedTools "$DISALLOWED" \
  > "$RESULT_JSON" 2>> logs/stderr.log
RC=$?
set -e

# Save the agent's visible output (its printed report / status lines) for Michael and for the summary script.
OUT_FILE="$OUT_DIR/$(date -u +%H%M)-$RUN_TYPE.md"
if jq -e . "$RESULT_JSON" >/dev/null 2>&1; then
  jq -r '.result // "(no result text)"' "$RESULT_JSON" > "$OUT_FILE"
else
  { echo "(non-JSON output; exit $RC)"; cat "$RESULT_JSON"; } > "$OUT_FILE"
fi
log_run "$RC" "$RESULT_JSON" ""
rm -f "$RESULT_JSON"

# Persist state. Logs and state are the agent's memory; a failed commit must be visible, not fatal to the next run.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git add -A >/dev/null 2>&1 || true
  if ! git diff --cached --quiet; then
    git commit -q -m "paper run: $RUN_TYPE $STARTED (model $MODEL, exit $RC)" || echo "[$STARTED] git commit failed" | tee -a logs/runs.log
  fi
fi

# Show the result when run from a terminal.
if [[ -t 1 ]]; then
  echo "----- agent output ($OUT_FILE) -----"
  cat "$OUT_FILE"
  echo "-----------------------------------"
  [[ -f state/ATTENTION.md ]] && { echo "NEEDS MICHAEL:"; cat state/ATTENTION.md; }
fi

echo "[$(date -u +%FT%TZ)] $RUN_TYPE finished (exit $RC)" | tee -a logs/runs.log
exit "$RC"
