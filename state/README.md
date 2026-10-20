# state/ — the agent's memory between runs

Everything here is read at the start of every run and written at the end. It is committed to git by `scripts/run.sh`.

| File | Who writes it | Purpose |
|---|---|---|
| `authorization.json` | **Michael only** (the agent is denied write access) | Operating mode, tier, limits, instruments. The single source of permission. |
| `strategy-params.json` | Weekly review (Opus), within bounds | Tunable strategy parameters. |
| `capabilities.json` | First run | What the MCP verified it can do: tool list, parameter names, account masked id, paper cash baseline, data feed, crypto history source and fees, order mechanics. `verified: false` means discovery mode regardless of `operating_mode`. |
| `portfolio.json` | Every run | Snapshot of the **virtual** account: equity, cash, settled cash, peak, positions with stops, regime; plus the paper account's raw cash/equity for the cross-check. |
| `open-intents.json` | Every run | Orders in flight. An intent is written **before** any order is placed. |
| `settlement.json` | Every run | Virtual settled-cash ledger (cash account rules) and the paper-cash cross-check. |
| `watchlist.json` | Hourly (adds), weekly (prunes) | Candidate symbols with the reason each was added. |
| `scan-config.json` | First run, weekly | Candidate-source definition (movers / most-active calls and filters). |
| `benchmark.json` | First run | SPY and BTC prices at paper start, for benchmark-relative return. |
| `conviction.md` | Weekly review | Thesis and checkpoints for a conviction hold, if any. |
| `strategy-changelog.md` | Weekly review | Every parameter change with evidence. |
| `proposals.md` | Agent | Changes the agent wants but may not make. |
| `ATTENTION.md` | Agent | Items Michael must act on. `scripts/summary.sh` prints it. |
| `price-history/` | Every run | `crypto.jsonl` hourly samples `{"ts","symbol","bid","ask","mid"}`; `SPY.json` cached daily closes; `BTC-daily.json` cached daily closes from the verified source. |
| `HALT` | Michael (`scripts/stop.sh`) or the agent on critical failure | Presence stops scheduled runs and blocks all order tools. |
| `ESCALATE` | Agent | Presence makes the next scheduled run use the stronger model once; `run.sh` deletes it. |
| `FLATTEN_CONFIRMED` | Michael (`scripts/stop.sh --flatten`) | Today's date; required by the flatten procedure. |
| `.run.lock` | `run.sh` | flock target. |

Schemas: `config/reporting.md`.
