# This is the code that is run after the spinup and full run have 
# already been run once
# Need to run for another year, to calc water table
# because each runs' outputs were removed to preserve memory
# I now want to create some spatial outputs summarized over time (1 year)

# Psuedo-code
# 1. Copy scenario-specific files (now including the last file of
#    the spinup) into the run directory
# 2. Run the 1-year simulation using `scen_run.tcl`
# 3. Run `postproc` f2py module to create vdz-aware water table depths
#    and summarize over time time-dimensions into matrixes:

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



rundir = '/home/theo/pf_files/pf_machine/scenarios/rundir'
specif_inputs_dir = '/home/theo/pf_files/pf_machine/scenarios/scens_inputs_specific'
common_inputs_dir = '/home/theo/pf_files/pf_machine/scenarios/scens_inputs_common'




    ####################################################
    # Run scenario one-year simulation for water balance
    ####################################################
for i in range(110,116):
    scen = 'scen%03d' %i

    print('Now processing... %s' %scen)



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
    # Calculate vdz Water Table
    ############################
   
    print('    Beginning water table calcs...')

    factors = np.array([[2.0],
                        [2.0],
                        [2.0],
                        [1.0],
                        [1.0],
                        [1.0],
                        [0.5],
                        [0.5],
                        [0.5],
                        [0.5]])


    matlist = [] # list to store each timestep's water table matrix

    for t in range(0,8761):
        infnam = 'slopes_only.out.satur.%05d.pfb' %t
        outfnam = 'watertable.out.%s.pfb' %t

        # calc
        a = vdz_watertable(pfbinfnam = infnam, vdzarr = factors, pfboutfnam = outfnam,
                nx = 12, ny = 10, nz = 10, dx = 10, dy = 10, dz = 1)

        matlist.append(a)


    ######################################
    # Calculate summary stats across time
    ######################################
    wt_outdir = '/home/theo/pf_files/pf_machine/scenarios/wt_outputs2'
    # stack all matrices in list into an array:
    newarray = np.dstack(matlist)
    
    m = np.mean(newarray, axis = 2)
    np.savetxt('%s/%s_mean_wtdepth.csv' %(wt_outdir,scen) ,m)

    m = np.std(newarray, axis = 2)
    np.savetxt('%s/%s_sd_wtdepth.csv' %(wt_outdir,scen)  ,m)

    m = np.min(newarray, axis = 2)
    np.savetxt('%s/%s_min_wtdepth.csv' %(wt_outdir,scen)  ,m)

    m = np.max(newarray, axis = 2)
    np.savetxt('%s/%s_max_wtdepth.csv' %(wt_outdir,scen) ,m)

    m = np.median(newarray, axis = 2)
    np.savetxt('%s/%s_median_wtdepth.csv' %(wt_outdir,scen)  ,m)



    # Remove run files to save memory
    print('    Removing all simulation run files...')
    delete_run_files()
    print('===========================================================')

