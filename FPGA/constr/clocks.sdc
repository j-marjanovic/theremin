


create_clock -name clk_50 -period 20.000 [get_ports {CLK_50}]

derive_clock_uncertainty

derive_pll_clocks
