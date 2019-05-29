#!/bin/bash
# Run drv_clmin.f
echo -e "running drv_vegm.f"
gfortran -g -fcheck=all drv_vegm.f
printf "%s,%s,%10.2e,%10.2e,%10.2e,%10.2e" $DAT_FILE $LANDCO_FILE $cols $rows $ewres $nsres | $PWD/a.out

