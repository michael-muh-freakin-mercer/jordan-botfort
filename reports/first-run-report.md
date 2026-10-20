# PAPER — First-run report (Alpaca paper account) — 2026-10-20

Run `20261020T234442Z-first-run`, 23:44–23:56 UTC (19:44–19:56 ET, after the close). Read-only: no orders were placed, cancelled or replaced, and no account setting was changed. The optional Alpaca watchlist `TB-watch` was **not** created; `state/watchlist.json` remains the source of truth. `state/capabilities.json` is now `verified: true`.

## 1. Account

| Item | Value |
|---|---|
| Account | `***GU2S`, **paper**. Evidence: the account number carries Alpaca's paper prefix, the default $100,000 balance, it was created 2026-10-20 21:14 UTC, and the MCP launcher is locked to paper keys. |
| Status | `ACTIVE`, crypto `ACTIVE`. Not trading-blocked, not account-blocked, not suspended by user. |
| Paper cash | $100,000.00, recorded as `paper_cash_baseline_usd` |
| `max_margin_multiplier` | 1 (also `multiplier` 1) |
| `no_shorting` | true (`shorting_enabled` false) |
| `fractional_trading` | true |
| Options level | 3 (Alpaca's paper minimum). Blocked by the deny list and the order guard, as the mandate says. |
| Existing positions / orders / activities | none / none / none. Nothing is tagged `manual`. |

Not available: `get_account_info` does not return `daytrade_count` or `pattern_day_trader`. The agent will count its own virtual day trades (risk.md §5).

## 2. Tool inventory and differences

Every tool in the expected 3.4.7 inventory (procedures §1.1) is exposed, both read-only and the permitted writing tools, with one exception: `delete_watchlist_by_id` is not exposed, which is harmless because it is on the never-call list anyway. The denied tools (`place_option_order`, `close_*`, `cancel_all_orders`, `replace_order_by_id`, `update_account_config`, `create_locate`, the exercise tools) are not visible, as intended. No `robinhood-trading` or other connector tools appeared. Exact parameter names are recorded in `capabilities.tool_params`. The order guard reads `notional`, `qty` and `limit_price`, which match the MCP schema.

All 30 probes worked except one: `get_stock_snapshot` with `feed: "sip"` returned HTTP 403 ("subscription does not permit querying recent SIP data"). That is expected on the free plan and is logged as a warning.

## 3. Data feed and its limits

| Need | Source used | Limit |
|---|---|---|
| Real-time quotes, spread checks, order pricing | IEX (`feed: "iex"`, the default) | IEX is one exchange. Its spread can be wider than the national best bid/offer. After hours the IEX ask showed **0**, so no order can be priced outside the session, which is fine because equities trade regular hours only. |
| Consolidated snapshot (today's volume, high, previous close) | `delayed_sip` | 15 minutes old |
| Daily and weekly history | SIP historical bars (`feed: "sip"`, `end` ≥ 15 min ago) | none observed |

IEX volume is about **3.5%** of consolidated volume (SPY 1.24M vs 35.09M shares on 2026-10-20). So the volume-pace and dollar-volume tests use SIP on both sides (delayed snapshot ÷ historical bars), and the spread test uses IEX on both sides. I could not measure IEX spreads during the session because this run was after hours. The first session run will record them; the delayed SIP spreads were SPY 0.007% and AAPL 0.044%.

## 4. Order mechanics (from the MCP schemas and Alpaca docs; nothing was placed)

- **Equities**: market or limit; time in force `day`, `gtc`, `opg`, `cls`, `ioc`, `fok`. The agent uses `day`. `notional` (dollar) orders work only as **market + day**.
- **Fractional limit orders**: documented as supported (docs page `us/fractional-trading`: "Limit orders are supported for both fractional and notional orders", time in force `day`), placed as a fractional `qty` with `type: limit`. The same page also says, in its disclaimer, that fractional shares "can only be bought or sold with market orders". I recorded `fractional_limit_supported: true`, but **it is not verified**: the first fractional limit order is the real test, and a rejection would be handled by the normal procedure (log it, no retry, ATTENTION). Minimum fractional order: $1.
- **Crypto**: market, limit, stop_limit; time in force `gtc` or `ioc` (no `day`). The agent uses limit + `gtc`. Dollar orders work for market only, so limits go by quantity. Minimum order is about **$1** per pair (BTC 0.000012261, ETH 0.00041936, SOL 0.009558127).
- **Fees**: stocks are commission-free; regulatory fees are not simulated in paper. Crypto Tier 1 fees (docs `us/crypto-fees`) are 0.15% maker and **0.25% taker**, so `crypto_fee_pct_per_side` = 0.25. Fees are posted at end of day as `CFEE`/`FEE` activities. **Whether paper actually charges them is unknown** (`paper_charges_crypto_fees: null`); this gets checked the day after the first crypto fill.
- **Partial fills**: yes. Per docs `us/paper-trading`, eligible orders get a random-size partial fill 10% of the time.
- `client_order_id` is accepted on both order tools, and Alpaca rejects duplicates.

## 5. Crypto

- Pairs: `BTC/USD`, `ETH/USD`, `SOL/USD`, all tradable and fractionable.
- History source: `get_crypto_bars` for both daily (30 days) and hourly (7 days) bars. No CoinGecko fallback is needed. Alpaca's own venue volume is thin (a few BTC a day), so bar volume is not a market-wide measure, but prices track the market.
- First quote sample (23:46 UTC): BTC 83,003.67 (spread 0.029%), ETH 2,448.83 (0.035%), SOL 106.53 (0.096%). Modeled round-trip cost (spread + 2 × 0.25%) is about 0.53–0.60%, well under the 2.0% cap.
- **Crypto regime: risk-off**. BTC 83,003.67 is below its SMA20 of 83,214.98 (−0.25%), so there are no crypto entries until that flips.

## 6. Equity regime

**Risk-on, barely.** SPY closed at 769.05, 0.10% above its SMA50 of 768.29, and SMA20 (770.62) is above its value five sessions ago (769.87). A small down day would flip it to risk-off, which blocks breakout entries and triggers the regime exit on positions up less than 10%. `high_vol` is false.

## 7. Virtual ledger and reconciliation against paper cash

- `state/settlement.json`: one settled deposit of **$50.00**, `method: "ledger"`. `state/portfolio.json`: virtual equity, cash, settled cash, peak and day-start all $50.00; `paper_start` 2026-10-20T23:52Z. This is inside the Tier 0 range of $0–200.
- How the check works on every run: the paper account's cash should fall by exactly what the virtual ledger spent. So (100,000.00 − paper cash now) must equal (50.00 − virtual cash) within $1 or 1%. Any extra position, order or cash move that the ledger can't explain is a reconciliation error: no new entries, ATTENTION, and ESCALATE if it persists. The ~$100k paper balance and `buying_power` are never used for sizing.
- Benchmarks (`state/benchmark.json`): SPY 769.05 (2026-10-20 close), BTC 83,003.67 (mid at 23:46 UTC).

## 8. Candidate source (`state/scan-config.json`)

Sources: `get_market_movers` (stocks, top 50 gainers), `get_most_active_stocks` (volume, top 25; this run used 50) and `state/watchlist.json`. Filters, in order: warrant/right/unit symbol pattern → price ≥ $5 (delayed SIP snapshot) → rank by today's change, top 8 → 30-session average dollar volume ≥ $20M (SIP daily bars) → `get_asset` (tradable, fractionable, not leveraged/inverse) → within 10% of the 52-week high (SIP weekly bars) → spread at entry time (IEX).

Dry run on the 2026-10-20 lists:

| Stage | Count |
|---|---|
| Gainers + most active (union) | 93 |
| After symbol-pattern filter | 64 |
| Price ≥ $5 | 34 |
| Ranked into the expensive filters | 10 |
| Avg dollar volume ≥ $20M | 6 (SAIQ, BRZE, NU, AAL, TSLL, SOFI) |
| Not leveraged/inverse | 5 (TSLL excluded: 2× TSLA) |
| Within 10% of 52-week high | **1 (BRZE)** |

The lists really are dominated by penny stocks and warrants: 59 of 93 symbols were dropped before any data call. BRZE rose 51.7% on 64.8M shares within a 45.26–45.61 range, which looks like a stock pinned to a pending cash takeover (not verified). I proposed excluding such names. SAIQ passed the dollar-volume filter only because of one spike day; I proposed using the median instead. A third proposal covers the weekly-bar shortcut. All three are in `state/proposals.md`.

## 9. Paper caveats that will affect results

- Fills happen at the current quote with no market impact, queue position or latency slippage. Fills will look better than reality, especially in thin names.
- Random partial fills (10% of eligible orders) will happen and exercise the partial-fill path.
- No regulatory fees, dividends or borrow fees. Crypto fees may not be charged. The weekly review applies modeled fees (0.25% per crypto side, 0.1% per side equity spread proxy) regardless.
- IEX-only real-time quotes: spreads may read wider than NBBO, which could block entries that the real account would take. SIP data is 15 minutes delayed, so volume pace lags by 15 minutes.
- Settlement (T+1 for both sleeves) is enforced only by the virtual ledger; Alpaca paper does not enforce it.
- Stops are soft and checked only when a run happens. A gap between hourly runs is a known risk.

## 10. Token usage of this run

Not directly visible to me. The session's token counter dropped by about **250k tokens** of context processed by the time of writing; `scripts/run.sh` records the exact usage in `logs/runs.jsonl`. The largest items were the 50-symbol snapshot (~20k) and the daily/weekly bars for the scan (~45k combined). The scan config caps both for hourly runs.

## 11. Could not verify

- Fractional **limit** orders actually accepted (documented only; the docs contradict themselves).
- Whether the paper engine charges crypto fees.
- IEX spreads during the regular session.
- The day-trade fields (not exposed by the MCP).
- BRZE's takeover status (inferred from price behaviour only).

## 12. Recommended next step

The setup is ready for Stage 1. Because `operating_mode` is already `paper`, the **next scheduled run (2026-10-21) will trade**. If you want to read this first, set `operating_mode` to `discovery` now and back to `paper` afterwards. Otherwise, watch the first session run or two (`scripts/summary.sh`). The first fractional equity order will settle the fractional-limit question, and the day after the first crypto fill the agent should check `CFEE`/`FEE` activities to set `paper_charges_crypto_fees`. Consider the three proposals before the first weekly review.

*All figures are PAPER figures. Nothing here is real money or a forecast of live results.*
