lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*

pfsave [pfload "testout.pfb"] -silo "testout.silo"
