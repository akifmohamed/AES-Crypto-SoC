# OpenSTA Timing Script for AES SoC
# Usage: sta timing/sta.tcl (from project root)
# You used this in PipeCore-GDS Phase 4

read_liberty timing/sky130.lib
read_verilog synth/netlist/aes_soc_synth.v
link_design aes_soc

read_sdc timing/constraints.sdc

# Setup checks
puts "=== Setup Timing (Max) ==="
report_checks -path_delay max -fields {capacitance slew input_pins} -digits 4 > timing/reports/setup_report.txt
report_checks -path_delay max -fields {capacitance slew input_pins} -digits 4

# Hold checks
puts "=== Hold Timing (Min) ==="
report_checks -path_delay min -fields {capacitance slew input_pins} -digits 4 > timing/reports/hold_report.txt
report_checks -path_delay min -fields {capacitance slew input_pins} -digits 4

# WNS/TNS
puts "=== Calculating Slack ==="
report_worst_slack -max
report_worst_slack -min
report_tns

# Clock skew (pre-CTS will be 0)
puts "=== Clock Skew (pre-CTS ideal) ==="
report_clock_skew

# Critical path detail
# report_checks already includes path

puts "STA complete. Reports in timing/reports/"
