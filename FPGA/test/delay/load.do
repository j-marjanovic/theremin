
if {[file exists work]} {vdel -lib work -all}

vlib work


vlog -sv ../../src/delay.sv
vlog -sv delay_tb.sv

vsim delay_tb
