Run 20261106T144500Z-hourly finished with no trades. Everything below is a paper result.

1. **Equity:** virtual equity is $48.53 against the $50.00 start. No other numbers moved this run.
2. **Cash:** virtual cash and settled cash are both $48.53. The paper account's own cash is $99,998.52 and matches the ledger within the $1 check.
3. **Positions and orders:** none are open, and nothing was placed.
4. **Regime:**
   - **Equity:** risk-off. SPY closed 11-05 at 733.00, below its 50-day average of 766.40. It is up 0.97% today, so the high-volatility flag has cleared.
   - **Crypto:** risk-off. BTC is at 75,796 against a 20-day average of 79,929.
   - Only the earnings-gap rule can enter equities, and no crypto entries are allowed.
5. **Entry check:** FROG (+29.6% today) was the only gainer that passed the price and dollar-volume filters. It failed the spread rule: the IEX quote was 82.21/97.74, about 17% wide against the 0.5% limit. Its earnings date was not checked because the spread already ruled it out.

**Housekeeping:** the SPY and BTC daily caches and the crypto price history are refreshed, and the decisions log, portfolio snapshot and `state/ATTENTION.md` are updated. At 09:47 ET this was not the last session run, so no daily summary was due and there was nothing to cancel. `scripts/run.sh` commits the files on exit.
