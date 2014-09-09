
if { [file exists work] } {vdel -lib work -all}


vlib work

vlog -sv ../../src/AD5660_SPI.sv
vlog -sv AD5660_SPI_tb.sv

vsim AD5660_SPI_tb
