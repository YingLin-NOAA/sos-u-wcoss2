#!/bin/sh
# This script sends plays the 'boing' sound on the home machine.  If run 
# locally it looks for the IP address of your current log-in session to send
# the ssh command to.  Can also be run remotely (with argument $i{home_ip}) 
# from cpecflow1/cpecflow2 to sound the alert when running the ecflow log
# monitoring script from these two machines, since cpecflow1[2] cannot ssh
# through VPN to reach the home machine. 

if [ $# -eq 0 ]
then
  home_ip=`who|grep "$USER"|grep -v localhost|tail -1|awk '{print $NF}'|sed 's/[()]//g'`
else
  home_ip=$1
fi

ssh ylin@${home_ip} "/usr/bin/afplay /Users/ylin/sounds/boing.au"
