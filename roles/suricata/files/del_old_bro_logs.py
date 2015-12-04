#!/usr/bin/python3

import os, sys, re
import shutil

logs_path = "/nsm/bro/logs"
threshold = 98

r = re.compile('^2[0-9]{3}-[0-9]{2}-[0-9]{2}$')

st = os.statvfs(logs_path)
free = (st.f_bavail * st.f_frsize)
total = (st.f_blocks * st.f_frsize)
used = (st.f_blocks - st.f_bfree) * st.f_frsize
try:
    percent = (float(used) / total)
except ZeroDivisionError:
    percent = 0

print(percent)

if percent*100 > threshold:
    dirs = []
    for dir in os.listdir(logs_path):
        if r.search(dir):
            dirs.append(dir)
    dirs.sort()
    todelete = dirs[0:2]
    try:
        os.chdir(logs_path)
    except:
        print("os.chdir failed, quitting")
        sys.exit(1)
    for deleteme in todelete:
        try:
            curpath = os.getcwd()
        except:
            print("os.getcwd failed, quitting")
            sys.exit(1)
        if curpath == logs_path:
            if not os.path.islink(curpath+deleteme):
                print(deleteme)
                try:
                    shutil.rmtree(deleteme)
                except:
                    print("shutil.rmtree failed, continuing")

