#!/bin/ksh
#
VERSION="20191210"
#

DO_CRAY="NO"
DO_DELL="NO"
DO_WCOSS="NO"
HOST_LETTER="`hostname | cut -c1`"
case ${HOST_LETTER} in
	"l" ) HOST="luna"
		DO_CRAY="YES"
		CRAY_MONITOR_NODE="lmon001"
		;;
	"m" ) HOST="mars"
		DO_DELL="YES"
		;;
	"s" ) HOST="surge"
		DO_CRAY="YES"
		CRAY_MONITOR_NODE="smon001"
		;;
	"v" ) HOST="venus"
		DO_DELL="YES"
		;;
	  * ) echo "We're not on luna,mars,surge, or venus.  Where are we?!"
	      echo "Please modify ${0} to support `hostname`"
	      echo "Exiting..."
	      echo ""
	      exit 1
		;;
esac

#
#----------
#  Set environment
#----------
BASEPATH="`dirname ${0}`"
echo ${BASEPATH}
if [ -f ${BASEPATH}/lt_prep.sh ]
then
	. ${BASEPATH}/lt_prep.sh
else
	. /u/nwprod/TOOLS/lt_prep.sh
fi

#
#----------
#  Launch ECFlow Clients
#----------
if [ "${DO_WCOSS}" = "YES" ]
then
	#-----------------------
	# old ecflowview
	#-----------------------
	# nohup  xterm -geometry ${XTERM_DIM_ECF1} -sl 5000 -sb  -bg ${ECFLOW_BG} -fg ${ECFLOW_FG} -e "ssh -Y ${ECFLOW1} '. /etc/bashrc; . ~/.bashrc; . ~/.bash_profile; echo $PATH; module load ecflow;  module unload ecflow; module load ecflow/4.7.1; ecflowview'" &
	# sleep 1
	# nohup  xterm -geometry ${XTERM_DIM_ECF2} -sl 5000 -sb  -bg ${ECFLOW_BG} -fg ${ECFLOW_FG} -e "ssh -Y ${ECFLOW2} '. /etc/bashrc; . ~/.bashrc; . ~/.bash_profile; echo $PATH; module load ecflow;  module unload ecflow; module load ecflow/4.7.1; ecflowview'" &
	# sleep 1
	#-----------------------
	# new ecflow_ui
	#-----------------------
	nohup  xterm -geometry ${XTERM_DIM_ECF1} -sl 5000 -sb  -bg ${ECFLOW_BG} -fg ${ECFLOW_FG} -e "ssh -Y ${ECFLOW1} '. /etc/bashrc; . ~/.bashrc; . ~/.bash_profile; echo $PATH; module load ecflow;  module unload ecflow; module load ecflow/4.7.1; /ecf/ecfdir/ecflow.v4.7.1.gnu/bin/ecflow_ui'" &
	sleep 1
	nohup  xterm -geometry ${XTERM_DIM_ECF2} -sl 5000 -sb  -bg ${ECFLOW_BG} -fg ${ECFLOW_FG} -e "ssh -Y ${ECFLOW2} '. /etc/bashrc; . ~/.bashrc; . ~/.bash_profile; echo $PATH; module load ecflow;  module unload ecflow; module load ecflow/4.7.1; /ecf/ecfdir/ecflow.v4.7.1.gnu/bin/ecflow_ui'" &
	sleep 1
fi
#----------
#  Older versions for reference
#----------
# module load ecflow; /ecf/ecfdir/ecflow_3_1_9/bin/ecflowview
# module load ecflow; /ecf/ecfdir/ecflow_3_1_9/bin/ecflowview
# module load ecflow/4.1.0

#----------
#  Launch job failure
#  monitor script
#----------
if [ "${DO_WCOSS}" = "YES" ]
then
	nohup xterm -geometry ${XTERM_DIM_MECFL1} -sl 5000 -sb -bg ${ECFLOW_BG} -fg ${ECFLOW_FG} -e "ssh -Y ${ECFLOW1} 'cd /u/ecfprod/TOOLS/MECFL; ./mecfl.sh ${MMI} ${ECFLOW1}'" &
	sleep 1
	nohup xterm -geometry ${XTERM_DIM_MECFL2} -sl 5000 -sb -bg ${ECFLOW_BG} -fg ${ECFLOW_FG} -e "ssh -Y ${ECFLOW2} 'cd /u/ecfprod/TOOLS/MECFL; ./mecfl.sh ${MMI} ${ECFLOW2}'" &
	sleep 1
fi

#----------
#  Launch xterms
#----------
nohup  xterm -geometry ${XTERM_DIM01} -sl 5000 -sb  -bg ${XTERM_BG1} -fg ${XTERM_FG1}   &
sleep 1
nohup  xterm -geometry ${XTERM_DIM02} -sl 5000 -sb  -bg ${XTERM_BG2} -fg ${XTERM_FG2}   &
sleep 1
nohup  xterm -geometry ${XTERM_DIM03} -sl 5000 -sb  -bg ${XTERM_BG2} -fg ${XTERM_FG2}   &
sleep 1
nohup  xterm -geometry ${XTERM_DIM04} -sl 5000 -sb  -bg ${XTERM_BG2} -fg ${XTERM_FG2}   &
sleep 1
nohup  xterm -geometry ${XTERM_DIM05} -sl 5000 -sb  -bg ${XTERM_BG2} -fg ${XTERM_FG2}   &
sleep 1
nohup  xterm -geometry ${XTERM_DIM06} -sl 5000 -sb  -bg ${XTERM_BG2} -fg ${XTERM_FG2}   &
sleep 1
#nohup  xterm -geometry ${XTERM_DIM07} -sl 5000 -sb  -bg ${XTERM_BG2} -fg ${XTERM_FG2}   &
#sleep 1
#nohup  xterm -geometry ${XTERM_DIM08} -sl 5000 -sb  -bg ${XTERM_BG2} -fg ${XTERM_FG2}   &
#sleep 1
if [ "${DO_WCOSS}" = "YES" ]
then
	nohup  xterm -geometry ${XTERM_DIM09} -sl 5000 -sb  -bg ${XTERM_BG3} -fg ${XTERM_FG3} -e "ssh -Y ${ECFLOW1}" &
	sleep 1
	nohup  xterm -geometry ${XTERM_DIM10} -sl 5000 -sb  -bg ${XTERM_BG3} -fg ${XTERM_FG3} -e "ssh -Y ${ECFLOW2}" &
	sleep 1
fi

#----------
#  Launch SEV
#  monitor script
#----------
# if [ "${DO_WCOSS}" = "YES" ]
# then
#	nohup xterm -geometry ${XTERM_DIM_WSEV} -sl 5000 -sb -bg ${XTERM_BG4} -fg ${XTERM_FG4} -e "cd /u/nwprod/TOOLS/WCSEV; ./wcsev.sh" &
#	sleep 1
# fi
# if [ "${DO_CRAY}" = "YES" ]
# then
# 	echo "Launching SEV monitor script..."
# 	echo " xterm -geometry ${XTERM_DIM_WSEV} -sl 5000 -sb -bg ${XTERM_BG4} -fg ${XTERM_FG4} -e cd /u/nwprod/TOOLS/CWSEV; ./ccsev.sh &"
# 	nohup xterm -geometry ${XTERM_DIM_WSEV} -sl 5000 -sb -bg ${XTERM_BG4} -fg ${XTERM_FG4} -e "cd /u/nwprod/TOOLS/CWSEV; ./ccsev.sh" &
# 	sleep 1
# fi

#----------
#  Launch Job Timeout Monitor
#----------
if [ "${DO_WCOSS}" = "YES" ]
then
	nohup  xterm -geometry ${XTERM_DIM_WCJTO} -sl 5000 -sb  -bg ${XTERM_BG3} -fg ${XTERM_FG3} -e "export TERM=xterms; cd /u/nwprod/TOOLS/WCJTO; ./wcjto.sh # (${HOST})" &
	else
	nohup  xterm -geometry ${XTERM_DIM_WCJTO} -sl 5000 -sb  -bg ${XTERM_BG6} -fg ${XTERM_FG6} -e "export TERM=xterms; cd /u/nwprod/TOOLS/CCJTO; ./ccjto.sh # (${HOST})" &
fi
if [ "${DO_DELL}" = "YES" ]
then
        nohup  xterm -geometry ${XTERM_DIM_DCJTO} -sl 5000 -sb  -bg ${XTERM_BG3} -fg ${XTERM_FG3} -e "export TERM=xterms; cd /u/nwprod/TOOLS/DCJTO; ./dcjto.sh # (${HOST})" &
fi

sleep 1

if [ "${DO_WCOSS}" = "YES" ]
then
	if [ -f /u/nwprod/TOOLS/launch_wcoss_dashboard.sh ]
	then
		nohup /u/nwprod/TOOLS/launch_wcoss_dashboard.sh ${HOST} ${XTERM_DIM_DB} &
	else
		if [ -f /u/nwprod/TOOLS/launch_wcoss_dashboard.sh ]
		then
			nohup /u/nwprod/TOOLS/launch_wcoss_dashboard.sh ${HOST} ${XTERM_DIM_DB} &
		fi
	fi
fi
