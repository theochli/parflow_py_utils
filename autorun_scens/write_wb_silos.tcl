# This writes non-vdz-aware silo files,
# using pftools
# to be used as inputs to water balance scripts
# Note: surface runoff is NOT written here
# because should directly use the overlandsum silo
# files to close the water balance.
# pftools-calced surface runoff will not close.

lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*


set tcl_precision 16

set rundir [lindex $argv 0]
set runname [lindex $argv 1]
set start [lindex $argv 2]
set end [lindex $argv 3]

cd $rundir
set slope_x          [pfload $runname.out.slope_x.silo]
set slope_y          [pfload $runname.out.slope_y.silo]
set mannings         [pfload $runname.out.mannings.silo]
set specific_storage [pfload $runname.out.specific_storage.silo]
set porosity         [pfload $runname.out.porosity.silo]

set mask             [pfload $runname.out.mask.silo]
set top              [pfcomputetop $mask]


for {set i $start } {$i <= $end} {incr i 1} {

  # Load in pressure and saturation pfb outputs

  set filename [format "%s.out.press.%05d.pfb" $runname $i]
  set pressure [pfload $filename]
  set filename [format "%s.out.satur.%05d.pfb" $runname $i]
  set saturation [pfload $filename]


  set surface_storage [pfsurfacestorage $top $pressure]
  pfsave $surface_storage -silo "surface_storage.$i.silo"


  set subsurface_storage [pfsubsurfacestorage $mask $porosity $pressure $saturation $specific_storage]
  pfsave $subsurface_storage -silo "subsurface_storage.$i.silo"


}
