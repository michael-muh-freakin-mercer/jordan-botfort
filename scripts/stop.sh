#!/usr/bin/env bash
# Emergency stop. Creates state/HALT so scheduled runs skip and the order guard blocks every order.
# Usage: scripts/stop.sh ["reason"]            -> halt only (positions stay as they are)
#        scripts/stop.sh --flatten ["reason"]  -> halt, then run the flatten procedure (sells everything the agent holds)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
FLATTEN=0
if [[ "${1:-}" == "--flatten" ]]; then FLATTEN=1; shift; fi
REASON="${*:-manual stop by Michael}"
printf 'HALTED %s by Michael: %s\n' "$(date -u +%FT%TZ)" "$REASON" > state/HALT
echo "state/HALT written. Scheduled runs will skip. Order tools are blocked."
git add state/HALT >/dev/null 2>&1 && git commit -q -m "halt: $REASON" || true
if [[ $FLATTEN -eq 1 ]]; then
  date +%F > state/FLATTEN_CONFIRMED
  echo "Running emergency flatten (this places real sell orders in live mode)..."
  scripts/run.sh flatten
fi
