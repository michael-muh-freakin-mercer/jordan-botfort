# Risk-Management Framework

Risk limits take precedence over every profit opportunity. When a rule here and a rule in `config/strategy.md` disagree, this file wins. When this file and `CLAUDE.md` §3 disagree, `CLAUDE.md` wins.

## 1. Hierarchy (highest first)

1. `CLAUDE.md` §3 immutable constraints.
2. `state/HALT`, `state/authorization.json` validity, and operating mode.
3. Loss limits (§3) and settlement rules (§4).
4. Position, concentration, and exposure limits (§2).
5. Execution safeguards (§5) and the pre-trade checklist (§6).
6. Strategy rules (`config/strategy.md`).

A lower rule can never loosen a higher one. A higher rule can block anything below it.

## 2. Hard limits by capital tier

Values below are starting points proposed by the designer and accepted by Michael for Tier 0 and Tier 1 (2026-10-16). They are not universally safe values; they are what this owner chose for money he can lose, and this paper instance mirrors them on a virtual account of `virtual_capital.starting_capital_usd`. Every percentage below is of **virtual** equity. The copy in `state/authorization.json` is authoritative; if the two disagree, halt and report.

| Limit | Tier 0 ($50 test) | Tier 1 ($500–$2,000) | Tier 2 (> $2,000) |
|---|---|---|---|
| `expected_equity_range_usd` | 0 – 200 | 200 – 3,000 | 2,000 – 20,000 |
| Max open positions (all sleeves) | 2 | 4 | 6 |
| Max single position, % of equity at entry | 60 | 40 | 30 |
| Max crypto positions (Tier 0: sleeve idle until the owner enables it; see §5) | 1 | 2 | 3 |
| Max combined crypto exposure, % | 60 | 50 | 40 |
| Max positions per equity sector (GICS-style sector, looked up with WebSearch at entry and stored on the position) | 1 | 2 | 2 |
| Max earnings exposure (positions with a report in the next 5 sessions or last 2), % of equity | 50 | 25 | 20 |
| Options: max per contract position, % of equity | n/a | 10 | 10 |
| Options: max total option premium at risk, % of equity | n/a | 20 | 20 |
| Min cash reserve, % of equity | 0 | 5 | 5 |
| Max new entries per run | 1 | 2 | 2 |
| Max new entries per day (all sleeves) | 2 | 3 | 4 |
| Loss limits enabled | **no** (owner's choice) | yes | yes |
| Max drawdown from equity peak before halt | — | 50% | 50% |
| Max single-day loss before pausing new entries until next day | — | 15% | 15% |

Equity peak is the highest end-of-run virtual equity since paper start, adjusted for deposits (a deposit raises the peak by the deposit amount; it never counts as a gain). Tracked in `state/portfolio.json.peak_equity`.

## 3. Loss limits (Tier 1 and above)

- **Daily loss**: if equity at any run is ≤ (1 − 0.15) × equity at the first run of the day, set `state/portfolio.json.entries_paused_until` to the next trading day. Exits still run.
- **Drawdown**: if equity ≤ (1 − 0.50) × peak_equity, create `state/HALT` with the reason, write `state/ATTENTION.md`, and stop. Open positions are left as they are; flattening is Michael's call. Resumption requires Michael to run `scripts/resume.sh` and, if he wants the halt threshold reconsidered, to edit `state/authorization.json`.
- During Tier 0 these are computed and **reported** every run but do not trigger. The daily summary shows what would have happened.

## 4. Settlement rules (virtual cash account)

- The paper account's cash, `buying_power`, `non_marginable_buying_power` and `equity` are **never** used for sizing. The virtual ledger in `state/settlement.json` (`method: "ledger"`) is the only source of cash.
- **Virtual cash** = starting capital + Σ(sale proceeds) − Σ(purchase costs) − Σ(fees), all from verified fills. **Virtual settled cash** = virtual cash − Σ(unsettled sale proceeds) − Σ(cash committed to open buy orders). **Virtual equity** = virtual cash + Σ(market value of the agent's positions at current quotes); `manual` positions are excluded.
- Cross-check every run: (`capabilities.paper_cash_baseline_usd` − paper `cash`) must equal (starting capital − virtual cash) within $1 or 1%, adjusted for any `manual` activity. A mismatch is a reconciliation discrepancy (`config/procedures.md` §3).
- Equity sale proceeds settle at the start of the next business day (T+1, business days from `get_calendar`). Record `settles_on` for every sale. Crypto proceeds also settle T+1 in the ledger, mirroring the real Robinhood account until Michael decides otherwise. Alpaca paper does not enforce settlement; the ledger does.
- A buy order's notional (including the limit offset) must be ≤ settled cash − cash reserve − cash committed to other open buy orders. Otherwise the order is not placed, and the decision log says "insufficient settled cash".
- Because every purchase uses settled funds, selling any position at any time cannot create a good-faith violation. Never rely on that reasoning to buy with unsettled funds "because we won't sell today".
- If the account ever reports a restriction (`trading_blocked`, `account_blocked`, `trade_suspended_by_user`), halt new buys for the run, write `state/ATTENTION.md`, and reconcile the ledger before the next run.

## 5. Execution safeguards

- Limit orders for whole-share equity and crypto (`config/strategy.md` §8). Fractional equity orders are marketable limits when `capabilities.fractional_limit_supported` is true; otherwise market orders, allowed only under the guards in `config/strategy.md` §8 (spread ≤ 0.3%, quote age ≤ 60 seconds, computed review within 1% of the quote, liquidity filters passed). No other market orders.
- No order when the quote is older than `execution.quote_max_age_seconds`, when bid/ask spread > `entry.max_spread_pct` (equities) or 1.0% (crypto), or when the quote has a zero or missing bid or ask.
- **Crypto round-trip cost cap**: no crypto entry when spread % + 2 × the fee rate % (`capabilities.crypto_fee_pct_per_side`, Alpaca's published taker fee at the lowest volume tier, used even if the paper engine charges nothing, so results stay comparable) > 2.0%. Checked at the computed review step (`CLAUDE.md` §6.4). Record `fee_pct_per_side` and `round_trip_cost_pct` on the intent. Exits are not blocked by this cap. The agent does not change the 2.0%; the owner does.
- No equity entries in the first 5 or last 10 minutes of the regular session. No equity orders outside regular hours.
- Halted stock: no new orders; an existing position is re-evaluated when trading resumes. Extreme volatility day (SPY down ≥ 3% intraday; Alpaca has no VIX quote): trading continues, but new equity entries are sized at 50% of the normal size and the limit offset doubles.
- Order size sanity: an order whose notional exceeds the tier's max single position × 1.05 is a bug; do not place it, log an error. (`scripts/order-guard.py` blocks it as well.)
- Minimum order: `execution.min_order_usd`. Below that, skip.

- **Crypto sleeve status**: `state/strategy-params.json` key `crypto.enabled` (owner-only; carried over as enabled from the Robinhood bot). While false, take no crypto entries. Exits for any existing crypto position still run. Every run that samples crypto quotes records the spread percent per symbol in `state/price-history/crypto-spreads.jsonl` (`{"ts","symbol","spread_pct","venue":"alpaca"}`, plus `fee_pct_per_side` and `round_trip_cost_pct` whenever the run previewed a crypto order) and the weekly review summarizes median and 90th percentile by hour, of spread and of round-trip cost. The 1.0% spread cap and the 2.0% round-trip cap are not changed by the agent; the owner decides on the data.
- **Day-trade counter**: each run, record `daytrade_count`, `pattern_day_trader` and restriction fields from `get_account_info` in `state/portfolio.json.account_flags`, and count the virtual account's own day trades (a round trip in one equity symbol on one day) over the last 5 sessions as the real sub-$25k account would. If that count reaches 2, or the account shows any restriction, open no new equity positions that could be exited the same day, and write ATTENTION. Equity entries are planned as swing trades regardless.

## 6. Pre-trade checklist (every order, every mode)

All must be true; otherwise log the failing item and skip:
1. `state/HALT` absent; mode is `paper`; authorization file valid; capabilities verified.
2. No intent with `status: "uncertain"` or `"submitted"` remains unresolved for this symbol.
3. No open order for the same symbol and side.
4. Entry: position count, sector, crypto, earnings, and exposure limits still satisfied after this order.
5. Entry: virtual settled cash covers the order (§4). Exit: held quantity covers the sale.
6. Quote fresh, spread acceptable, session state acceptable (§5).
7. Loss limits not triggered (Tier ≥ 1); `entries_paused_until` not in the future (entries only).
8. The rule that fired is named, with the numbers that satisfied it, in the intent record.

## 7. Correlation and concentration

- Equities: at most the per-sector count in §2; never two positions in the same company (different share classes count as the same).
- Crypto: BTC, ETH, and all other coins are treated as one correlated group for the "max combined crypto exposure" line.
- A conviction hold (`config/strategy.md` §7) counts toward every limit like any other position.

## 8. Reducing exposure, pausing, and requiring approval

| Condition | Action |
|---|---|
| Daily loss limit (Tier ≥ 1) | No new entries until next trading day; exits continue |
| Drawdown limit (Tier ≥ 1) | HALT; ATTENTION |
| Reconciliation mismatch unresolved after one full run | No new entries; ESCALATE; ATTENTION |
| Any order outcome unknown at run end | No new entries in that symbol; ATTENTION; next run reconciles first |
| MCP auth failure, account unreadable, or trade approval blocking | Read-only for the run; ATTENTION; ESCALATE |
| Equity outside tier range | Treat as HALT until `state/authorization.json` is updated |
| Three or more tool errors in one run | Stop placing orders for the run; finish read-only; log |
| Owner wants limits changed | Michael edits `state/authorization.json`; agent only proposes |
