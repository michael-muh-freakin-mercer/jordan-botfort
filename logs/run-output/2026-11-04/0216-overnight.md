The overnight crypto run ended with no trades. BTC is below its 20-day average, so the crypto sleeve is risk-off and new entries are blocked. All results below are paper results.

1. **Equity:** virtual equity is $48.53, all of it settled cash (starting capital $50).
2. **Positions and cash:** no positions and no orders since 11-03 00:00Z. Paper cash moved −$1.48 against a ledger of −$1.4727, which is within tolerance. The account is ACTIVE and not blocked, and the market is closed, so no equity orders were considered.
3. **Regime:** BTC mid is $76,841.70 against a 20-day average of $80,290.72 (−4.30%). That uses 20 closed daily bars to 11-03. The BTC daily cache was about 40 hours old, so I refreshed it.
4. **Entries and exits:** there was no crypto position, so no exits and no open orders to cancel. Entries were blocked by the risk-off regime. For the record, 24h returns for BTC/ETH/SOL were −0.18%, +0.20% and −0.49%, all below the 3% threshold. Spreads were 0.025%, 0.023% and 0.117%. There were 167 hourly bars per symbol, so history was sufficient.
5. **Warning:** the 20:45Z hourly run exited 1 after 10 seconds, and I couldn't tell why. The account shows no orders, so nothing was affected. I logged it in `state/ATTENTION.md`. You may want to check `logs/runs.log`.

I updated the BTC daily cache, the crypto price and spread samples, `state/portfolio.json`, `state/settlement.json`, `logs/decisions.jsonl` and `state/ATTENTION.md`. The intents file stays empty. No daily summary was written because this isn't the last session run.
