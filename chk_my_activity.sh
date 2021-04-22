#!/bin/bash 
# Deyong Xu, 10/29/2017
# Modified 04/01/2020 by Justin Cooke for Dell ecFlow servers
#
# from /ecf/ecfutils/chk_man_activity.sh, 2020/07/21
# Purpose : 
#    Show which jobs that have been touched by SOS/SPA.
#    We want to make sure that these jobs are properly re-queued, especially when 
#    the time they were touched is right before 00Z. 
# How to run 
#   $ ./chk_man_activity.sh $ecf_server (e.g. vecflow2)
#
# YL, 2021/03/31 review my own activities on ecf UI
  
# arguments:
#   arg1 required ecflow server name
#   arg2 (optional): if not current day, look at log from  $arg2 days prior

if [ $# -eq 0 ]
then
  echo 'This script requires at least one argument, [m/v]ecflow[1/2].'
  echo 'Optional arg2: check ecflog from $arg2 days before'
  exit
else
  ecfserver=$1
  if [ $# -eq 1 ]
  then
    nback=0
  else
    nback=$2
  fi
fi 

if [ $nback -eq 0 ]
then
  LOG=/ecf/rundir/ecf.$ecfserver.log
else
  LOG=/ecf/rundir/log/ecf.$ecfserver.log${nback}
fi
day=`date +%Y%m%d -d "$nback days ago"`

if [ ! -s $LOG ]
then
  echo $LOG does not exist or is empty!
  exit
fi

outdir=/gpfs/dell1/ptmp/$USER
if [ ! -d $outdir ]
then
   mkdir -p $outdir
fi

#grep $USER $LOG | egrep -v 'NEWS|--edit_history|--file=|--server|--stats|--sync' > $outdir/chk_my_activity.$ecfserver.$day

grep -v 'MSG.*MSG' $LOG | grep $USER | \
  egrep \
  'aborted.*reason|-alter|-force|-requeue|-run|-suspend' \
  > $outdir/chk_my_activity.$ecfserver.$day

exit

