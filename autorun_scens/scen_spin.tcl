# To be used for all scenarios, scen-specific spinup
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
pfset Geom.indinput.FileName			ind_scen.pfb
pfset GeomInput.indinput.GeomNames		"br sapr topurb topfor"

pfset GeomInput.br.Value		        1	
pfset GeomInput.sapr.Value			2
pfset GeomInput.topurb.Value			3
pfset GeomInput.topfor.Value                    4



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

pfset Geom.domain.Perm.FileName         	perm_scen.pfb

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
set	end	43805
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
pfset Patch.z-upper.BCPressure.alltime.Value     0.0


#---------------------------------------------------------
# Topo slopes in x-direction
#---------------------------------------------------------

#pfset TopoSlopesX.Type 				"PFBFile"
#pfset TopoSlopesX.GeomNames 			"domain"
#pfset TopoSlopesX.FileName 			slopex.pfb


pfset TopoSlopesX.GeomNames				"domain"
pfset TopoSlopesX.Type 				"Constant"
pfset TopoSlopesX.Geom.domain.Value   0.01

#---------------------------------------------------------
# Topo slopes in y-direction
#---------------------------------------------------------

#pfset TopoSlopesY.Type 				"PFBFile"
#pfset TopoSlopesY.GeomNames 			"domain"
#pfset TopoSlopesY.FileName 			slopey.pfb

pfset TopoSlopesY.GeomNames				"domain"
pfset TopoSlopesY.Type 				"Constant"
pfset TopoSlopesY.Geom.domain.Value   0.01



#---------------------------------------------------------
# Mannings coefficient 
#---------------------------------------------------------

#pfset Mannings.Type 				"Constant"
pfset Mannings.Type				"PFBFile"
pfset Mannings.GeomNames 			"domain"
pfset Mannings.FileName				mann_scen.pfb
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
#pfset Solver.MaxIter                                     200

pfset Solver.TerrainFollowingGrid			 True
pfset Solver.AbsTol                                      1E-10
pfset Solver.Nonlinear.MaxIter                           500
pfset Solver.Nonlinear.ResidualTol                       1e-4
pfset Solver.Nonlinear.EtaChoice                         EtaConstant
pfset Solver.Nonlinear.EtaValue                          0.001
pfset Solver.Nonlinear.UseJacobian                       True
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-14
pfset Solver.Nonlinear.StepTol                           1e-25
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.KrylovDimension                      30
pfset Solver.Linear.MaxRestart                           2
pfset Solver.MaxConvergenceFailures			 2
pfset Solver.Drop					 1E-20
pfset Solver.Linear.Preconditioner                       PFMG
pfset Solver.Linear.Preconditioner.PCMatrixType		 FullJacobian
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

pfset Solver.LSM                                         CLM
pfset Solver.WriteSiloCLM                                True
pfset Solver.CLM.MetForcing                              1D
pfset Solver.CLM.MetFileName                            dauphco.nldas.10yr.txt
pfset Solver.CLM.MetFilePath                             ./


pfset Solver.WriteSiloEvapTrans                          True
pfset Solver.WriteSiloOverlandBCFlux                     True
pfset Solver.CLM.Print1dOut                           	False
pfset Solver.CLM.BinaryOutDir                           False
pfset Solver.WriteCLMBinary                		False


pfset OverlandFlowSpinUp				0	

#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------

# set water table to be at the bottom of the domain, the top layer is initially dry
#pfset ICPressure.Type                        	HydroStaticPatch
#pfset ICPressure.GeomNames                 	domain
#pfset Geom.domain.ICPressure.Value         	-5.0
#pfset Geom.domain.ICPressure.RefGeom         	domain
#pfset Geom.domain.ICPressure.RefPatch       	z-upper

pfset ICPressure.Type                           PFBFile
pfset ICPressure.GeomNames                      domain
pfset Geom.domain.ICPressure.FileName	        spin3.out.press.pfb
pfdist 						spin3.out.press.pfb

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

#pfdist slopey.pfb
#pfdist slopex.pfb
pfdist mann_scen.pfb

pfset ComputationalGrid.NZ                      10


#-----------------------------------------------------------------------------
# Run ParFlow
#-----------------------------------------------------------------------------
pfdist ind_scen.pfb
pfdist perm_scen.pfb

pfrun slopes_only
pfundist slopes_only

pfset ComputationalGrid.NZ                      1
#pfundist slopex.pfb
#pfundist slopey.pfb
pfundist mann_scen.pfb

pfset ComputationalGrid.NZ                      10
pfundist ind_scen.pfb
pfundist perm_scen.pfb


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


