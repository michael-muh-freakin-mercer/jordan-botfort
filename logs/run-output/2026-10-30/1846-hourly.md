Run 20261030T184500Z-hourly (PAPER, 14:45 ET): no trade this run.

1. **Equity (virtual):** $48.53, against $50.00 starting capital and a peak of $50.00. Paper cash is unchanged at $99,998.52 and matches the virtual ledger.
2. **Cash:** $48.53 virtual cash, all settled. There are no positions and no open orders or intents.
3. **Actions:** None. Equity regime is risk-on on closed data, but SPY is −2.31% live (below the −3% `high_vol` line), and its live price is below the 50-day average. Crypto regime is risk-off, with BTC 6.1% under its 20-day average, so crypto entries are blocked. I rejected new equity movers AIOK, ULH and OSPN on the §3a/§1 rules (price vs 20-day high, gap size, or average dollar volume).
4. **Warnings:** There are no new ATTENTION items, and I did not create HALT or ESCALATE. This is not the last session run (it is 14:45 ET), so there was nothing to cancel and no daily summary yet.
5. **Caveats:** This is paper only, and the engine does not simulate regulatory fees. Quotes are IEX feed.

Decisions, the crypto price samples and spreads, and the portfolio snapshot are written. `scripts/run.sh` handles the commit.
