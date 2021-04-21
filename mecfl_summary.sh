#!/bin/sh
VERSION=20210421

if [ $# -lt 1 ]
then
  echo 'This script requires at least one argument, [m/v]ecflow[1/2].'
  echo 'Optional arg2: check ecflog from $arg2 days before'
  exit 1
else
  arg1=$1
  if [ $# -eq 1 ]
  then
    nback=0
  else
    nback=$2
  fi
fi

       #==================================================================#
       #                                                                  #
       #  Author:   Mike Jackson                                          #
       #                                                                  #
       #  Revison History                                                 #
       #  ---------------                                                 #
       #  31 July  2020 - YL: run with a single argument for ecf server   # 
       #    1) argument is either the full name of the ecflow server      #
       #       (vecflow1, ldecflow1 etc., should contain the string       #
       #       'ecflow', or a 2-character code for one of the four        #
       #       ecf servers below:                                         #
       #                         m1 - mecflow1                            #
       #                         m2 - mecflow2                            #
       #                         v1 - vecflow1                            #
       #                         v1 - vecflow2                            #
       #    2) get IP address using 'who'                                 #
       #    3) Do not skip the sound for 'test', in honor of              #  
       #       /test/network_monitor/p35/jtransfer_hera_p3                #
       #                                                                  #
       #  xx xxx   2020 - Justin modified for telework                    #
       #  24 July  2019 - modified warning message                        #
       #  23 July  2019 - add warning if not running on production node   #
       #  10 April 2015 - removed audible alarm for jobs in /test family  #
       #                - modified reference to LOGDIR for initial        #
       #                  work file cleanup during script startup         #
       #   5 June  2013 - created                                         #
       #                                                                  #
       #------------------------------------------------------------------#

#---------------------------------
#  Which ecflow log?  
#---------------------------------
# If argument to this script contains 'ecflow' (e.g. ldecflow1 or vecflow1), 
# then assume the argument is the ecflow server: 
#
echo $arg1 | grep ecflow
err=$?
if [ $err -eq 0 ]; then 
  monitored_ecflow=$arg1
elif [ $arg1 = m1 -o $arg1 = m2 -o $arg1 = v1 -o $arg1 = v2 ]; then
  p1=`echo $arg1 | cut -c 1-1`
  s1=`echo $arg1 | cut -c 2-2`
  ecfserver=${p1}ecflow${s1}
else
  echo Unrecognized ecFlow server name or abbreviation ${arg1}.  EXIT.
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
egrep -v 'MSG.*MSG|:ecfprod|:nwprod' $ECFLOG | grep -v ':nwprod' | \
  egrep 'aborted.*reason|defstatus|force=complete|requeue|-run'  >> $sumfile

exit
