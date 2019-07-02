
# This script sums the surface storage using
# pftools' pfsurface storage, the 'top' and
# 'pressure' outputs


set tcl_precision 16
#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

pfset FileVersion 4

# Set these values prior to executing

set runname slopes_only
set nsteps [lindex $argv 0]
set timing_base_interval 1

# Time-invariant Values needed for calculation

set mask             [pfload $runname.out.mask.silo]
set top              [pfcomputetop $mask]

set total_surface_stor 0.0

#If the pressure is less than zero set to zero
for {set i 1 } {$i <= $nsteps } {incr i} {
	set pressure [pfload [format "%s.out.press.%05d.pfb" $runname $i]]
	set surface_stor [pfsurfacestorage $top $pressure]
  set total_surface_stor [expr [pfsum $surface_stor] * $timing_base_interval]

	puts [format "%s \t %.16e" $i $total_surface_stor]
}
