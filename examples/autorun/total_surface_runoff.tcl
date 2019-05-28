
# This script sums all overland flow from the domain
# see water_balance_x.tcl in Paflow test scripts dir
#
# Does not require that surface_runoff silos were 
# previously calculated. (Will calc surface runoff,
# but does not input these silo files) 


lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

# Set these values prior to executing
set tcl_precision 16
set runname slopes_only
#set dir "home/tclim/Dropbox/projects/pf_simple/01testruns/slopes_only_run"
set start 1
set end 19
set timing_base_interval 0.1

# Time-invariant Values needed for calculation

set slope_x          [pfload $runname.out.slope_x.silo]
set slope_y          [pfload $runname.out.slope_y.silo]
set mannings         [pfload $runname.out.mannings.silo]
set specific_storage [pfload $runname.out.specific_storage.silo]
set porosity         [pfload $runname.out.porosity.silo]

set mask             [pfload $runname.out.mask.silo]
set top              [pfcomputetop $mask]


set total_surface_runoff 0.0

#If the pressure is less than zero set to zero
for {set i $start } {$i <= $end } {incr i} {
	set pressure [pfload [format "%s.out.press.%05d.pfb" $runname $i]]
	#set surface_runoff [pfsurfacerunoff $top $slopex $slopey $mannings $pressure]
	set surface_runoff [pfsurfacerunoff $top $slope_x $slope_y $mannings $pressure]
        set total_surface_runoff [expr [pfsum $surface_runoff] * $timing_base_interval]
	
	# write a header if first line
	if { $i == 1} {
	    puts "i\ttot_runoff"
	}

	puts [format "%s\t%.16e" $i $total_surface_runoff]
}
