lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*

pfsave [pfload "testperm.pfb"] -silo "testperm.silo"
pfsave [pfload "testmann.pfb"] -silo "testmann.silo"


