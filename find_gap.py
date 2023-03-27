import pandas as pd
import sys
from datetime import datetime, timedelta

# Last update: 2023/03/09
# Find time gap between ecflog LOG entries that are 1min (default) or longer
# This code has 0-2 arguments:
#  - No argument: python find_gap.py
#    find gaps in the current active ecflog.  Current active ecflow server
#    info is from /lfs/h1/ops/prod/config/active.ecflow.
#  - 1 argument: user-supplied ecflog name (or ecflog name under log/,
#    which is a subdir under /lfs/h1/ops/prod/output/ecflow/
#    Example 1:  python find_gap.py ecf.decflow01.log
#      (if on the day of an ecflow server switch, you want to find earlier gaps
#       that happened prior to the switch)
#    Example 2:  python find_gap.py log/ecf.decflow02.log1
#      (find gaps in previous day's ecflog)
#  - 2 argument: user supplied ecflog name and threshold time gap (default 
#      is > 59s.  The threshold value needs to be in seconds, e.g.
#      python find_gap.py $ecflog_name 29
#      python find_gap.py $ecflog_name 120
# 
# Note: 
#  - I'm still not sure if /lfs/h1/ops/prod/config/active.ecflow gets updated
#    after an emergency prod switch, so this script writes out the path/name
#    of the ecflog to be looked at
#  - The script also writes out the maximum time gap between LOG entries 
#    in the ecflog.  I'm surprised that there are often 20-30s gaps. 
#
#  Example:
#  > python find_gap.py
#    Locate time gaps greater than  0:00:59 between LOG entries in
#    /lfs/h1/ops/prod/output/ecflow/ecf.decflow02.log :
#    Maximum time gap between LOGs: 0:00:34
#  Now rerun with smaller time gap threshold: 
#  > python find_gap.py ecf.decflow02.log 30
#    Locate time gaps greater than  0:00:30 between LOG entries in
#    /lfs/h1/ops/prod/output/ecflow/ecf.decflow02.log :
#    time gap of 0:00:34 :
#    LOG:[00:07:07 9.3.2023]  active: /prod/backup/cron/transfer/v2.4/wcoss_network_monitor
#    LOG:[00:07:41 9.3.2023]  submitted: /prod/primary/18/hrrr/v4.1/23z/conus/post/post_subh/jhrrr_post_f1000 job_size:5165
#    Maximum time gap between LOGs: 0:00:34 

ecfdir='/lfs/h1/ops/prod/output/ecflow/'

narg=len(sys.argv)
if narg == 1 :
  f=open('/lfs/h1/ops/prod/config/active.ecflow','r')
  actvecf=f.read()
  f.close
  infile=ecfdir+'ecf.'+actvecf[0:9]+'.log'
elif narg >= 2 :
  logf=sys.argv[1]
  infile=ecfdir+logf

if narg == 3 :
  delta0=timedelta(seconds=int(sys.argv[2]))
else:  
  delta0=timedelta(seconds=59)

maxgap=timedelta(seconds=0)
# Read in the entire ecflog into whole_log:
file = open(infile)
whole_log = file.readlines()

print('Locate time gaps greater than ', delta0, 'between LOG entries in\n', infile, ':')

def findtime(line):
  """
  Convert the hh:mm:ss Day.Mon.Year info in a ecflog entry into a datetime
  object
  LOG:[23:55:04 27.2.2023]
  ----:----|----:----|---
  """
  time_fmt_str='%H:%M:%S %d.%m.%Y'
  ecftime=datetime.strptime(line[5:23],time_fmt_str)
  return ecftime

first = True
for i in range(len(whole_log)):
  line=whole_log[i]
  if line[0:5] == 'LOG:[' and line[23] == ']': 
    time=findtime(whole_log[i])
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
