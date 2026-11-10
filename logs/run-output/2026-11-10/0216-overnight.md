Overnight run `20261110T021500Z-overnight` placed no orders. Crypto is still risk-off, so entries were blocked, and there were no positions to exit.

1. **Equity (paper):** virtual equity is $48.53 and virtual cash and settled cash are both $48.53.
2. **Positions and orders:** no positions, no open orders and no open intents. Paper cash is $99,998.52, unchanged and consistent with the virtual ledger. The account (`***GU2S`) is active and not blocked. The equity market is closed, so equities got a snapshot only.
3. **Regime:** BTC mid is $74,883.72 against its 20-day average of $78,596.39 (−4.72%), so entries are blocked. BTC is −0.39% over 24h and −2.49% over 7d. I refreshed the BTC daily series because the cache was 24 hours old. Quotes and spreads for BTC, ETH and SOL are appended to the price-history files; spreads are 0.024%, 0.014% and 0.070%.
4. **Actions:** none. I did not fetch ETH or SOL hourly bars because the BTC regime already blocks every entry. BTC hourly history is well over 72 hours, so the insufficient-history case did not apply.
5. **Warnings:** none. I added one info line to `state/ATTENTION.md`.

The decision log, portfolio snapshot and settlement timestamps are updated. I wrote two helper scripts to `/tmp` to do the calculations and file writes; they are outside the repo.
