**Run 20261022T134500Z-hourly (PAPER), 09:45 ET, session open**

1. **Equity:** virtual equity is about $48.53, down 2.9% from $50. That is all cash, because the one position was sold this run. The cash figure uses my estimate of the 0.25% sell fee, so it is not yet checked against the paper account's real cash.
2. **Positions:** none. ETH/USD was sold in full under the regime-exit rule (`config/strategy.md` §4). BTC fell below its 20-day average (about 81,565 against about 83,025), which makes crypto risk-off. The position was down 4.4%, under the 10% gain needed to stay.
3. **Actions:**
   - The sell was a limit order at 2393.04 for 0.011847307 ETH and filled at 2401.6, a realized loss of about $1.47.
   - I verified the fill with `get_order_by_id`.
   - Intent `885596fe` is closed, and the trade and decision logs are written.
4. **No entries:**
   - Crypto: the regime is risk-off.
   - Equity: the session was only 15 minutes old, below the 25% needed for the volume-pace test, so I skipped the scan.
5. **Warnings:**
   - Positions, open orders and cash matched on reconciliation at the start of the run.
   - I did not re-check paper cash after the sell. Next run needs to confirm the sell fee, which the paper engine took in kind on the ETH buy.
   - There was no daily summary or order cancel to do, since this is not the last session run. `state/ATTENTION.md` is unchanged and nothing needed escalating.
