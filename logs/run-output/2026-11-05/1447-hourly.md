This run placed no orders: both sleeves are risk-off and APP, the only equity candidate, failed two §3b tests.

1. **Virtual equity:** $48.53 (paper), against $50.00 starting capital.
2. **Cash:** $48.53 virtual cash and $48.53 settled. The paper account's cash of $99,998.52 matches the ledger within tolerance.
3. **Positions:** none. There are no open orders or open intents, and reconciliation passed.
4. **Actions:** none. SPY's 11-04 close of 766.81 sits just under its SMA50 of 767.06, and its SMA20 is falling. BTC (78,724) is 1.85% under its SMA20 of 80,206. That leaves only the earnings-gap rule (§3b) for equities.
   - **APP candidate:** It reported 11-04 after the close, per the SEC 8-K, and is up about 30% on a $1.27B average daily dollar volume. It fails two tests for now:
     - **Volume:** about 1.12× the 30-day average so far (pre-market included), against the 2.0× needed.
     - **Spread:** 0.565% on the IEX quote, against the 0.5% maximum.
     - **Next run:** it re-checks, and APP still qualifies on 11-05 and 11-06.
   - **Other candidates:** the other four of the five evaluated (AEHL, APPC, APPX, AGL) failed the liquidity and spread tests.
5. **Warnings:** Everything here is a paper result, and the IEX-only data can make spreads look wider than they are. The 11-03 20:45Z run's exit code 1 is still unexplained, but it left no orders. It's noted in `state/ATTENTION.md`.

Both regime caches (SPY and BTC) are refreshed. It's 09:47 ET, so there was no end-of-day cancel step and no daily summary.
