#!/bin/sh
#
# check to see if files needed for the  
# /prod??/gfs/atmos/post_processing/grib2_wafs/jgfs_atmos_wafs_blending job have arrived
#
# This job needs one argument, yyyymmddhh, where hh=00/06/12/18
# The 00/06/12/18Z jgfs_wafs_blending runs at 0433/1033/1633/2233Z.  Data
#   normally arrive at DCOM 45-55min prior to run time.  If files are missing
#   on prod dcom, see if they are there on dev dcom and copy them over to 
#   prod prior to run time.
#
if [ $# -eq 1 ]
then
  arg1=$1
  day=${arg1:0:8}
  cyc=${arg1:8:2}
  echo $day $cyc
else
  echo This job needs one argument, yyyymmddhh, where hh=00/06/12/18.  Exit
  exit
fi

DCOM=/gpfs/dell1/nco/ops/dcom/prod/$day/wgrbbul/ukmet_wafs
echo Check for missing EGRR_WAFS_unblended_${day}_${cyc}z_t*.grib2 in 
echo '   '  $DCOM
for fhr in 06 09 12 15 18 21 24 27 30 33 36 39 42 45 48 
do
  file=EGRR_WAFS_unblended_${day}_${cyc}z_t${fhr}.grib2
  if [ ! -s $DCOM/$file ]; then
    echo No valid $file
  fi
done
exit

