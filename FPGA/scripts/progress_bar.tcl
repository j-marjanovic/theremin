


set BAR_LEN 50

###############################################################################
# Puts top line
proc put_top_line { } {
	global BAR_LEN	
	puts -nonewline "|"
	for {set i 0} {$i < $BAR_LEN} {incr i} {
		puts -nonewline "-"
	}
	puts -nonewline "|\n"
}

###############################################################################
# Puts # to fill the progress bar, should be called every loop iteration
proc put_filler {cur max} {
	global BAR_LEN	
	if { [expr $cur eq 0] } { 
		puts -nonewline "|"
	} elseif { [expr $cur eq $max] } { 
		puts -nonewline "|\n"
	} else {
		set curValue [ expr $cur*$BAR_LEN/$max ]
		set nextValue [ expr ($cur+1)*$BAR_LEN/$max ]
		if { [expr $curValue ne $nextValue ] } {
			puts -nonewline "#"
		}
	}	
}


###############################################################################
# Test

#put_top_line
#
#for {set i 0} { $i < 1000 } { incr i } {
#	put_filler $i 999
#	after 10
#}



