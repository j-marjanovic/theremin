

do load.do

add wave -divider "Clk and reset"
add wave -position insertpoint  \
sim:/a_ctrls_tb/clk \
sim:/a_ctrls_tb/reset_n


add wave -divider "UART"
add wave -position insertpoint sim:/a_ctrls_tb/CTRL_RX
add wave -position insertpoint -radix ASCII sim:/a_ctrls_tb/a_ctrls_inst/uart_rx_inst/rx_data


add wave -divider "Top"
add wave -position insertpoint -radix hex \
sim:/a_ctrls_tb/a_ctrls_inst/a8 \
sim:/a_ctrls_tb/a_ctrls_inst/a5 \
sim:/a_ctrls_tb/a_ctrls_inst/a4 \
sim:/a_ctrls_tb/a_ctrls_inst/blend \
sim:/a_ctrls_tb/a_ctrls_inst/delay \
sim:/a_ctrls_tb/a_ctrls_inst/feedbk \
sim:/a_ctrls_tb/a_ctrls_inst/gain


add wave -divider "Decoder"
add wave -position insertpoint sim:/a_ctrls_tb/a_ctrls_inst/a_ctrls_decode_inst/state
add wave -position insertpoint sim:/a_ctrls_tb/a_ctrls_inst/a_ctrls_decode_inst/byte_cntr
add wave -position insertpoint -expand -radix hex sim:/a_ctrls_tb/a_ctrls_inst/a_ctrls_decode_inst/values
