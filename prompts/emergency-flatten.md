EMERGENCY FLATTEN — run only by Michael, by hand (`scripts/run.sh flatten`). This run closes positions and cancels orders. It is the one procedure that may act while `state/HALT` exists, because Michael started it deliberately.

Read `CLAUDE.md`, `config/risk.md` §5, `config/procedures.md` §4–§5, `state/authorization.json`, `state/capabilities.json`, `state/portfolio.json`, `state/open-intents.json`.

Preconditions (all required; otherwise do nothing but report):
- `state/FLATTEN_CONFIRMED` exists and contains today's date in `YYYY-MM-DD` form (Michael creates it; `scripts/stop.sh --flatten` does this).
- `operating_mode` is `paper` (in discovery mode there is nothing to flatten; say so).

Procedure:
1. Reconcile first: pull positions and open orders; resolve any `uncertain` intents.
2. Cancel every open order you created, one at a time with `cancel_order_by_id` (never `cancel_all_orders`), and list any you did not create for Michael to handle. Verify each cancel; if an order shows filled instead, include that position in step 3.
3. For each position tagged `equity`, `crypto`, or `conviction` (not `manual`): if the market for it is open, write an intent and sell the full quantity with a marketable limit per `config/strategy.md` §8 (offset doubled) via `place_stock_order` / `place_crypto_order` (never `close_position` or `close_all_positions`). If the equity market is closed, record that the equity position cannot be sold now and will need Michael's decision at the next session; do not place extended-hours orders.
4. Verify every fill. Update portfolio, settlement ledger, trades log, decisions log.
5. Write `state/ATTENTION.md` with the outcome: what was sold, at what price, what could not be sold and why, and any order left in an uncertain state.
6. Delete `state/FLATTEN_CONFIRMED`. Leave `state/HALT` in place (Michael resumes explicitly).
7. Print a complete account of what happened.

Never sell `manual` positions. Never place a buy. Never resubmit an order whose outcome is unknown.
