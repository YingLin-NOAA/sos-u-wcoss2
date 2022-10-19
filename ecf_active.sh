#!/bin/sh 
# Script to produce either a static snapshot or the last 10 PBS jobs going
# active, for either the primary/backup system (updated every 15s), from the 
# prod ecflog.  
if [ $# -lt 3 ]
then
  echo This script needs three arguments: c1/c2/d1/d2, primary/backup, snap/tail
  exit
else
  arg1=$1
  arg2=$2
  arg3=$3
fi

if [[ $arg1 = 'c1' || $arg1 = 'c2' || $arg1 = 'd1' || $arg1 = 'd2' ]]
then 
  p1=`echo $arg1 | cut -c 1-1`
  s1=`echo $arg1 | cut -c 2-2`
  ecf_server=${p1}ecflow0${s1}
else
  echo $arg1 is not among c1/c2/d1/d2, EXIT
  exit
fi

ecfdir=/lfs/h1/ops/prod/output/ecflow
ecflog=ecf.${ecf_server}.log

wrkdir=/lfs/h1/nco/stmp/$USER
if [ ! -d $wrkdir ]; then mkdir $wrkdir; fi

if ! [[ $arg2 = 'primary' || $arg2 = 'backup' ]]
then 
  echo $arg2 is neither primary nor backup, EXIT
  exit
fi

if [ $arg3 = 'snap' ]
then  
  snapshot=$wrkdir/$ecflog.active
  grep ' active: ' $ecfdir/$ecflog | grep "/$arg2" | grep -v ecflocal | grep -v spa_on_call > $snapshot
  echo See snapshot in $snapshot

elif [ $arg3 = 'tail' ]
then
  watch --interval 15 "grep ' active: ' $ecfdir/$ecflog | grep "/$arg2" | grep -v ecflocal | grep -v spa_on_call | tail" 

fi


