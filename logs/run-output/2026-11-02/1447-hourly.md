Run `20261102T144500Z-hourly` (**PAPER**) placed no orders.

- **Equity:** virtual $48.53 (peak $50.00), all of it settled cash. No positions are held and no orders are open.
- **Reconcile:** it passed. Paper cash of 99,998.52 matches the ledger delta.
- **Regime:** equity is now **risk_off**. SPY's last close of 755.72 (10-30) is below its SMA50 of 767.49. The 10-30 runs had logged risk_on, but their SPY cache was missing that day's close, so that reading was stale. I refreshed the cache and noted it in `state/ATTENTION.md`. Crypto is still risk_off: BTC is 3.78% below its SMA20.
- **Actions:** none, so there were no exits. In a risk_off regime only the earnings-gap rule (§3b) can enter equities, and every candidate failed it:
  - **IDXX:** it gapped up 18.6%, but its quote spread was 10.5% (cap 0.5%) on two checks 10 seconds apart.
  - **LITZ and CLRO:** their spreads were about 1.3% and 28%.
  - **PERI:** it fails the $20M dollar-volume floor.
  - **CASK:** it was not evaluable (one day of history).
- **Warnings:** one INFO item, the stale-regime note above. I did not run a WebSearch to confirm IDXX's report date, since the spread already ruled it out. Next run's re-look at IDXX depends on its spread tightening.
