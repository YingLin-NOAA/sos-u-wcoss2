#!/usr/bin/python3
import re
import sys
from datetime import timedelta
from termcolor import colored

# if there is no more than 10min left in run time, print the job info in red. 
# Note that 'time left' computed below are not padded to have double-digit
# hours unless there are at least 10h left.  So to do this the lazy way, 
# comparing two strings, the 'redtime' cannot have '00' for the hour. 
redtime="0:10:00"

def parse_time(timestr):
  """Parse HH:MM:SS into timedelta."""
  h, m, s = map(int, timestr.strip().split(":"))
  return timedelta(hours=h, minutes=m, seconds=s)

def main():
  
  infile=sys.argv[1]

  jobs = []
  with open(infile) as f:
    lines = f.readlines()

  job = {}

  for line in lines + [""]: # Add sentinel for last job
    line = line.strip()
    if line.startswith("Job Id:"):
      if job:
        # skip jobs with missing 'resources_used.walltime' or
        # 'Resource_List.walltime'.  The former is sometimes missing when
        # the job is just ending.  
        if "used" in job and "allocated" in job:
          jobs.append(job)
        job = {}
      job["Job_Id"] = line.split(":", 1)[1].strip()
    elif "Job_Name" in line:
      job["Job_Name"] = line.split("=", 1)[1].strip()
    elif "resources_used.walltime" in line:
      job["used"] = parse_time(line.split("=", 1)[1].strip())
    elif "Resource_List.walltime" in line:
      job["allocated"] = parse_time(line.split("=", 1)[1].strip())

  # Also check for the last job (the sentinel):  
  if job and "used" in job and "allocated" in job:
    jobs.append(job)

  # Compute time left and sort
  for job in jobs:
    job["time_left"] = job["allocated"] - job["used"]

  jobs.sort(key=lambda x: x["time_left"], reverse=True)
  # Output
  #print(f"{'Job_Id':<25} {'Job_Name':<45} {'time_left'}")
  for job in jobs:
    ta = str(job["allocated"])
    tl = str(job["time_left"])
    if tl <= redtime: 
      print(colored(f"{job['Job_Id']:<16} {job['Job_Name']:<45} {ta} {tl}", 'red'))
    else:
      print(f"{job['Job_Id']:<16} {job['Job_Name']:<45} {ta} {tl}")

if __name__ == "__main__":
  main()
