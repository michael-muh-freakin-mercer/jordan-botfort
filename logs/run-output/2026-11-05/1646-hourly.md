**Run 20261105T164500Z-hourly (PAPER): no orders placed.**

- **Equity:** virtual $48.53 and $48.53 settled cash. The paper account's cash is unchanged and matches the virtual ledger.
- **Positions:** none held and no open orders, so there were no exits to evaluate.
- **Actions:** none. Both sleeves are risk-off, and no entry rule passed. SPY is −3.20% on the day, which is past the −3% line, so `high_vol` is now true. BTC is 4.82% below its 20-day average.
- **Candidates:** APP (earnings gap) still fails the spread rule: its IEX spread is 3.87% against a 0.5% limit. The other gainers on the movers list were either screened out in earlier runs or not checked this run. I logged which is which and did not claim they were evaluated.
- **Warnings:** the 11-03 20:45Z run's exit 1 is still unexplained, though it left no orders.

I logged all the decisions, appended the crypto quotes and spreads to the price history, and updated `state/portfolio.json` and `state/ATTENTION.md`. This is not the last session run (11:45 ET), so I did no cancels and wrote no daily summary.
