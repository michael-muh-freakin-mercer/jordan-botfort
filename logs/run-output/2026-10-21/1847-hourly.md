PAPER run 20261021T184500Z-hourly, 14:50 ET. I bought ETH/USD in this run.

1. **Equity (virtual):** $49.95 (started with $50.00).
2. **Cash:** $20.15 virtual cash, all settled. The paper account's cash fell by $29.85, matching the ledger.
3. **Positions:** ETH/USD 0.011847 at 2513.606, about $29.80. Its stop is soft: it sells if the price drops 10% from the peak.
4. **Actions:**
   - **Reconcile:** the 4 canceled `[WARBOT]_PREFLIGHT_*` SPY orders are the ones Michael marked manual, so I excluded them and the check passed.
   - **Regime:** equity and crypto are both risk-on. SPY is 774.23, above its 50-day average of 768.36. BTC is 84,634, above its 20-day average of 83,244.
   - **Entry:** ETH passed the crypto momentum rule. It is up 3.16% over 24h and ranks first of BTC, ETH and SOL. It sits 0.41% below its 72h high, and the round-trip cost is about 0.53%.
   - **Order:** I bought with a marketable limit at 2525.77 (intent 68adc72c). It filled at 2513.606 and I verified the fill with `get_order_by_id`.
   - **Equity entries:** I skipped the movers and most-active scan. The one crypto entry used the per-run limit of 1, and I didn't want to spend tokens on a scan that couldn't lead to an order.
5. **Warnings:**
   - **Crypto fee:** the paper engine did charge the 0.25% taker fee, taken in kind (about $0.07). I can't edit `state/capabilities.json`, so I added a proposal in `state/proposals.md` and an INFO note in `state/ATTENTION.md` asking Michael to set `paper_charges_crypto_fees` to true.
   - **No daily summary:** it wasn't due, since it's before 15:30 ET.

This is a paper result only. The fill came in 0.03% above the quote I had at order time because the quote moved. Paper fills have no market impact.
