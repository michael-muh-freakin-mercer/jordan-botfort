# Reporting, Logging, and Record Schemas

All timestamps are ISO 8601 UTC (`2026-10-16T14:35:02Z`) unless a field name ends in `_et`. All money is USD with two decimals as numbers, not strings. `.jsonl` files are append-only: one JSON object per line, never rewritten. Michael reads the terminal; `scripts/summary.sh` prints today's summary and the attention file.

## 1. `logs/decisions.jsonl` — one record per considered action, every run

```json
{"ts":"...","run_id":"...","run_type":"hourly","mode":"paper","tier":0,
 "kind":"entry|exit|no_trade|cancel|reconcile|regime|note",
 "sleeve":"equity|crypto|conviction|null","symbol":"AAPL|null",
 "rule":"strategy.md §3a|§4.2|risk.md §6.5|...",
 "inputs":{"price":0.0,"breakout_level":0.0,"volume_pace":0.0,"spread_pct":0.0,"settled_cash":0.0},
 "result":"pass|fail|skipped","reason":"one sentence with the numbers",
 "intent_id":"uuid|null"}
```
A run with no trades still writes at least: one `regime` record, one `reconcile` record, and one `no_trade` record per sleeve with the controlling reason.

## 2. `state/open-intents.json` — array of intents not yet closed

```json
{"intent_id":"uuid (also the Alpaca client_order_id)","created":"...","mode":"paper","sleeve":"equity","symbol":"AAPL|BTC/USD","side":"buy|sell",
 "notional_usd":30.00,"quantity":null,"limit_price":0.0,"quote":{"bid":0.0,"ask":0.0,"ts":"..."},
 "rule":"strategy.md §3a","rule_inputs":{},"earnings_exposure":false,
 "status":"pending_submit|submitted|open|partial|filled|cancelled|expired|rejected|uncertain",
 "order_id":null,"alpaca_status":null,"preview":{"method":"computed","est_cost":0.0,"est_fees":0.0,"quote_ts":"..."},"updates":[{"ts":"...","status":"...","note":"..."}]}
```
Closed intents (filled, cancelled, rejected) move to `logs/trades.jsonl` (fills) or stay only in the decision log (cancels, rejects) and are removed from this file.

## 3. `logs/trades.jsonl` — one record per paper fill

```json
{"ts":"...","mode":"paper","intent_id":"uuid","order_id":"...","sleeve":"equity","symbol":"AAPL",
 "side":"buy|sell","quantity":0.0,"fill_price":0.0,"notional_usd":0.0,"fees_usd":0.0,"fees_modeled_usd":0.0,"quote_at_order":{"bid":0.0,"ask":0.0},"slippage_vs_quote_pct":0.0,"spread_cost_usd_est":0.0,
 "rule":"...","rationale":"two or three sentences: the rule, the numbers, the regime","settles_on":"YYYY-MM-DD|null",
 "closes_position":false,"realized_pnl_usd":null,"realized_pnl_pct":null,"holding_days":null}
```

## 4. `state/portfolio.json` — rewritten each run

```json
{"ts":"...","run_id":"...","account_masked":"***1234","basis":"virtual","equity_usd":0.0,"cash_usd":0.0,"settled_cash_usd":0.0,
 "paper_account":{"cash":0.0,"equity":0.0},"paper_start":"...",
 "peak_equity_usd":0.0,"day_start_equity_usd":0.0,"deposits_total_usd":50.00,
 "entries_today":0,"entries_paused_until":null,
 "regime":{"risk_on_equity":true,"risk_on_crypto":false,"high_vol":false,"inputs":{}},
 "positions":[{"symbol":"AAPL","sleeve":"equity|crypto|conviction|manual","quantity":0.0,"avg_cost":0.0,
   "entry_ts":"...","entry_intent_id":"uuid","peak_price":0.0,"current_stop":0.0,"last_price":0.0,
   "unrealized_pnl_usd":0.0,"unrealized_pnl_pct":0.0,"sessions_held":0,"earnings_exposure":false,"sector":"..."}],
 "open_orders":[{"order_id":"...","symbol":"...","side":"...","intent_id":"..."}],
 "reconciliation":"ok|reconciled_with_warning","last_daily_summary":"YYYY-MM-DD"}
```

## 5. `state/settlement.json`

```json
{"updated":"...","method":"ledger","paper_cash_baseline_usd":0.0,"cash_cross_check":{"ts":"...","paper_cash_delta":0.0,"ledger_cash_delta":0.0,"ok":true},
 "entries":[{"ts":"...","symbol":"...","type":"buy|sell|fee|deposit","amount_usd":0.0,"settles_on":"YYYY-MM-DD","settled":false}],
 "unsettled_total_usd":0.0,"committed_to_open_buys_usd":0.0,"settled_cash_usd":0.0}
```

## 6. `logs/errors.jsonl`

`{"ts","run_id","severity":"warn|error|critical","source":"tool name|file|reconcile|injection","message","details":{},"action_taken"}`

## 7. `logs/runs.jsonl` — written by `scripts/run.sh`, not by the agent

`{"run_type","model","started","ended","duration_s","exit_code","num_turns","total_cost_usd","usage":{"input_tokens","cache_creation_input_tokens","cache_read_input_tokens","output_tokens"},"skipped_reason":null}`

## 8. Daily summary — `logs/daily/YYYY-MM-DD.md` (written by the last session run of the day; ≤ 40 lines)

```
# PAPER trading summary (Alpaca) — 2026-10-17 (Fri) — tier 0, virtual $50

Virtual equity $52.14 (+1.6% day, +4.3% since paper start 2026-10-16) | Cash $12.10 (settled $12.10) | Peak $52.14 | Drawdown 0.0%
Benchmarks since paper start: SPY +0.8% | BTC −1.2%  → vs SPY: +3.5 pts

Positions (2/2):
- SOL (crypto) 0.21 @ $95.20, now $101.40 (+6.5%), stop $91.26 (trail), held 1d
- NVDA (equity, frac) $25.00 @ $118.30, now $120.10 (+1.5%), stop $108.84 (initial), held 2 sessions, earnings in 9 sessions

Open orders: none
Today's actions: BUY NVDA $25.00 @ 118.30 (§3a breakout; pace 1.9, +1.2% over 20d high) | no crypto entry (§3c.6: entry within 24h)
Exits/closed trades today: none | Closed trades to date: 1 (1 win, +12.4%) | 50%+ winners: 0
Would-have-triggered (Tier 0, limits disabled): daily loss no, drawdown no
Regime: equity risk-on (SPY 587.1 > SMA50 571.4) | crypto risk-on (BTC > SMA20) | high_vol no
Errors/warnings: 0 | Reconciliation: ok (paper cash Δ matches ledger) | Avg slippage vs quote: +0.02% | Runs today: 9/9 | Tokens today: 184k in / 21k out (est. $0.00 subscription)
Needs Michael: nothing   (or: see state/ATTENTION.md)
Next: hourly runs resume Mon 09:35 ET; overnight crypto checks 21:00 and 03:00 ET
```

## 9. Weekly review — `reports/weekly/YYYY-Www.md` (Opus, Saturday)

Every report is labelled PAPER. Sections, in order: Performance (virtual equity curve points per day, return vs SPY and BTC since paper start and for the week, drawdown, exposure by sleeve); Trades (table: symbol, rule, entry, exit, P&L %, holding time, costs, rule adherence yes/no); Losing-trade review (each loss: did the rule work as designed, was the stop respected, was there a data or execution problem); Strategy health (signals generated vs taken, no-trade reasons histogram, slippage vs limit, time-of-day of fills); Operations (runs executed vs scheduled, errors, reconciliation warnings, token usage per run type and total); Backtest work this week (if any, with caveats); Parameter changes applied (within bounds, with reasons; also appended to `state/strategy-changelog.md`); Proposals for Michael (anything outside the agent's authority; also written to `state/proposals.md`); Conviction hold review (checkpoints); Plan for next week.

## 10. `state/ATTENTION.md` — only items needing Michael, newest first

```
# Needs Michael — updated 2026-10-17T20:05Z
- [2026-10-17 20:05Z] HIGH  Order outcome unknown: BUY NVDA intent 3f2a… placed 15:36 ET, no order id returned, get_order_by_client_id found nothing. No new NVDA orders until reconciled. Check the Alpaca paper dashboard for an NVDA order with that client order id.
- [2026-10-16 14:10Z] INFO  Data feed is IEX only: volume-pace ratios use IEX volume on both sides; spreads may look wider than NBBO.
```
Severity: HIGH (money or integrity at risk), MEDIUM (blocking something), INFO (unlock, proposal). Remove resolved items; keep history in the decision log.

## 11. `state/strategy-changelog.md` and `state/proposals.md`

Changelog line: `- 2026-10-25 | weekly-review | equity.entry.min_volume_ratio 1.5 → 1.8 | reason: 4 of 5 losing breakouts had pace < 1.8; 11 trades sample, low confidence`.
Proposal entry: what, why, evidence, risk it adds, exactly which protected field or file would change, and the agent's recommendation. Proposals expire after 30 days if not acted on and are removed with a note.

## 12. Status line printed at the end of every run (stdout; shown in `logs/run-output/`)

Five lines: `mode/tier`, `equity/cash/settled`, `positions (n/max) with P&L`, `actions this run`, `warnings or "none"`.
