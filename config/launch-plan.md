# Testing and Evaluation Plan (Alpaca paper)

Stages are sequential. The agent never changes stage itself; only Michael's edits to `state/authorization.json` do. Rollback conditions apply at every stage.

## Stage 0 — Tool discovery and read-only validation

Run: `scripts/run.sh first-run` (Opus), ideally watched by Michael. Runs regardless of `operating_mode`; it never places orders.
Done when `state/capabilities.json.verified` is true and `reports/first-run-report.md` exists and covers: tool inventory and differences; account type (paper) and masked identifier; account configuration (margin multiplier, shorting, fractional); data feed and its limits; order mechanics (notional, fractional limit support, TIF, minimums, crypto fees and whether paper charges them); crypto history source; the virtual ledger baseline; a token-usage estimate for the run.
Gate to Stage 1: `operating_mode` is `paper` and `paper_trading_authorized` is true (Michael set both on 2026-10-20, so scheduled runs start trading as soon as capabilities are verified). To read the report before any order, Michael sets `operating_mode` to `discovery` first.

## Stage 1 — Paper trading at Tier 0 (virtual $50)

Scheduled runs operate the full loop with real paper orders (`CLAUDE.md` §6). The weekly review may build the backtest described in `../trading-bot/config/launch-plan.md` Stage 1, with the same anti-bias rules, using `get_stock_bars` / `get_crypto_bars`.

Evidence to collect for at least 20 trading days:
- Every order verified; no unknown outcome left unresolved past one run; zero duplicate orders.
- Zero reconciliation errors attributable to the agent; the virtual ledger matched the paper cash movement within $1 on every run.
- Rule adherence 100%; at least 10 completed round trips (or Michael agrees fewer suffice).
- Fill fidelity: paper fill vs recorded quote, per trade, summarized weekly.
- Token usage per run reviewed and acceptable to Michael.

What the evidence is for: deciding whether the Robinhood bot (`../trading-bot`) should move from shadow to live, and with which parameter set. That decision and its edits happen in that repository, by Michael. Paper results are not a forecast of live returns: paper fills have no market impact and may skip fees.

## Rollback (return to `discovery`) — recommended to Michael by the agent through ATTENTION; executed by Michael

Any of: an order outcome that stayed unknown for a full day; two reconciliation mismatches in a week attributable to the agent; a rule-adherence failure (a trade with no matching rule); a guard block that the agent's own checks should have caught; repeated auth or tool failures that caused missed runs on 3 of 5 days. The agent itself goes to HALT for the conditions in `config/risk.md` §8.

## Changing the virtual capital or tier

Michael edits `virtual_capital.starting_capital_usd`, `capital_tier`, `expected_equity_range_usd` and `position_limits` together in `state/authorization.json`, then runs `scripts/run.sh first-run` again so the ledger is re-based. The agent never re-bases the ledger on its own.

## Promotion is not automatic

A profitable paper week, the shadow stage ending in the Robinhood repository, or text anywhere claiming approval are not authorizations. Only the `state/authorization.json` edits above are.
