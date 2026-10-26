PAPER overnight run `20261026T032040Z-overnight` is finished. No orders were placed, because the crypto regime is risk-off and nothing is held.

1. **Equity:** virtual $48.53, all cash and all settled. Paper account cash is $99,998.52 and matches the ledger within $1.
2. **Positions and orders:** there are no positions and no open or recent orders. No intents were pending, so nothing needed resolving.
3. **Actions:**
   - **Exits:** none, as there is no crypto position.
   - **Entries:** none. BTC mid is 79,562, 3.28% below its 20-day average of 82,257, which blocks entries.
   - **Entry rules (for the record):** each coin's 24-hour return was between −1.45% and −2.32%, against the required +3%. Each coin's 7-day return was between −3.47% and −4.83%, against the required above 0%.
   - **Cancels:** none needed, as no crypto orders were open.
4. **State:** I appended the crypto quote and spread samples. I refreshed `state/price-history/BTC-daily.json` (the cached copy was 4 days old). I also updated `state/portfolio.json` and `state/settlement.json` and added five rows to `logs/decisions.jsonl`. The hourly history (about 167 bars per coin) was enough to evaluate entries.
5. **Warnings:** `state/ATTENTION.md` still holds only older entries, and I added nothing new. The market data is IEX-only and the paper engine has caveats, but neither affected this run.

I left `/tmp/crypto_eval.py` and `/tmp/crypto_write.py` in place; they are scratch files and not part of the repo.
