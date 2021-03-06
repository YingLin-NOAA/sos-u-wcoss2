#!/bin/bash
# similar to save_wk_dir.bash, but save just a few items from the working 
# directory, if the original directory is too huge and if you're pretty sure
# that the problem is a bad node or some system issues.  Save the following:
#   OUTPUT*, errfile, core* 
#   and a list of files in the working directory.  
# 
# As of 2020/07/21, Dell output is under either /gpfs/dell1/ or /gpfs/dell4/, 
# cray output is under /gpfs/hps/ only.  But that might change ... before the
# migration to wcoss_2.  For now I'll just check whether characters 6-7 are
# 'del' or 'hps'.  
suffix=`date +%Y%m%d_%H%MZ`
if [ $# -gt 0 ]; then
  output_file=$1
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
  data_dir=`grep " DATA=" ${output_file} | head -1 | cut -d "=" -f 2`
  filename=`basename ${data_dir}_:`
  echo "sudo -u nwprod cp -rp ${data_dir} ${dest}/${filename}_${suffix}"
  sudo -u nwprod "mkdir -p ${dest}/${filename}_few_files_${suffix}
else
  echo "no output file to work with ... exiting"
fi

