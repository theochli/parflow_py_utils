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

for {set i 1} {$i <= 19} {incr i} {
#	set filename [format "vdz_subsurfstor.%05d.pfb" $i]
#	set stor [pfload $filename]
	set stor [pfload "vdz_subsurface_storage.$i.pfb"]	
	set total_subsurface_storage [pfsum $stor]
	puts [format "%s \t %.16e" $i $total_subsurface_storage]
}
