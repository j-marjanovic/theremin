
do load.do

add wave -divider "Clk and reset"
add wave -position insertpoint  \
sim:/delay_tb/clk \
sim:/delay_tb/reset_n \
sim:/delay_tb/delay_inst/smp_en

add wave -divider "Controls"
add wave -position insertpoint -radix hex \
sim:/delay_tb/delay_inst/delay

add wave -divider "Addresses"
add wave -position insertpoint -radix hex  \
sim:/delay_tb/delay_inst/rd_addr \
sim:/delay_tb/delay_inst/wr_addr
