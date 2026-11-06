Run `20261106T154500Z-hourly` is complete (PAPER). It placed no orders, because both sleeves are risk-off and the earnings-gap names were untradeable.

1. **Equity:** virtual equity is $48.53 (paper), against the $50.00 starting capital. SPY is $738.47, up 0.69% on the day. Its last close of $733.00 is below the SMA50 of $766.40, so the equity regime is risk-off. High-volatility is false.
2. **Cash:** virtual cash and settled cash are both $48.53. Paper cash of $99,998.52 matches the ledger.
3. **Positions:** none held, no open orders, no open intents. Reconciliation passed, the account is ACTIVE and not blocked, and the clock shows the session open at 10:45 ET.
4. **Actions:** none.
   - **Crypto:** BTC is $75,551, which is 5.5% below its SMA20 of $79,929, so entries are blocked. I logged the BTC, ETH and SOL quotes and spreads to the price history.
   - **Equities:** only the earnings-gap rule can enter while risk-off. The two eligible gainers, GIBO (+42.5%) and SKIN (+34%), each had only a few trades today. Their IEX spreads were 56% and 29%, against the 0.5% limit, so neither qualified.
5. **Warnings:** none new. I added an INFO line to `state/ATTENTION.md`. This is not the last session run of the day (10:45 ET), so there was no cancel step and no daily summary.

I only logged the 15:45Z data: the Alpaca MCP launches paper-locked, and I didn't verify the stale-quote risk on thinly traded names beyond the spread test.
