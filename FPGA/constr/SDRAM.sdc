

create_generated_clock -name "sdram_clk_pin" -source [get_pins {mem_controller_inst|altpll_0|sd1|pll7|clk[0]}] [get_ports {DRAM_CLK}]

set trace_delay 	0.0
set data_out_hold 	2.5
set data_out_setup	5.5
set input_setup		2

# This should be -1
set input_hold		-0.2

set_input_delay -clock "sdram_clk_pin" -min [expr $trace_delay + $data_out_setup] [get_ports DRAM_DATA*]  
set_input_delay -clock "sdram_clk_pin" -max [expr $trace_delay + $data_out_hold] [get_ports DRAM_DATA*]  

set_output_delay -clock "sdram_clk_pin" -max [expr $input_setup] [get_ports {DRAM_DATA* DRAM_CKE DRAM_ADDR* DRAM_UDQM DRAM_LDQM DRAM_RASn DRAM_CASn DRAM_WEn DRAM_CSn}]
set_output_delay -clock "sdram_clk_pin" -min [expr $input_hold] [get_ports {DRAM_DATA* DRAM_CKE DRAM_ADDR* DRAM_UDQM DRAM_LDQM DRAM_RASn DRAM_CASn DRAM_WEn DRAM_CSn}]

