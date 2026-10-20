FIRST RUN — tool discovery, read-only validation, and virtual-ledger setup. Whatever `operating_mode` says, this run places no orders and cancels nothing. Change nothing in the account except, optionally, creating an Alpaca watchlist named `TB-watch`.

Read, in full: `CLAUDE.md`, `config/mandate.md`, `config/risk.md`, `config/strategy.md`, `config/procedures.md`, `config/launch-plan.md`, `config/reporting.md`, `state/authorization.json`, `state/strategy-params.json`, `state/README.md`.

Then:
1. Verify the repository layout (`state/`, `logs/`, `reports/`, `scripts/`) and create any missing state file from the schemas in `config/reporting.md` with empty contents.
2. Follow `config/procedures.md` §1 step by step. Record every probe's outcome (worked / failed / not available) with the exact tool and parameters used.
3. Identify the account: confirm it is a paper account, masked identifier (last four characters only), status, paper cash, account configuration (`max_margin_multiplier`, `no_shorting`, `fractional_trading`), existing positions and orders (list them; they become `manual`). Record `paper_cash_baseline_usd`.
4. Open the virtual ledger: `state/settlement.json` with one settled deposit of `virtual_capital.starting_capital_usd`, `method: "ledger"`; `state/portfolio.json` with that amount as equity, cash and settled cash, `peak_equity_usd` and `day_start_equity_usd` equal to it, `paper_start` = now. Confirm virtual equity is inside the Tier 0 `expected_equity_range_usd`.
5. Determine order mechanics without placing anything, from schemas and `search_alpaca_docs` / `fetch_alpaca_doc` (procedures §1.7).
6. Determine the data feed (procedures §1.4), the crypto history source (§1.5), and the exact pair symbols for BTC, ETH, SOL (`get_asset`), recorded in `state/capabilities.json.crypto_pairs`.
7. Pull SPY daily bars (60+ sessions) and BTC daily bars (30 days); compute both regimes with `scripts/indicators.py`; save to `state/price-history/SPY.json` and `BTC-daily.json`. Take one crypto quote sample and append it to `state/price-history/crypto.jsonl`. Record SPY and BTC prices as the benchmark start in `state/benchmark.json`.
8. Define the candidate source in `state/scan-config.json`: which `get_market_movers` / `get_most_active_stocks` calls (with `top`), then which filters from `config/strategy.md` §1 are applied with which tool. Run it once read-only and record how many candidates survived each filter.
9. Write `state/capabilities.json` (`verified: true`).
10. Write `reports/first-run-report.md` for Michael, in plain language, with these sections: Account (paper, configuration); Tool inventory and differences; Data feed and its limits; Order mechanics; Crypto (pairs, fees, history source); Virtual ledger and how reconciliation against paper cash works; Candidate source; Paper caveats that will affect results; Token usage of this run if visible; Recommended next step. State clearly anything you could not verify.
11. Write `state/ATTENTION.md` with the items Michael must act on (or "nothing"), and print the report to stdout.

Do not call `place_*`, `cancel_*`, `close_*`, `replace_*`, `exercise_*`, `create_locate`, or `update_account_config`.
