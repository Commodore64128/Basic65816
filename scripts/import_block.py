# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		import_block.py
#		Purpose :	Import Basic Block into binary object.
#		Date :		18th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import os,sys
assert len(sys.argv) == 3

fBinary = sys.argv[1].replace("/",os.sep).replace("\\",os.sep)
fInject = sys.argv[2].replace("/",os.sep).replace("\\",os.sep)

print("Injecting {1} into {0}".format(fInject,fBinary))
h = open(fBinary,"rb")
binary = [x for x in h.read(-1)]
h.close()

h = open(fInject,"rb")
block = [x for x in h.read(-1)]
h.close()

for i in range(0,len(block)):
	binary[i+0x24000] = block[i]

h = open(fBinary,"wb")
h.write(bytes(binary))
h.close()

