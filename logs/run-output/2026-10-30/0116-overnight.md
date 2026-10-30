Overnight run `20261030T011501Z-overnight` placed no orders. The paper account is flat and BTC is risk-off.

- **Equity (virtual):** $48.53, all in cash and all settled. It is a PAPER result, and the account is down about 2.9% since the $50 start.
- **Positions and orders:** none open for crypto or equity. There were no open intents and no orders since 10-28. Paper cash is $99,998.52, which matches the virtual ledger delta of −$1.47.
- **Crypto regime:** BTC mid is $77,099.86 against a 20-day average of $81,596.70, which is 5.51% below it, so `risk_on_crypto` is false. I refreshed the BTC daily series (it was more than 24 hours old). BTC fell from about $81.2k to about $77.1k since 10-29 19:00Z, with an hourly low of $75,762.
- **Actions:** no exits, since no position is held. Crypto entries are blocked by the regime. I didn't evaluate ETH or SOL momentum because the regime check fails first, and I pulled hourly bars for BTC only (167 bars, more than the 72 hours required). Spreads for BTC, ETH and SOL are 0.039%, 0.027% and 0.081%.
- **Warnings:** none, and I didn't write `ATTENTION.md`. The account is ACTIVE and not blocked. The equity market is closed, so I took no equity snapshot.

I didn't run a verifying read-back of the updated state files, and I didn't run any git commands; `scripts/run.sh` commits on exit.
