#!/usr/bin/env bash
# power_report.sh - post-layout power ANALYSIS (not measurement) via OpenSTA
# Usage:  cd ~/aes-crypto-soc/pnr && bash dft/power_report.sh runs/scan_v2_0822f
set -euo pipefail
RUN="${1:-runs/scan_v2_0822f}"
SCL=/home/akif/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd
OR=$(find /nix/store -maxdepth 1 -type d -name '*openroad-*' | head -1)/bin/openroad

DEF=$(find "$RUN" -name "*.def" ! -name "*master*" | tail -1)
SPEF=$(find "$RUN" -name "*.spef" | grep -i "nom" | tail -1 || true)
[ -z "$SPEF" ] && SPEF=$(find "$RUN" -name "*.spef" | tail -1)
[ -n "$DEF" ] || { echo "ERROR: no DEF found in $RUN"; exit 1; }
[ -n "$SPEF" ] || { echo "ERROR: no SPEF found in $RUN"; exit 1; }

export PLIB_TT=$SCL/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
export PLIB_SS=$SCL/lib/sky130_fd_sc_hd__ss_100C_1v60.lib
export PLIB_FF=$SCL/lib/sky130_fd_sc_hd__ff_n40C_1v95.lib
export PTEF=$SCL/techlef/sky130_fd_sc_hd__nom.tlef
export PLEF1=$SCL/lef/sky130_fd_sc_hd.lef
export PLEF2=$SCL/lef/sky130_ef_sc_hd.lef
export PDEF=$DEF
export PSPEF=$SPEF

echo "DEF : $DEF"
echo "SPEF: $SPEF"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$OR" -exit "$SCRIPT_DIR/power_report.tcl" 2>&1 | tee power_report_out.log
echo "Saved to power_report_out.log"
