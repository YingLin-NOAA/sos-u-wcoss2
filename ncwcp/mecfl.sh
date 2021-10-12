#!/bin/ksh
VERSION=20200308

if [ $# -ne 2 ]
then
     echo "$0 Usage: arg1 = mmirc and arg2 = machine to monitor"
     exit 1
else
    monitored_ecflow=$2
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
       #  24 July  2019 - modified warning message                        #
       #  23 July  2019 - add warning if not running on production node   #
       #  10 April 2015 - removed audible alarm for jobs in /test family  #
       #                - modified reference to LOGDIR for initial        #
       #                  work file cleanup during script startup         #
       #   5 June  2013 - created                                         #
       #                                                                  #
       #------------------------------------------------------------------#

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
ECFLOG=/gpfs/dell1/nco/ops/ecf/rundir/ecf.$monitored_ecflow.log
ECFLOG0=/gpfs/dell1/nco/ops/ecf/rundir/ecf.$monitored_ecflow.log
ECFLOG1=/gpfs/dell1/nco/ops/ecf/rundir/log/ecf.$monitored_ecflow.log1
ECF_WORK_LOG=${LOGDIR}/ecf.$monitored_ecflow.log.$$
MECF_MESSAGES=${LOGDIR}/MECF_MESSAGES.$$
PREVIOUS_SUM="`echo ${CHECKSUM}`"
RECENT_ACTIVITY=${LOGDIR}/RECENT_ACTIVITY.$$
RECENT_ERROR_JOB_LIST=${LOGDIR}/RECENT_ERROR_JOB_LIST.$$
RECENT_ERRORS=${LOGDIR}/RECENT_ERRORS.$$
UPDATELOG_FILE="/gpfs/dell1/nco/ops/ecf/rundir/updatelog"
SERVER_SWITCH_FLAG="NO"
SUM="/usr/bin/sum"

#-----------------------------------
#  Map WCOSS user names to 
#  Linux workstation login IDs
#  If the user isn't mapped
#    audio alarms cannot be enabled
#-----------------------------------
USER="`/usr/bin/whoami`"
CUT_USER="`/usr/bin/whoami | cut -c1-8`"
case ${CUT_USER} in
        "Justin.C" ) WS_USER="wx11jc" ;;
	 "Hoai.Vo" ) WS_USER="hpvo" ;;
	"Kevin.Do" ) WS_USER="kdozier" ;;
	"Keith.Li" ) WS_USER="kliddick" ;;
	"Nitin.Ga" ) WS_USER="wx11ng" ;;
	"Houmin.L" ) WS_USER="wx11hl" ;;
	"Reginald" ) WS_USER="wx11rr" ;;
	"I.M.Jack" ) WS_USER="wx11mj" ;;
	"Ying.Lin" ) WS_USER="wx11yl" ;;
	         * ) AUDIO="NO" ;;
esac
export USER WS_USER

#-----------------------------------
# Determine where we're logged in
#   so that audible alarms can be
#   sent back there
#  If the local workstation isn't 
#    identified audio alarms cannot 
#    be enabled
#    (only listed workstations are 
#      supported)
#-----------------------------------
if [ "${1}" = "" ]
then
	LAST_WS="`last | grep ${CUT_USER} | head -1 | awk ' { print $3 } '`"
	case ${LAST_WS} in
		"nco-lw-sos1.ncep" ) MMI="nco-lw-sos1.ncep.noaa.gov" ;;
		"nco-lw-sos2.ncep" ) MMI="nco-lw-sos2.ncep.noaa.gov" ;;
		"nco-lw-sos3.ncep" ) MMI="nco-lw-sos3.ncep.noaa.gov" ;;
		                 * ) AUDIO="NO" ;;
	esac
else
	MMI="${1}"
fi
export MMI

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
				echo ${line} | awk ' { print $4 } ' | cut -c1-6 | grep -v "\/test\/"  >> ${RECENT_ERROR_JOB_LIST}
			done < "${RECENT_ERRORS}"

        		TRUE_ERROR_COUNT=`cat ${RECENT_ERROR_JOB_LIST}  | wc -l`
			if [ "${TRUE_ERROR_COUNT}" = "0" ]
			then
				echo "We don't have any non-test job errors, so we won't do anything." > /dev/null
			else
				# ssh ${WS_USER}@${MMI} "/usr/bin/aplay ~wx11mj/sounds/KDE_Beep_Beep.wav ~wx11mj/sounds/KDE_Beep_Beep.wav ~wx11mj/sounds/KDE_Beep_Beep.wav" 2> /dev/null
				ssh ${WS_USER}@${MMI} "/usr/bin/aplay ~wx11mj/sounds/boing.au" 2> /dev/null
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
