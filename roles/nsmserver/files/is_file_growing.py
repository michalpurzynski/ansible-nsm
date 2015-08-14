#!/usr/bin/env python
import os
import sys
import time

SIZE_TIMEOUT = 10

def get_size(f):
    for x in range(SIZE_TIMEOUT):
        try:
            size = os.stat(f).st_size
            return size
        except OSError:
            time.sleep(1)

    return os.stat(f).st_size


def is_growing(f):
    size = get_size(f)
    time.sleep(1)
    for x in range(SIZE_TIMEOUT):
        time.sleep(1)
        newsize = get_size(f)
        if newsize != size:
            return True
    return False

def is_growing_with_retries(f):
    """Check to see if a file is growing, with retries
       this should handle the case when a file gets rotated mid check
    """
    for x in range(3):
        if os.path.isfile(f) and is_growing(f):
            return True
    return False
    


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print "Usage %s filename" % sys.argv[0]
        sys.exit(1)

    f = sys.argv[1]

    res = is_growing_with_retries(f)

    if not res:
        print "%s is not growing" % f

    sys.exit(not res)
