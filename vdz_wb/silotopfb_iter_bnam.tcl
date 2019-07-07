

lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*


set tcl_precision 16

set rundir [lindex $argv 0]
set fbasenam [lindex $argv 1]
set start [lindex $argv 2]
set end [lindex $argv 3]
set fw [lindex $argv 4]

cd $rundir

for {set i $start } {$i <= $end} {incr i 1} {
	if $fw {
	
	set filename [format "%s.%05d.silo" $fbasenam $i]
	set silo [pfload $filename]
	pfsave $silo -pfb [format "$fbasenam.$i.pfb"]

        } {
	
	set silo [pfload $fbasenam.$i.silo]
	pfsave $silo -pfb [format "$fbasenam.$i.pfb"]
        
        }
	

}
