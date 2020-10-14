#!/bin/bash
# little clock script originally from Justin
while [ true ]
do
 curr_time=`date -u "+%a %d %b %H:%M:%S"Z`
 echo $curr_time
 sleep 1
 clear
done
