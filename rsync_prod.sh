#!/bin/sh
#PBS -N RsyncJob 
#PBS -l select=1:ncpus=1:mem=900MB
#PBS -l walltime=01:00:00
#PBS -j oe 
#PBS -q prod_transfer
#PBS -A SDM-DEV
#PBS -l debug=true
#PBS -V

# xfer to cactus:  cdxfer.wcoss2.ncep.noaa.gov
# xfer to dogwood: ddxfer.wcoss2.ncep.noaa.gov

set -x
DIR=/lfs/h1/ops/prod/com/cfs/v2.3/cdas.20220521

rsync -rav --progress $DIR/ cdxfer.wcoss2.ncep.noaa.gov:$DIR

