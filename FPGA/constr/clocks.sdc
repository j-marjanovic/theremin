


create_clock -name clk_50 -period 20.000 [get_ports {CLK_50}]
create_generated_clock -name clk_100 -source {pll_100_inst|altpll_component|auto_generated|pll1|inclk[0]} -divide_by 1 -multiply_by 2 -duty_cycle 50.00 { pll_100_inst|altpll_component|auto_generated|pll1|clk[0] }
derive_clock_uncertainty

#derive_pll_clocks


set_output_delay -clock clk_100 -max 0.1 [get_ports ANT_OUT]
set_output_delay -clock clk_100 -min -0.1 [get_ports ANT_OUT]