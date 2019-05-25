lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*

pfsave [pfload "perm_het1.pfb"] -silo "perm_het1.silo"
pfsave [pfload "mann_het1.pfb"] -silo "mann_het1.silo"
pfsave [pfload "ind_het1.pfb"] -silo "ind_het1.silo"


