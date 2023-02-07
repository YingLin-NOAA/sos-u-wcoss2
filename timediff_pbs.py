import sys
from datetime import datetime
# stime='Mon Feb  6 20:59:14 2023'

# When we run python script.py arg1 arg2, the number of 'systems argument' is 
# actually 3: the first argument is script.py, of course. 
if len(sys.argv)!=3:
  sys.exit('timediff_pbs.py needs 2 arguments, stime and mtime')

stime=sys.argv[1]
mtime=sys.argv[2]

time_format_str='%a %b %d %H:%M:%S %Y'
# %a : Locale’s abbreviated weekday name
# %b : Locale’s abbreviated month name
# %d : Day of the month as a decimal number [01,31]
# %H : Hour (24-hour clock) as a decimal number
# %M : Minute as a decimal number [00,59]
# %S : Second as a decimal number [00,61]

time1=datetime.strptime(stime,time_format_str)
time2=datetime.strptime(mtime,time_format_str)
delta_time=time2-time1
print('mtime-stime = ',delta_time)

