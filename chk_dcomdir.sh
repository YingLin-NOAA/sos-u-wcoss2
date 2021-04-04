#!/bin/sh
#
# look into several dcom directories to see if they are still empty
#
if [ $# -eq 0 ]
then
  day=`date +%Y%m%d`
else
  day=$1
fi

DCOM=/gpfs/dell1/nco/ops/dcom/prod/$day/wgrbbul
if [ ! -d $DCOM ]; then
  echo $DCOM does not exist!  EXIT.
  exit
fi

for dcomdir in $DCOM/cmc             \
               $DCOM/cmc_gdps_25km   \
               $DCOM/cmcens_gb2      \
               $DCOM/cmcensbc_gb2
do
  echo file count for ${dcomdir}: 
  ls $dcomdir | wc -l
done

exit

