lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*

pfsave [pfload "outtest2.pfb"] -silo "outtest2.silo"

