# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		test_comparison.py
#		Purpose :	Create lots of variables/arrays and check comparison
#		Date :		10th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random
from variables import *

def calculate(op,a,b):
	if op == "=":
		return a == b
	if op == ">":
		return a > b
	if op == "<":
		return a < b
	if op == "<>":
		return a != b
	if op == ">=":
		return a >= b
	if op == "<=":
		return a <= b
	assert False

if __name__ == "__main__":
	print("Comparison test code.")
	operators = "<,>,=,>=,<=,<>".split(",")

	eb = EntityBucket()
	#
	bs = BasicSource()
	bs.append(eb.setupCode())
	bs.append(eb.assignCode())
	bs.append(eb.checkCode())

	for i in range(0,800):
		ok = False
		while not ok:
			v1 = eb.pickOne()
			v2 = eb.pickOne()
			ok = v1[3] == v2[3]
		operator = operators[random.randint(0,len(operators)-1)]
		bs.append("assert ({0}{1}{2}) = {3}".format(v1[0],operator,v2[0],-1 if calculate(operator,v1[2],v2[2]) else 0))
	bs.save()
	#
	blk = BasicBlock(0x4000,0x8000)
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	
