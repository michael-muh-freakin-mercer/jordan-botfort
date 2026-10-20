WEEKLY STRATEGY REVIEW — PAPER (Saturday, stronger model). You are reviewing, not trading. Place no orders. You may change `state/strategy-params.json` only within the bounds in `config/strategy.md` §9, and the watchlist and the conviction-hold designation. Everything else is a proposal in `state/proposals.md`.

Read in full: `CLAUDE.md`, `config/mandate.md`, `config/risk.md`, `config/strategy.md`, `config/procedures.md`, `config/launch-plan.md`, `config/reporting.md`, `state/authorization.json`, `state/strategy-params.json`, `state/capabilities.json`, `state/portfolio.json`, `state/conviction.md` (if present), `state/strategy-changelog.md`, `state/proposals.md`. Read the last 7 days of `logs/trades.jsonl`, `logs/decisions.jsonl`, `logs/errors.jsonl`, `logs/runs.jsonl`, and `logs/daily/`. Pull the current account state with the read-only tools and reconcile it against `state/portfolio.json`.

Produce `reports/weekly/YYYY-Www.md` with the sections in `config/reporting.md` §9. Compute every number with `python3` and show the inputs. Specifically:
1. Performance of the virtual account vs SPY and BTC since paper start and for the week (from `state/benchmark.json` and current quotes). Drawdown from peak. Deposits excluded from return.
2. Trade table and rule adherence: for each trade, name the rule and confirm from the decision log that its inputs satisfied it. Any trade with no matching rule is a process failure: report it prominently and add it to ATTENTION.
3. Losing-trade review per `config/reporting.md` §9.
4. Operations: runs executed vs scheduled (`scripts/crontab.txt`), errors, reconciliation warnings, token and cost totals per run type from `logs/runs.jsonl`, and a usage projection for the coming week. Flag if usage is trending up.
5. Strategy health: signals generated vs taken, no-trade reason histogram, slippage (fill vs quote recorded on the intent), unfilled-order and partial-fill rates, and the paper caveats (`CLAUDE.md` §10) that affected results.
6. Backtest work per `config/launch-plan.md` Stage 1, if Michael asked. Follow the anti-bias rules there. Store data and scripts under `reports/backtest/`. If sample sizes are small, say "insufficient evidence" rather than drawing conclusions.
7. Parameter changes: at most one per parameter, within bounds, each justified by evidence from the logs (not by this week's P&L alone). Apply to `state/strategy-params.json`, bump its `version`, append to `state/strategy-changelog.md`. If the evidence is weak, change nothing and say so.
8. Conviction hold: review checkpoints in `state/conviction.md`; designate, keep, or remove per `config/strategy.md` §7. A new designation needs the thesis, three measurable checkpoints from SEC EDGAR filings, and the break condition.
9. Watchlist hygiene: remove symbols that failed the universe filters for two weeks; add candidates from the movers lists and confirmed upcoming earnings for next week (with the reason). Never add a symbol because of a news story alone.
10. Proposals for Michael: anything you believe should change in `config/`, `state/authorization.json`, the prompts, or the scripts. Include the risk each proposal adds. Write them to `state/proposals.md` and reference them in `state/ATTENTION.md` as INFO items.
11. Promotion or rollback assessment against `config/launch-plan.md`: state which criteria are met and which are not, with evidence. Recommend; do not act.

Print the report's first 40 lines to stdout, then the five-line status.
