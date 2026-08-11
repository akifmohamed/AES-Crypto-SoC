<<<<<<< HEAD
# SDC Constraints for AES-128 Crypto Accelerator SoC
# Clock: 50 MHz (Period = 20.0 ns) vs PipeCore 100 MHz (10.0 ns)
# Low power IoT target & clean timing closure

create_clock -name clk -period 20.00 [get_ports clk]

# Clock transition / uncertainty
set_clock_transition 0.15 [get_clocks clk]
set_clock_uncertainty 0.25 [get_clocks clk]

# Input delays (UART RX pin and Reset)
set_input_delay -clock [get_clocks clk] -max 2.00 [get_ports uart_rx_pin]
set_input_delay -clock [get_clocks clk] -min 0.50 [get_ports uart_rx_pin]
set_input_delay -clock [get_clocks clk] -max 1.00 [get_ports rst_n]
set_input_delay -clock [get_clocks clk] -min 0.20 [get_ports rst_n]

# Output delays (UART TX pin and LEDs)
set_output_delay -clock [get_clocks clk] -max 2.00 [get_ports uart_tx_pin]
set_output_delay -clock [get_clocks clk] -min 0.50 [get_ports uart_tx_pin]
set_output_delay -clock [get_clocks clk] -max 2.00 [get_ports led_*]
set_output_delay -clock [get_clocks clk] -min 0.50 [get_ports led_*]

# Output load capacitance (pF)
set_load 0.05 [all_outputs]

# Fix hold constraints for PNR clock tree
set_fix_hold [get_clocks clk]
=======
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
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
