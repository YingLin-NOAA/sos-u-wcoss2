#!/bin/ksh
VERSION=20210225

if [ $# -ne 2 ]
then
     echo "$0 Usage: arg1 = machine to monitor (full name or abbreviation)"
     echo "          arg2 = mars[venus]: machine to be used to trigger alert sound on home computer"
else
     arg1=$1
     arg2=$2
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
       #  25 Feb   2021 - YL: added triggering of alert sound on home     #
       #    computer, use ssh to run a little job on either mars or venus #
       #    the job on mars/venus in turn do an ssh to trigger the alert  #
       #    sound on the home machine.                                    #
       #    $arg2 is either mars or venus (cpecflow doesn't seem to have  #
       #    /etc/prod[dev] or some other way to tell which side is        #
       #    currently prod, but either should be on since during          #
       #    a para/prod test both side should be working).                #
       #  17 Feb   2021 - YL: modified to run on cpecflow1/cpecflow2      #
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
#  Which ecflow server to monitor?
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
  monitored_ecflow=${p1}ecflow${s1}
else
  echo Unrecognized ecFlow server name or abbreviation ${arg1}.  EXIT.
fi

#----------------------------
#  Set up working environment
#----------------------------
LOGDIR=${HOME}/bin/MECFL
if [ -d ${LOGDIR} ]
then
	#----------------------------
	#  Remove old working files
	#----------------------------
	cd ${LOGDIR}
	for file in `ls ecf.*.log.* RECENT_ACTIVITY.* RECENT_ERROR_JOB_LIST.* RECENT_ERRORS.*`
	do
		rm ${file}
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
	mkdir -p ${LOGDIR}
fi

#-------------------
#  Define variables
#-------------------
AUDIO="YES"
# DEFAULT_SOUND_COMMAND="cat ~wx11mj/sounds/KDE_Beep_Beep.wav ~wx11mj/sounds/KDE_Beep_Beep.wav ~wx11mj/sounds/KDE_Beep_Beep.wav > /dev/audio"
 DEFAULT_SOUND_COMMAND="/usr/bin/aplay /usr9/wx11mj/sounds/KDE_Beep_Beep.wav /usr9/wx11mj/wx11mj/sounds/KDE_Beep_Beep.wav /usr9/wx11mj/sounds/KDE_Beep_Beep.wav"

CHECKSUM="`${SUM} ${UPDATELOG_FILE}`"
ECFLOG=/ecf/rundir/ecf.$monitored_ecflow.log
ECFLOG0=/ecf/rundir/ecf.$monitored_ecflow.log
ECFLOG1=/ecf/rundir/log/ecf.$monitored_ecflow.log1
ECF_WORK_LOG=${LOGDIR}/ecf.$monitored_ecflow.log.$$
MECF_MESSAGES=${LOGDIR}/MECF_MESSAGES.$$
PREVIOUS_SUM="`echo ${CHECKSUM}`"
RECENT_ACTIVITY=${LOGDIR}/RECENT_ACTIVITY.$$
RECENT_ERROR_JOB_LIST=${LOGDIR}/RECENT_ERROR_JOB_LIST.$$
RECENT_ERRORS=${LOGDIR}/RECENT_ERRORS.$$
UPDATELOG_FILE="/ecf/rundir/updatelog"
SERVER_SWITCH_FLAG="NO"
SUM="/usr/bin/sum"

#-----------------------------------
#  Map WCOSS user names to 
#  Linux workstation login IDs
#  If the user isn't mapped
#    audio alarms cannot be enabled
#-----------------------------------
CUT_USER="`/usr/bin/whoami | cut -c1-8`"
case ${CUT_USER} in
        "Justin.C" ) WS_USER="truby1980" ;;
	 "Hoai.Vo" ) WS_USER="hpvo" ;;
	"Kevin.Do" ) WS_USER="kdozier" ;;
	"Keith.Li" ) WS_USER="kliddick" ;;
	"Nitin.Ga" ) WS_USER="wx11ng" ;;
	"Houmin.L" ) WS_USER="wx11hl" ;;
	"Reginald" ) WS_USER="wx11rr" ;;
	"I.M.Jack" ) WS_USER="wx11mj" ;;
	"Ying.Lin" ) WS_USER="ylin" ;;
	         * ) AUDIO="NO" ;;
esac
export USER WS_USER

#-----------------------------------
# Determine where we're logged in
#   so that audible alarms can be
#   sent back there

# I've seen instances of two different IP addresses ... so using the last one, 
# which seems to be the latest log in.  
export MMI=`who|grep "$USER"|grep -v localhost|tail -1|awk '{print $NF}'|sed 's/[()]//g'`

echo "Running as ${USER} from ${WS_USER}@${MMI}"

if [ "${AUDIO}" = "YES" ]
then
	print ""
	print "#======================================#"
	print "#      AUDIBLE Alarms are enabled -    #" 
	print "#(requires \"xhost +\" & ssh on local WS)#"
	print "#======================================#"
	print ""
else
	print ""
	print "------------------------"
	print "For AUDIBLE Alarms:"
	print " add ${LAST_USER} and ${LAST_WS}"
	print " to authorized lists"
	print "------------------------"
	print ""
fi

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
        cp -p ${ECFLOG} ${ECF_WORK_LOG}

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
                cp -p ${ECFLOG1} ${ECF_WORK_LOG}
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
        	#-------------------------------------------
		if [ ${DOTS_TO_BE_PRINTED} -gt 0 ]
		then
			print ".\c"
		else
        	        #-------------------------------------------
        	        # Verify this is still the production node
        	        # If not, issue a warning message
        	        #-------------------------------------------
                        CHECKSUM="`${SUM} ${UPDATELOG_FILE}`"
                        TEST_SUM="`echo ${CHECKSUM}`"
		        if [ "${TEST_SUM}" = "${PREVIOUS_SUM}" ]
                        then 
		             if [ "${SERVER_SWITCH_FLAG}" = "YES" ]
                             then
                                  SECOND_TIME_FLAG="YES"
                             else
                                  SERVER_SWITCH_FLAG="YES"
                                  SECOND_TIME_FLAG="NO"
                             fi
                        else
                             SERVER_SWITCH_FLAG="NO"
                             PREVIOUS_SUM="`echo ${CHECKSUM}`"
                        fi
		        if [ "${SECOND_TIME_FLAG}" = "YES" ]
                        then 
                             SECOND_TIME_FLAG="NO"
                             SERVER_SWITCH_FLAG="NO"
			     print ""
			     print "There has not been any log activity in a while.  Have we switched servers?\c"
                        fi
        	        #-------------------------------------------
        	        # End of production node test section
        	        #-------------------------------------------
			print ""
			print ".\c"
			DOTS_TO_BE_PRINTED=60
		fi
		DOTS_TO_BE_PRINTED=`expr ${DOTS_TO_BE_PRINTED} - 1`
	else
		# -------------------
		# Issue a line feed
		# and display messages
		# -------------------
		print ""
        	egrep -i abort ${RECENT_ACTIVITY} | grep reason

		# ------------------------
		# Issue an audible alarm
		# ------------------------
		if [ "$AUDIO" = "YES" ]
		then
			# ------------------------
			# We don't want to sound
			# audible alarms if the
			# only job that has failed
			# is in the test family
			# ------------------------
        		egrep -i abort ${RECENT_ACTIVITY} | grep reason > ${RECENT_ERRORS}
			cat /dev/null > ${RECENT_ERROR_JOB_LIST}
			TRUE_ERROR_COUNT=0

			while read line
			do
			  #	echo ${line} | awk ' { print $4 } ' | cut -c1-6 | grep -v "\/test\/"  >> ${RECENT_ERROR_JOB_LIST}
			  	echo ${line} | awk ' { print $4 } ' | cut -c1-6  >> ${RECENT_ERROR_JOB_LIST}
			done < "${RECENT_ERRORS}"

        		TRUE_ERROR_COUNT=`cat ${RECENT_ERROR_JOB_LIST}  | wc -l`
			if [ "${TRUE_ERROR_COUNT}" = "0" ]
			then
				echo "We don't have any non-test job errors, so we won't do anything." > /dev/null
			else
				# ssh ${WS_USER}@${MMI} "/usr/bin/aplay ~wx11mj/sounds/KDE_Beep_Beep.wav ~wx11mj/sounds/KDE_Beep_Beep.wav ~wx11mj/sounds/KDE_Beep_Beep.wav" 2> /dev/null
				ssh ${USER}@${arg2} "/u/$USER/sos/ring_bell.sh ${MMI}"

			fi
		fi
		# ----------------------------
		# Reset new line "dot" counter
		# ----------------------------
		DOTS_TO_BE_PRINTED=60
	fi

 	#-------------------
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
 	# Set the loop delay
 	#-------------------
 	sleep ${LOOP_DELAY}

done

