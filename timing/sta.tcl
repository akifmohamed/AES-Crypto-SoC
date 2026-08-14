read_liberty synth/sky130.lib
read_verilog synth/netlist/aes_soc_synth.v
link_design aes_soc
read_sdc timing/constraints.sdc

report_checks -path_delay max -format full_clock_expanded -fields {slew cap input nets pin} -digits 4 > timing/reports/setup_report.txt
report_checks -path_delay min -format full_clock_expanded -fields {slew cap input nets pin} -digits 4 > timing/reports/hold_report.txt

puts ""
puts "=== SETUP WORST PATH SUMMARY (MAX DELAY) ==="
report_checks -path_delay max -digits 4

puts ""
puts "=== HOLD WORST PATH SUMMARY (MIN DELAY) ==="
report_checks -path_delay min -digits 4
