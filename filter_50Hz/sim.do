
if {[file exists work]} {vdel -lib work -all}

vlib work

vlog -sv filter.sv
vlog -sv filter_tb.sv


vsim work.filter_tb

add wave -divider "Clk and reset"
add wave sim:/filter_tb/clk sim:/filter_tb/reset_n

add wave -divider "Input"
add wave -radix hex sim:/filter_tb/in_data sim:/filter_tb/in_valid 

add wave -divider "Output"
add wave -radix hex sim:/filter_tb/out_data sim:/filter_tb/out_valid


add wave -divider "Internal"
add wave sim:/filter_tb/filter_inst/state

add wave -radix hex  \
sim:/filter_tb/filter_inst/y \
sim:/filter_tb/filter_inst/x \
sim:/filter_tb/filter_inst/acc \
sim:/filter_tb/filter_inst/mult \
sim:/filter_tb/filter_inst/cntr
