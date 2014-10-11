

set QSYS_SIMDIR ../../mem_controller/testbench/
set TOP_LEVEL_NAME mem_qsys_top

do ../../mem_controller/testbench/mentor/msim_setup.tcl

# Compile 
com

# Load top module and test program
vlog -sv ./mem_qsys_top.sv -L altera_common_sv_packages
vlog -sv ./mem_qsys_program.sv -L altera_common_sv_packages

# Simulate top level module
elab

# Add waveforms
do waveform.do



