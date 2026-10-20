#!/usr/bin/env bash
# One-time setup for the Alpaca paper instance.
# Creates the directory tree, empty state files, git repo, and checks the tools the agent depends on.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

mkdir -p state/price-history logs/daily logs/run-output reports/weekly reports/backtest/data
chmod +x scripts/*.sh scripts/*.py

init_json() { [[ -f "$1" ]] || printf '%s\n' "$2" > "$1"; }
init_json state/portfolio.json '{"ts":null,"run_id":null,"account_masked":null,"basis":"virtual","equity_usd":0,"cash_usd":0,"settled_cash_usd":0,"paper_account":{},"paper_start":null,"peak_equity_usd":0,"day_start_equity_usd":0,"deposits_total_usd":50.00,"entries_today":0,"entries_paused_until":null,"regime":{},"positions":[],"open_orders":[],"reconciliation":"never","last_daily_summary":null}'
init_json state/open-intents.json '[]'
init_json state/settlement.json '{"updated":null,"method":"ledger","paper_cash_baseline_usd":null,"cash_cross_check":null,"entries":[],"unsettled_total_usd":0,"committed_to_open_buys_usd":0,"settled_cash_usd":0}'
init_json state/watchlist.json '{"updated":null,"symbols":[]}'
init_json state/capabilities.json '{"verified":false}'
touch logs/decisions.jsonl logs/trades.jsonl logs/errors.jsonl logs/runs.jsonl state/price-history/crypto.jsonl
[[ -f state/strategy-changelog.md ]] || echo "# Strategy parameter changelog" > state/strategy-changelog.md
[[ -f state/proposals.md ]] || echo "# Proposals for Michael (agent-written; nothing here is active until Michael edits the protected files)" > state/proposals.md

if [[ ! -d .git ]]; then
  git init -q && git add -A && git commit -q -m "trading-bot-alpaca: initial paper setup" && echo "git repository created"
fi

echo
echo "Dependency check:"
for c in claude jq python3 flock git crontab uvx; do
  if command -v "$c" >/dev/null || [[ -x "$HOME/.local/share/mise/shims/$c" ]]; then echo "  ok   $c"; else echo "  MISSING $c"; fi
done
ENV_FILE="$HOME/.config/trading-bot-alpaca/paper.env"
if [[ -r "$ENV_FILE" ]]; then
  echo "  ok   $ENV_FILE ($(stat -c %a "$ENV_FILE"))"
  grep -q '^ALPACA_API_KEY=PK' "$ENV_FILE" || echo "  WARNING: ALPACA_API_KEY in $ENV_FILE does not look like a paper key (PK...)"
else
  echo "  MISSING $ENV_FILE (ALPACA_API_KEY=PK..., ALPACA_SECRET_KEY=..., chmod 600)"
fi
jq -e '.mcpServers.alpaca' .mcp.json >/dev/null 2>&1 && echo "  ok   .mcp.json server 'alpaca'" || echo "  WARNING: no server named 'alpaca' in .mcp.json; the allow rules use that name."
echo
echo "Next: claude mcp list (in this folder), scripts/run.sh first-run, then install scripts/crontab.txt."
