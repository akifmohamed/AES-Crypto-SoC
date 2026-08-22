#!/usr/bin/env bash
# dft_report.sh - extract signoff metrics from an OpenLane 2 run directory
# Usage: bash dft_report.sh ~/aes-crypto-soc/pnr/runs/scan_v2_0822f
RUN="${1:?usage: bash dft_report.sh <run-dir>}"
S=$(find "$RUN" -name "state_out.json" 2>/dev/null | sort | tail -1)
if [ -z "$S" ]; then
    echo "no state_out.json found under $RUN"
    exit 1
fi
echo "=== metrics from: $S ==="
python3 - "$S" <<'PY'
import json, sys
m = json.load(open(sys.argv[1])).get("metrics", {})
want = ("area", "util", "slack", "drc", "antenna", "lvs", "wire",
        "drop", "instance__count", "clocks", "timing")
for k in sorted(m):
    if any(w in k for w in want):
        print(f"{k} = {m[k]}")
PY
echo
echo "=== GDS files ==="
find "$RUN" -name "*.gds" 2>/dev/null
echo
echo "=== AES_DFT lines ==="
grep -rh "AES_DFT" "$RUN" 2>/dev/null | grep -v '"' | head -12
