#!/bin/sh
if [ $# -eq 0 ]
then
  Echo This script needs an argument, c1/c2/d1/d2
  exit
else
  arg1=$1
fi

p1=`echo $arg1 | cut -c 1-1`
s1=`echo $arg1 | cut -c 2-2`
ecf_server=${p1}ecflow0${s1}

ecfdir=/lfs/h1/ops/prod/output/ecflow
ecflog=$ecfdir/ecf.${ecf_server}.log

tail -1000 $ecflog | grep active | grep -v ecflocal | grep -v backup | grep -v spa_on_call 
tail -f $ecflog | grep active | grep -v ecflocal | grep -v backup | grep -v spa_on_call



