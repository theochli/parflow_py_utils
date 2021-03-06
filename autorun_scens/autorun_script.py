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

from postproc import scale_pfb, vdz_watertable
import pandas as pd
from io import StringIO
import itertools
import numpy as np
from shlex import split

from autorun_utils import *
import sys

logfile = open('runscenarios.log', 'a')
sys.stdout = logfile

rundir = '/home/theo/pf_files/pf_machine/scenarios/rundir'
specif_inputs_root_dir = '/home/theo/pf_files/pf_machine/scenarios/scens_inputs_specific/'
common_inputs_dir = '/home/theo/pf_files/pf_machine/scenarios/scens_inputs_common'
wb_output_dir = '/home/theo/pf_files/pf_machine/scenarios/wb_outputs'
wt_output_dir = '/home/theo/pf_files/pf_machine/scenarios/wt_outputs'


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

nz = 10

depths = np.zeros((nz,1))

for i in range(0,nz):
    depths[[i]] = sum(factors[i+1:nz])


# Create dictionary of urb_scens and config_scens
# urb_scen is the number of cells in domain that are 
#   urbanized
# config_scens: within a given urb_scen, the confirguration
#   scenarios (placement and shape)


n_urb_list = [0,10,20,30,40,50,60,70]
scens = {}

for n_urb in n_urb_list:
    scens['n_urb%03d' %n_urb] = []

    if n_urb == 0:
        i = 0
        scens['n_urb%03d' %n_urb].append('%03d%03d' %(n_urb,i))

    fp = find_factors(n_urb)
    fp = prune_f_pairs(fp,12,10)

    patch_dict = get_upper_left_index(12,10,fp)

    i = 10

    for patch in patch_dict:
        cur_patch_xdim = patch['patch_xdim']
        cur_patch_ydim = patch['patch_ydim']

        for unique_corner in patch['upperleftind']:

            scens['n_urb%03d' %n_urb].append('%03d%03d' %(n_urb, i))
            i +=1

# the dictionary scens has two 'levels': 
#     scens.keys(): n_urb000, n_urb010, etc
#     scens['n_urb000'] = ['000000']
#     scens['n_urb010'] = ['010000', '010001', etc...]


for urb_scen in list(scens.keys())[:1]:
    print(urb_scen)
    # input file directory
    specif_inputs_dir = '%s/%s/' %(specif_inputs_root_dir, urb_scen)

    for config_scen in scens[urb_scen]:
        
        print ('Now processing... %s' %config_scen)
        
        # Copy scenario-specific inputs into rundir
        shutil.copy2('%s/%s/mann_scen.pfb' %(specif_inputs_dir,  config_scen), '.')
        shutil.copy2('%s/%s/ind_scen.pfb' %(specif_inputs_dir,  config_scen), '.')
        shutil.copy2('%s/%s/perm_scen.pfb' %(specif_inputs_dir, config_scen), '.')
        shutil.copy2('%s/%s/drv_vegm.dat' %(specif_inputs_dir,  config_scen), '.')

        # Copy scenario-common inputs into rundir
        shutil.copy2('%s/dauphco.nldas.10yr.txt' %common_inputs_dir, '.')
        shutil.copy2('%s/drv_clmin.dat' %common_inputs_dir, '.')
        shutil.copy2('%s/drv_vegp.dat' %common_inputs_dir, '.')
        shutil.copy2('%s/spin03.out.press.pfb' %common_inputs_dir, '.')


        print('    Run inputs copied')

        #########################################
        # Run scenario-specific spinup (5 years)
        #########################################
        print('    Running scenario-specific spinup')
        start = time.time()
        bashCommand = "tclsh scen_spin.tcl"
        process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
        process.wait()
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
        process.wait()
        output, error = process.communicate()
        print(output)
        print(error)

        # convert silos to pfbs
        silo2pfb(rundir = rundir, bnam ='subsurface_storage' , start= 0, stop=cur_stop)

        # scale pfbs using factors
        for t in range(0,cur_stop+1):
            infnam = '%s/subsurface_storage.%s.pfb' %(rundir, t)
            outfnam = '%s/vdz_subsurface_storage.%s.pfb' %(rundir,t)

            scale_pfb(pfbinfnam = infnam, vdzarr = factors, pfboutfnam = outfnam,
                nx = 12, ny = 10, dx = 10, dy = 10, dz = 1)
    
        ss = sumoverdomain(rundir = rundir,
                       bnam = 'vdz_subsurface_storage',start = 0, stop= cur_stop)
        print('    vdz-aware subsurface storage calc completed.\n    ss.head(10)\n')
        print(ss.head(10))

        # checking subsurf storage stabilized
        print('year-on-year subsurf storage percent change:\n')
        print(ss['sum_val'][list(np.multiply(8610, [0,1,2,3,4,5]))].pct_change())

        if (sum((abs(ss['sum_val'][list(np.multiply(8610, [0,1,2,3,4,5]))].pct_change())) < 0.01)== 0):
            print('    WARNING %s: No years where pct change in vdz subsurf storage < 1 pct' %config_scen)
            print('    continuing with next scenario...')
            print('===========================================================')
            break

        print('    Spinup stabilization PASSED')

        # Save and rename the last pressure file
        print('    saving scenario-specific slopes_only_out.press.43805.pfb as %s/%s/spin4.out.press.pfb...' %(specif_inputs_dir, config_scen))
        os.rename('slopes_only.out.press.%05d.pfb' %cur_stop, '%s/%s/spin4.out.press.pfb' %(specif_inputs_dir, config_scen))

        # Removing spinup run files to save memory
        print('    Removing all spinup run files...')
        delete_run_files()


        ####################################################
        # Run scenario one-year simulation for water balance
        ####################################################
        scen_files = os.listdir('%s/%s' %(specif_inputs_dir, config_scen))
        for file_name in scen_files:
            full_file_name = os.path.join('%s/%s' %(specif_inputs_dir, config_scen), file_name)
            if os.path.isfile(full_file_name):
                shutil.copy(full_file_name, '.')

        print('    simulation files for %s copied to rundir' %config_scen)

        print('    beginning scenario one-year simulation')
        start = time.time()
        bashCommand = "tclsh scen_run.tcl"
        process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
        process.wait()
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
        process.wait()
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
        for t in range(0,cur_stop+1):
            infnam = '%s/subsurface_storage.%s.pfb' %(rundir, t)
            outfnam = '%s/vdz_subsurface_storage.%s.pfb' %(rundir,t)

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
        for t in range(1,cur_stop):
            infnam = '%s/evaptranssum.%s.pfb' %(rundir, t)
            outfnam = '%s/vdz_evaptranssum.%s.pfb' %(rundir,t)

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
            print('    WARNING %s water balance not closing' %config_scen)
            print('    continuing with next scenario...')
            print('===========================================================')
            break

        # Save the water balance
        wb.to_csv('%s/wb_%s.csv' %(wb_output_dir,config_scen))

        ###############################
        # Calculate Water Table Depth
        ###############################

        print('    Beginning water table calcs...')

        matlist = [] # list to store each timestep's water table matrix

        for t in range(0,cur_stop):
            infnam = 'slopes_only.out.satur.%05d.pfb' %t
            outfnam = 'watertable.out.%s.pfb' %t

            # calc
            a = vdz_watertable(pfbinfnam = infnam, vdzarr = depths, pfboutfnam = outfnam,
                    nx = 12, ny = 10, nz = 10, dx = 10, dy = 10, dz = 1)

            matlist.append(a)

        ###############################################
        # Calculate summary stats over time, across space
        ################################################
        # stack all matrices in list into an array:
        newarray = np.dstack(matlist)
    
        m = np.mean(newarray, axis = 2)
        np.savetxt('%s/%s_mean_wtdepth.csv' %(wt_output_dir,config_scen) ,m)

        m = np.std(newarray, axis = 2)
        np.savetxt('%s/%s_sd_wtdepth.csv' %(wt_output_dir,config_scen)  ,m)

        m = np.min(newarray, axis = 2)
        np.savetxt('%s/%s_min_wtdepth.csv' %(wt_output_dir,config_scen)  ,m)

        m = np.max(newarray, axis = 2)
        np.savetxt('%s/%s_max_wtdepth.csv' %(wt_output_dir,config_scen) ,m)

        m = np.median(newarray, axis = 2)
        np.savetxt('%s/%s_median_wtdepth.csv' %(wt_output_dir,config_scen)  ,m)

    
    
    
        # Remove run files to save memory
        print('    Removing all simulation run files...')
        delete_run_files()


        print('===========================================================')


