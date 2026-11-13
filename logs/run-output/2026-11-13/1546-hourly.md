Run 20261113T154500Z-hourly finished with no trades. Nothing in the account changed, and there were no entries or exits to evaluate.

1. **Virtual equity:** $48.53 (paper). Virtual cash and settled cash are both $48.53.
2. **Positions and orders:** none held, none open, no open intents. Paper cash is $99,998.52, unchanged. The cross-check against the ledger is within tolerance (−1.48 against −1.4727).
3. **Regime:** risk_off on both sleeves.
   - **SPY:** SPY's last close of 757.12 is below its 50-day average of 764.80, and live it trades at 750.39 (−1.88% vs the average). `high_vol` is false.
   - **BTC:** BTC is at 68,184 against a 20-day average of 77,226 (−11.71%). It is selling off sharply today.
4. **Actions:** no exits, since nothing is held. No entries either. Crypto entries are blocked by the regime. In equities only the earnings-gap rule applies. The three gainers above $5 (FCUV, NMAX, SBC) all fail the $20M dollar-volume floor, at $0.07M, $6.49M and $1.02M.
5. **Warnings:** none blocking. Logs and state are updated and `state/ATTENTION.md` has a new info line. It is 10:45 ET, so no order cancels and no daily summary were due. The logs show no run between 2026-11-10 02:20Z and this one. The account is unchanged over that gap.

I left three scratch scripts in `/tmp` (`regime_1113.py`, `adv_1113.py`, `write_1113.py`). The cleanup command was blocked, so they are still there.
