#!/bin/sh
VERSION=20210421

  #=======================================================================#
  #                                                                       #
  #  Purpose: extracting abort messages and human interventions from      #
  #    a day's ecflow log.                                                #
  #    This is a simplified combination of mecfl.sh and chk_man_activity  #
  #    Human (non-nwprod, non-ecfprod) actions listed:                    #
  #      --alter (e.g. --alter change defstatus complete, etc.)           #
  #      --force=complete                                                 #
  #      --requeue force                                                  #
  #      --run                                                            #
  #      --suspend                                                        #
  #                                                                       #
  #  Usage:                                                               #
  #    Arg1: name of ecflow server, or a 2-character code for one of      # 
  #      the four ecf servers below:                                      #
  #         m1 - mecflow1                                                 #
  #         m2 - mecflow2                                                 #
  #         v1 - vecflow1                                                 #
  #         v1 - vecflow2                                                 #
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
if [ $# -lt 1 ]
then
  echo 'This script requires at least one argument, [m/v]ecflow[1/2].'
  echo 'Optional arg2: check ecflog from $arg2 days before'
  exit
else
  arg1=$1
  echo $arg1 | grep ecflow
  err=$?
  if [ $err -eq 0 ]; then 
    ecfserver=$arg1
  elif [ $arg1 = m1 -o $arg1 = m2 -o $arg1 = v1 -o $arg1 = v2 ]; then
    p1=`echo $arg1 | cut -c 1-1`
    s1=`echo $arg1 | cut -c 2-2`
    ecfserver=${p1}ecflow${s1}
  else
    echo Unrecognized ecFlow server name or abbreviation \"${arg1}\".  EXIT.
    exit
  fi

  if [ $# -eq 1 ]
  then
    nback=0
  else
    nback=$2
  fi
fi

LOGDIR=/ecf/rundir
if [ $nback -eq 0 ]
then
  ECFLOG=$LOGDIR/ecf.$ecfserver.log
else
  ECFLOG=$LOGDIR/log/ecf.$ecfserver.log${nback}
fi
day=`date +%Y%m%d -d "$nback days ago"`

outdir=/gpfs/dell1/ptmp/$USER
if [ ! -d $outdir ]
then
   mkdir -p $outdir
fi

sumfile=$outdir/$ecfserver.sum.$day
if [ -s $sumfile ]
then
  rm -f $sumfile
fi
	
#----------------------------------------------
# Display message if we're just getting started
#----------------------------------------------

#grep -v 'MSG.*MSG' $ECFLOG | grep -v ':nwprod' | \
egrep -v 'MSG.*MSG|-alter change label|:ecfprod|:nwprod' $ECFLOG | \
  egrep \
  'aborted.*reason|-alter|-force|-requeue|-resume|-run|-suspend' \
  >> $sumfile

exit
