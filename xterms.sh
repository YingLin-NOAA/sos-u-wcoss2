#!/bin/ksh
#
VERSION="20220111"

# This script is a greatly simplified version of lt.sh.  It 
# pops up a number of xterms. It takes 0, 1, or 2 arguments
# No RTDB pop-up for now

#   No argument: 
#     4 white for prod
#     2 lightgoldenrod1 for Dev 
#   1 argument (n1): n1 white xterms
#   2 argument (n1, n2): n1/n2 white/gold xterms
# RTDB: no special provision for restarting it in this script since it is easy
#   to start it manually.  Note that RTDB should be restarted after 00Z during
#   an evening/night shift.  

#

#----------
#  Launch xterms
#----------
X_BG1="white"
X_BG2="lightgrey"
X_BG3="lightgoldenrod1"
X_FT="'Monospace' -fs 14" 

if [ $# -eq 0 ]
then 
  nwhite=4
  ngrey=1
  ngold=2
  rtdb=N
elif [ $# -eq 1 ]
then
  nwhite=$1
  ngold=0
  rtdb=N
elif [ $# -eq 2 ]
then
  nwhite=$1
  ngold=$2
  rtdb=N
else
  print "Number of arguments need to be 0, 1, or 2"
  exit
fi

n=1
while [ $n -le $nwhite ]
do 
  nohup  xterm -sl 5000 -sb  -bg ${X_BG1} -fa ${X_FT} &
  sleep 1
  let n=n+1
done 

n=1
while [ $n -le $ngold ]
do 
  nohup  xterm -sl 5000 -sb  -bg ${X_BG3} -fa ${X_FT} &
  sleep 1
  let n=n+1
done

if [ $rtdb = 'Y' ]
then
  ~/sos/rtdb.sh
fi
