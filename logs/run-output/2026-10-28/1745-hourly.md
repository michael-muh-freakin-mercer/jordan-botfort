Run 20261028T174500Z-hourly (13:45 ET) is complete. I placed no orders and found nothing to act on.

**Status (PAPER, virtual account)**
1. **Equity:** $48.53 virtual, down 2.9% from the $50 start. SPY is the benchmark and BTC is the crypto benchmark.
2. **Cash:** $48.53 virtual cash, all of it settled.
3. **Positions:** none held and no open orders or intents. Reconciliation passed: paper cash is unchanged at $99,998.52, a $1.48 drop against a ledger delta of $1.4727.
4. **Actions:**
   - Exits: none to check, since nothing is held.
   - Equity entries: blocked by `risk_off_equity`. The SPY close is above its 50-day average, but its 20-day average is not above its level five sessions ago.
   - Earnings-gap scan: no candidate. AXGN has a spread of about 15.6% against the 0.5% cap. GMAB has no confirmed report date and no gap at the open. The rest failed on dollar volume or price, or were warrants or leveraged names.
   - Crypto entries: blocked by `risk_off_crypto`. The BTC mid of 80,634.5 is 1.49% below its 20-day average of 81,855.87.
   - Cancels: skipped, since it isn't the last session run and nothing is open.
5. **Warnings:** none new. I appended crypto quotes and spreads to the price history and updated the decision log and `state/portfolio.json`. I left `state/ATTENTION.md` as it was and didn't create `ESCALATE`. No daily summary is due until the run after 15:30 ET.

Paper-engine caveats apply: IEX-only quotes can show wider spreads than the consolidated market.
