#!/bin/sh
# check timeliness of GFS atmos master files, compare today against yesterday

if [ $# -lt 2 ]
then
  echo 'Need at least two argument: 1) model 2) cycle (00/06/12/18) 3) yyyymmdd (if not today) '
  exit
else
  model=$1
  cyc=$2
  if [ $# -ge 3 ]
  then
    day0=$3
  else
    day0=`date +%Y%m%d`
  fi
fi

daym1=`date -d "$day0 - 1 day" +%Y%m%d`

# find path for gfs directory:
CPFX=`compath.py $model`
err=$?
if [ $err -ne 0 ]
then
  echo compath.py cannot find path for ${model}.
  exit
fi

wrkdir=/gpfs/dell1/stmp/Ying.Lin/chk_timeliness
if [ -d $wrkdir ]
then
rm -f $wrkdir/*
else
mkdir -p $wrkdir
fi

# Model directory and file name prefix and suffix:
# 
# Model directory: ${dpfx}/${model}.$day/${dsfx}/
# MOdel master files: ${fpfx}*${fsfx}, where '*' is fcst hour

# GFS: $CPFX/prod/gfs.$day/$cyc/atmos/gfs.t${cyc}z.master.grb2f${fhr}
# NAM: $CPFX/prod/nam.$day/nam.t12z.bgdawp${fhr}.tm00
# RAP: $CPFX/prod/rap.$day/rap.t12z.wrfnatf${fhr}.grib2 
dpfx=$CPFX/prod
if [ $model = 'gfs' ]
then
  dsfx=$cyc/atmos
  fpfx=gfs.t${cyc}z.master.grb2f
  fsfx=''
elif [ $model = 'nam' ]
then
  dsfx=''
  fpfx=nam.t${cyc}z.bgdawp
  fpsfx='.tm00'
elif [ $model = 'rap' ]
then
  dsfx=''
  fpfx=rap.t${cyc}z.wrfnatf
  fsfx='.grib2'
fi

for day in $day0 $daym1 
do
  COMDIR=$dpfx/$model.$day/$dsfx
  cd $COMDIR
  ls -lGgc --time-style="+ %H:%M:%S" ${fpfx}*${fsfx} | awk '{print $4, $5}' > $wrkdir/$model.${day}-${cyc}z.time
done

exit

