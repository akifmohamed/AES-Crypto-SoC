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
