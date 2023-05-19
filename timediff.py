import sys
from datetime import datetime
# Compute the time diff between two hh:mm:ss arguments: arg2-arg1
# When we run python script.py arg1 arg2, the number of 'systems argument' is 
# actually 3: the first argument is script.py, of course. 
if len(sys.argv)!=3:
  sys.exit('timediff.py needs 2 arguments of hh:mm:ss')

arg1=sys.argv[1]
arg2=sys.argv[2]

time_format_str='%H:%M:%S'

time1=datetime.strptime(arg1,time_format_str)
time2=datetime.strptime(arg2,time_format_str)
delta_time=time2-time1
print('time2-time1= ',delta_time)

