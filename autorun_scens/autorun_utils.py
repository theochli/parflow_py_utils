# This contains helper functions
# for autorunning scenarios (generating waterbalance files)

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


# Post Processing
def silo2pfb(rundir, bnam, start, stop, fw=0):
    '''
    Converts a timeseries of silo output to pfb format
    (saves converted pfbs to same directory)

    bnam     the basename of the files (everything up to the iterating index)
    start    start number of file indexing
    end      end number of file indexing
    fw       fixed width = 0 for non-fixed width iterating index,
             fixed width = 1 for fixed width (assumed width is 5) index.
    '''
    bashCommand = "tclsh silotopfb_iter_bnam.tcl %s %s %s %s %s" %(rundir, bnam,start,stop, fw)
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    print(output)
    print(error)

    # if fw =1, rename the output files to remove $runname.out
    if fw:
        print("renaming output pfb files")
        newbnam = bnam.split(".")[-1]

        for i in range(start, stop+1):
            ofnam = "%s/%s.%s.pfb" %(rundir,bnam,i)
            nfnam = "%s/%s.%s.pfb" %(rundir,newbnam,i)
            os.rename(ofnam, nfnam)

def sumoverdomain(rundir, bnam, start, stop):
    '''
    Sums over the entire domain for an input pfb file,
    returns a dataframe with columns for t and the sum values

    bnam    the base name of the files to sum
    start   the start number of file indexing
    end     the end number of file indexing
    '''
    bashCommand = "tclsh sum_domain_bnam.tcl %s %s %s %s" %(rundir, bnam,start,stop)
    process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()

    # Save the output to a dataframe
    output = output.decode("utf-8").format()
    df = pd.read_csv(StringIO(output), sep="\t", header = None)
    df.columns = ['t','sum_val']  # add a header (column name)

    # return
    return(df)


# Delete Run Files
def delete_run_files():
    start = time.time()
    p1 = subprocess.Popen(split('find . -name "slopes_only*" -print0'), stdout=subprocess.PIPE)
    p2 = subprocess.Popen(split('xargs -0 rm -rf'), stdin=p1.stdout)
    print('Removed slopes_only*')
    end = time.time()
    print('Time Elapsed:  %s s' %(end - start))

    start = time.time()
    p1 = subprocess.Popen(split('find . -name  "*silo"  -print0'), stdout=subprocess.PIPE)
    p2 = subprocess.Popen(split('xargs -0 rm -rf'), stdin=p1.stdout)
    print('Removed *silo')
    end = time.time()
    print('Time Elapsed:  %s s' %(end - start))

    start = time.time()
    p1 = subprocess.Popen(split('find . -name  "*pfb"  -print0'), stdout=subprocess.PIPE)
    p2 = subprocess.Popen(split('xargs -0 rm -rf'), stdin=p1.stdout)
    print('Removed *pfb')
    end = time.time()
    print('Time Elapsed:  %s s' %(end - start))

    start = time.time()
    p1 = subprocess.Popen(split('find . -name  "gp*"  -print0'), stdout=subprocess.PIPE)
    p2 = subprocess.Popen(split('xargs -0 rm -rf'), stdin=p1.stdout)
    print('Removed gp*')
    end = time.time()
    print('Time Elapsed:  %s s' %(end - start))
