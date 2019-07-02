#!/usr/bin/tclsh
#  This script can be used to sum over an entire
#  3d array, for example, when you want to
#  calculate the total subsurface storage in the
#  domain. Note: if using variable dz,
#  need to first scale the subsurface storage values
#  by the scaling factors before applying
#  this script.

set tcl_precision 17



set bnam [lindex $argv 0]
set start [lindex $argv 1]
set end [lindex $argv 2]


#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

pfset FileVersion 4

for {set i $start} {$i <= $end} {incr i} {
#	set filename [format "vdz_subsurfstor.%05d.pfb" $i]
#	set stor [pfload $filename]
	set dom [pfload "$bnam.$i.pfb"]
	set total [pfsum $dom]
	puts [format "%s \t %.16e" $i $total]
}
