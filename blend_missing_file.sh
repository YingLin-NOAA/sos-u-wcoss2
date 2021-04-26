#!/bin/sh
# when a blend file is missing - say it's 
#  /gpfs/dell5/nco/ops/com/blend/prod/blend.20210425/wmo/grib2.blend.t15z.awp_cig_d004.hi
#
# Try to compare /gpfs/dell5/nco/ops/com/blend/prod/blend.20210425/15/modeldata/blend.t15z.allmodels_prep_avn.20210425.hi.grd_sq
# against that from a 'good' blend run.  
# arg1=2021042515
# arg2=hi
# optional arg3: 'good cycle' to compare with.  Default is the cycle from 
# the day before.  
#

EXEC_blend=/gpfs/dell1/nco/ops/nwprod/blend.v4.0.5/exec/
COM_blend=/gpfs/dell5/nco/ops/com/blend/prod
if [ $# -lt 2 ]
then
#  echo This script requires at least two arguments:
#  echo   arg1: yyyymmddhh (day and cycle of blend run)
#  echo   arg2: region (hi, ak, etc.)
#  echo   arg3 (optional) a day (same cyc) of good blend run to compare with
  exit
else
  arg1=$1
  day1=${arg1:0:8}
  cyc=${arg1:8:2}
  reg=$2
  if [ $# -gt 2 ]; then
    day0=$3
  else
    day0=`date -d "$day1 - 1 day" +%Y%m%d`
  fi
fi

wrkdir=/gpfs/dell1/ptmp/Ying.Lin/blend.chk
if [ -d $wrkdir ]
then
  rm -f $wrkdir/*
else
  mkdir -p $wrkdir
fi
cd $wrkdir

MDAT1=$COM_blend/blend.$day1/$cyc/modeldata
MDAT0=$COM_blend/blend.$day0/$cyc/modeldata
sq1=$MDAT1/blend.t${cyc}z.allmodels_prep_avn.$day1.$reg.grd_sq
sq0=$MDAT0/blend.t${cyc}z.allmodels_prep_avn.$day0.$reg.grd_sq

list1=$day1.$cyc.$reg.sq
list0=$day0.$cyc.$reg.sq
$EXEC_blend/itdlp $sq1 > $list1
$EXEC_blend/itdlp $sq0 > $list0

cat $list1 | awk -F":" '{print $4, $5}' > $list1.2col
cat $list0 | awk -F":" '{print $4, $5}' > $list0.2col

diff $list1.2col $list0.2col

