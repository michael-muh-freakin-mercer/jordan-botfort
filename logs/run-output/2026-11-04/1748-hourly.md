No orders this run. Both sleeves are risk-off, so I placed nothing. This is a paper result on a virtual $50 account.

- **Equity:** virtual equity is $48.53 (Alpaca paper account holds ≈$99,998.52 and reconciles). Cash and settled cash are both $48.53.
- **Positions:** none held, no open orders and no open intents. Cash matches the ledger (paper −1.48 vs ledger −1.4727).
- **Actions:** none.
  - **Crypto:** BTC's mid on the freshest quote (17:46Z) was 80,278 against an SMA20 of 80,291, which is 0.016% under, so `risk_off_crypto` held. The quote a minute earlier was 0.03% above. ETH (24h +5.7%) would have passed the other 3c checks, so the next run may enter if BTC stays above the line. I used the freshest quote rather than the earlier one that passed.
  - **Equity:** only the 3b earnings-gap rule can enter while risk-off.
    - Kyndryl (KD) is up 36%, but two searches didn't confirm a recent report date, so 3b is "not evaluated".
    - Duolingo (DUOL) is up 32%, but its IEX spread is 2.3% against the 0.5% limit.
    - CRCT, LYEL and ANGI fail the $20M dollar-volume floor.
- **Warnings:**
  - I didn't refresh the SPY cache, which stops at the 11-02 close. SPY's 11-03 close of 754.38 is still about 13 points below the 50-day average, so the regime result doesn't change.
  - The 11-03 20:45Z run exited 1. It placed nothing and its cause is still unknown.
  - Not the last session run (12:45 ET), so no daily summary or cancels were due.

I updated `logs/decisions.jsonl`, `state/portfolio.json`, `state/ATTENTION.md` and the crypto price history.
