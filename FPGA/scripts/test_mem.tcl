
#

puts "abc\bd"

# Mem size in bytes
set MEM_SIZE  	[ expr 128*1024 ]
set MEM_OFFSET	[ expr 1024*1024]
puts "Mem size: $MEM_SIZE"
puts "Mem offset $MEM_OFFSET"

set mm [lindex [get_service_paths master] 0]

open_service master $mm

# Erase memory
puts "\nErasing memory"
for {set i 0} {$i < [expr $MEM_SIZE/4]} {incr i} {
	master_write_32 $mm [expr $i *4 + $MEM_OFFSET] 0
	#progres $i [expr $MEM_SIZE/4]
	#puts -nonewline "."
	#puts "$i of [expr $MEM_SIZE/4]"
}

puts "\nChecking if memory erased"
# Check if really empty
for {set i 0} {$i < [expr $MEM_SIZE/4]} {incr i} {
	set readback [master_read_32 $mm [expr $i * 4 + $MEM_OFFSET] 1]
	if { $readback != 0 } { 
		puts "ERROR, at [expr $i * 4], should be zero, got $readback instead" 
		exit 0
	}
}

puts "\nWriting to memory"
# Write address to each word
for {set i 0} {$i < [expr $MEM_SIZE/4]} {incr i} {
	master_write_32 $mm [expr $i * 4 + $MEM_OFFSET] [expr $i * 4 + $MEM_OFFSET]
	#puts -nonewline "."
	#puts "$i of [expr $MEM_SIZE/4]"
}

puts "\nChecking memory"
# Check address for each word
for {set i 0} {$i < [expr $MEM_SIZE/4]} {incr i} {
	set readback [master_read_32 $mm [expr $i * 4 + $MEM_OFFSET] 1]
	if { $readback != [expr $i * 4 + $MEM_OFFSET] } { 
		puts "ERROR, at [expr $i * 4 + $MEM_OFFSET ], should be [expr $i * 4 + $MEM_OFFSET], got $readback instead" 
		exit 0
	}
}


close_service master $mm



