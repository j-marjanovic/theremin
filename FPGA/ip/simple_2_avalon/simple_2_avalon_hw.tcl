# TCL File Generated by Component Editor 14.0
# Sat Oct 11 15:07:55 CEST 2014
# DO NOT MODIFY


# 
# simple_2_avalon "simple 2 Avalon" v1.0
# Jan Marjanovic 2014.10.11.15:07:55
# 
# 

# 
# request TCL package from ACDS 14.0
# 
package require -exact qsys 13.1


# 
# module simple_2_avalon
# 
set_module_property DESCRIPTION ""
set_module_property NAME simple_2_avalon
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP Interfaces
set_module_property AUTHOR "Jan Marjanovic"
set_module_property DISPLAY_NAME "simple 2 Avalon"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL simple_2_avalon
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file simple_2_avalon.sv SYSTEM_VERILOG PATH simple_2_avalon.sv TOP_LEVEL_FILE

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL simple_2_avalon
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VERILOG ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file simple_2_avalon.sv SYSTEM_VERILOG PATH simple_2_avalon.sv


# 
# parameters
# 
add_parameter ADDR_W INTEGER 19
set_parameter_property ADDR_W DEFAULT_VALUE 19
set_parameter_property ADDR_W DISPLAY_NAME ADDR_W
set_parameter_property ADDR_W TYPE INTEGER
set_parameter_property ADDR_W UNITS None
set_parameter_property ADDR_W ALLOWED_RANGES -2147483648:2147483647
set_parameter_property ADDR_W HDL_PARAMETER true


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_n reset_n Input 1


# 
# connection point master
# 
add_interface master avalon start
set_interface_property master addressUnits SYMBOLS
set_interface_property master associatedClock clock
set_interface_property master associatedReset reset
set_interface_property master bitsPerSymbol 8
set_interface_property master burstOnBurstBoundariesOnly false
set_interface_property master burstcountUnits WORDS
set_interface_property master doStreamReads false
set_interface_property master doStreamWrites false
set_interface_property master holdTime 0
set_interface_property master linewrapBursts false
set_interface_property master maximumPendingReadTransactions 0
set_interface_property master maximumPendingWriteTransactions 0
set_interface_property master readLatency 0
set_interface_property master readWaitTime 1
set_interface_property master setupTime 0
set_interface_property master timingUnits Cycles
set_interface_property master writeWaitTime 0
set_interface_property master ENABLED true
set_interface_property master EXPORT_OF ""
set_interface_property master PORT_NAME_MAP ""
set_interface_property master CMSIS_SVD_VARIABLES ""
set_interface_property master SVD_ADDRESS_GROUP ""

add_interface_port master avm_master_address address Output ADDR_W
add_interface_port master avm_master_read read Output 1
add_interface_port master avm_master_readdata readdata Input 32
add_interface_port master avm_master_write write Output 1
add_interface_port master avm_master_writedata writedata Output 32
add_interface_port master avm_master_readdatavalid readdatavalid Input 1
add_interface_port master avm_master_waitrequest waitrequest Input 1


# 
# connection point conduit_end_0
# 
add_interface conduit_end_0 conduit end
set_interface_property conduit_end_0 associatedClock clock
set_interface_property conduit_end_0 associatedReset reset
set_interface_property conduit_end_0 ENABLED true
set_interface_property conduit_end_0 EXPORT_OF ""
set_interface_property conduit_end_0 PORT_NAME_MAP ""
set_interface_property conduit_end_0 CMSIS_SVD_VARIABLES ""
set_interface_property conduit_end_0 SVD_ADDRESS_GROUP ""

add_interface_port conduit_end_0 coe_simple_write export Input 1
add_interface_port conduit_end_0 coe_simple_writedata export Input 32
add_interface_port conduit_end_0 coe_simple_writeaddr export Input "(ADDR_W-3) - (0) + 1"
add_interface_port conduit_end_0 coe_simple_read export Input 1
add_interface_port conduit_end_0 coe_simple_readdata export Output 32
add_interface_port conduit_end_0 coe_simple_readaddr export Input "(ADDR_W-3) - (0) + 1"
add_interface_port conduit_end_0 coe_simple_readdone export Output 1
