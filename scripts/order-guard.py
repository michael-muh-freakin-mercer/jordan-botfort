#!/usr/bin/env python3
"""PreToolUse hook: last line of defence in front of every order-placing Alpaca MCP tool.

Claude Code runs this before place_stock_order / place_crypto_order (and any other order or account-changing
tool that slips past the deny list). It reads the hook payload on stdin and exits 2 (block, message to the model) when:
  - the tool is not one of the two order tools this agent may use,
  - the run is a first-run or weekly review (TB_RUN_TYPE from scripts/run.sh), which never trade,
  - state/HALT exists (unless state/FLATTEN_CONFIRMED exists for today and the order is a sell),
  - operating_mode is not "paper" or paper_trading_authorized is false,
  - the order is extended-hours, has an order class, stop/trail fields or advanced instructions, or an unknown type,
  - client_order_id is missing or does not match a pending_submit intent for the same symbol and side,
  - it is a crypto buy and crypto.enabled is false,
  - it is a buy and its notional cannot be determined, or exceeds the tier's max single position × 1.05
    of VIRTUAL equity (never the $100k paper balance).
Exit 0 lets the call through. Any failure to read state blocks the order (fail closed).
This is a backstop; the agent's own rules come first. It does not replace them.
"""
import json
import os
import sys
from datetime import date

ROOT = os.environ.get("CLAUDE_PROJECT_DIR") or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
S = lambda *p: os.path.join(ROOT, "state", *p)

ORDER_TOOLS = ("place_stock_order", "place_crypto_order")
# Parameter names that may carry the order size. state/capabilities.json.tool_params
# (keys "notional_keys" / "quantity_keys" / "price_keys") override these after the first run.
NOTIONAL_KEYS = ["notional"]
QUANTITY_KEYS = ["qty"]
PRICE_KEYS = ["limit_price"]
FORBIDDEN_KEYS = ["stop_price", "trail_price", "trail_percent", "take_profit_limit_price",
                  "stop_loss_stop_price", "stop_loss_limit_price", "advanced_instructions", "legs", "position_intent"]


def block(msg):
    sys.stderr.write("ORDER BLOCKED by scripts/order-guard.py: " + msg + "\n")
    sys.exit(2)


def num(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return None


def first(inp, keys):
    for k in keys:
        if inp.get(k) not in (None, ""):
            n = num(inp[k])
            if n is not None:
                return n
    return None


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception as e:  # noqa: BLE001
        block(f"could not read hook payload ({e}); failing closed")
    tool = payload.get("tool_name", "")
    inp = payload.get("tool_input") or {}
    short = tool.rsplit("__", 1)[-1]
    if short not in ORDER_TOOLS:
        block(f"{short} is not an order tool this agent may use (CLAUDE.md §3.12).")

    run_type = os.environ.get("TB_RUN_TYPE", "")
    if run_type in ("first-run", "weekly"):
        block(f"{run_type} runs never place orders.")

    side = str(inp.get("side") or "").lower()
    if side not in ("buy", "sell"):
        block(f"side '{side}' is not buy or sell.")

    today = date.today().isoformat()
    if os.path.exists(S("HALT")):
        ok = False
        try:
            with open(S("FLATTEN_CONFIRMED")) as f:
                ok = today in f.read()
        except OSError:
            ok = False
        if not ok or side != "sell":
            block("state/HALT exists. No orders until Michael runs scripts/resume.sh (flatten allows sells only).")

    try:
        with open(S("authorization.json")) as f:
            auth = json.load(f)
    except Exception as e:  # noqa: BLE001
        block(f"state/authorization.json unreadable ({e}); failing closed")

    if auth.get("operating_mode") != "paper" or auth.get("paper_trading_authorized") is not True:
        block(f"operating_mode is '{auth.get('operating_mode')}' and paper_trading_authorized="
              f"{auth.get('paper_trading_authorized')}. No orders in this mode.")

    # Order shape: simple marketable limit or (guarded) market order, regular hours only.
    if inp.get("extended_hours"):
        block("extended-hours orders are prohibited.")
    if inp.get("order_class") not in (None, "", "simple"):
        block(f"order_class '{inp.get('order_class')}' is prohibited; simple orders only.")
    for k in FORBIDDEN_KEYS:
        if inp.get(k) not in (None, "", [], {}):
            block(f"field '{k}' is prohibited (no stop, trailing, bracket or multi-leg orders).")
    otype = str(inp.get("type") or "market").lower()
    if otype not in ("market", "limit"):
        block(f"order type '{otype}' is prohibited; limit or guarded market only.")

    # Intent first (CLAUDE.md §6.1): client_order_id must be a pending_submit intent for this symbol and side.
    cid = str(inp.get("client_order_id") or "")
    if not cid:
        block("client_order_id is missing; it must be the intent_id written to state/open-intents.json first.")
    try:
        with open(S("open-intents.json")) as f:
            intents = json.load(f)
    except Exception as e:  # noqa: BLE001
        block(f"state/open-intents.json unreadable ({e}); failing closed")
    intent = next((i for i in intents if isinstance(i, dict) and i.get("intent_id") == cid), None)
    if intent is None:
        block(f"no intent with intent_id {cid} in state/open-intents.json.")
    if intent.get("status") != "pending_submit":
        block(f"intent {cid} has status '{intent.get('status')}', not pending_submit; never resubmit an intent.")
    norm = lambda s: str(s or "").upper().replace("/", "").replace("-", "")
    if norm(intent.get("symbol")) != norm(inp.get("symbol")) or str(intent.get("side", "")).lower() != side:
        block(f"intent {cid} is {intent.get('side')} {intent.get('symbol')}, order is {side} {inp.get('symbol')}.")

    # Crypto sleeve switch: buys are blocked unless the owner set crypto.enabled in strategy-params.json.
    if short == "place_crypto_order" and side == "buy":
        try:
            with open(S("strategy-params.json")) as f:
                enabled = json.load(f).get("crypto", {}).get("enabled") is True
        except Exception:  # noqa: BLE001
            enabled = False
        if not enabled:
            block("crypto sleeve is disabled (strategy-params.json crypto.enabled is not true). Sells are still allowed.")

    if side == "sell":
        sys.exit(0)  # the account has no_shorting set; held quantity is checked by the agent (CLAUDE.md §6.4)

    # Size check against VIRTUAL equity. Fail closed for buys.
    try:
        with open(S("capabilities.json")) as f:
            caps = json.load(f).get("tool_params", {})
    except Exception:  # noqa: BLE001
        caps = {}
    nk = caps.get("notional_keys") or NOTIONAL_KEYS
    qk = caps.get("quantity_keys") or QUANTITY_KEYS
    pk = caps.get("price_keys") or PRICE_KEYS

    notional = first(inp, nk)
    if notional is None:
        q, p = first(inp, qk), first(inp, pk)
        if p is None:  # market order by quantity: price it at the intent's recorded quote or limit
            quote = intent.get("quote") or {}
            p = num(quote.get("ask")) or num(intent.get("limit_price"))
        if q is not None and p is not None:
            notional = q * p
    if notional is None or notional <= 0:
        block("could not determine the buy notional from the order or its intent; failing closed.")

    try:
        with open(S("portfolio.json")) as f:
            equity = num(json.load(f).get("equity_usd")) or 0.0
    except Exception:  # noqa: BLE001
        equity = 0.0
    start = num((auth.get("virtual_capital") or {}).get("starting_capital_usd")) or 0.0
    if equity <= 0:
        equity = start
    if equity <= 0:
        block("virtual equity unknown (portfolio.json and virtual_capital both empty); failing closed.")
    range_max = num((auth.get("expected_equity_range_usd") or {}).get("max"))
    if range_max:
        equity = min(equity, range_max)
    max_pct = num(auth.get("position_limits", {}).get("max_position_pct_of_equity")) or 60.0
    cap = equity * max_pct / 100 * 1.05
    if notional > cap:
        block(f"buy notional ${notional:.2f} exceeds the tier cap ${cap:.2f} "
              f"({max_pct}% of virtual equity ${equity:.2f} × 1.05).")
    sys.exit(0)


if __name__ == "__main__":
    main()
