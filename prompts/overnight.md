OVERNIGHT RUN (crypto only). Follow `CLAUDE.md` §5 for the crypto sleeve. Read `config/strategy.md` §2–§6 and §8, and `config/risk.md`. Read `config/procedures.md` only on errors or unclear order outcomes.

Keep it short:
1. Startup checklist (`CLAUDE.md` §8). HALT or invalid authorization → log, status line, exit.
2. Resolve open intents and reconcile crypto positions, crypto orders, and cash. Equity positions: snapshot only, no orders (market closed).
3. Crypto quotes for the universe; append to `state/price-history/crypto.jsonl`. Pull `get_crypto_bars` (`1Hour`, 7 days) for the universe. Refresh the BTC daily series from the verified source if the cached copy is older than 24 hours.
4. Crypto exits (§4), then crypto entries (§3c) if allowed. Execute per mode. Cancel any crypto entry order left unfilled from the previous run and verify.
5. Logs, portfolio snapshot, intents, settlement, ATTENTION if needed, five-line status.

Do not call equity order tools. Do not run scans or research. If fewer than 72 hours of hourly bars (or samples) are available, record "crypto entries not evaluated: insufficient history" and continue with exits only.
