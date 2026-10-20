#!/usr/bin/env bash
# Prints what Michael wants to see in the terminal: attention items, today's (or the latest) daily summary,
# the last run's output, and this week's token usage. Usage: scripts/summary.sh [YYYY-MM-DD]
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
DAY="${1:-$(TZ=America/New_York date +%F)}"

if [[ -f state/HALT ]]; then echo "=== HALTED ==="; cat state/HALT; echo; fi
if [[ -f state/ATTENTION.md ]]; then echo "=== NEEDS MICHAEL ==="; cat state/ATTENTION.md; echo; fi

echo "=== Daily summary ==="
if [[ -f "logs/daily/$DAY.md" ]]; then
  cat "logs/daily/$DAY.md"
else
  LATEST=$(ls -1 logs/daily/*.md 2>/dev/null | sort | tail -n1 || true)
  if [[ -n "${LATEST:-}" ]]; then echo "(no summary for $DAY yet; latest is $LATEST)"; cat "$LATEST"; else echo "(no daily summaries yet)"; fi
fi
echo

echo "=== Last run output ==="
LAST_OUT=$(ls -1 logs/run-output/*/*.md 2>/dev/null | sort | tail -n1 || true)
[[ -n "${LAST_OUT:-}" ]] && { echo "($LAST_OUT)"; cat "$LAST_OUT"; } || echo "(none)"
echo

echo "=== Runs in the last 7 days (tokens) ==="
if [[ -f logs/runs.jsonl ]] && command -v jq >/dev/null; then
  SINCE=$(date -u -d '7 days ago' +%FT%TZ 2>/dev/null || date -u +%FT%TZ)
  jq -r --arg since "$SINCE" 'select(.started >= $since)' logs/runs.jsonl | jq -s '
    group_by(.run_type) | map({run_type: .[0].run_type, runs: length,
      skipped: (map(select(.skipped_reason != null)) | length),
      input_tokens: (map(.usage.input_tokens // 0) | add),
      cache_read: (map(.usage.cache_read_input_tokens // 0) | add),
      output_tokens: (map(.usage.output_tokens // 0) | add),
      est_cost_usd: (map(.total_cost_usd // 0) | add | . * 100 | round / 100)})'
else
  echo "(no runs.jsonl yet)"
fi
