
# 24 bit LFSR (taps: 23,22,21,16)
proc lfsr24 { data } {
	set bit23 [ expr ($data >> 23) & 0x1 ]
	set bit22 [ expr ($data >> 22) & 0x1 ]
	set bit21 [ expr ($data >> 21) & 0x1 ]
	set bit16 [ expr ($data >> 16) & 0x1 ]
	set xorBit [ expr $bit23 ^ $bit22 ^ $bit21 ^ $bit16 ]
	return [ expr (($data << 1) & 0xFFFFFF) | $xorBit ]
}


# 32 bit LFSR (taps: 31,21,1,0)
proc lfsr32 { data } {
	set bit31 [ expr ($data >> 31) & 0x1 ]
	set bit21 [ expr ($data >> 21) & 0x1 ]
	set bit1  [ expr ($data >>  1) & 0x1 ]
	set bit0  [ expr ($data >>  0) & 0x1 ]
	set xorBit [ expr $bit31 ^ $bit21 ^ $bit1 ^ $bit0]
	return [ expr (($data << 1) & 0xFFFFFFFF) | $xorBit ]
}


proc test_lfst { } {
	set addr 0xFFFFFF
	set data 0xFFFFFFFF

	for {set i 0} {$i < 10} {incr i} {
		set addr [lfsr24 $addr]
		set data [lfsr32 $data]
		puts "At 0x[format %06x $addr] = 0x[format %08x $data]"
	}
}

# test_lfst
