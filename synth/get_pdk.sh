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
