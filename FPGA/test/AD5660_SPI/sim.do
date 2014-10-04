
do load.do

add wave -divider "Clk and reset"
add wave -position insertpoint  \
sim:/AD5660_SPI_tb/clk \
sim:/AD5660_SPI_tb/reset_n

add wave -divider "Input"
add wave -position insertpoint  \
sim:/AD5660_SPI_tb/go


add wave -divider "Internal"
add wave -position insertpoint -radix unsigned  \
sim:/AD5660_SPI_tb/AD5660_SPI_inst/state \
sim:/AD5660_SPI_tb/AD5660_SPI_inst/cntr \
sim:/AD5660_SPI_tb/AD5660_SPI_inst/bits_cntr


add wave -divider "SPI"
add wave -position insertpoint  \
sim:/AD5660_SPI_tb/SS_n \
sim:/AD5660_SPI_tb/SCLK \
sim:/AD5660_SPI_tb/SDO	
