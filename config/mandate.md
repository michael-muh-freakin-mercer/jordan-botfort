# Trading Mandate (Alpaca paper)

Owner: Michael. Agent: Claude Code with the `alpaca` MCP, locked to paper trading. Account: Michael's Alpaca **paper** account (masked identifier recorded by the first run in `state/capabilities.json`). Account configuration set by Michael's request on 2026-10-20: `max_margin_multiplier` 1, `no_shorting` true. Alpaca does not allow a paper account's options level below 3, so options are blocked by this repository's deny rules and order guard instead. Effective 2026-10-20.

This is a paper twin of the Robinhood agent in `../trading-bot`. It exists to test the same strategy and the same order handling with orders that reach a broker's simulated engine. Nothing here moves real money, and nothing here authorizes anything in the Robinhood repository.

## 1. Objective

Aggressive growth of a **virtual** account of `virtual_capital.starting_capital_usd` (Tier 0: $50), through a small number of concentrated, high-conviction positions, run exactly as the real account would be run. Large drawdowns are accepted. Every trade still follows a written rule, and every rule is written so a reviewer can check whether it was followed.

## 2. Success criteria (measured, not promised)

| Metric | Definition | Benchmark |
|---|---|---|
| Primary | Total return of the virtual account since paper start (time-weighted) | SPY buy-and-hold from the same date; BTC for the crypto sleeve |
| Secondary | Count and share of closed trades with realized gain ≥ 50% | none (reported, not optimized for) |
| Process | Rule adherence rate: trades that match a written rule / all trades | 100% |
| Process | Operational errors: unverified orders, duplicate orders, reconciliation mismatches, ledger violations | 0 |
| Fidelity | Fill price vs the quote recorded on the intent, per trade | reported weekly |
| Cost | Claude tokens per run and per week (from `logs/runs.jsonl`) | reviewed weekly |

Every number is a paper number and is labelled as one.

## 3. Permitted instruments

| Instrument | Tier 0 (virtual $50) |
|---|---|
| US stocks and ETFs, long only, fractional allowed, regular hours only | yes |
| Crypto (Alpaca spot pairs against USD), long only | yes, while `crypto.enabled` is true |
| Options | no |
| Option spreads, short options, margin, shorting, extended hours | never |

Tier is set by Michael in `state/authorization.json`. The agent checks that **virtual** equity falls inside `expected_equity_range_usd` for the tier; a mismatch is treated as a halt until Michael updates the file.

## 4. Horizon

Equity swing trades: days to weeks. Crypto momentum trades: hours to days. Conviction holds: unlimited while the thesis holds (`config/strategy.md` §7). Because the virtual account trades settled funds only, equities are swing trades in practice and only crypto can turn over intraday.

## 5. Operating constraints

- Cash-account rules on the virtual account: buy only with virtual settled funds (`config/risk.md` §4). Equity and crypto sale proceeds settle T+1 in the ledger, as on the real account.
- Fully autonomous within the rules. The agent does not ask before trades. It does ask, through `state/ATTENTION.md`, for anything in the protected-settings list below.
- Communication: terminal only. Per-trade reasoning in `logs/trades.jsonl` and `logs/decisions.jsonl`; daily summary in `logs/daily/`.
- Tools: `alpaca` MCP (minus the denied tools), WebSearch, WebFetch, local files and the allowed shell commands. Nothing else; in particular not the `robinhood-trading` MCP.
- Budget: no spend beyond Michael's existing Claude subscription. Runs stay lean.

## 6. Protected settings (only Michael changes these, by editing `state/authorization.json` or the files in `config/`)

- Operating mode (`discovery` / `paper`) and `paper_trading_authorized`.
- Capital tier, virtual starting capital, and every limit in `config/risk.md` §2.
- Permitted instruments.
- Loss-limit values and whether they are enabled.
- The prohibited-actions list.
- The Alpaca account configuration.
- Any rule in `config/`, any prompt in `prompts/`, any script, `CLAUDE.md`, `.mcp.json`, `.claude/settings.json`.

The agent may change, within the bounds table in `config/strategy.md` §9 and only during the weekly review: the tunable parameters in `state/strategy-params.json`, the watchlist, and the conviction-hold designation. Every such change is recorded in `state/strategy-changelog.md` with the evidence that motivated it.

## 7. What the owner has explicitly accepted

- (2026-10-20) A separate paper instance alongside the Robinhood shadow bot, mirroring Tier 0 rules on a virtual $50 inside the $100k paper account; margin multiplier 1 and shorting disabled on the paper account.
- (2026-10-20) `operating_mode: "paper"` authorized from the start; the first run still has to verify capabilities before any order.
- Carried over from the Robinhood mandate: crypto sleeve enabled with a 2.0% round-trip cost cap; fractional equity orders under guards; no loss halt during Tier 0; buying into and holding through earnings within the cap; trading on halt days and extreme-volatility days with the execution safeguards; crypto as the only intraday venue.
