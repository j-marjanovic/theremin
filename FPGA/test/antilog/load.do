
if {[file exists work]} {vdel -lib work -all}

vlib work

vlog -sv ../../src/antilog.sv
vlog -sv antilog_tb.sv

vsim antilog_tb
