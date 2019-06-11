# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		test_maths.py
#		Purpose :	Create lots of variables/arrays and arithmetic/bitwise.
#		Date :		10th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random
from variables import *

def calculate(op,a,b):
	if op == "+":
		return a + b
	if op == "-":
		return a - b
	if op == "*":
		return a * b
	if op == "%":
		return a % b
	if op == "/":
		return int(a / b)
	if op == "&":
		return a & b
	if op == "|":
		return a | b
	if op == "^":
		return a ^ b
	assert False

if __name__ == "__main__":
	print("Arithmetic/Bitwise test code.")
	operators = "+,-,*,/,&,|,^".split(",")

	eb = EntityBucket(-1,60,0,0,0)
	#
	bs = BasicSource()
	bs.append(eb.setupCode())
	bs.append(eb.assignCode())

	for i in range(0,900):
		ok = False
		while not ok:
			v1 = eb.pickOne()
			v2 = eb.pickOne()
			operator = operators[random.randint(0,len(operators)-1)]
			ok = True
			if abs(v1[2]*v2[2]) >= 32768*4096:
				ok = False
			if (operator == "/" or operator == "%") and v2[2] == 0:
				ok = False
		bs.append("assert ({0}{1}{2}) = {3}".format(v1[1],operator,v2[1],calculate(operator,v1[2],v2[2])))

	bs.append(eb.checkCode())
	bs.save()
	#
	blk = BasicBlock(0x4000,0x8000)
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	
