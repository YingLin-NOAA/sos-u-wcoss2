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
#      nosudo: save under own username (in case sudo to ops.prod is not working)
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
# Add this for wcoss2 later.
# SPC_PRC=/gpfs/dell1/ptmp/$USER/Special_Procedures

# 2024/01/31
#   Added 'nosudo' option, in case sudo isn't working, files will be saved
#   under username in */ptmp/ops.prod/, rather than as ops.prod. 
# 2023/09/26
#   Changed 'sudo -u ops.prod cp -rp ...' 
#        to 'sudo -u ops.prod -i cp -rp ...'
#   w/o the -i the sudo no longer worked, due to RFC 11607:
#     'Add more parm_access control of su and sudo'
# 2023/01 
#   use 'grep -a' in case job log contains binary character(s): looking at you,
#   petss_postprob! 

alias grep='grep -a'

suffix=`date +%Y%m%d_%H%MZ`

if [ $# -eq 0 ]; then
  echo This script needs at least one argument: /path/*.o\$pid.  Exit
  exit
else
  output_file=$1

  if [ ! -s $output_file ]
  then
    echo $output_file does not exist! 
    exit
  fi

  # first see if the job has been preempted, if so, skip the rest:
  grep TERM_PREEMPT $output_file
  err=$?
  if [ $err -eq 0 ]; then exit; fi

  # Also check for hardware failure (no route to host), skip the rest if found:
  grep -i 'no route to host' $output_file | sort -u
  err=${PIPESTATUS[0]}
  if [ $err -eq 0 ] 
  then 
    grep -i 'killing job' $output_file
    exit
  fi

  # if the job output file contains hyspt_canned_post, and the error message
  # is "HYSPLIT output DID NOT mirror successfully to", print out the lines
  # containing this err msg.
  echo $output_file | grep hyspt_canned_post 
  err1=$?
  if [ $err1 -eq 0 ]; then
    # proceed if the otuput file does contain the 'DID NOT mirror' message
    # (supress outout of matching line here (-q), check $? to see if there
    # is a match:
    grep -q 'HYSPLIT output DID NOT mirror successfully' $output_file
    err2=$?
    if [ $err2 -eq 0 ]; then
      line0=`grep -n 'HYSPLIT output DID NOT mirror successfully' $output_file | head -1 | awk -F ":" '{ print $1 }'`
      let line1=line0-1
      let line2=line0+4
      sed -n ${line1},${line2}p $output_file
      exit
    fi 
  fi
  
  # jcfs_cdas_vrfyfits:
  #    BUFR ARCHIVE LIBRARY ABORT
  #    selecetfile cannot id filetype 

  # find model name; strip off trailing numbers (e.g. 'hmon2'):
  modelx=`basename ${output_file} | awk -F "_" '{print $1}'`
  model=${modelx//[0-9]/}
  grep -i \
    -e 'abnormal exit' \
    -e 'aborting execution on processor' \
    -e 'Abort trap signal' \
    -e 'bad file descriptor' \
    -e 'broken pipe' \
    -e 'BUFR ARCHIVE LIBRARY ABORT' \
    -e 'claim exceeds' \
    -e 'command timeout' \
    -e 'connection timed out' \
    -e 'core dump' \
    -e 'could not find' \
    -e 'connection unexpectedly closed' \
    -e 'CRITICAL:' \
    -e 'CRITICAL FAILURE' \
    -e 'DATACOUNT low on 1 or more CRITICAL ob type' \
    -e 'Disk quota exceeded' \
    -e 'dump failed' \
    -e 'end-of-file during read' \
    -e 'err=[1-999]' \
    -e 'ERROR'\
    -e 'Error reading' \
    -e 'exit signal aborted' \
    -e failed \
    -e 'failed with exit code' \
    -e fatal \
    -e 'file not found' \
    -e 'HPSS_ENOENT' \
    -e 'invalid' \
    -e 'io timeout' \
    -e 'IOError' \
    -e killed \
    -e 'killing job' \
    -e 'launch RPC: Couldn' \
    -e missing \
    -e 'MPI_Abort' \
    -e ' NaN ' \
    -e 'No space left' \
    -e 'no such file or directory' \
    -e 'No GEMPAK parameter name defined for this grid' \
    -e 'OSError:' \
    -e 'Permission denied' \
    -e 'PROBLEM ARCHIVING' \
    -e 'RC=[1-999]' \
    -e 'refusing to create empty archive' \
    -e 'Resource temporarily unavailable' \
    -e 'rsync error' \
    -e 'SegFault' \
    -e 'Segmentation fault' \
    -e 'selecetfile cannot id filetype' \
    -e 'Send alert message to' \
    -e 'sending SIGTERM to' \
    -e Sev1 \
    -e severe \
    -e 'target_IP=' \
    -e Terminated \
    -e SIGSEGV \
    -e 'unable to set' \
    -e 'unexplained error' \
    -e 'unphysical' \
    -e 'Unsupported option' \
    -e 'User defined signal' \
    -e WARN4 \
    -e 'your password' \
    ${output_file} | sort -u | grep -v ' + eval ' | grep -v 'LIBRARY_PATH' | grep -v 'grep ' | grep -v 'ERROR 0' | grep -v 'ERROR \$'
  
  # check for walltime used:
    grep '\.walltime' ${output_file}
  # did the job complete successfully?  As of 2022/05/04, wcoss2 work flow does
  # not have an equivalent of wcoss1 ecf's "Successfully completed".
    grep 'ecflow_client --complete' ${output_file}
  # 
  # The grep -v 'eval ATP_HOME=' is to filter out the excessively long line
  #   from cray output:
  #   e.g. rap_postsnd_15:       ++1 + eval AR=ar ';export' 'AR;ARFLAGS=rv' ';export' ....
  # LMOD_REF_COUNT_LD_LIBRARY: long line in wsa_enlil output
  # Does the job use the intranet? 
  # pnwps_datachk sends to intra.ncep.noaa.gov: 
    grep intra ${output_file} | grep timeout | sort -u 
    # The node_load job's output has just a couple of lines with nwprod@intra
    # but the lines are very long, so print out just the last column:
    grep \@intra ${output_file} | awk '{ print $NF }' 
  # Is there an entry in the Special Procedures for $model?
  # grep -i "\ $model" ${SPC_PRC} > /dev/null
  err=$?
  if [ $err -eq 0 ]; then
    echo 
    echo $model has entry in Special Procedures
    echo
  fi

  # Anything place other than the *.o file to look for errors?
  # if the *.o file has specified a WORK_DIR (SREF), save that directory; 
  # otherwise save 'DATA':
  grep " WORK_DIR=" ${output_file}
  err=$?
  if [ $err -eq 0 ]
  then
    data_dir=`grep " WORK_DIR=" ${output_file} | head -1 | cut -d "=" -f 2`
  else
    data_dir=`grep " DATA=" ${output_file} | head -1 | cut -d "=" -f 2`
  fi

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
  else
    saveopt=sudo
  fi 

  dest="/lfs/h1/nco/ptmp/ops.prod"
  echo "extracting data directory from ${output_file}"
  
  filename=`basename ${data_dir}`
  
  if [ $saveopt = 'sudo' ];
  then
    echo "sudo -u ops.prod -i cp -rp ${data_dir} ${dest}/${filename}_${suffix}"
    sudo -u ops.prod -i cp -rp ${data_dir} ${dest}/${filename}_${suffix}
  else
    echo "cp -rp ${data_dir} ${dest}/${filename}_${suffix}"
    cp -rp ${data_dir} ${dest}/${filename}_${suffix}
  fi
fi

exit

