Run 20261109T164500Z-hourly is finished: no orders were placed, and nothing is held. Both sleeves are still risk-off.

- **Virtual equity:** $48.53 (paper). It is all cash and all settled, because there have been no trades since the 10-22 ETH round trip.
- **Reconcile:** it passes. The account is `***GU2S` and ACTIVE, with no positions and no orders since 11-03. Paper cash matches the ledger (−1.48 against −1.4727).
- **Equity regime:** risk-off. SPY closed at 735.29 on 11-06, below its 50-day average of 765.68, and SPY is trading at 750.54 now, still 1.98% under it.
- **Crypto regime:** risk-off. BTC is at 74,791, 5.3% below its 20-day average of 78,980.
- **Exits and entries:** there was nothing to exit.
  - **Crypto:** entries are blocked by the regime.
  - **Equity:** only the earnings-gap rule is allowed in a risk-off market, and no gainer qualified. Everything except GFR failed the 0.5% spread limit (the tightest, ASTT, was 1.1%). GFR's spread passed, but it fails the $20M dollar-volume floor ($7.2M). I did not run the earnings-date searches because those checks had already failed.
- **Housekeeping:** I appended the crypto quotes and spreads to the price history, updated `state/portfolio.json`, added this run's rows to `logs/decisions.jsonl`, and added a line to `state/ATTENTION.md`. It's 11:45 ET, so there was no cancel step and no daily summary yet. I did not create `state/ESCALATE`.
- **Log typo:** the decision-log entry for the SPY regime says "−1.97 pct vs SMA50", but the correct figure is −1.98. I left the append-only log as it is and fixed the `state/ATTENTION.md` line.

All of this is a paper result.
