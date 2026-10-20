# trading-bot-alpaca — paper twin of `../trading-bot`

Same agent, same "Concentrated Momentum" strategy and Tier 0 limits as the Robinhood bot, but orders go to an **Alpaca paper account**. The paper account holds ~$100k of fake cash; the agent trades a **virtual $50** inside it under cash-account rules, so results are comparable with the real Robinhood test. Nothing here can touch real money: the MCP launcher refuses non-paper keys, and the Robinhood MCP is denied.

## Layout

| Path | What |
|---|---|
| `CLAUDE.md` | Core system prompt (paper version). Read §3 and §10. |
| `config/` | Mandate, risk, strategy, procedures, reporting, launch plan. |
| `prompts/` | Run prompts: `first-run`, `hourly`, `overnight`, `weekly-review`, `emergency-flatten`. |
| `scripts/alpaca-mcp.sh` | Starts `alpaca-mcp-server` (via `uvx`) with keys from `~/.config/trading-bot-alpaca/paper.env`, forced to paper. |
| `scripts/order-guard.py` | PreToolUse hook: blocks any order unless mode is `paper`, an intent was written first (`client_order_id` = intent id), the size fits **virtual** equity, and the order is a simple regular-hours limit/market. |
| `scripts/run.sh` | Cron entry point. `scripts/stop.sh`, `resume.sh`, `summary.sh` as in the Robinhood bot. |
| `state/` | Agent memory; `authorization.json` is yours alone. |

## Keys

`~/.config/trading-bot-alpaca/paper.env` (chmod 600, outside every repo):

```
ALPACA_API_KEY=PK...
ALPACA_SECRET_KEY=...
```

Regenerate them in the Alpaca paper dashboard if they leak or stop working. For live trading later, do **not** put live keys here: this instance is paper-only by design.

## Running it

1. `claude mcp list` in this folder: `alpaca` should show as connected.
2. `scripts/run.sh first-run` (Opus, read-only): verifies tools, data feed, order mechanics, opens the virtual ledger, writes `reports/first-run-report.md`.
3. Install the schedule: see the header of `scripts/crontab.txt`.
4. Daily: `scripts/summary.sh`. Stop: `scripts/stop.sh`. Flatten: `scripts/stop.sh --flatten`.

`operating_mode` is `paper` with `paper_trading_authorized: true` (set 2026-10-20), so the first scheduled run after a successful first run will trade. To review the first-run report before any order, set `operating_mode` to `discovery` first, then back to `paper`.

## How it differs from the Robinhood bot

- Virtual ledger: settled cash, equity and every limit come from `state/settlement.json`, cross-checked each run against how much the paper account's cash actually moved.
- No preview tool: the pre-trade review is computed (cost vs virtual settled cash, limit within 1% of quote).
- Idempotent orders: the intent id is the Alpaca `client_order_id`, so an order with an unknown outcome can be looked up directly.
- Candidates come from `get_market_movers` / `get_most_active_stocks` instead of a saved scan. Earnings dates and sectors come from one WebSearch per candidate that already passed every other rule. No VIX (high-vol is SPY ≤ −3% only).
- Crypto history comes from `get_crypto_bars`, so crypto entries don't have to wait 72 hours for self-recorded samples.
- Paper caveats (no market impact, random partial fills, no regulatory fees, maybe IEX-only data) are recorded and reported, never hidden.
