# First heterogeneous subsurface (input pfb files)
#
#
set tcl_precision 17

set runname slopes_only
set verbose 1
#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*

pfset FileVersion 4

#---------------------------------------------------------
# Flux on the top surface
#---------------------------------------------------------

pfset Process.Topology.P        		1
pfset Process.Topology.Q        		1
pfset Process.Topology.R        		1

#---------------------------------------------------------
# Computational Grid
#---------------------------------------------------------
# 'native' grid resolution
pfset ComputationalGrid.Lower.X			0.0
pfset ComputationalGrid.Lower.Y			0.0
pfset ComputationalGrid.Lower.Z			0.0

pfset ComputationalGrid.NX            		12
pfset ComputationalGrid.NY            	 	10
pfset ComputationalGrid.NZ            		10

pfset ComputationalGrid.DX	      		100
pfset ComputationalGrid.DY           		100
pfset ComputationalGrid.DZ			1

#---------------------------------------------------------
# The Names of the GeomInputs
#---------------------------------------------------------
pfset GeomInput.Names 				"domain_input indinput"
pfset GeomInput.domain_input.InputType            Box
pfset GeomInput.domain_input.GeomName             domain
pfset Geom.domain.Lower.X                        0.0 
pfset Geom.domain.Lower.Y                        0.0
pfset Geom.domain.Lower.Z                          0.0
pfset Geom.domain.Upper.X                        1200
pfset Geom.domain.Upper.Y                        1000
pfset Geom.domain.Upper.Z                        10.0
pfset Geom.domain.Patches "x-lower x-upper y-lower y-upper z-lower z-upper"

pfset GeomInput.indinput.InputType		IndicatorField
pfset Geom.indinput.FileName			ind_het1.pfb
pfset GeomInput.indinput.GeomNames		"br sapr topurb topfor"

pfset GeomInput.br.Value		        1	
pfset GeomInput.sapr.Value			2
pfset GeomInput.topurb.Value			3
pfset GeomInput.topfor.Value                    4


#--------------------------------------------------
# Domain Geometry 
#--------------------------------------------------
# Set to the computational grid


#pfset Geom.domain.Lower.X          		    0.0
#pfset Geom.domain.Lower.Y             		0.0
#pfset Geom.domain.Lower.Z            		0.0
 
#pfset Geom.domain.Upper.X            		12
#pfset Geom.domain.Upper.Y               	10
#pfset Geom.domain.Upper.Z               	10
#
#pfset Geom.domain.Patches  			"x-lower x-upper y-lower y-upper \
						z-lower z-upper"

#--------------------------------------------
# variable dz assignments
#--------------------------------------------
pfset Solver.Nonlinear.VariableDz       True
pfset dzScale.GeomNames            		domain
pfset dzScale.Type            			nzList
pfset dzScale.nzListNumber       		10

pfset Cell.0.dzScale.Value 		   	2.0	
pfset Cell.1.dzScale.Value 		   	2.0	
pfset Cell.2.dzScale.Value 		   	2.0	
pfset Cell.3.dzScale.Value 		   	1.0	
pfset Cell.4.dzScale.Value 			1.0
pfset Cell.5.dzScale.Value			1.0
pfset Cell.6.dzScale.Value 			0.25
pfset Cell.7.dzScale.Value 			0.25
pfset Cell.8.dzScale.Value 			0.25
pfset Cell.9.dzScale.Value			0.25

#-----------------------------------------------------------------------------
# Perm
#-----------------------------------------------------------------------------

pfset Geom.Perm.Names                 		"domain"

pfset Geom.domain.Perm.Type             	PFBFile
#pfset Geom.domain.Perm.Type             	Constant
# in m/hr, based on K_sat for pervious
#pfset Geom.domain.Perm.Value 			0.0000306

pfset Geom.domain.Perm.FileName         	perm_het1.pfb

pfset Perm.TensorType               		TensorByGeom

pfset Geom.Perm.TensorByGeom.Names  		"domain"

pfset Geom.domain.Perm.TensorValX  		1.0d0
pfset Geom.domain.Perm.TensorValY  		1.0d0
pfset Geom.domain.Perm.TensorValZ  		1.0d0

#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------

pfset Phase.RelPerm.Type                	VanGenuchten
pfset Phase.RelPerm.GeomNames           	"domain"

pfset Geom.domain.RelPerm.Alpha         	3.5
pfset Geom.domain.RelPerm.N             	2.

pfset Geom.domain.RelPerm.NumSamplePoints 	20000
pfset Geom.domain.RelPerm.MinPressureHead 	-300

#---------------------------------------------------------
# Saturation
#---------------------------------------------------------

pfset Phase.Saturation.Type             	VanGenuchten
pfset Phase.Saturation.GeomNames        	"domain"

pfset Geom.domain.Saturation.Alpha      	3.5
pfset Geom.domain.Saturation.N          	2
pfset Geom.domain.Saturation.SRes       	0.2
pfset Geom.domain.Saturation.SSat       	1.0

#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------

pfset SpecificStorage.Type            		"Constant"
pfset SpecificStorage.GeomNames       		"domain"
pfset Geom.domain.SpecificStorage.Value 	1.0e-5

#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------

pfset Phase.Names 				"water"

pfset Phase.water.Density.Type	        	Constant
pfset Phase.water.Density.Value	        	1.0

pfset Phase.water.Viscosity.Type		Constant
pfset Phase.water.Viscosity.Value		1.0

#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------

pfset Contaminants.Names			""

#-----------------------------------------------------------------------------
# Retardation
#-----------------------------------------------------------------------------

pfset Geom.Retardation.GeomNames        	""

#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------

pfset Gravity					1.0

#-----------------------------------------------------------------------------
# Setup timing info
#-----------------------------------------------------------------------------
# run for 2 h @ 0.1 hr timesteps (note: parking lot test req 0.01 hr ts)
# Dump outputs (silo) every 1 hour (36 seconds) (5 timesteps)

set	start	0
set	end	20

pfset TimingInfo.BaseUnit        		1
pfset TimingInfo.StartCount      		$start
pfset TimingInfo.StartTime       	        $start
pfset TimingInfo.StopTime        		$end
pfset TimingInfo.DumpInterval    		1
pfset TimeStep.Type              		Constant
pfset TimeStep.Value             		1

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
# Match with TimingInfo.BaseUnit
pfset Cycle.Names constant
pfset Cycle.constant.Names              "alltime"
pfset Cycle.constant.alltime.Length      1
pfset Cycle.constant.Repeat              -1


#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------

#pfset Geom.Porosity.GeomNames		domain
#pfset Geom.domain.Porosity.Type		Constant
#pfset Geom.domain.Porosity.Value	0.001

pfset Geom.Porosity.GeomNames		"br sapr topurb topfor"

pfset Geom.br.Porosity.Type		Constant
pfset Geom.br.Porosity.Value		0.02

pfset Geom.sapr.Porosity.Type		Constant
pfset Geom.sapr.Porosity.Value		0.47

pfset Geom.topurb.Porosity.Type		Constant
pfset Geom.topurb.Porosity.Value	0.001

pfset Geom.topfor.Porosity.Type		Constant
pfset Geom.topfor.Porosity.Value	0.73



#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------

pfset Domain.GeomName 				domain
#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                       	""

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames     		"z-upper z-lower x-lower x-upper \
                                      		y-lower y-upper"
              
pfset Patch.y-upper.BCPressure.Type             FluxConst
pfset Patch.y-upper.BCPressure.Cycle            "constant"
pfset Patch.y-upper.BCPressure.alltime.Value	0

pfset Patch.y-lower.BCPressure.Type             FluxConst 
pfset Patch.y-lower.BCPressure.Cycle          	"constant"
pfset Patch.y-lower.BCPressure.alltime.Value    0

pfset Patch.x-upper.BCPressure.Type             FluxConst 
pfset Patch.x-upper.BCPressure.Cycle          	"constant"
pfset Patch.x-upper.BCPressure.alltime.Value	0.0

pfset Patch.x-lower.BCPressure.Type             FluxConst 
pfset Patch.x-lower.BCPressure.Cycle          	"constant"
pfset Patch.x-lower.BCPressure.alltime.Value	0.0

pfset Patch.z-lower.BCPressure.Type		FluxConst
pfset Patch.z-lower.BCPressure.Cycle		"constant"
pfset Patch.z-lower.BCPressure.alltime.Value	0.0

## overland flow boundary condition with constant rainfall
pfset Patch.z-upper.BCPressure.Type          	OverlandFlow
pfset Patch.z-upper.BCPressure.Cycle            "constant"
pfset Patch.z-upper.BCPressure.alltime.Value            -0.05


#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------

pfset TopoSlopesX.Type 				"PFBFile"
pfset TopoSlopesX.GeomNames 			"domain"
pfset TopoSlopesX.FileName 			slopex.pfb


#pfset TopoSlopesX.GeomNames				"domain"
#pfset TopoSlopesX.Type 				"Constant"
#pfset TopoSlopesX.Geom.domain.Value   0.001

#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------

pfset TopoSlopesY.Type 				"PFBFile"
pfset TopoSlopesY.GeomNames 			"domain"
pfset TopoSlopesY.FileName 			slopey.pfb

#pfset TopoSlopesY.GeomNames				"domain"
#pfset TopoSlopesY.Type 				"Constant"
#pfset TopoSlopesY.Geom.domain.Value   0.001



#---------------------------------------------------------
# Mannings coefficient 
#---------------------------------------------------------

#pfset Mannings.Type 				"Constant"
pfset Mannings.Type				"PFBFile"
pfset Mannings.GeomNames 			"domain"
pfset Mannings.FileName				mann_het1.pfb
#pfset Mannings.Geom.domain.Value   		5.00e-5
#pfset Mannings.Geom.domain.Value 0.035
#pfset Mannings.domain.Value          0.00005 this doesn't work! but above does.

#-----------------------------------------------------------------------------
# Phase sources:-------------------------------------------------- 
#-----------------------------------------------------------------------------
pfset PhaseSources.Type                   	Constant
pfset PhaseSources.GeomNames                    domain
pfset PhaseSources.Geom.domain.Value            0.0

pfset PhaseSources.water.Type                  	Constant
pfset PhaseSources.water.GeomNames             	domain
pfset PhaseSources.water.Geom.domain.Value    	0.0

#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------

pfset KnownSolution                       	NoKnownSolution

#-----------------------------------------------------------------------------
# Set solver parameters
#-----------------------------------------------------------------------------

### Settings from wb
pfset Solver                                             Richards
pfset Solver.MaxIter                                     100

pfset Solver.AbsTol                                      1E-9
pfset Solver.Nonlinear.MaxIter                           100
pfset Solver.Nonlinear.ResidualTol                       1e-9
pfset Solver.Nonlinear.EtaChoice                         Walker1
pfset Solver.Nonlinear.EtaChoice                         EtaConstant
pfset Solver.Nonlinear.EtaValue                          0.001
pfset Solver.Nonlinear.UseJacobian                       False
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-16
pfset Solver.Nonlinear.StepTol                           1e-10
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.KrylovDimension                      20
pfset Solver.Linear.MaxRestart                           2
pfset Solver.Drop					 1E-20
pfset Solver.Linear.Preconditioner                       PFMG
#pfset Solver.Linear.Preconditioner.PFMG.MaxIter           1
#pfset Solver.Linear.Preconditioner.PFMG.Smoother          RBGaussSeidelNonSymmetric
#pfset Solver.Linear.Preconditioner.PFMG.NumPreRelax       1
#pfset Solver.Linear.Preconditioner.PFMG.NumPostRelax      1

pfset Solver.WriteSiloSubsurfData                       True
pfset Solver.WriteSiloPressure                          True
pfset Solver.WriteSiloSaturation                        True
pfset Solver.WriteSiloConcentration                     True
pfset Solver.WriteSiloSlopes                            True
pfset Solver.WriteSiloMask                              True
pfset Solver.WriteSiloEvapTrans                         True
pfset Solver.WriteSiloEvapTransSum                      True
pfset Solver.WriteSiloOverlandSum                       True
pfset Solver.WriteSiloMannings                          True
pfset Solver.WriteSiloSpecificStorage                   True

pfset OverlandFlowSpinUp				1

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------

# set water table to be at the bottom of the domain, the top layer is initially dry
pfset ICPressure.Type                        	HydroStaticPatch
pfset ICPressure.GeomNames                 	domain
pfset Geom.domain.ICPressure.Value         	-5.0
pfset Geom.domain.ICPressure.RefGeom         	domain
pfset Geom.domain.ICPressure.RefPatch       	z-upper

#pfset ICPressure.Type                           PFBFile
#pfset ICPressure.GeomNames                      domain
#pfset Geom.domain.ICPressure.FileName	        spin1.out.press.03285.pfb
#pfdist 						spin1.out.press.03285.pfb

#set num_processors [expr{ [pfget Process.Topology.P] * [pfget Process.Topology.Q] * [pfget Process.Topology.R]}]

#for {set i 0} { $i <= $num_processors } {incr i} {
#        file delete drv_clmin.dat.$i
#        file copy drv_clmin.dat drv_clmin.dat.$i
#        }

#spinup key (See LW_var_dz_spinup.tcl and http://parflow.blogspot.com/2015/08/spinning-up-watershed-model.html)
# True=skim pressures, False = regular (default)
#pfset Solver.Spinup           True
#pfset Solver.Spinup           False 


#pfset OverlandFlowSpinUp			1
#pfset OverlandSpinupDampP1			1.0
#pfset OverlandSpinupDampP2			0.001

#---------------------------------------------------------
##  Distribute slopes and mannings
#---------------------------------------------------------

pfset ComputationalGrid.NZ                      1

pfdist slopey.pfb
pfdist slopex.pfb
pfdist mann_het1.pfb

pfset ComputationalGrid.NZ                      10


#-----------------------------------------------------------------------------
# Run ParFlow
#-----------------------------------------------------------------------------
pfdist ind_het1.pfb
pfdist perm_het1.pfb

pfrun slopes_only
pfundist slopes_only

pfset ComputationalGrid.NZ                      1
pfundist slopex.pfb
pfundist slopey.pfb

pfset ComputationalGrid.NZ                      10
pfundist mann_het1.pfb
pfundist ind_het1.pfb
pfundist perm_het1.pfb


#-----------------------------------------------------------------------------
# Undistribute output files
#-----------------------------------------------------------------------------
#pfundist $runname
#pfundist slopex.pfb
#pfundist slopey.pfb
#pfundist mannings.pfb
#pfundist permeability-spinup.pfb
#pfundist indicator.pfb

puts "ParFlow run complete"


# The below is from parflow/test/water_balance_x.tcl
#
# Tests 
#
source pftest.tcl
set passed 1

set slope_x          [pfload $runname.out.slope_x.silo]
set slope_y          [pfload $runname.out.slope_y.silo]
set mannings         [pfload $runname.out.mannings.silo]
set specific_storage [pfload $runname.out.specific_storage.silo]
set porosity         [pfload $runname.out.porosity.silo]

set mask             [pfload $runname.out.mask.silo]
set top              [pfcomputetop $mask]

set surface_area_of_domain [expr [pfget ComputationalGrid.DX] * [pfget ComputationalGrid.DY] * [pfget ComputationalGrid.NX] * [pfget ComputationalGrid.NY]]

set prev_total_water_balance 0.0

for {set i 0} {$i <= 19} {incr i} {
    if $verbose {
        puts "======================================================"
        puts "Timestep $i"
        puts "======================================================"
    }
    set total_water_in_domain 0.0

    set filename [format "%s.out.press.%05d.pfb" $runname $i]
    set pressure [pfload $filename]
    set surface_storage [pfsurfacestorage $top $pressure]
    pfsave $surface_storage -silo "surface_storage.$i.silo"
    set total_surface_storage [pfsum $surface_storage]
    if $verbose {
        puts [format "Surface storage\t\t\t\t\t : %.16e" $total_surface_storage]
    }
    set total_water_in_domain [expr $total_water_in_domain + $total_surface_storage]

    set filename [format "%s.out.satur.%05d.pfb" $runname $i]
    set saturation [pfload $filename]

    set water_table_depth [pfwatertabledepth $top $saturation]
    pfsave $water_table_depth -silo "water_table_depth.$i.silo"

    set subsurface_storage [pfsubsurfacestorage $mask $porosity $pressure $saturation $specific_storage]
    pfsave $subsurface_storage -silo "subsurface_storage.$i.silo"
    set total_subsurface_storage [pfsum $subsurface_storage]
    if $verbose {
       puts [format "Subsurface storage\t\t\t\t : %.16e" $total_subsurface_storage]
    }
    set total_water_in_domain [expr $total_water_in_domain + $total_subsurface_storage]

    if $verbose {
        puts [format "Total water in domain\t\t\t\t : %.16e" $total_water_in_domain]
        puts ""
    }

    set total_surface_runoff 0.0
    if { $i > 0} {
        set surface_runoff [pfsurfacerunoff $top $slope_x $slope_y $mannings $pressure]
        pfsave $surface_runoff -silo "surface_runoff.$i.silo"
        set total_surface_runoff [expr [pfsum $surface_runoff] * [pfget TimingInfo.DumpInterval]]
        if $verbose {
            puts [format "Surface runoff from pftools\t\t\t : %.16e" $total_surface_runoff]
        }

        set filename [format "%s.out.overlandsum.%05d.silo" $runname $i]
        set surface_runoff2 [pfload $filename]
        set total_surface_runoff2 [pfsum $surface_runoff2]
        if $verbose {
            puts [format "Surface runoff from pfsimulator\t\t\t : %.16e" $total_surface_runoff2]
        }

        if ![pftestIsEqual $total_surface_runoff $total_surface_runoff2 "Surface runoff comparison" ] {
            set passed 0
        }
    }

#    if [expr $i < 1] {
#        set bc_index 0
#    } elseif [expr $i > 0 && $i < 7] {
#        set bc_index [expr $i - 1]
#    } {
#        set bc_index 6
#    }
#    set bc_flux [pfget Patch.z-upper.BCPressure.$bc_index.Value]

    #if [expr $i < 11] {
#	set bc_index rain
#    } elseif [expr $i > 10 && $i < 20] {
#	set bc_index rec
#    } {
#	set bc_index rec
#    }
#    set bc_flux [pfget Patch.z-upper.BCPressure.$bc_index.Value]
    
    set bc_flux [pfget Patch.z-upper.BCPressure.alltime.Value]

    set boundary_flux [expr $bc_flux * $surface_area_of_domain * [pfget TimingInfo.DumpInterval]]
    if $verbose {
        puts [format "BC flux\t\t\t\t\t\t : %.16e" $boundary_flux]
 }

    # Note flow into domain is negative
    set expected_difference [expr $boundary_flux + $total_surface_runoff]
    if $verbose {
        puts [format "Total Flux\t\t\t\t\t : %.16e" $expected_difference]
    }

    if { $i > 0 } {

        if $verbose {
            puts ""
            puts [format "Diff from prev total\t\t\t\t : %.16e" [expr $total_water_in_domain - $prev_total_water_balance]]
        }

        if [expr $expected_difference != 0.0] {
            set percent_diff [expr (abs(($prev_total_water_balance - $total_water_in_domain) - $expected_difference)) / abs($expected_difference) * 100]
            if $verbose {
                puts [format "Percent diff from expected difference\t\t : %.12e" $percent_diff]
            }
        }

        set expected_water_balance [expr $prev_total_water_balance - $expected_difference]
        set percent_diff [expr abs(($total_water_in_domain - $expected_water_balance)) / $expected_water_balance * 100]
        if $verbose {
            puts [format "Percent diff from expected total water sum\t : %.12e" $percent_diff]
        }

        if [expr $percent_diff > 0.005] {
            puts "Error: Water balance is not correct"
            set passed 0
        }

    }

    set prev_total_water_balance [expr $total_water_in_domain]
}

if $verbose {
    puts "\n\n"
}

if $passed {
    puts "$runname : PASSED"
} {
    puts "$runname : FAILED"
}

