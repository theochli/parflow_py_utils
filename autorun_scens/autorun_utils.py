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


# Helper scripts to generate scenarios dictionary


def find_factors(value):
    '''
    A function to get all factor pairs of a given integer
    Outputs a list of tuples
    '''
    factors = []
    for i in range(1, int(value**0.5)+1):
        if value % i == 0:
            factors.append((float(i), value / i))
    return factors

def prune_f_pairs(f_pairs, dom_dx, dom_dy):
    '''
    Removes factor pairs whose dimensions exceed the domains
    (will not fit into domain as one "patch")
    '''
    new_fp = []
    for f in f_pairs:
        if max(f) > max(dom_dx,dom_dy): # one pair of the factor exceeds the domain, need to check if it exceeds the other
            if max(f) <= min(dom_dx,dom_dy): # if it does, then don't keep this pair
                new_fp.append(f)
        else:
            new_fp.append(f)

    return(new_fp)

def make_combinations(list1, list2):
    '''
    make combinations given two lists
    '''
    combs = []
    for element in itertools.product(list1, list2):
            combs.append(element)
    return(combs)


def get_upper_left_index(dom_x, dom_y, f_pairs):
    '''
    A list of feasible upper left indexes, given dims of domain
    and dims of patch
    '''

    results = []

    for f in f_pairs:

        # can patch's longside be oriented on x?
        if max(f) <= dom_x:
            patch_dims = (max(f), min(f))
            x_ind_list = list(range(0, dom_x - int(max(f)) + 1) )
            # then the short side (min(f)), has to be oriented on y:
            y_ind_list = list(range(0, dom_y - int(min(f)) + 1) )

            upper_left_indices = make_combinations(x_ind_list, y_ind_list)

            results.append({'patch_xdim': patch_dims[0],
                        'patch_ydim':  patch_dims[1],
                        'upperleftind':upper_left_indices })
        else:
            print("cannot be oriented with long side on x")
            upper_left_indices = []

        # can patch's longside be oriented on y?
        if max(f) <= dom_y:
            patch_dims = (min(f), max(f))
            x_ind_list = list(range(0, dom_x - int(min(f)) + 1) )
            y_ind_list = list(range(0, dom_y - int(max(f)) + 1) )

            upper_left_indices = make_combinations(x_ind_list, y_ind_list)

            results.append({'patch_xdim': patch_dims[0],
                        'patch_ydim':  patch_dims[1],
                        'upperleftind':upper_left_indices })
        else:
            print("cannot be oriented with long side on y")
            upper_left_indices = []

    return(results)









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
    # slopes_only*
    fileList = glob.glob('./slopes_only**', recursive=True)
    for filePath in fileList:
        try:
            os.remove(filePath)
        except:
            print("Error while deleting file : ", filePath)

    # .silos
    fileList = glob.glob('./*.silo', recursive=True)
    for filePath in fileList:
        try:
            os.remove(filePath)
        except:
            print("Error while deleting file : ", filePath)


    # .pfbs
    fileList = glob.glob('./*.pfb', recursive=True)
    for filePath in fileList:
        try:
            os.remove(filePath)
        except:
            print("Error while deleting file : ", filePath)


    # gp*
    fileList = glob.glob('./gp*', recursive=True)
    for filePath in fileList:
        try:
            os.remove(filePath)
        except:
            print("Error while deleting file : ", filePath)
