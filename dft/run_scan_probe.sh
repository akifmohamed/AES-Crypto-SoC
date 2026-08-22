#!/usr/bin/env bash
# run_scan_probe.sh - drive scan_probe.tcl with the right files
# Run this INSIDE the environment that has `openroad` on PATH (your OpenLane 2
# nix env / venv). Adjust the two path variables if your layout differs.
#
#   chmod +x dft/run_scan_probe.sh
#   ./dft/run_scan_probe.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# --- 1. Locate a synthesized netlist (newest first) ---------------------------
# OL2 run dirs look like: pnr/runs/RUN_*/??_yosys-synthesis/aes_soc.nl.v
CANDIDATES=$(find "$REPO_ROOT/pnr/runs" -name '*.nl.v' -o -name '1_synth.v' 2>/dev/null | head -20)
if [ -z "$CANDIDATES" ]; then
    echo "ERROR: no synthesized netlist found under pnr/runs/"
    echo "Re-run synthesis once (or point DFT_NETLIST at an existing netlist)."
    exit 1
fi
NETLIST=$(ls -t $CANDIDATES | head -1)
echo "Using netlist: $NETLIST"

# --- 2. Locate sky130 hd liberty (single tt corner is enough) -----------------
if [ -z "${PDK_ROOT:-}" ]; then
    echo "ERROR: PDK_ROOT not set - enter your OpenLane/PDK environment first."
    exit 1
fi
LIB=$(find "$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/lib" \
      -name 'sky130_fd_sc_hd__tt_025C_1v80.lib' | head -1)
if [ -z "$LIB" ]; then
    echo "ERROR: sky130_fd_sc_hd__tt_025C_1v80.lib not found under $PDK_ROOT"
    exit 1
fi
echo "Using liberty: $LIB"

# --- 3. Run --------------------------------------------------------------------
export DFT_NETLIST="$NETLIST"
export DFT_LIBS="$LIB"
export DFT_OUTDIR="$REPO_ROOT/dft/probe_out"
export DFT_MAXLEN="${DFT_MAXLEN:-800}"

command -v openroad >/dev/null || { echo "ERROR: openroad not on PATH"; exit 1; }
openroad -version
openroad -exit "$REPO_ROOT/dft/scan_probe.tcl" 2>&1 | tee "$DFT_OUTDIR.log" || {
    echo "NOTE: if the failure is 'invalid command name set_dft_config', your"
    echo "openroad build predates the dft module rename (preview_dft/insert_dft"
    echo "era) - tell the agent, we adapt the script."
    exit 1; }
echo "Probe finished - see dft/probe_out/ and dft/probe_out.log"
