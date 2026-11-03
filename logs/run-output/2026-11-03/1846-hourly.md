Run 20261103T184500Z-hourly (PAPER) is done. I placed no orders because both sleeves are risk-off.

- **Equity:** $48.53 virtual equity. This is a virtual $50 sub-account, not the ~$100k paper balance.
- **Cash:** $48.53 virtual cash, all settled. Paper cash is $99,998.52, which matches the ledger within a cent.
- **Positions:** none held and no open orders, so no exit rules fired.
- **Actions:**
  - **Equity:** SPY's last close of 752.10 is below its 50-day average of 767.22 (live 756.49, +0.58%), so only the earnings-gap rule could enter. The top gainers failed on the 20M average-volume floor, the 5-letter warrant/unit symbol filter, or a leveraged-ETF exclusion (WULX, new this run). None had a confirmed earnings report, so none qualified.
  - **Crypto:** BTC at 77,638 is 3.56% below its 20-day average of 80,502, so entries are blocked. I sampled quotes for BTC, ETH and SOL; spreads were 0.03–0.06%.
  - **Cancels:** skipped, since it's 13:45 ET and not the last session run.
- **Warnings:** none. The decisions log, price history, `state/portfolio.json`, `state/settlement.json` and `state/ATTENTION.md` are updated. `state/ATTENTION.md` has one refreshed info line and nothing needs Michael's action.

I skipped the daily summary because it's before 15:30 ET.

I wrote the update script to `/tmp/hourly_update_20261103T184500Z.py` because the shell blocked my first inline attempt. It's outside the repo, so it isn't committed.
