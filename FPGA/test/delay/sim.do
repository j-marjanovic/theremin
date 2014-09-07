
do load.do

add wave -divider "Clk and reset"
add wave -position insertpoint  \
sim:/delay_tb/clk \
sim:/delay_tb/reset_n
