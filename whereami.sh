#!/bin/sh
# run Nitin's "watch for ensemble files to arrive at dcom" in a script.
# 
# watch --interval=30 "ls -l /gpfs/dell1/nco/ops/dcom/prod/20200816/wgrbbul/ecmwf/DCE081600* | wc -l"
# 
# 
  watch --interval=300 "hostname"

exit


