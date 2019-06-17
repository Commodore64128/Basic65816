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
	eb = EntityBucket(-1,40,40,6,6)
	#
	bs = BasicSource()
	bs.append(eb.setupCode())
	bs.append(eb.assignCode())
	#
	for i in range(0,80):
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
		#
		s = v2.getValue()
		n1 = random.randint(0,len(s)+2)
		bs.append("assert left$({0},{1}) = \"{2}\"".format(v2.getEither(),n1,s[:n1]))
		bs.append("assert right$({0},{1}) = \"{2}\"".format(v2.getEither(),n1,s[-n1:] if n1 != 0 else ""))
		n1 = random.randint(1,len(s)+2)
		n2 = random.randint(0,int(len(s)/2)+1)
		s2 = s[n1-1:][:n2] if n2 > 0 else ""
		bs.append("assert mid$({0},{1},{2}) = \"{3}\"".format('"'+s+'"',n1,n2,s2))
		#
		ok = False
		while not ok:
			v2 = eb.pickOneString()
			s = v2.getValue()
			ps = random.randint(0,len(s)+1)
			pl = random.randint(1,3)
			ss = s[ps:][:pl]
			ok = len(ss) != 0
		if random.randint(0,3) == 0:
			s = eb.pickOneString().getValue()
		pos = s.find(ss) + 1
		bs.append("assert instr(\"{0}\",\"{1}\") = {2}".format(s,ss,pos))

	bs.append(eb.checkCode())
	#
	for i in range(0,10):
		n = random.randint(32,127)
		ch = chr(n)
		if ch != '"':
			bs.append("assert asc(\"{0}\") = {1}".format(ch,n))
			bs.append("assert chr$({1}) = \"{0}\"".format(ch,n))	
			#
		s = "".join([chr(random.randint(48,125)) for i in range(0,random.randint(3,8))])
		bs.append("assert upper$(\"{0}\") = \"{1}\"".format(s,s.upper()))
		bs.append("assert lower$(\"{0}\") = \"{1}\"".format(s,s.lower()))
	#
	for i in range(2,17):
		bs.append("assert str$(32767*65536+65535,{1}) = \"{0}\"".format(toStr(0x7FFFFFFF,i).lower(),i))
	#
	bs.save()
	blk = BasicBlock(0x4000,0x8000)
	blk.setBoot("run")
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	
