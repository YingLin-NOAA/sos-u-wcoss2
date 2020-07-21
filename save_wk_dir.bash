#!/bin/bash
dest="/gpfs/hps3/ptmp/nwprod"
suffix=`date +%Y%m%d_%H%MZ`
if [ $# -gt 0 ]; then
        output_file=$1
        echo "extracting data directory from ${output_file}"
        data_dir=`grep " DATA=" ${output_file} | head -1 | cut -d "=" -f 2`
        filename=`basename ${data_dir}`
        echo "sudo -u nwprod cp -rp ${data_dir} ${dest}/${filename}_${suffix}"
        sudo -u nwprod cp -rp ${data_dir} ${dest}/${filename}_${suffix}
else
        echo "no output file to work with ... exiting"
fi

