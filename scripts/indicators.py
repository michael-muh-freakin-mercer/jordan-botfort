#!/usr/bin/env python3
"""Arithmetic helper so the agent never does numbers in its head.

Usage (all read JSON from a file or stdin; output is JSON):
  indicators.py sma   --n 50 closes.json              -> {"sma": x, "last": y, "above": bool}
  indicators.py regime closes.json                   -> SPY-style regime: last>SMA50 and SMA20 rising (5 sessions)
  indicators.py returns closes.json                   -> {"ret_1":..,"ret_5":..,"ret_20":..} in percent
  indicators.py high  --n 20 --exclude-last closes.json -> highest close of prior n (breakout level)
  indicators.py pace  --vol-today V --avg-vol A --elapsed F -> volume pace
  indicators.py stop  --entry E --peak P --params '{"initial":8,"trail_after":15,"trail":10,"wide_after":40,"wide":15}'
  indicators.py size  --equity E --max-pct 60 --settled S --reserve-pct 0 --committed C [--min-order 2] [--high-vol]
  indicators.py drawdown --equity E --peak P --day-start D
  indicators.py crypto --hours 72 samples.jsonl --symbol BTC   -> 24h/7d returns, 72h high, from the price history
Input "closes.json" is a JSON list of numbers (oldest first) or a list of objects with a "close" key.
"""
import argparse
import json
import sys
from datetime import datetime, timedelta, timezone


def load_series(path):
    data = json.load(open(path)) if path and path != "-" else json.load(sys.stdin)
    if data and isinstance(data[0], dict):
        for key in ("close", "close_price", "c", "price", "mid"):
            if key in data[0]:
                return [float(d[key]) for d in data]
        raise SystemExit("no close-like key in objects")
    return [float(x) for x in data]


def sma(xs, n):
    if len(xs) < n:
        return None
    return sum(xs[-n:]) / n


def out(d):
    print(json.dumps(d, indent=None, default=str))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd")
    ap.add_argument("path", nargs="?", default="-")
    ap.add_argument("--n", type=int, default=50)
    ap.add_argument("--exclude-last", action="store_true")
    ap.add_argument("--vol-today", type=float); ap.add_argument("--avg-vol", type=float); ap.add_argument("--elapsed", type=float)
    ap.add_argument("--entry", type=float); ap.add_argument("--peak", type=float); ap.add_argument("--params", type=str)
    ap.add_argument("--equity", type=float); ap.add_argument("--max-pct", type=float); ap.add_argument("--settled", type=float)
    ap.add_argument("--reserve-pct", type=float, default=0.0); ap.add_argument("--committed", type=float, default=0.0)
    ap.add_argument("--min-order", type=float, default=2.0); ap.add_argument("--high-vol", action="store_true")
    ap.add_argument("--day-start", type=float); ap.add_argument("--hours", type=int, default=72); ap.add_argument("--symbol", type=str)
    a = ap.parse_args()

    if a.cmd == "sma":
        xs = load_series(a.path); s = sma(xs, a.n)
        out({"n": a.n, "sma": s, "last": xs[-1], "above": (s is not None and xs[-1] > s), "count": len(xs)})
    elif a.cmd == "regime":
        xs = load_series(a.path)
        s50 = sma(xs, 50); s20 = sma(xs, 20); s20_prev = sma(xs[:-5], 20) if len(xs) >= 25 else None
        risk_on = s50 is not None and s20 is not None and s20_prev is not None and xs[-1] > s50 and s20 > s20_prev
        out({"last": xs[-1], "sma50": s50, "sma20": s20, "sma20_5_sessions_ago": s20_prev, "risk_on": bool(risk_on), "count": len(xs)})
    elif a.cmd == "returns":
        xs = load_series(a.path)
        r = {}
        for k in (1, 5, 20, 60):
            r[f"ret_{k}_pct"] = (xs[-1] / xs[-1 - k] - 1) * 100 if len(xs) > k else None
        out(r)
    elif a.cmd == "high":
        xs = load_series(a.path)
        if a.exclude_last:
            xs = xs[:-1]
        out({"n": a.n, "highest_close": max(xs[-a.n:]) if len(xs) >= a.n else None, "count": len(xs)})
    elif a.cmd == "pace":
        if not a.elapsed or a.elapsed <= 0:
            out({"pace": None, "note": "elapsed fraction must be > 0"}); return
        out({"pace": a.vol_today / (a.avg_vol * a.elapsed), "evaluable": a.elapsed >= 0.25})
    elif a.cmd == "stop":
        p = json.loads(a.params) if a.params else {}
        initial = p.get("initial", 8); trail_after = p.get("trail_after", 15); trail = p.get("trail", 10)
        wide_after = p.get("wide_after", 40); wide = p.get("wide", 15)
        e, pk = a.entry, a.peak
        stop = e * (1 - initial / 100); kind = "initial"
        if pk >= e * (1 + trail_after / 100):
            stop = max(e, pk * (1 - trail / 100)); kind = "trail"
        if pk >= e * (1 + wide_after / 100):
            stop = pk * (1 - wide / 100); kind = "wide_trail"
        out({"stop": round(stop, 6), "kind": kind, "gain_at_peak_pct": (pk / e - 1) * 100})
    elif a.cmd == "size":
        base = a.equity * a.max_pct / 100
        if a.high_vol:
            base *= 0.5
        avail = a.settled - a.equity * a.reserve_pct / 100 - a.committed
        size = min(base, avail)
        out({"size_usd": round(max(size, 0), 2), "ok": size >= a.min_order, "base_cap": round(base, 2), "available": round(avail, 2)})
    elif a.cmd == "drawdown":
        out({"drawdown_pct": (1 - a.equity / a.peak) * 100 if a.peak else None,
             "day_change_pct": (a.equity / a.day_start - 1) * 100 if a.day_start else None})
    elif a.cmd == "crypto":
        now = datetime.now(timezone.utc)
        rows = []
        for line in open(a.path):
            line = line.strip()
            if not line:
                continue
            r = json.loads(line)
            if a.symbol and r.get("symbol") != a.symbol:
                continue
            ts = datetime.fromisoformat(r["ts"].replace("Z", "+00:00"))
            rows.append((ts, float(r.get("mid") or r.get("price"))))
        rows.sort()
        if not rows:
            out({"error": "no samples"}); return
        last_ts, last = rows[-1]
        def at(hours):
            target = last_ts - timedelta(hours=hours)
            cands = [p for t, p in rows if t <= target]
            return cands[-1] if cands else None
        window = [p for t, p in rows[:-1] if t >= last_ts - timedelta(hours=a.hours)]
        p24, p7d = at(24), at(24 * 7)
        out({"symbol": a.symbol, "last": last, "last_ts": last_ts.isoformat(), "sample_age_min": (now - last_ts).total_seconds() / 60,
             "ret_24h_pct": (last / p24 - 1) * 100 if p24 else None, "ret_7d_pct": (last / p7d - 1) * 100 if p7d else None,
             f"high_{a.hours}h": max(window) if window else None, "samples": len(rows),
             "history_hours": (last_ts - rows[0][0]).total_seconds() / 3600})
    else:
        raise SystemExit("unknown command")


if __name__ == "__main__":
    main()
