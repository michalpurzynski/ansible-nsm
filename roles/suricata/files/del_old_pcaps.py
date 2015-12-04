#!/usr/bin/python3

import os, sys

pcaps_path = "/nsm/pcaps"
pcap_prefix = "data.pcap"
threshold = 98

st = os.statvfs(pcaps_path)
free = (st.f_bavail * st.f_frsize)
total = (st.f_blocks * st.f_frsize)
used = (st.f_blocks - st.f_bfree) * st.f_frsize
try:
    percent = (float(used) / total)
except ZeroDivisionError:
    percent = 0

print(percent)

if percent*100 > threshold:
    files = []
    for file in os.listdir(pcaps_path):
        if file.startswith(pcap_prefix):
            files.append(file)
    files.sort()
    todelete = files[0:2]
    try:
        os.chdir(pcaps_path)
    except:
        print("os.chdir failed, quitting")
        sys.exit(1)
    for deleteme in todelete:
        try:
            curpath = os.getcwd()
        except:
            print("os.getcwd failed, quitting")
            sys.exit(1)
        if curpath == pcaps_path:
            if not os.path.islink(curpath+deleteme):
                print(deleteme)
                try:
                    os.remove(deleteme)
                except:
                    print("os.remove failed, continuing")

