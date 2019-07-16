# This writes non-vdz-aware silo files,
# using pftools
# to be used as inputs to assess spinup progress
# based on subsurface storage. additional proc
# steps needed to get vdz-aware subsurf storage

lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*


set tcl_precision 16

set rundir [lindex $argv 0]
set runname [lindex $argv 1]
set start [lindex $argv 2]
set end [lindex $argv 3]

cd $rundir
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

  set subsurface_storage [pfsubsurfacestorage $mask $porosity $pressure $saturation $specific_storage]
  pfsave $subsurface_storage -silo "subsurface_storage.$i.silo"


}
