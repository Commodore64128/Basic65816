# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		test_func.py
#		Purpose :	Create lots of variables/arrays and check unary functions
#		Date :		10th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random
from variables import *

def sgn(c):
	if c != 0:
		c = -1 if c < 0 else 1
	return c

if __name__ == "__main__":
	print("Unary function test code.")
	eb = EntityBucket()
	#
	bs = BasicSource()
	bs.append(eb.setupCode())
	bs.append(eb.assignCode())
	bs.append(eb.checkCode())
	#
	for i in range(0,300):
		v1 = eb.pickOneInteger()
		bs.append("assert abs({0})={1}".format(v1[0],abs(v1[2])))
		bs.append("assert sgn({0})={1}".format(v1[0],sgn(v1[2])))
		v2 = eb.pickOneString()
		bs.append("assert len({0})={1}".format(v2[0],len(v2[2])))
	#
	bs.save()
	blk = BasicBlock(0x4000,0x8000)
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	
