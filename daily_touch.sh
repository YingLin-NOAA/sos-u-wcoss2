#!/bin/sh
# run this daily to make sure that cron.out doesn't disappear.
CRONOUT=/gpfs/dell1/ptmp/Ying.Lin/cron.out
if [ ! -d $CRONOUT ]
then
  mkdir -p $CRONOUT
fi
exit
