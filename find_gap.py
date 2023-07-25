##!/usr/bin/python3
import pandas as pd
import sys
import re
from datetime import datetime, timedelta

# Last update: 2023/07/25
# Find time gap between ecflog LOG entries that are 1min (default) or longer
# This code has 0-2 arguments:
#  - No argument: python find_gap.py
#    find gaps greater than 59s in the current active ecflog.  Current active 
#    ecflow server info is from /lfs/h1/ops/prod/config/active.ecflow.
#  - 1 argument: user-supplied threshold time gap.  The threshold value needs 
#      to be in seconds, e.g. 'python find_gap.py 119' will identify time gaps
#      of at least 2 minutes in the current active ecflog.      
#  - 2 argument: user-supplied threshold time gap, and ecflog name (or ecflog 
#    name under log/, which is a subdir under /lfs/h1/ops/prod/output/ecflow/
#    Example 1:  python find_gap.py 29 ecf.decflow01.log
#      (if on the day of an ecflow server switch, you want to find earlier gaps
#       that happened prior to the switch)
#    Example 2:  python find_gap.py 29 log/ecf.decflow02.log1
#      (find gaps in previous day's ecflog)
# 
# Note: 
#  - I'm still not sure if /lfs/h1/ops/prod/config/active.ecflow gets updated
#    after an emergency prod switch, so this script writes out the path/name
#    of the ecflog to be looked at
#  - The script also writes out the maximum time gap between LOG entries 
#    in the ecflog.  I'm surprised that there are often 20-30s gaps. 
#  - As of 2023/07/25, /usr/bin/python3 (symlinked to python3.6) does not seem
#    to play well with numpy (v1.20.1): got an error message when running this
#    script directly:
#      > find_gap.py
#      > ImportError: Unable to import required dependencies
#    Maybe because my .bashrc loads module python/3.8.6, and that makes 
#    /usr/bin/phthon3.6 not working with numpy and pandas?  In any case
#    'python find_gap.py' works.  

ecfdir='/lfs/h1/ops/prod/output/ecflow/'

delta0=timedelta(seconds=59)
narg=len(sys.argv)
if narg <= 2 :
  f=open('/lfs/h1/ops/prod/config/active.ecflow','r')
  actvecf=f.read()
  f.close
  infile=ecfdir+'ecf.'+actvecf[0:9]+'.log'

if narg >= 2 :
  delta0=timedelta(seconds=int(sys.argv[1]))

if narg == 3 :
  logf=sys.argv[2]
  infile=ecfdir+logf

maxgap=timedelta(seconds=0)
# Read in the entire ecflog into whole_log:
file = open(infile)
whole_log = file.readlines()

print('Locate time gaps greater than ', delta0, 'between LOG entries in\n', infile, ':')

time_fmt_str='%H:%M:%S %d.%m.%Y'

first = True
for i in range(len(whole_log)):
  line=whole_log[i]
  match=re.search(r'LOG:\[.*?\]',line)
  if match:
    tmpstr=match.group()
    timestr=tmpstr.replace("LOG:[","").replace("]","")
    time=datetime.strptime(timestr,time_fmt_str)
    if not first:
      gap=time-prevtime
      if gap > maxgap:
        maxgap=gap      
      if gap > delta0:
        print('time gap of', gap, ':')
        print(whole_log[previ])
        print(line)
    else:
      first = False
    prevtime=time
    previ=i
  i=i+1

print('Maximum time gap between LOGs:', maxgap)
