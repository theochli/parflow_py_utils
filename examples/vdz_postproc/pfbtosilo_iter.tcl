lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*


set tcl_precision 16

for {set i 0 } {$i <= 19} {incr i 1} {

	set pfb [pfload "vdz_subsurface_storage.$i.pfb"]
	pfsave $pfb  -silo "vdz_subsurface_storage.$i.silo"

}
