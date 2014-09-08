
if {[file exists work]} {vdel -lib work -all}

vlib work


vlog -sv ../../src/mixer.sv

vsim mixer_tb



add wave -position insertpoint -radix unsigned \
sim:/mixer_tb/a \
sim:/mixer_tb/b \
sim:/mixer_tb/mix \
sim:/mixer_tb/out


run 5

