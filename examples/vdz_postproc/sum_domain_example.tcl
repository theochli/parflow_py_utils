#!/usr/bin/tclsh 
#  This script can be used to sum over an entire
#  3d array, for example, when you want to 
#  calculate the total subsurface storage in the 
#  domain. Note: if using variable dz,
#  need to first scale the subsurface storage values
#  by the scaling factors before applying
#  this script. 

set tcl_precision 17


set runname lbase


#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*

pfset FileVersion 4

set nsteps [lindex $argv 0]

for {set i 1} {$i <= $nsteps} {incr i} {
	set stor [pfload "vdz_subsurface_storage.$i.pfb"]
	set total_subsurface_storage [pfsum $stor]
	puts [format "%.16e" $total_subsurface_storage]
}
