# Static Timing Analysis Script (OpenSTA 2.0.17) for AES SoC
read_liberty synth/sky130.lib
read_verilog synth/netlist/aes_soc_synth.v
link_design aes_soc

read_sdc timing/constraints.sdc

# Report setup timing (max delay)
report_checks -path_delay max -format full_clock_expanded -fields {slew cap input nets pin} -digits 4 > timing/reports/setup_report.txt

# Report hold timing (min delay - pre-CTS negative slack is normal, fixed during PNR CTS)
report_checks -path_delay min -format full_clock_expanded -fields {slew cap input nets pin} -digits 4 > timing/reports/hold_report.txt

# Report worst slack summary
report_worst_slack -max
report_worst_slack -min

# Report design area and cell count summary
report_design_area
