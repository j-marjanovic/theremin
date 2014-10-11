

source lfsr.tcl
source progress_bar.tcl

set BLK_SIZE [expr 1024]
set BLK_NUMBERS 100

# initial values
set addr 0xFFFFFF
set data 0xFFFFFFFF

set mm [lindex [get_service_paths master] 0]
open_service master $mm

# This advnaces LFSR so it does not change only last bit, which is masked
set addr [lfsr24 $addr]
set addr [lfsr24 $addr]
set addr [lfsr24 $addr]


for {set j 0} {$j < $BLK_NUMBERS} {incr j} {
	puts "sequence $j (start: 0x[format %06x [expr $addr & 0x1FFFFC]])"

	put_top_line

	# Save sequence initial values
	set initialAddr $addr
	set initialData $data

	# Write
	for {set i 0} {$i < $BLK_SIZE} {incr i} {
		master_write_16 $mm [expr $addr & 0x1FFFFC] [expr $data & 0xFFFF]
		set addr [lfsr24 $addr]
		set data [lfsr32 $data]
		put_filler $i [expr $BLK_SIZE - 1]
	}

	# Write
	for {set i 0} {$i < $BLK_SIZE} {incr i} {
		set readback [master_read_16 $mm [expr $initialAddr & 0x1FFFFC] 1]
		if { [expr $readback] ne [expr $initialData & 0xFFFF] } {
			puts "\nERROR: read from 0x[format %06x [expr $initialAddr & 0x1FFFFC]] data [expr $readback], should be [expr $initialData & 0xFFFF]\n"
		}
		set initialAddr [lfsr24 $initialAddr]
		set initialData [lfsr32 $initialData]
		put_filler $i [expr $BLK_SIZE - 1]
	}

	puts "\n"
	
}


close_service master $mm
