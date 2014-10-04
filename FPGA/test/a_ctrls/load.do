

if { [file exist work] } { vdel -lib work -all}

vlib work

vlog 	 ../../src/a_ctrls/baud_gen.v
vlog     ../../src/a_ctrls/uart_rx.v
vlog     ../../src/a_ctrls/a_ctrls_decode.sv
vlog -sv ../../src/a_ctrls/a_ctrls.sv
vlog -sv uart_tx_nonsynth.sv
vlog -sv a_ctrls_tb.sv

vsim work.a_ctrls_tb
