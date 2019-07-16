lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*


set tcl_precision 16

set silo [pfload "slopes_only.out.press.43805.silo"]
pfsave $silo -pfb "slopes_only.out.press.43805.pfb"
