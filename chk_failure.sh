#!/bin/sh
# 1. check job *.o file for a list of known error messages 
# 2. check model name in (downloaded daily by cron) Special Procedures
# 3. (under development) check various output files in output dir for node_failed
#    info
# 4. save wrkdir using Hoai's script (optional)
# 
# Arguments:
#   1. Job output file (required)
#   2. nosave: do not save working directory, if optional 2nd argument is 
#      'nosave'.  
#
# 'sort -u' so that if there are, say hundreds of identical lines of 'SIGSEGV',
#   only one will print out.
#
# Per Eric Rogers in re NAM code issue, most aborts trigger prints in the 
# microphysics that Brad added, with "WARN#" at the start of the message. 
# 'WARN1" messages are not a problem, they pop up occasionally almost every 
# run due to relatively large amounts of moisture in the stratosphere. But if 
# you see lots of WARN# (WARN4 is usually bad) and then prints that start 
# with "{}" then we got problems.
# Remove this for now - runhistory has legit '{}'s.  
#    -e {} \
# if failure is nam forecast related, search for {} in vi.

# Note that 'FATAL ERROR' does not necessarily mean that's the cause for job
# failure.  Plenty of successfully completed jobs have 'FATAL ERROR' in the
# output when wgrib2 is used on a non-existant but optional input file. 
# 

# Special procedures are downloaded daily (cron'd wget):
SPC_PRC=/gpfs/dell1/ptmp/$USER/Special_Procedures

suffix=`date +%Y%m%d_%H%MZ`

if [ $# -eq 0 ]; then
  echo This script needs at least one argument: /path/*.o\$pid.  Exit
  exit
else
  output_file=$1

  # first see if the job has been preempted, if so, skip the rest:
  grep TERM_PREEMPT $output_file
  err=$?
  if [ $err -eq 0 ]; then exit; fi
 
  # find model name; strip off trailing numbers (e.g. 'hmon2'):
  modelx=`basename ${output_file} | awk -F "_" '{print $1}'`
  model=${modelx//[0-9]/}
  grep -i \
    -e 'abnormal exit' \
    -e 'aborting execution on processor' \
    -e 'Abort trap signal' \
    -e 'broken pipe' \
    -e 'claim exceeds' \
    -e 'connection timed out' \
    -e 'core dump' \
    -e 'could not find' \
    -e 'connection unexpectedly closed' \
    -e 'CRITICAL:' \
    -e 'CRITICAL FAILURE' \
    -e 'DATACOUNT low on 1 or more CRITICAL ob type' \
    -e 'dump failed' \
    -e 'end-of-file during read' \
    -e 'err=[1-999]' \
    -e 'Error reading' \
    -e 'exit signal aborted' \
    -e failed \
    -e 'failed with exit code' \
    -e fatal \
    -e 'HPSS_ENOENT' \
    -e 'io timeout' \
    -e 'IOError' \
    -e killed \
    -e missing \
    -e 'no route to host' \
    -e 'no such file or directory' \
    -e 'No GEMPAK parameter name defined for this grid' \
    -e 'PROBLEM ARCHIVING' \
    -e 'RC=[1-999]' \
    -e 'refusing to create empty archive' \
    -e 'rsync error' \
    -e Sev1 \
    -e severe \
    -e 'target_IP=' \
    -e Terminated \
    -e SIGSEGV \
    -e 'unable to set' \
    -e 'User defined signal' \
    -e WARN4 \
    ${output_file} | sort -u

  # Is there an entry in the Special Procedures for $model?
  grep -i "\ $model" ${SPC_PRC} > /dev/null
  err=$?
  if [ $err -eq 0 ]; then
    echo 
    echo $model has entry in Special Procedures
    echo
  fi

  # Anything place other than the *.o file to look for errors?
  data_dir=`grep " DATA=" ${output_file} | head -1 | cut -d "=" -f 2`
  # for hmonx_couple_forecast:
  if [[ "${output_file}" == *hmon* && "$output_file" == *forecast* ]]
  then
    moreout=${data_dir}/forecast/err.forecast
    grep -i node_failed $moreout
    if [ $? -eq 0 ] 
    then 
      echo in $moreout
    fi
  fi 

  if [ $# -eq 2 ]
  then
    saveopt=$2
    if [ $saveopt = 'nosave' ];
    then 
      exit
    fi
  fi 

  odisk=`echo $output_file | cut -c 7-9`
  if [ $odisk = del ]
  then
    dest="/gpfs/dell3/ptmp/nwprod"
  elif [ $odisk = hps ]
  then
    dest="/gpfs/hps3/ptmp/nwprod"
  else
    echo *.o file is not on /gpfs/dell1/ or /gpfs/hps/. Exit w/o saving wrkdir.
    exit
  fi 
  echo "extracting data directory from ${output_file}"
  
  filename=`basename ${data_dir}`
  echo "sudo -u nwprod cp -rp ${data_dir} ${dest}/${filename}_${suffix}"
  sudo -u nwprod cp -rp ${data_dir} ${dest}/${filename}_${suffix}

fi

exit

