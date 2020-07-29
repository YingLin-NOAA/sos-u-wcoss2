#!/bin/bash 
# Deyong Xu, 10/29/2017
# Modified 04/01/2020 by Justin Cooke for Dell ecFlow servers
#
# from /ecf/ecfutils/chk_man_activity.sh, 2020/07/21
# Purpose : 
#    Show which jobs that have been touched by SOS/SPA.
#    We want to make sure that these jobs are properly re-queued, especially when 
#    the time they were touched is right before 00Z. 
# How to run 
#   $ ./chk_man_activity.sh $ecf_server (e.g. vecflow2)
#  

ECF_EXEC_ROOT=$(readlink -f /ecf)

function header {
echo -e "\n This is to show the jobs that have been touched by SOS/SPA. "
echo  " We want to make sure that these jobs are properly re-queued, "
echo  " especially when the time they were touched is right before 00Z.  "
echo  "    - No checking on TEST jobs !!!"
echo  "    - It is designed to FAIL to remind P-shift SOS to check these"
echo  "      job requeued properly shortly after 00Z each day."
echo  ""
echo  "Tips : Double-click label 'info' to bring out a detached Label-Edit window"
echo  "       so you can examine them easily."
echo  ""
echo  "Current Time : `date +%Y/%m/%d" "%H%MZ`"
}

function shortenMsg {
   # Input line containing pattern like "--force=queued" or "--run"
   local line="$1"
   # Break into two parts and remove multiple MSG info in part1
   local part1=`echo $line | cut -d"-" -f1 | cut -d"]" -f1`
   part1=${part1}"]"
   local part2=`echo $line | cut -d"-" -f3 `
   part2=" --"${part2}
   # Return a newly constructed line after remove multiple MSG info.
   echo ${part1}${part2}
}

# ----  end of local func definition -------------------------

#-----------------------
# Main code starts here.
#-----------------------

# List header 
header

# Determine active ecFlow host
#extHostname=$(${ECF_EXEC_ROOT}/ecfutils/exthostname.pl)
extHostname=$1

# Define two arrays 
# Ecflow log file descriptions
#desp_arr=('1. Today log : /ecf/rundir/ecf.log '  '2. Previous day log : /ecf/rundir/log/ecflog1')
desp_arr=("1. Today log : /ecf/rundir/ecf.$extHostname.log "  "2. Previous day log : /ecf/rundir/log/ecf.$extHostname.log1")
# Ecflow log files
log_arr=("/ecf/rundir/ecf.$extHostname.log"  "/ecf/rundir/log/ecf.$extHostname.log1")

# Get the size of the array
size=${#log_arr[@]} 

# Loop thru. the array defined above and search for forced CHANGEs and RUNs.
# Array is 0-base index.
for logIndex in $(seq 0 1 $[$size-1])
do 
   log_file=${log_arr[$logIndex]}
   log_desc=${desp_arr[$logIndex]}

   echo  ""
   echo  "************************************************"
   echo  "$log_desc"
   echo  "************************************************"

   # Searched keywords desription 
   kw_desp_arr=("Forced 'CHANGE'"  "Forced 'RUN'")
   # Searched keywords
   kw_arr=('force'  '--run')

   # Get array size of keywords
   size2=${#kw_arr[@]} 
   
   # Loop thru. keywords
   for kwIndex in $(seq 0 1 $[$size2-1])
   do 
      echo  "------------------------------------"
      echo  "($[$kwIndex+1]):  ${kw_desp_arr[$kwIndex]} : " 
      echo  "------------------------------------"
      # Find jobs being forced (CHANGE/RUN) by SOS or SPA
      msg=`grep -e "${kw_arr[$kwIndex]}" ${log_file} | grep -ve ":nwprod" | grep -ve " /test"` 

      # Check if $msg is not empty. "Not empty" means there are some activities.
      if [ -n "$msg" ] 
      then 
         # Define tmp files
         tmpFile=~/chk_man_activity.$$
         tmpFile2=~/chk_man_activity2.$$
         tmpFile3=~/chk_man_activity3.$$
         [ -f $tmpFile ] && rm -rf $tmpFile 
         [ -f $tmpFile2 ] && rm -rf $tmpFile2 
         [ -f $tmpFile3 ] && rm -rf $tmpFile3 

         # Find all the activies and pipe out the result into a tmp file line-by-line
         grep -e "${kw_arr[$kwIndex]}" ${log_file} | grep -ve ":nwprod" | grep -ve "'"| grep -ve " /test"  >$tmpFile  2>>$tmpFile
  
         # Read back result line-by-line so each lie won't be too long as ecflow label.
         # Ecflow label seems to have a limit on how long a label string can be. 
         # Without this limitation, the code could be simplified much further. 
         while read LINE 
         do 
	    # Exclude entries that have multiple MSG info block / MSG time stamps.
	    # EG: Search pattern "MSG:[13:00:17 30.10.2017] MSG:[12:56:48 30.10.2017] "
            # EG : multiple MSG info blocks. 
	    # "MSG:[13:00:17 30.10.2017] MSG:[12:56:48 30.10.2017] "
	    # "MSG:[13:00:17 3.10.2017] MSG:[12:56:48 30.10.2017] "
	    # "MSG:[13:00:17 30.1.2017] MSG:[12:56:48 30.10.2017] "
	    # "MSG:[13:00:17 3.1.2017] MSG:[12:56:48 30.10.2017] "
            # Four different patterns : month and day could be 1-digit or 2-digit.
	    # "MSG:[13:00:17 30.10.2017] MSG:["
	    # "MSG:[13:00:17 3.10.2017] MSG:["
	    # "MSG:[13:00:17 30.1.2017] MSG:["
	    # "MSG:[13:00:17 3.1.2017] MSG:["
	    rePat="MSG:[[][0-9][0-9]:[0-9][0-9]:[0-9][0-9][[:space:]][0-9][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9][]][[:space:]]MSG:[[]"
	    rePat2="MSG:[[][0-9][0-9]:[0-9][0-9]:[0-9][0-9][[:space:]][0-9].[0-9][0-9].[0-9][0-9][0-9][0-9][]][[:space:]]MSG:[[]"
	    rePat3="MSG:[[][0-9][0-9]:[0-9][0-9]:[0-9][0-9][[:space:]][0-9][0-9].[0-9].[0-9][0-9][0-9][0-9][]][[:space:]]MSG:[[]"
	    rePat4="MSG:[[][0-9][0-9]:[0-9][0-9]:[0-9][0-9][[:space:]][0-9].[0-9].[0-9][0-9][0-9][0-9][]][[:space:]]MSG:[[]"
	    if [[ "$LINE" =~ $rePat ]] || [[ "$LINE" =~ $rePat2 ]] || [[ "$LINE" =~ $rePat3 ]] || [[ "$LINE" =~ $rePat4 ]]
	    then
               # SKip lines that have multiple MSG blocks.
               continue
            else
               # Save lines that has ONLY one MSG block.
               echo $LINE  >> $tmpFile2 
	    fi
         done < $tmpFile

         # Remove "duplicate lines" if any.
         # $tmpFile2 contains entires with ONLY one MSG block, so does $tmpFile3.
         [ -f $tmpFile2 ] && cat $tmpFile2  | sort |  uniq   > $tmpFile3

         # Print line as ecflow label.
         if [ -f $tmpFile3 ]
         then 
	    while read line
	    do
	       echo $line
	    done < $tmpFile3
         else 
            # No line with ONLY one MSG block found.
            echo "None found!"
         fi

         # Remove all tmp files if existing.
         [ -f $tmpFile ] && rm -rf $tmpFile 
         [ -f $tmpFile2 ] && rm -rf $tmpFile2 
         [ -f $tmpFile3 ] && rm -rf $tmpFile3 
      else 
         # Keyword NOT found.
         echo "None found!"
      fi  
       
      echo 
   done   # Loop thru. keywords
done      # Loop thru. log files
