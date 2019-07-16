# This is the script that runs all scenarios
# Pseudo-code:
# 1. running a scenario-specific spinup, initialized with
#    `spin3.out.press.pfb` using `scen_spin.tcl` (this will
#     simulate 5 years of 2010 meteorological forcing
# 2. Running the variable dz subsurface post processing script
#    (python with fortran module, which needs to be installed
#    using:
#    `f2py -c -m postproc scale_pfb.f pfb_read.f writepfb.f`
#    and has dependencies: `scale_pfb.f pfb_read.f writepfb.f`)
#    Need to confirm that subsurface storage is changing by less
#    than 1% between years 4 and 5.
# 3. Use the last pfb file `slopes_only.out.press.43805.pfb` as
#    the input `spin4.out.press.pfb` (save this in each scen's
#    directory) to the one year simulation
# 4. Remove all spinup run files to make space
# 5. Run the 1-year simulation using `scen_run.tcl`
# 6. Run the full water balance script using `postproc`
#    f2py module. Save the csv dataframe in outputs directory.
# 7. Remove all run files.

import subprocess
import glob
import os
import shutil
import time

from postproc import scale_pfb
import pandas as pd
from io import StringIO
import itertools
import numpy as np
from shlex import split

from autorun_utils import *


rundir = '/home/theo/pf_files/pf_machine/scenarios/rundir'
specif_inputs_dir = '/home/theo/pf_files/pf_machine/scenarios/scens_inputs_specific'
common_inputs_dir = '/home/theo/pf_files/pf_machine/scenarios/scens_inputs_common'

factors = np.array([[2.0],  # <- bottom
                    [2.0],
                    [2.0],
                    [1.0],
                    [1.0],
                    [1.0],
                    [0.25],
                    [0.25],
                    [0.25],
                    [0.25]]) # <- top

for i in range(3,7):
    scen = 'scen%03d' %i

    print('Now processing... %s' %scen)

    # Copy scenario-specific inputs into rundir
    shutil.copy2('%s/%s/mann_scen.pfb' %(specif_inputs_dir, scen), '.')
    shutil.copy2('%s/%s/ind_scen.pfb' %(specif_inputs_dir, scen), '.')
    shutil.copy2('%s/%s/perm_scen.pfb' %(specif_inputs_dir, scen), '.')
    shutil.copy2('%s/%s/drv_vegm.dat' %(specif_inputs_dir, scen), '.')

    # Copy scenario-common inputs into rundir
    shutil.copy2('%s/dauphco.nldas.10yr.txt' %common_inputs_dir, '.')
    shutil.copy2('%s/drv_clmin.dat' %common_inputs_dir, '.')
    shutil.copy2('%s/drv_vegp.dat' %common_inputs_dir, '.')
    shutil.copy2('%s/spin3.out.press.pfb' %common_inputs_dir, '.')

    print('    Run inputs copied')

    #########################################
    # Run scenario-specific spinup (5 years)
    #########################################
    print('    Running scenario-specific spinup')
    start = time.time()
    bashCommand = "tclsh scen_spin.tcl"
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    end = time.time()
    print('    Scenario-specific spinup complete.\n    Time Elapsed:  %s s' %(end - start))


    #########################################
    # Calculate vdz-aware susburface storage
    #########################################
    print('    Calculating vdz-aware subsurface storage for spinup')
    cur_stop = 43805

    # create silos needed for subsurf stor
    bashCommand = "tclsh write_subsurf_silos.tcl %s %s %s %s" %(rundir,'slopes_only',0,cur_stop)
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    print(output)
    print(error)

    # convert silos to pfbs
    silo2pfb(rundir = rundir, bnam ='subsurface_storage' , start= 0, stop=cur_stop)

    # scale pfbs using factors
    for i in range(0,cur_stop+1):
        infnam = '%s/subsurface_storage.%s.pfb' %(rundir, i)
        outfnam = '%s/vdz_subsurface_storage.%s.pfb' %(rundir,i)

        scale_pfb(pfbinfnam = infnam, vdzarr = factors, pfboutfnam = outfnam,
             nx = 12, ny = 10, dx = 10, dy = 10, dz = 1)

    ss = sumoverdomain(rundir = rundir,
                       bnam = 'vdz_subsurface_storage',start = 0, stop= cur_stop)
    print('    vdz-aware subsurface storage calc completed.\n    ss.head(10)\n')
    print(ss.head(10))

    # checking subsurf storage stabilized
    print('year-on-year subsurf storage percent change:\n')
    print(ss['sum_val'][list(np.multiply(8610, [0,1,2,3,4,5]))].pct_change())

    if (abs(ss['sum_val'][list(np.multiply(8610, [0,1,2,3,4,5]))].pct_change().tail(1)) > 0.01).iloc[0] > 0.01:
        print('    WARNING %s spinup change from year 4 to year 5 NOT LESS THAN 1pc' %scen)
        print('    continuing with next scenario...')
        print('===========================================================')
        break

    print('    Spinup stabilization PASSED')

    # Save and rename the last pressure file
    print('    saving scenario-specific slopes_only_out.press43805.pfb as %s/%s/spin4.out.press.pfb...' %(specif_inputs_dir, scen))
    os.rename('slopes_only.out.press.43805.pfb', '%s/%s/spin4.out.press.pfb' %(specif_inputs_dir, scen))

    # Removing spinup run files to save memory
    print('    Removing all spinup run files...')
    delete_run_files()

    ####################################################
    # Run scenario one-year simulation for water balance
    ####################################################
    scen_files = os.listdir('%s/%s' %(specif_inputs_dir, scen))
    for file_name in scen_files:
        full_file_name = os.path.join('%s/%s' %(specif_inputs_dir, scen), file_name)
        if os.path.isfile(full_file_name):
            shutil.copy(full_file_name, '.')

    print('    simulation files for %s copied to rundir' %scen)

    print('    beginning scenario one-year simulation')
    start = time.time()
    bashCommand = "tclsh scen_run.tcl"
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    end = time.time()
    print('    Scenario one-year simulation complete.\n    Time Elapsed:  %s s' %(end - start))

    ############################
    # Calculate Water Balance
    ############################
    cur_stop = 8761

    # Write silo files for water balance
    bashCommand = "tclsh write_wb_silos.tcl %s %s %s %s" %(rundir,'slopes_only',0,cur_stop)
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    print(output)
    print(error)

    # Read in NLDAS input
    nldas = pd.read_fwf('%s/dauphco.nldas.10yr.txt' %rundir, header = None, sep = '')
    nldas.columns = ['DSWR', 'DLWR', 'APCP', 'TMP', 'UGRD', 'VGRD', 'PRESS', 'SPFH']
    print('    Example of NLDAS nldas.head()\n')
    print(nldas.head())

    prcp_m_hr = nldas.APCP/1000*60*60 # meters per hour precipitation
    prcp_v = prcp_m_hr*1200*1000 # total precip volume over domain (to use in water balance)

    # Overland Flow
    silo2pfb(rundir = rundir,
         bnam ='slopes_only.out.overlandsum' , start= 1, stop=cur_stop, fw = 1)

    of = sumoverdomain(rundir = rundir,
                       bnam = 'overlandsum',start = 1, stop= cur_stop)
    of['sum_val'] = of['sum_val']
    print('    Example of overland flow of.head()\n')
    print(of.head(10))

    # Surface storage
    silo2pfb(rundir = rundir, bnam ='surface_storage' , start= 0, stop=cur_stop)
    s = sumoverdomain(rundir = rundir, bnam = 'surface_storage',start = 0, stop= cur_stop)
    print('    Example of surface storage s.head()\n')
    print(s.head(10))

    # Subsurface storage
    # convert silos to pfbs
    silo2pfb(rundir = rundir, bnam ='subsurface_storage' , start= 0, stop=cur_stop)

    # scale pfbs using factors
    for i in range(0,cur_stop+1):
        infnam = '%s/subsurface_storage.%s.pfb' %(rundir, i)
        outfnam = '%s/vdz_subsurface_storage.%s.pfb' %(rundir,i)

        scale_pfb(pfbinfnam = infnam, vdzarr = factors, pfboutfnam = outfnam,
             nx = 12, ny = 10, dx = 10, dy = 10, dz = 1)

    ss = sumoverdomain(rundir = rundir,
                       bnam = 'vdz_subsurface_storage',start = 0, stop= cur_stop)

    print('    Example of subsurface storage ss.head()\n')
    print(ss.head(10))

    # Evapotranspiration
    silo2pfb(rundir = rundir,
         bnam ='slopes_only.out.evaptranssum' , start= 1, stop=cur_stop, fw = 1)

    # scale pfbs using factors
    for i in range(1,cur_stop):
        infnam = '%s/evaptranssum.%s.pfb' %(rundir, i)
        outfnam = '%s/vdz_evaptranssum.%s.pfb' %(rundir,i)

        scale_pfb(pfbinfnam = infnam, vdzarr = factors, pfboutfnam = outfnam,
             nx = 12, ny = 10, dx = 10, dy = 10, dz = 1)

    et = sumoverdomain(rundir = rundir,
                       bnam = 'vdz_evaptranssum',start = 1, stop= cur_stop)
    et['sum_val'] = et['sum_val']
    et['t'] = et['t'] - 1
    print('    Example of evapotranspiration et.head()\n')
    print(et.head(10))


    # Put pieces of water balance together
    print('    Putting pieces of water balance together')
    wb = ss.merge(of, on = 't', how = 'left').merge(s, on = 't', how = 'left').merge(et, on = 't', how = 'left')
    wb.columns = ['t', 'vdz_subsurfstor', 'overland_flow', 'surf_stor', 'vdz_et']
    wb['overland_flow'] = (- wb['overland_flow'])
    wb['overland_flow'] = wb['overland_flow'].shift(-1)
    wb['dom_tot'] = wb['vdz_subsurfstor'] +  wb['surf_stor']
    wb['bndy_flux'] = wb['vdz_et'] + wb['overland_flow']
    wb['exp_wb'] = wb['dom_tot'].shift(-1) + wb['bndy_flux']
    wb['dom_tot_chg'] = wb['dom_tot'].diff()
    wb['dom_tot_chg'] = wb['dom_tot_chg'].shift(-1)
    wb['diff'] = wb['dom_tot_chg'] - wb['bndy_flux']
    wb['pc_diff'] = abs(wb['diff'])/wb['exp_wb']*100
    wb['prcp_v'] = prcp_v[:cur_stop]

    print('    Example of wb.head()\n')
    print(wb.head(20))

    # check what the pct differences are
    if abs(max(wb.pc_diff.dropna())) > 0.0005:
        print('    WARNING %s water balance not closing' %scen)
        print('    continuing with next scenario...')
        print('===========================================================')
        break

    # Save the water balance
    wb.to_csv('/home/theo/pf_files/pf_machine/scenarios/wb_outputs/wb_%s.csv' %scen)

    # Remove run files to save memory
    print('    Removing all simulation run files...')
    delete_run_files()


    print('===========================================================')
