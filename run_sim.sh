#!/bin/bash
# Run all three verified testbenches with Icarus Verilog
# v2 (22 Aug 2026): uses the fixed/verified testbenches.
set -e
echo "=== [1/3] AES core: 4 known-answer vectors ==="
iverilog -g2012 -o /tmp/aes_core_v2 rtl/crypto/*.v tb/tb_aes_core_v2.v
vvp /tmp/aes_core_v2 | tee reports/sim_core.log
echo "=== [2/3] SoC level: NIST TV1 over UART ==="
iverilog -g2012 -o /tmp/aes_soc_v2 rtl/crypto/*.v rtl/peripheral/*.v rtl/top/*.v tb/tb_aes_soc_v2_1.v
vvp /tmp/aes_soc_v2 | tee reports/sim_soc.log
echo "=== [3/3] MBIST: March C- with fault injection ==="
iverilog -g2012 -o /tmp/aes_mbist rtl/mbist_ctrl.v rtl/ram_wrapper.v rtl/ram_256x8.v tb/tb_mbist.v
vvp /tmp/aes_mbist | tee reports/sim_mbist.log
echo "All three testbenches completed. Expect PASS lines in each log (reports/)."
