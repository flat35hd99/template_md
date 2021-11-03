#! /usr/bin/env python3

import sys
filename = sys.argv[1]
print("----{0}----------\n".format(filename))

f = open(filename,'r')
for line in f:
    l = line.split()
    value = float(l[2])
    if value < 0: print(line)


