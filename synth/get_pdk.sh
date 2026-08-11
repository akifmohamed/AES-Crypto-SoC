#!/usr/bin/env bash
# Helper script to copy or download Sky130 standard cell liberty file (sky130_fd_sc_hd__tt_025C_1v80.lib)
set -e

if [ -f "synth/sky130.lib" ]; then
    echo "[OK] synth/sky130.lib already exists."
    exit 0
fi

if [ -f "$HOME/PipeCore-GDS/synth/sky130.lib" ]; then
    echo "[INFO] Copying sky130.lib from PipeCore-GDS project..."
    cp "$HOME/PipeCore-GDS/synth/sky130.lib" "synth/sky130.lib"
    echo "[SUCCESS] Copied sky130.lib successfully."
    exit 0
fi

echo "[INFO] Downloading sky130_fd_sc_hd__tt_025C_1v80.lib from OpenROAD/SkyWater repository..."
wget -O synth/sky130.lib "https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/master/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
echo "[SUCCESS] Downloaded sky130.lib successfully."
