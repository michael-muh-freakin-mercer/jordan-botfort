HOURLY RUN (regular session). Follow `CLAUDE.md` §5 exactly. Read `config/strategy.md` and `config/risk.md`; read `config/procedures.md` only if a tool errors, an order outcome is unclear, or reconciliation fails.

Keep this run lean: read state from files, pull only the data the rules need, evaluate exits before entries, do arithmetic with `python3 scripts/indicators.py`, and stop when the checklist is complete. Do not re-research anything the state files already answer.

Sequence:
1. Startup checklist (`CLAUDE.md` §8). If `state/HALT` exists or authorization is invalid: log, print the status line, exit.
2. Resolve intents with `submitted` / `uncertain` status, then reconcile positions, orders, and cash. Update the settlement ledger and compute settled cash.
3. Market state: session status from quotes, ET time, regime (reuse today's cached SPY series if `state/price-history/SPY.json` is from today; otherwise refresh). Append crypto quotes to the price history.
4. Exits: evaluate every rule in `config/strategy.md` §4 for every held position, both sleeves. Execute per mode.
5. Entries: only if no-trade conditions are clear. Candidates from the movers and most-active lists defined in `state/scan-config.json`, the earnings-gap check (§3b), and the watchlist, at most `equity.max_candidates_per_run`; crypto universe from the price history. Rank per §5 and respect the per-run and per-day entry limits.
6. Cancels: if this is the last session run of the day (ET time ≥ 15:30), cancel unfilled equity entry orders and verify.
7. Logs: decisions (including every no-trade with its reason), trades, errors, portfolio snapshot, open intents, settlement, watchlist.
8. If ET time ≥ 15:30 and no daily summary exists for today, write `logs/daily/YYYY-MM-DD.md` per `config/reporting.md` §8.
9. Update `state/ATTENTION.md` (add new items, remove resolved ones). Create `state/ESCALATE` if something could not be resolved.
10. Print the five-line status.

If today is not a trading day for equities (weekend, holiday, or the session is closed), do only: startup checklist, reconcile, crypto price sample, crypto exits and entries, logs, status. Never guess whether the market is open; use `get_clock`.
