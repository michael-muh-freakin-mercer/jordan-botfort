# PAPER — First-run report (Alpaca paper account) — 2026-10-20

The first run finished and `state/capabilities.json` is now `verified: true`. Nothing was placed, cancelled or changed in the account, and I skipped the optional `TB-watch` watchlist. Because `operating_mode` is already `paper`, the next scheduled run (2026-10-21) will place real paper orders. If you want to read this report first, set `operating_mode` to `discovery` now. The full report is in `reports/first-run-report.md`.

**Account:** a clean paper account `***GU2S`, `ACTIVE`, with $100,000.00 cash (recorded as `paper_cash_baseline_usd`).
- Configuration: `max_margin_multiplier` 1, `no_shorting` true, `fractional_trading` true.
- Options level is 3, Alpaca's paper minimum; the deny list and order guard block options.
- No existing positions, orders or activities, so nothing is tagged `manual`.
- `get_account_info` doesn't return `daytrade_count` or `pattern_day_trader`, so the agent will count its own day trades.

**Tools:** everything in the expected 3.4.7 inventory is there except `delete_watchlist_by_id`, which is on the never-call list anyway. No `robinhood-trading` or other connector tools appeared. The order guard's parameter names (`notional`, `qty`, `limit_price`) match the tool schema. Of 30 probes, only `feed: "sip"` failed (HTTP 403), which is expected on the free plan.

**Data feed:**
- **Real-time quotes:** IEX only. It carries about 3.5% of consolidated volume, and after hours its ask shows 0, so nothing can be priced outside the session.
- **Consolidated data:** snapshots are 15 minutes delayed (`delayed_sip`); historical SIP bars work fine.
- **Volume tests:** use consolidated data on both sides.
- **Spread checks:** use IEX on both sides, so spreads may look wider than the national best quote.

**Order mechanics** (from the schemas and Alpaca's docs; nothing was placed):
- **Stocks:** dollar-amount orders only work as market orders with time in force `day`.
- **Fractional limit orders:** Alpaca's docs say they're supported (by quantity, `day`), but the same page also says market only. I recorded them as supported; the first such order is the real test.
- **Crypto:** limit orders use time in force `gtc` or `ioc`. The minimum is about $1 per pair.
- **Crypto fee:** 0.25% per side (Tier 1 taker). Whether paper actually charges it is unknown until the day after the first crypto fill.
- **Partial fills:** paper gives a random partial fill on about 10% of orders.

**Crypto:** the pairs are `BTC/USD`, `ETH/USD` and `SOL/USD`, all tradable. History comes from `get_crypto_bars` (daily and hourly), so no CoinGecko fallback is needed. Spreads are 0.03–0.10%, and modeled round-trip cost is about 0.53–0.60%, well under the 2% cap.

**Regimes:**
- **Equities:** risk-on, but only just. SPY closed at 769.05, 0.10% above its 50-day average of 768.29, so one small down day flips it.
- **Crypto:** risk-off. BTC is 0.25% below its 20-day average (83,003.67 vs 83,214.98), so no crypto entries for now.

**Virtual ledger:** it opened with one settled $50.00 deposit, and equity, cash, settled cash and peak all equal $50.00, inside the Tier 0 range of $0–200. Each run checks that the paper account's cash dropped by exactly what the ledger spent (within $1 or 1%). Benchmarks start at SPY 769.05 and BTC 83,003.67.

**Candidate scan** (dry run, defined in `state/scan-config.json`):

| Stage | Count |
|---|---|
| Gainers + most active | 93 |
| After dropping warrants, rights and units | 64 |
| Price ≥ $5 | 34 |
| Top 10 by today's change | 10 |
| 30-day average dollar volume ≥ $20M | 6 |
| Not leveraged or inverse (TSLL dropped) | 5 |
| Within 10% of 52-week high | 1 (BRZE) |

BRZE's trading (+51.7% in a 45.26–45.61 range all day) looks like a stock pinned to a takeover price. I haven't checked that. I wrote three proposals in `state/proposals.md`:
- exclude pending takeover targets;
- use median dollar volume (SAIQ passed only on one spike day);
- allow weekly bars for the 52-week high.

**Paper caveats:**
- Fills have no market impact or slippage, so results will look better than reality.
- No regulatory fees or dividends, and crypto fees may not be charged.
- Consolidated volume runs 15 minutes behind.
- Settlement rules are enforced only by the virtual ledger.

**Token usage:** I can't see it directly. The session counter fell by about 250k tokens; the exact figures will be in `logs/runs.jsonl`.

**Not verified:** fractional limit orders being accepted, paper crypto fees, IEX spreads during the session, the day-trade fields, and BRZE's takeover status.

**`state/ATTENTION.md`:** one MEDIUM item (trading starts at the next run unless you switch to `discovery`) and four INFO items (data feed, untested mechanics, missing day-trade fields, the proposals).

*All figures are PAPER figures — not real money and not a forecast of live results.*

```
mode paper / tier 0 (first-run: read-only, no orders)
virtual equity $50.00 / cash $50.00 / settled $50.00 (paper cash baseline $100,000.00)
positions 0/2 — none
actions: probes + ledger opened + regimes (equity risk-on, crypto risk-off) + scan dry run (1 survivor: BRZE); no orders
warnings: SIP real-time 403 (IEX quotes in use); next scheduled run will trade (mode=paper) — see state/ATTENTION.md
```
