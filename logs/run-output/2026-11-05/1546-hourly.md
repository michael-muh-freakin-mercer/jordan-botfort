Run 20261105T154500Z-hourly is done. I placed no orders and held no positions.

1. **Virtual equity:** $48.53 (PAPER). The starting capital was $50.
2. **Cash:** $48.53 total and $48.53 settled. Paper cash is $99,998.52 against a ledger delta of −1.47, which reconciles.
3. **Positions and orders:** none, and no open intents.
4. **Actions:** none. No exits were possible. Both sleeves are risk-off, and the one earnings-gap candidate (APP) failed the spread rule.
   - **Equity regime:** the SPY series is cached from today and is risk-off (last close 766.81 against an SMA50 of 767.06). SPY is −2.94% on the day, just short of the −3% volatility flag (`high_vol`).
   - **Crypto regime:** BTC is at 76,208 against an SMA20 of 80,206 (−4.98%), so crypto entries are blocked.
   - **APP:** its IEX spread is 1.82%, over the 0.5% limit. The only other gainers were illiquid names or leveraged/inverse products, which can't qualify.
5. **Warnings:** the account is ACTIVE and not blocked. I updated `state/ATTENTION.md` with an INFO item. The 11-03 20:45Z run's exit 1 is still unexplained, but it left no orders. No ESCALATE was needed.

Two things I did not do. It's 10:45 ET, so this wasn't the last session run: no daily summary was written, and there were no unfilled orders to cancel. I also didn't re-fetch the SPY series, because today's cache was already current.

A leftover `/tmp/hourly_1545.py` helper is still there. My cleanup command was blocked, and it's outside the repo.
