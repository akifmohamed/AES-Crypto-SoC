# Basys3 FPGA Constraints for AES SoC
# Clock: 100MHz on Basys3 (W5), but we use 50MHz divided
# Adjust per board - using 50MHz clock buffer

## Clock signal (100MHz on Basys3)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Reset - btnC (center button)
set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]
# Active low, so need invert in design or use button logic

## UART pins - Basys3 uses FTDI USB-UART
# USB-RS232 interface
set_property PACKAGE_PIN A18 [get_ports uart_tx_pin]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_pin]
set_property PACKAGE_PIN B18 [get_ports uart_rx_pin]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_pin]

## LEDs for status
## LEDs - data on LD0..LD7, status on LD13..LD15
# led_data[7:0] -> LD0..LD7
set_property PACKAGE_PIN U16 [get_ports led_data[0]]
set_property IOSTANDARD LVCMOS33 [get_ports led_data[0]]
set_property PACKAGE_PIN E19 [get_ports led_data[1]]
set_property IOSTANDARD LVCMOS33 [get_ports led_data[1]]
set_property PACKAGE_PIN U19 [get_ports led_data[2]]
set_property IOSTANDARD LVCMOS33 [get_ports led_data[2]]
set_property PACKAGE_PIN V19 [get_ports led_data[3]]
set_property IOSTANDARD LVCMOS33 [get_ports led_data[3]]
set_property PACKAGE_PIN W18 [get_ports led_data[4]]
set_property IOSTANDARD LVCMOS33 [get_ports led_data[4]]
set_property PACKAGE_PIN U15 [get_ports led_data[5]]
set_property IOSTANDARD LVCMOS33 [get_ports led_data[5]]
set_property PACKAGE_PIN U14 [get_ports led_data[6]]
set_property IOSTANDARD LVCMOS33 [get_ports led_data[6]]
set_property PACKAGE_PIN V14 [get_ports led_data[7]]
set_property IOSTANDARD LVCMOS33 [get_ports led_data[7]]

# status LEDs -> LD13, LD14, LD15
set_property PACKAGE_PIN N3  [get_ports led_busy]
set_property IOSTANDARD LVCMOS33 [get_ports led_busy]
set_property PACKAGE_PIN L1  [get_ports led_done]
set_property IOSTANDARD LVCMOS33 [get_ports led_done]
set_property PACKAGE_PIN P1  [get_ports led_error]
set_property IOSTANDARD LVCMOS33 [get_ports led_error]

## Clock divider to get 50MHz from 100MHz - if using on-chip divider, comment out and use MMCM


