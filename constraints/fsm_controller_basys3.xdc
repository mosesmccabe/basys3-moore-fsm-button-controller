## FPGA configuration voltage
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## 100 MHz clock
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports clk]

## Center button: synchronous reset
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports rst]

## Right button: START
set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports start_button_async]

## Up button: FINISHED
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports finished_button_async]

## Left button: CLEAR
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports clear_button_async]

## Status LEDs
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports busy]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports done]
