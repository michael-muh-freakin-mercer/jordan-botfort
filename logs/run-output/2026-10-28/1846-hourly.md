Status for run 20261028T184500Z-hourly (**PAPER**, 14:45 ET):

1. **Equity:** virtual equity is $48.53 against a $50.00 start, which is -2.9%. The −2.9% comes from the closed ETH round trip on 10-21 to 10-22.
2. **Cash:** virtual cash is $48.53, all settled. The paper account's cash of $99,998.52 matches the ledger, with a delta of −1.48 against −1.47.
3. **Positions:** none open, no open orders and no open intents. Reconciliation is clean and the account is ACTIVE and not blocked.
4. **Actions:** no orders placed.
   - **Equity regime:** risk-off. SPY closed at 769.66, above its SMA50 of 767.53, but its SMA20 of 770.41 is not above the 770.62 from five sessions ago, and both are required. I reused today's cached SPY series.
   - **Crypto regime:** risk-off. BTC mid is 81,055.04, which is 0.98% below its SMA20 of 81,855.87. I appended the crypto quotes and spreads to the price history.
   - **§3b earnings-gap scan:** no candidate.
     - AXGN: spread of about 28.8% against the 0.5% cap.
     - VRTL: spread of 2.76%, and only about 3,800 shares traded today, so it can't meet the $20M volume test.
     - ULBI and BOOM fail the average dollar volume test.
     - GMAB has no confirmed earnings report and no gap at the open.
     - RIBBU, AIOK and the SK* names are excluded as units or leveraged funds.
   - **Cancels:** skipped, since this isn't the last session run and there are no open orders.
5. **Warnings:** none new, and I made no changes to `state/ATTENTION.md`. The 15:45 ET run is the last session run today, so it will write the daily summary. The first attempt of my logging script crashed on a formatting error after it had already appended the crypto samples. I removed those appends before rerunning, and `state/price-history` has no duplicates. The throwaway script is still at `/tmp/hourly_log_184500.py`, because the sandbox blocked deleting it.

These are paper results only and say nothing about live performance. Alpaca's IEX-only quotes make equity spreads look wider than the real NBBO, which may be excluding a few borderline candidates.
