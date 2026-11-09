Logs are written. All 7 decision rows for this run are in `logs/decisions.jsonl`. The last step is the five-line status.

**Status (PAPER, run 20261109T194500Z-hourly, 14:45 ET)**
1. **Virtual equity:** $48.53, down 2.9% from the $50 start. The paper account holds $99,998.52, which is not used for sizing.
2. **Cash:** virtual cash and settled cash are both $48.53. The cash cross-check passes: paper delta −1.48 against ledger −1.47.
3. **Positions:** none open, and no open orders or intents.
4. **Actions:** no orders placed. Both regimes are risk-off: SPY is −1.56% against its 50-day average and BTC is −5.14% against its 20-day average. Of the gainers, TANH and CKX fail the spread test (about 30% spread on the IEX feed). TLS fails the dollar-volume floor, and WCT and FISN are under $5. I sampled crypto quotes and logged the decisions.
5. **Warnings:** none new. It is not the last session run, so no cancels and no daily summary. `state/ATTENTION.md` has an info line only, and I did not create `state/ESCALATE`.
