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
path = argv[3] + "/"

with open(binfile, "rb") as f:
    bindata = f.read()

hexfile0 = "firmware0.hex"
hexfile1 = "firmware1.hex"
hexfile2 = "firmware2.hex"
hexfile3 = "firmware3.hex"

miffile = "firmware.mif"

h0 = open(path + hexfile0, "w")
h1 = open(path + hexfile1, "w")
h2 = open(path + hexfile2, "w")
h3 = open(path + hexfile3, "w")
mif = open(path + miffile, "w")

print ("-- Altera Quartus Memory Initilization file .mif",          file=mif)
print ("DEPTH = 16384;         -- The size of memory in words",     file=mif)
print ("WIDTH = 32;            -- The size of data in bits",        file=mif)
print ("",                                                          file=mif)
print ("ADDRESS_RADIX = HEX;   -- The radix for address values",    file=mif)
print ("DATA_RADIX = HEX;      -- The radix for data values",       file=mif)
print ("",                                                          file=mif)
print ("CONTENT BEGIN          -- start of (address : data pairs)", file=mif)

assert len(bindata) < 4*nwords
assert len(bindata) % 4 == 0

for i in range(nwords):
    if i < len(bindata) // 4:
        w = bindata[4*i : 4*i+4]
        print("%02x%02x%02x%02x" % (w[3], w[2], w[1], w[0]))
        print("%02x" % (w[0]), file=h0)
        print("%02x" % (w[1]), file=h1)
        print("%02x" % (w[2]), file=h2)
        print("%02x" % (w[3]), file=h3)
        print("\t%04x : %08x;" % (i  ,(w[3] << 24) + (w[2] << 16) + (w[1] << 8) + w[0]) , file=mif)
    else:
        print("0")
        print("%02x" % (0),            file=h0)
        print("%02x" % (0),            file=h1)
        print("%02x" % (0),            file=h2)
        print("%02x" % (0),            file=h3)
        print("\t%04x : %08x;" % (0, 0), file=mif)

print ("END;", file=mif)

h0.close()
h1.close()
h2.close()
h3.close()
mif.close()
