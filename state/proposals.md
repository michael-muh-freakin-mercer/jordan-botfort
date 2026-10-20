# Proposals for Michael (agent-written; nothing here is active until Michael edits the protected files)

## P-2026-10-20-1 — Allow weekly bars for the 52-week-high filter (expires 2026-11-19)
- **What**: in `config/strategy.md` §1, allow the 52-week high to come from `get_stock_bars` `1Week` (max of weekly highs) instead of `1Day`.
- **Why / evidence**: first run, 6 candidates: 1Day for a year is ~252 bars per symbol, 1Week is 53. The max of weekly highs equals the max of daily highs over the same weeks; only the window edge differs (< 1 week). `state/scan-config.json` step 6 already uses 1Week and flags the deviation.
- **Risk added**: a 52-week high set 52–53 weeks ago may be counted or missed at the edge. Negligible for a 10% band.
- **Change**: `config/strategy.md` §1, the sentence "30-day dollar volume and the 52-week high from `get_stock_bars` (`1Day`)".
- **Recommendation**: accept. If you decline, the next run switches step 6 back to 1Day (days=370).

## P-2026-10-20-2 — Exclude pending-acquisition targets from the equity universe (expires 2026-11-19)
- **What**: add a §1 exclusion: no entry in a stock with an announced definitive cash acquisition (verified with one WebSearch at entry, the same query as the earnings-date lookup).
- **Why / evidence**: the only first-run scan survivor, BRZE, rose 51.7% on 64.8M shares and traded in a 45.26–45.61 range all day, which looks like a price pinned to a deal (not verified). Such a stock passes the 20-day breakout and the 52-week-high filters, but its upside is capped at the deal price while a broken deal can gap it down 30%+.
- **Risk added**: one extra WebSearch per candidate that passes everything else; this may miss a stock-for-stock deal.
- **Change**: `config/strategy.md` §1 "Excluded:" line.
- **Recommendation**: accept.

## P-2026-10-20-3 — Sub-$5 / thin-history names that pass the dollar-volume filter on a single spike (expires 2026-11-19)
- **What**: compute the 30-day average dollar volume as the **median** of daily dollar volume, or require ≥ 20 of 30 sessions above $5M.
- **Why / evidence**: SAIQ (a recent de-SPAC, not fractionable) passed the $20M average only because of one $447M day (2026-10-05); its median day was under $1M. It then failed the 52-week filter, but the dollar-volume test is not doing its job here.
- **Risk added**: none to the account; it narrows the universe slightly.
- **Change**: `config/strategy.md` §1 (dollar-volume definition).
- **Recommendation**: accept the median version.
