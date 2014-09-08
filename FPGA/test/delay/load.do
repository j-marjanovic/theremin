
if {[file exists work]} {vdel -lib work -all}

vlib work


vlog -sv ../../src/mixer.sv
vlog -sv ../../delay_mem/delay_mem.v
vlog -sv ../../src/delay.sv
vlog -sv delay_tb.sv

vsim -L altera_mf_ver delay_tb
