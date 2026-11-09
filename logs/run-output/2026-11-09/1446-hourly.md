Run `20261109T144500Z-hourly` placed no orders, because both sleeves are risk_off and the one candidate that passed the spread check failed the volume floor.

1. **Equity (virtual):** $48.53, all cash and all settled. The ledger still agrees with the paper account's cash (-$1.48 against -$1.4727).
2. **Positions:** none held and no open orders. The account is `***GU2S`, active and not blocked, and the market is open (09:45 ET).
3. **Regime:** SPY's last close of 735.29 is below its 50-day average of 765.68, and its 20-day average is falling (763.36 against 770.47 five sessions ago). BTC at 74,538 is 5.62% below its 20-day average of 78,980. Only the earnings-gap rule (3b) can enter while equities are risk_off.
4. **Actions:** none.
   - **Crypto:** entries were blocked by the regime, and I added the quote samples and spreads to the price history.
   - **Equity:** of the eight gainers I checked, GFR (+38.6%) was the only one with a spread inside the 0.5% limit. Its 30-day average dollar volume is $7.2M against the $20M floor, so it was out. The other seven had spreads of 2.8% to 33%.
5. **Warnings:** none new. I appended an INFO line to `state/ATTENTION.md`.

I also refreshed `state/price-history/SPY.json` with closes through 11-06.

Everything above is paper-account activity only. I didn't cancel any orders (this isn't the last run of the day) or write a daily summary (before 15:30 ET).
