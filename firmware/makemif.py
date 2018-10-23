#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

from sys import argv

binfile = argv[1]
nwords = int(argv[2])

with open(binfile, "rb") as f:
    bindata = f.read()

print ("-- Altera Quartus Memory Initilization file .mif")
print ("DEPTH = 16384;         -- The size of memory in words")
print ("WIDTH = 32;            -- The size of data in bits")
print ("")
print ("ADDRESS_RADIX = HEX;   -- The radix for address values")
print ("DATA_RADIX = HEX;      -- The radix for data values")
print ("")
print ("CONTENT BEGIN          -- start of (address : data pairs)")

assert len(bindata) < 4 * nwords
assert len(bindata) % 4 == 0

for i in range(nwords):
    if i < len(bindata) // 4:
        w = bindata[4 * i : 4 * i + 4]
        print("%04x : %02x%02x%02x%02x;" % (i, w[3], w[2], w[1], w[0]))
    else:
        print("%04x : 00000000;" % (i))

print ("END;")
