# SDC for OpenSTA - AES SoC @50MHz
# For 50MHz: period 20ns, but we can also try 10ns during exploration
# Previous PipeCore used 10ns (100MHz). AES is larger, so 20ns safer.
# Start with 20ns, then tighten to check max freq.

create_clock -name clk -period 20.0 [get_ports clk]
set_clock_uncertainty 0.5 [get_clocks clk]

# Input/output delays - 40% rule like before
set_input_delay 8.0 -clock [get_clocks clk] [all_inputs]
set_output_delay 8.0 -clock [get_clocks clk] [all_outputs]

# False path for async reset (same as PipeCore fix)
set_false_path -from [get_ports rst_n]

# Hold fixing hint for PnR (you already learned this in Phase 4)
set_fix_hold [all_clocks]

# Driving cell and load (optional, for realistic STA)
# set_driving_cell -lib_cell sky130_fd_sc_hd__inv_2 [all_inputs]
# set_load 0.1 [all_outputs]
