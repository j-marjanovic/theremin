


source progress_bar.tcl

# Mem size in bytes
set MEM_SIZE  	[ expr 2*1024*1024 ]
set MEM_OFFSET	[ expr 0 ]
puts "Mem size: $MEM_SIZE"
puts "Mem offset $MEM_OFFSET"

set mm [lindex [get_service_paths master] 0]

open_service master $mm

###############################################################################
# Erase memory
puts "\n\nErasing memory"
put_top_line
for {set i 0} {$i < [expr $MEM_SIZE/4]} {incr i} {
	master_write_32 $mm [expr $i *4 + $MEM_OFFSET] 0
	put_filler $i [expr $MEM_SIZE/4]
	#progres $i [expr $MEM_SIZE/4]
	#puts -nonewline "."
	#puts "$i of [expr $MEM_SIZE/4]"
}

###############################################################################
# Check if really empty
puts "\n\nChecking if memory erased"
put_top_line
for {set i 0} {$i < [expr $MEM_SIZE/4]} {incr i} {
	set readback [master_read_32 $mm [expr $i * 4 + $MEM_OFFSET] 1]
	if { $readback != 0 } { 
		puts "ERROR, at [expr $i * 4], should be zero, got $readback instead" 
		exit 0
	}
	put_filler $i [expr $MEM_SIZE/4]
}

###############################################################################
# Write address to each word
puts "\n\nWriting to memory"
put_top_line
for {set i 0} {$i < [expr $MEM_SIZE/4]} {incr i} {
	master_write_32 $mm [expr $i * 4 + $MEM_OFFSET] [expr $i * 4 + $MEM_OFFSET]
	#puts -nonewline "."
	#puts "$i of [expr $MEM_SIZE/4]"
	put_filler $i [expr $MEM_SIZE/4]
}

###############################################################################
# Check address for each word
puts "\n\nChecking memory"
put_top_line
for {set i 0} {$i < [expr $MEM_SIZE/4]} {incr i} {
	set readback [master_read_32 $mm [expr $i * 4 + $MEM_OFFSET] 1]
	if { $readback != [expr $i * 4 + $MEM_OFFSET] } { 
		puts "ERROR, at [expr $i * 4 + $MEM_OFFSET ], should be \
			[expr $i * 4 + $MEM_OFFSET], got $readback instead" 
		exit 0
	}
	put_filler $i [expr $MEM_SIZE/4]
}


close_service master $mm



