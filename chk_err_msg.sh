#!/bin/sh
# check job *.o file for a list of known error messages

# 'sort -u' so that if there are, say hundreds of identical lines of 'SIGSEGV',
#   only one will print out.
#
# Per Eric Rogers in re NAM code issue, most aborts trigger prints in the 
# microphysics that Brad added, with "WARN#" at the start of the message. 
# 'WARN1" messages are not a problem, they pop up occasionally almost every 
# run due to relatively large amounts of moisture in the stratosphere. But if 
# you see lots of WARN# (WARN4 is usually bad) and then prints that start 
# with "{}" then we got problems.
 
outfile=$1
grep -i \
  -e 'abnormal exit' \
  -e 'broken pipe' \
  -e 'connection timed out' \
  -e 'connection unexpectedly closed' \
  -e 'DATACOUNT low on 1 or more CRITICAL ob type' \
  -e 'end-of-file during read' \
  -e fatal   \
  -e 'io timeout' \
  -e killed \
  -e missing \
  -e 'no route to host' \
  -e 'rsync error' \
  -e severe \
  -e SIGSEGV \
  -e WARN4 \
  -e {} \
  $1 | sort -u

exit

