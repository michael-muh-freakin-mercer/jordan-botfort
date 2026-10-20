#!/usr/bin/env bash
# Lifts an emergency stop. The next scheduled run starts with a full reconcile (CLAUDE.md §8).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
if [[ ! -f state/HALT ]]; then echo "not halted"; exit 0; fi
echo "Current halt: $(cat state/HALT)"
if [[ -f state/ATTENTION.md ]]; then echo; echo "Open attention items:"; cat state/ATTENTION.md; echo; fi
read -r -p "Remove state/HALT and resume scheduled runs? [y/N] " ans
[[ "$ans" == "y" || "$ans" == "Y" ]] || { echo "unchanged"; exit 0; }
rm -f state/HALT state/FLATTEN_CONFIRMED
git add -A >/dev/null 2>&1 && git commit -q -m "resume: halt lifted by Michael $(date -u +%FT%TZ)" || true
echo "Resumed. Next run reconciles before trading."
