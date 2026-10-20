#!/usr/bin/env bash
# Launches the Alpaca MCP server for this project, locked to PAPER trading.
# .mcp.json points here. Credentials live outside the repo in ~/.config/trading-bot-alpaca/paper.env (chmod 600),
# so nothing secret is ever committed by scripts/run.sh's `git add -A`.
# This instance has no live path: ALPACA_PAPER_TRADE is forced true and live-looking keys are refused.
set -euo pipefail

ENV_FILE="${TB_ALPACA_ENV:-$HOME/.config/trading-bot-alpaca/paper.env}"
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

if [[ ! -r "$ENV_FILE" ]]; then
  echo "alpaca-mcp.sh: $ENV_FILE not found or unreadable" >&2; exit 1
fi
set -a; source "$ENV_FILE"; set +a

# Alpaca paper key ids start with PK; live key ids start with AK.
if [[ "${ALPACA_API_KEY:-}" != PK* ]]; then
  echo "alpaca-mcp.sh: ALPACA_API_KEY is not a paper key (expected PK...). Refusing to start." >&2; exit 1
fi
export ALPACA_PAPER_TRADE=true
unset ALPACA_API_BASE_URL ALPACA_BASE_URL APCA_API_BASE_URL

exec uvx alpaca-mcp-server "$@"
