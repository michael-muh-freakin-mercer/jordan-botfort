Hourly run 20261102T154500Z is finished (10:45 ET, regular session). I placed no orders: there is nothing to exit, and no entry rule passed.

1. **Equity (paper, virtual):** $48.53, a −2.9% return on the $50 start. Cash and settled cash are both $48.53. The paper account's $99,998.52 cash is not used for sizing.
2. **Positions and orders:** none held and none open. Reconciliation passed: the ledger and the broker's cash agree, the account is ACTIVE and unblocked, and there were no open intents.
3. **Regimes:** both are risk-off.
   - **Equity:** SPY's last close of 755.72 is below its 50-day average of 767.49, so only the earnings-gap rule (3b) could have entered. SPY is trading at 763.19, up 0.99%, so `high_vol` is false.
   - **Crypto:** BTC at 77,894 is 3.6% below its 20-day average of 80,824, so no crypto entries.
4. **Earnings-gap scan:**
   - **Volume floor:** ULCC ($17.6M 30-day dollar volume) and TEMT ($8.1M) fail the $20M floor, as do RVNL, RIVC and BRAZ.
   - **LITZ:** it passes on volume but looks like a leveraged ETF, which I did not confirm with `get_asset`. It has no earnings report and its spread was 1.3% last run.
   - **IDXX:** its spread tightened from 10.5% to 1.05%, still above the 0.5% cap, so I did not search for its report date.
5. **Warnings:** none new. The 14:50Z note in `state/ATTENTION.md` about the equity regime turning risk-off still applies. This isn't the last session run, so I wrote no daily summary and had no orders to cancel.

All figures are paper results. I appended this run's decisions to `logs/decisions.jsonl`, added crypto samples to the price history, and refreshed `state/portfolio.json` and `state/settlement.json`.
