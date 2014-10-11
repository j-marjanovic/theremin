

add wave -divider "Clk and reset"
add wave -position insertpoint  \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/clk_clk \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/reset_reset_n

add wave -divider "Internal states"
add wave -position insertpoint  \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/simple_2_avalon/state_read \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/simple_2_avalon/state_write
add wave -position insertpoint  \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/simple_2_avalon/wr_do \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/simple_2_avalon/rd_do

add wave -divider "S2A Avalon MM"
add wave -position insertpoint -radix hex \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/simple_2_avalon/avm_master_*

add wave -divider "S2A Conduit"
add wave -position insertpoint -radix hex \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/simple_2_avalon/coe_simple_*

add wave -divider "Memory"
add wave -position insertpoint  \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_my_partner/zs_dq \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_my_partner/zs_addr \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_my_partner/zs_ba \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_my_partner/zs_cas_n \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_my_partner/zs_cke \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_my_partner/zs_cs_n \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_my_partner/zs_dqm \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_my_partner/zs_ras_n \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_my_partner/zs_we_n

add wave -position insertpoint  \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/mem/az_addr \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/mem/az_be_n \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/mem/az_cs \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/mem/az_data \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/mem/az_rd_n \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/mem/az_wr_n \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/mem/clk \
sim:/mem_qsys_top/mem_controller_tb_inst/mem_controller_inst/mem/reset_n
