#!/bin/sh
# check for error messages in (saved) wrkdir.  Assuming we're checking for
#   output* and */output* 

grep -i \
  -e 'could not find' \
  -e 'Error reading' \
  -e fatal \
  -e killed \
  -e missing \
  -e SIGSEGV \
  -e segmentation \
  output* */output* | sort -u

grep NaN output* */output*
exit

