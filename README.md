# ParFlow Python utility scripts

This is a collection of python-based utility scripts for pre/post-processing
ParFlow.CLM inputs/outputs.

## Heterogeneous subsurface pre-processing
ParFlow can be run with a heterogeneous subsurface -- including spatially variable  permeability and porosity over horizontal and vertical dimensions of the domain, and spatially variable mannings n over the horizontal domain.

An easy way to specify these 2 or 3-dimension heterogeneous parameter values is to write an input Parflow binary file (.pfb) (see ParFlow manual), which can then be specified as the input method in the ParFlow run tcl file. The source code for ParFlow includes fortran code for writing pfb files in: `pftools/prepostproc/pfb_write.f90`.

The heterogeneous parameters are often linked to differences in land use and land cover. Land cover rasters can be read into or created in Python in the form of 2 dimensional array. This 2D array can then be used to assign permeability, porosity, and manning's n values.

f2py is used to connect the Fortran-based creation of three dimensional arrays and to write out the .pfb ParFlow binary file.

### Installation of Fortran modules:
`cd` into the directory from which the Python kernel will be launched and move the files `createpfb3.f`, `createpfb2.f`, and `writepfb.f` into this directory.

In the terminal:

```
f2py -c -m subsurface createpfb3.f createpfb2.f writepfb.f
```

This command creates the module called `subsurface`, which can be called from within Python, with sub-modules `createpfb3` and `createpfb2`. You should see a file created in the directory after this step, similar to: `subsurface/cpython-37m-x86_64-linux-gnu.so`.

### Running subsurface pre-processing in python
The module can now be called in python to create pfb files. For example:

```py
from subsurface import createpfb3, createpfb2
import numpy as np

mat = np.array([[1,1,2,2,2],
              [1,1,2,2,2],
              [1,1,2,2,2],
              [1,1,2,2,2]])

landco_perm = np.array([[1.0,2.0],
                       [3.0,4.0],
                       [5.0,6.0]])

landco_mann = np.array([[0.001,0.00001]])

nx = mat.shape[0]
ny = mat.shape[1]

a = createpfb3(arrin = mat, dx = 1, dy = 1, dz = 1, nlc = 2, nx = 4, ny = 5, nz = 3, lcin = landco_perm, arroutfnam='testperm.pfb')

b = createpfb2(arrin = mat, dx = 1, dy = 1, dz = 1, nlc = 2, nx = 4, ny = 5, lcin_flat = landco_mann, arroutfnam='testmann.pfb')

```

### Running subsurface post-processing in python
The following module is a *post-processing* step used to scale volumes that are calculated non-variable dz (vdz)-aware, on simulations that have used variable dz settings.

**Note**: outputs of pfsimulator (including output silo files and water balance calculations) are non-vdz-aware. But, it appears that running pftools water balance calcs after the simulation does apply a scaling factor for variable dz. This means that if passing water balance checks relies on pfsimulator and pftools outputs matching, the waterbalance sill not match.

On the command line, install the module:

```
f2py -c -m postproc scale_pfb.f pfb_read.f writepfb.f
```

```py
from postproc import scale_pfb
import numpy as np

factors = np.array([[10.0],  # <- bottom
                    [5.0],
                    [2.5],
                    [2.5],
                    [1.0],
                    [1.0],
                    [0.5],
                    [0.5],
                    [0.5],
                    [0.5]]) # <- top

scale_pfb(pfbinfnam = 'subsurface_storage.0.pfb', vdzarr = factors, pfboutfnam = "test.pfb", nx = 12, ny = 10, dx = 10, dy = 10, dz = 1)

```
The above script will write a file called "test.pfb" which has the scaling factors applied to it.
