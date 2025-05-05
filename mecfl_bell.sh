#!/bin/ksh
VERSION=20231231

if [ $# -lt 1 ]
then
  echo "$0 Usage: arg1 = machine to monitor (full name or abbreviation)"
  echo "Optional arg: nomail (skip sending email to ${USER}.noaa.gov)"
  echo "Optional arg: [sos1,sos2,sos3]: if working on site using one of the"
  echo "  linux machines, run with this argument for a 'Boing' alert when"
  echo "  there is a job failure."
  echo "Optional arg full: displays timestamps instead of dots"
  echo "Arguments can be in any order."
  exit 1
else
  SENDMAIL=YES
  LINUX=NO
  FULL=NO
  BEEP="echo -ne '\a\a\a'"

  while (("$#")); do
    case "$1" in
      [cd][12]|[cd]ecflow0[12])
	if [ ${#1} -eq 2 ]
	then
		s1=`echo $1 | cut -c 1`
		s2=`echo $1 | cut -c 2`
		monitored_ecflow=${s1}ecflow0${s2}
	else
		monitored_ecflow=$1
	fi
	shift
	;;
      noemail|nomail)
        SENDMAIL=NO
	shift
	;;
      sos[123])
	LINUX=YES
	sosn=$1
	BEEP="ssh -q wx11yl@nco-lw-${sosn} '/usr/bin/aplay -q ~wx11yl/sounds/boing.au'"
	shift
	;;
      full)
        FULL=YES
	shift
	;;
      noaudio)
	BEEP=""
	shift
	;;
      *)
	echo unknonwn argument $1
	exit 1
    esac
  done
fi

print ""
print ""
print "#==================================================================#"
print "${0} - Monitor ECFlow run log for messages of interest" 
print "VERSION ${VERSION}" 
print "#==================================================================#"
print "#                                                                  #"
print "# Scanning the ecf.log file every 20 seconds...                    #"
print "#==================================================================#"
#                                                                  #
#  Author:   Mike Jackson                                          #
#                                                                  #
#  Revison History                                                 #
#  ---------------                                                 #
#  31 Dec 2023:added line number check and			   #
#    updated arg parsing method					   #
#   3 Apr 2023: ssh from wcoss2 to lw-sos1/sos2/sos3 now works     #
#    (due to RHEL8 upgrade on the lw-sos*?).  Make the 'boing'     #
#    sound if the 2nd or 3rd argument of this script is            #
#    sos1||sos2||sos3. 
# 
#  12 Jan 2022: updated for wcoss2
#    abbreviations are d1/d2/c1/c2
#    this script is in ksh because 'print' is a korn shell command
#  11 Jan 2022: make email optional 
#  14 Jul 2021: when there is a new (non /test) error in the ecf   #
#    log, do the following:                                        # 
#      echo -en “\007”                                             #
#    to ring the bell through PuTTY.  The sound can be 'Boing' if  #
#    the boing file in .wav format is provided to PuTTY as a       #
#    custom sound file                                             #
#  30 Jun 2021: added Nitin's 'email ecflog error to cell phone    #
#                    as a text message'                            #
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

# Do not send email on the initial run - there'll be too many emailed texts. 
initrun=YES

#----------------------------
#  Set up working environment
#----------------------------
if [ $LINUX = YES ]
then
  WRKDIR=/lfs/h1/nco/ptmp/${USER}/MECFL_linux.wrk
else
  WRKDIR=/lfs/h1/nco/ptmp/${USER}/MECFL.wrk
fi

if [ -d ${WRKDIR} ]
then
  #----------------------------
  #  Remove old working files
  #----------------------------
  cd ${WRKDIR}
    for file in `ls ecf.*.log.* RECENT_ACTIVITY.* RECENT_ERROR_JOB_LIST.* RECENT_ERRORS.*`
    do
      rm $file
    done

    echo ""                                                       > README
    echo "-----------------------------------------------------" >> README
    echo "| The files in this directory are used by mecfl.sh  |" >> README
    echo "|  to monitor messages found in the ECFlow run log. |" >> README
    echo "|                                                   |" >> README
    echo "| Old versions of these files will be removed       |" >> README
    echo "|         each time mecfl.sh is started.            |" >> README
    echo "|                                                   |" >> README
    echo "|                       Thanks.                     |" >> README
    echo "-----------------------------------------------------" >> README
else
  #------------------------------
  #  Creating working directory
  #------------------------------
  mkdir -p ${WRKDIR}
fi

#-------------------
#  Define variables
#-------------------
#AUDIO="YES"

ECFDIR=/lfs/h1/ops/prod/output/ecflow
ECFLOG=$ECFDIR/ecf.$monitored_ecflow.log
ECFLOG0=$ECFDIR/ecf.$monitored_ecflow.log
ECFLOG1=$ECFDIR/log/ecf.$monitored_ecflow.log1
ECF_WORK_LOG=${WRKDIR}/ecf.$monitored_ecflow.log.$$
MECF_MESSAGES=${WRKDIR}/MECF_MESSAGES.$$
RECENT_ACTIVITY=${WRKDIR}/RECENT_ACTIVITY.$$
RECENT_ERROR_JOB_LIST=${WRKDIR}/RECENT_ERROR_JOB_LIST.$$
RECENT_ERRORS=${WRKDIR}/RECENT_ERRORS.$$
# YL in wcoss1, updatelog is produced by /prod/admin/admin/update_config
#  (under 'script' tab, it shows that updatelog=/ecf/rundir/updatelog)
#  'Manual' tab says this job backs up various /ecf dirs from primary to
#  secondary system.  Not seeing such a set up on wcoss2 now.  Deleteing
#  updatelog/checksum related stuff
# UPDATELOG_FILE="/gpfs/dell1/nco/ops/ecf/rundir/updatelog"
SERVER_SWITCH_FLAG="NO"

#--------------------
#  Assign initial values
#--------------------
LOG_ROLL="FALSE"
INITIAL_PASS="TRUE"
LOOP_DELAY=20
PREVIOUS_LINE_NUMBER=0
DOTS_TO_BE_PRINTED=60

#-------------------
#  Begin Processing
#-------------------
while true
do

  #-------------------------------------
  # Copy current ecf log to work location
  # (This is to avoid missing log lines 
  #  as the log file gets updated.)
  #-------------------------------------
  cp ${ECFLOG} ${ECF_WORK_LOG}

  #-------------------------------------
  # Get current activity from ecf log
  # - determine current number of lines
  #-------------------------------------
  CURRENT_LINE_NUMBER=`cat ${ECF_WORK_LOG} | wc -l`

  #-------------------------------------
  # Verify that the ecf.log did not roll over
  # (this happened if the current log is
  #  smaller than the previous log file)
  # 
  # If the log rolled, finish processing the
  # last lines in the old log then begin
  # processing the new file on the next cycle
  #-------------------------------------
  if [ ${CURRENT_LINE_NUMBER} -lt ${PREVIOUS_LINE_NUMBER} ]
  then
    LOG_ROLL="TRUE"
    cp ${ECFLOG1} ${ECF_WORK_LOG}
    CURRENT_LINE_NUMBER=`cat ${ECF_WORK_LOG} | wc -l`
  fi

  #----------------------------------------------
  # Determine the number of lines to process
  #----------------------------------------------
  LL=`expr ${CURRENT_LINE_NUMBER} - ${PREVIOUS_LINE_NUMBER}`

  #----------------------------------------------
  # Display message if we're just getting started
  #----------------------------------------------
  if [ "${INITIAL_PASS}" = "TRUE" ]
    then
    echo ""
    echo "`date`"
    echo "====================================================="
    echo "Reading $LL lines in ${ECFLOG}..."      
    echo "====================================================="
  fi

  #-------------------------------------
  # Grab the determined number of lines
  # from the end of the log file and place 
  # in buffer file
  #-------------------------------------
  tail -${LL} ${ECF_WORK_LOG} > ${RECENT_ACTIVITY}

  #--------------------------------------
  # Determine number of messages of interest
  #--------------------------------------
  ERROR_COUBNT="0"
  ERROR_COUNT=`egrep -i abort ${RECENT_ACTIVITY} | grep reason | wc -l`

  if [ "${ERROR_COUNT}" = "0" ]
  then
    #-------------------------------------------
    # If there aren't any messages of interest
    #  display a "." to indicate activity
    # Generate a line feed and reset the "dot" 
    #  counter after every 60 dots are displayed
    #
    # DOTS_TO_BE_PRINTED is initially set to 60.  
    #-------------------------------------------
    if [ $FULL = "YES" ]
    then
	print "$LL    \c"
	date
    else
      if [ ${DOTS_TO_BE_PRINTED} -gt 0 ]
        then
        print ".\c"
      else
        print ""
        print ".\c"
        DOTS_TO_BE_PRINTED=60
      fi # start a new line of dots? 
      DOTS_TO_BE_PRINTED=`expr ${DOTS_TO_BE_PRINTED} - 1`
    fi

    if [ $LL -lt 30 ]
    then
	echo "less than 30 lines, is $monitored_ecflow the right server or gap in activity?"
	eval $BEEP
	#echo -ne "\a\a\a"
    fi
  else # there are new failures:
    # -------------------
    # Issue a line feed
    # and display messages
    # -------------------
    print ""
    egrep -i abort ${RECENT_ACTIVITY} | grep reason

    # ------------------------
    # Audible alarms/send email if the
    # only job that has failed is in the test family
    # ------------------------
    egrep -i abort ${RECENT_ACTIVITY} | grep reason > ${RECENT_ERRORS}
    cat /dev/null > ${RECENT_ERROR_JOB_LIST}
    TRUE_ERROR_COUNT=0
    while read line
    do
      echo ${line} | awk ' { print $4 } ' | cut -c1-6 | grep -v "\/test\/"  >> ${RECENT_ERROR_JOB_LIST}
    done < "${RECENT_ERRORS}"

    TRUE_ERROR_COUNT=`cat ${RECENT_ERROR_JOB_LIST}  | wc -l`
    if [ "${TRUE_ERROR_COUNT}" = "0" ]
    then
      echo "We don't have any non-test job errors, so we won't do anything." > /dev/null
    else
      # send email alert? 
      # if this is the initial run, do not send email
      if [ "$SENDMAIL" = 'YES' ] 
      then
        if [ $initrun = 'YES' ]
        then
          initrun=NO
        else
          egrep -i abort ${RECENT_ACTIVITY} | grep reason | awk '{print $4}' | mail ${USER}@noaa.gov
        fi
      fi # send mail? 

      eval $BEEP
      #if [ "$AUDIO" = "YES" ]
      #then
        #if [ $LINUX = YES ]
        #then
          # use 'ssh -q' to quiet the 'log in' message upon connecting to sos*
          # use 'aplay -q' so it doesn't print out "Playing Sparc Audio '/usr1/wx11yl/sounds/boing.au' : Mu-Law, Rate 8000 Hz, Mono"
          #ssh -q wx11yl@nco-lw-${sosn} "/usr/bin/aplay -q ~wx11yl/sounds/boing.au"
        #else
          # BEEP repeated 3 times:
          #echo -en "\007 \007 \007"
        #fi
      #fi
      # ----------------------------
      # Reset new line "dot" counter
      # ----------------------------
      DOTS_TO_BE_PRINTED=60
    fi # Are any recent errors from the any non-test families? 
  fi

  #------------------
  # Reset any flags
  #-------------------
  INITIAL_PASS="FALSE"

  #----------------------------------------------
  # Verify that the ecf  log did not roll over
  # If the log rolled, begin processing the
  # new log at line 0 on the next cycle
  #----------------------------------------------
  if [ "${LOG_ROLL}" = "TRUE" ]
  then
    LOG_ROLL="FALSE"
    PREVIOUS_LINE_NUMBER=0
  else
    PREVIOUS_LINE_NUMBER=${CURRENT_LINE_NUMBER}
  fi

  #-------------------
  # loop delay
  #-------------------
  sleep ${LOOP_DELAY}

done # end big 'while true; do" loop
