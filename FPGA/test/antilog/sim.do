
do load.do

add wave -divider "Clk and reset"
add wave -position insertpoint  \
sim:/antilog_tb/clk \
sim:/antilog_tb/reset_n

add wave -divider "Input"
add wave -position insertpoint -radix unsigned \
sim:/antilog_tb/in_data \
sim:/antilog_tb/in_valid

add wave -divider "Output"
add wave -position insertpoint -radix unsigned \
sim:/antilog_tb/out_data \
sim:/antilog_tb/out_valid


run -all
