#!/bin/sh
VERSION=20220210

  #=======================================================================#
  #                                                                       #
  #  Purpose: extracting abort messages and human interventions from      #
  #    a day's ecflow log.                                                #
  #    This is a simplified combination of mecfl.sh and chk_man_activity  #
  #    Human (non-nwprod, non-ecfprod) actions listed:                    #
  #      --alter (e.g. --alter change defstatus complete, etc.)           #
  #      --force (=complete, queued)                                      #
  #      --kill                                                           #
  #      --requeue                                                        #
  #      --resume                                                         #
  #      --run                                                            #
  #      --suspend                                                        #
  #      submit_file (i.e. --edit_script= ... submit_file)                #
  #                                                                       #
  #  Usage:                                                               #
  #    Arg1: name of ecflow server, or a 2-character code for one of      # 
  #      the four ecf servers below:                                      #
  #         c1 - decflow01                                                 #
  #         c2 - decflow02                                                 #
  #         d1 - decflow01                                                 #
  #         d2 - decflow02                                                 #
  #      if no argument is present, the (current) ecflow server name is   #
  #        extracted from /ecf/rundir/switch_ecflow.log                   #
  #    Arg2 (optional): N (days prior to today)                           #
  #                                                                       #
  #  Example:                                                             #
  #    "ecflog_summary.sh m1" produces a list of ecf failures and human   #
  #      actions in /gpfs/dell1/ptmp/$USER/mecflow1.sum.$today            #
  #    "ecflog_summary.sh m1 1" produces the list mecflow1.sum.$daym1     #
  #  Author:   Ying Lin                                                   #
  #  Revison History                                                      #
  #    21 Apr 2021 - created, from a simplified version of                #
  #      mecfl_home_yl.sh and my chk_man_activity.sh                      #
  #                                                                       #
  #=======================================================================#

#---------------------------------
#  Which ecflow log?  
#---------------------------------
# If argument to this script contains 'ecflow' (e.g. ldecflow1 or vecflow1), 
# then assume the argument is the ecflow server: 
#
if [ $# -eq 0 ]
then
  echo 'Needs at least one argument, e.g. decflow01 or d1'
  exit
  #ecfserver=`tail -1 /ecf/rundir/switch_ecflow.log | awk '{print $5}'`
  #shortecfname=${ecfserver:0:1}${ecfserver: -1}
else
  arg1=$1
  echo $arg1 | grep ecflow0
  err=$?
  if [ $err -eq 0 ]; then 
    ecfserver=$arg1
    shortecfname=${ecfserver:0:1}${ecfserver: -1}
  elif [ $arg1 = c1 -o $arg1 = c2 -o $arg1 = d1 -o $arg1 = d2 ]; then
    shortecfname=$arg1
    p1=${arg1:0:1}
    s1=${arg1: -1}
    echo 'p1, s1=', $p1, $s1
    ecfserver=${p1}ecflow0${s1}
  else
    echo Unrecognized ecFlow server name or abbreviation \"${arg1}\".  EXIT.
    exit
  fi
fi

if [ $# -lt 2 ]
then
  nback=0
else
  nback=$2
fi

LOGDIR=/lfs/h1/ops/prod/output/ecflow
if [ $nback -eq 0 ]
then
  ECFLOG=$LOGDIR/ecf.$ecfserver.log
else
  ECFLOG=$LOGDIR/log/ecf.$ecfserver.log${nback}
fi
day=`date +%Y%m%d -d "$nback days ago"`

outdir=/lfs/h1/nco/ptmp/$USER
if [ ! -d $outdir ]
then
   mkdir -p $outdir
fi

sumfile=$outdir/$day.$shortecfname
if [ -s $sumfile ]
then
  rm -f $sumfile
fi
	
#----------------------------------------------
# Display message if we're just getting started
#----------------------------------------------

egrep -v 'MSG.*MSG|-alter change label|:ops.prod' $ECFLOG | \
  egrep \
  'aborted.*reason|-alter|-force|-kill|-requeue|-resume|-run|-suspend|submit_file' \
  >> $sumfile

# Print out $sumfile so alias 'logv' can go directly to view it.  Wait for a second, else 'view +' in logv won't get the latest 
# version of this job's output:
echo $sumfile
sleep 1
exit
