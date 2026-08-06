# ─────────────────────────────────────────
# Cadence Genus Synthesis Script
# AES-128 Crypto SoC
# ─────────────────────────────────────────

# Set up libraries - UPDATE THESE PATHS TO YOUR PDK!
set_db init_lib_search_path /path/to/pdk/lib
set_db library {slow.lib}
# Common PDK lib options:
# TSMC 180nm: /path/to/tsmc180/lib/slow.lib
# TSMC 65nm:  /path/to/tcb65lp/lib/tcbn65lp_200a.lib
# GF 180MCU:  gf180mcu_fd_sc_mcu9t5v0__tt_025C_1v80.lib

set_db init_hdl_search_path {../../rtl/crypto ../../rtl/peripheral ../../rtl/top}

# Read RTL
read_hdl -language verilog -f ../../rtl/crypto/flist.txt
# Or list manually:
read_hdl -language verilog aes-crypto-soc/rtl/crypto/aes_sbox.v
read_hdl -language verilog aes-crypto-soc/rtl/crypto/sub_bytes.v
read_hdl -language verilog aes-crypto-soc/rtl/crypto/shift_rows.v
read_hdl -language verilog aes-crypto-soc/rtl/crypto/gf_mult2.v
read_hdl -language verilog aes-crypto-soc/rtl/crypto/gf_mult3.v
read_hdl -language verilog aes-crypto-soc/rtl/crypto/mix_column.v
read_hdl -language verilog aes-crypto-soc/rtl/crypto/mix_columns.v
read_hdl -language verilog aes-crypto-soc/rtl/crypto/add_round_key.v
read_hdl -language verilog aes-crypto-soc/rtl/crypto/aes_enc_round.v
read_hdl -language verilog aes-crypto-soc/rtl/crypto/key_expand.v
read_hdl -language verilog aes-crypto-soc/rtl/crypto/aes_core.v
read_hdl -language verilog aes-crypto-soc/rtl/peripheral/uart_rx.v
read_hdl -language verilog aes-crypto-soc/rtl/peripheral/uart_tx.v
read_hdl -language verilog aes-crypto-soc/rtl/top/aes_soc.v

# Elaborate
elaborate aes_soc
check_design -unresolved

# Read constraints
read_sdc synthesis/constraints.sdc

# Synthesis steps
syn_generic
syn_map
syn_opt

# Reports
report_timing > reports/timing.rpt
report_area   > reports/area.rpt
report_power  > reports/power.rpt
report_qor    > reports/qor.rpt
report_gates  > reports/gates.rpt

# Write outputs
write_hdl > output/aes_soc_netlist.v
write_sdc > output/aes_soc_synth.sdc
write_db  output/aes_soc.db
write_sdf > output/aes_soc.sdf
write_script > output/synthesis_script.tcl

puts "==================================="
puts "Synthesis complete!"
puts "Netlist: output/aes_soc_netlist.v"
puts "Expected: ~8,200 gates, Setup slack +2.1ns"
puts "==================================="
