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

def toStr(n,base):
	convertString = "0123456789ABCDEF"
	if n < 0:
		return "-"+toStr(-n,base)
	if n < base:
		return convertString[n]
	else:
		return toStr(int(n/base),base) + convertString[n % base]

if __name__ == "__main__":
	print("Unary function test code.")
	eb = EntityBucket()
	#
	bs = BasicSource()
	bs.append(eb.setupCode())
	bs.append(eb.assignCode())
	#
	for i in range(0,100):
		v1 = eb.pickOneInteger()
		bs.append("assert abs({0})={1}".format(v1.getEither(),abs(v1.getValue())))
		bs.append("assert sgn({0})={1}".format(v1.getEither(),sgn(v1.getValue())))
		v2 = eb.pickOneString()
		bs.append("assert len({0})={1}".format(v2.getEither(),len(v2.getValue())))
		n = v1.getValue()
		base = random.randint(2,16)
		conv = toStr(n,base)
		bs.append("assert val(\"{0}\",{2}) = {1}".format(conv,n,base))
		bs.append("assert str$({0},{2}) = \"{1}\"".format(n,conv.lower(),base))
		n = random.randint(32,127)
		ch = chr(n)
		bs.append("assert asc(\"{0}\") = {1}".format(ch,n))
		bs.append("assert chr$({1}) = \"{0}\"".format(ch,n))

	#
	bs.append(eb.checkCode())
	bs.save()
	blk = BasicBlock(0x4000,0x8000)
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	
