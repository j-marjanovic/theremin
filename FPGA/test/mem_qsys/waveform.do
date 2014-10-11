

add wave -divider "Clk and reset"
add wave -position insertpoint  \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/clk_clk \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/reset_reset_n

add wave -divider "Internal states"
add wave -position insertpoint  \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/simple_2_avalon/state_read \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/simple_2_avalon/state_write

add wave -divider "S2A Avalon MM"
add wave -position insertpoint -radix hex \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/simple_2_avalon/avm_master_*

add wave -divider "S2A Conduit"
add wave -position insertpoint -radix hex \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/simple_2_avalon/coe_simple_*
