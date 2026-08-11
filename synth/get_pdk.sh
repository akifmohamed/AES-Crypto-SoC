<<<<<<< HEAD
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
=======
#!/bin/bash
# Download Sky130 liberty - Reuse from PipeCore-GDS if you have it
# You already did this in previous project

# Option 1: Copy from PipeCore-GDS if you still have it
# cp ~/PipeCore-GDS/synth/sky130.lib ./synth/

# Option 2: Download fresh
echo "Downloading Sky130 lib..."
wget -O synth/sky130.lib https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/master/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Also download for OpenSTA if needed
mkdir -p timing
if [ ! -f timing/sky130.lib ]; then
  cp synth/sky130.lib timing/sky130.lib
fi

echo "Lib downloaded: $(wc -l synth/sky130.lib | awk '{print $1}') lines"
ls -lh synth/sky130.lib
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
