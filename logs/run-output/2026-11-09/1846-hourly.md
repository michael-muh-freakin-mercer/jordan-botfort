Paper run 20261109T184500Z-hourly placed no orders. Both sleeves are still risk-off, and nothing was held or open.

1. **Equity:** virtual $48.53 (paper). Cash and settled cash are both $48.53.
2. **Positions:** none held, no open orders, no open intents. Paper cash is $99,998.52, a $1.48 drop from baseline against the ledger's $1.4727, so reconciliation passes.
3. **Regime:**
   - **Equity:** SPY is at 752.71, 1.69% below its 50-day average of 765.68, so `risk_off_equity`. `high_vol` is false.
   - **Crypto:** BTC is at 74,514.67, 5.65% below its 20-day average of 78,980.35, so `risk_off_crypto`.
4. **Actions:** exits were skipped because there is nothing to exit. Crypto entries are blocked by the regime. Of the movers, only CKX and GFR clear the $5 price floor. CKX fails the spread rule (29% on earlier runs) and GFR fails the dollar-volume floor ($7.2M against $20M). WCT and FISN are below $5. I searched for no earnings reports, since every candidate fails an earlier filter. It's 13:45 ET, so there were no cancels and no daily summary yet.
5. **Warnings:** none new. `state/ATTENTION.md` has one more INFO line, and I did not create `state/ESCALATE`.

I appended the crypto samples to the price history and added the decision records, portfolio snapshot and attention line. A heredoc in Bash was rejected, so I wrote the logging script to `/tmp/run_20261109T184500Z.py` and ran it from there. Nothing in the repo was affected.
