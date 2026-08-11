#!/bin/bash
# Run simulation with Icarus Verilog (free alternative to Xcelium)
# For Cadence Xcelium: see cadence/simulation/sim.tcl

set -e
echo "=== AES SoC Simulation ==="

# Compile and run AES core TB
iverilog -g2012 -o /tmp/aes_core_sim \
    rtl/crypto/*.v \
    tb/tb_aes_core.v

vvp /tmp/aes_core_sim | tee reports/sim_core.log

echo ""
echo "=== SoC Level Simulation ==="
iverilog -g2012 -o /tmp/aes_soc_sim \
    rtl/crypto/*.v \
    rtl/peripheral/*.v \
    rtl/top/*.v \
    tb/tb_aes_soc.v

vvp /tmp/aes_soc_sim | tee reports/sim_soc.log

echo "Waves: aes_sim.vcd, aes_soc.vcd - open with gtkwave"
