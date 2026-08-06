# ─────────────────────────────────────────
# SDC Timing Constraints for AES SoC
# 50 MHz = 20 ns period
# ─────────────────────────────────────────

# Clock definition
create_clock -name clk -period 20.0 -waveform {0 10} [get_ports clk]

# Clock uncertainty
set_clock_uncertainty -setup 0.2 [get_clocks clk]
set_clock_uncertainty -hold  0.1 [get_clocks clk]

# Input delays - 40% of period before input valid
set_input_delay -clock clk -max 8.0 [all_inputs]
set_input_delay -clock clk -min 1.0 [all_inputs]

# Output delays
set_output_delay -clock clk -max 8.0 [all_outputs]
set_output_delay -clock clk -min 1.0 [all_outputs]

# Drive strength
set_driving_cell -lib_cell BUFX4 [all_inputs]

# Load on outputs
set_load 0.1 [all_outputs]

# False paths - async reset
set_false_path -from [get_ports rst_n]

# Don't touch clock
set_dont_touch_network [get_clocks clk]

# Operating conditions (example for TSMC 180nm)
# set_operating_conditions -library slow -analysis_type on_chip_variation

# Max transition
set_max_transition 1.0 [current_design]

# Max fanout
set_max_fanout 16 [current_design]
