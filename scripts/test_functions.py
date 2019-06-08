# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		test_functions.py
#		Purpose :	Create a pile of memory variables, check the unary functions
#					Also checks assignment retrieval.
#
#		Date :		8th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import re,os,sys,random
from dispvariables import *
from variables import *

def sgn(x):
	if x == 0:
		return 0
	return -1 if x < 0 else 1

def pickOne(varSet,reqString):
	done = False
	while not done:
		variable = varSet[random.randint(0,len(varSet)-1)]
		done = (variable.isString == reqString)
	#
	v1 = variable.pickElement()
	if variable.isString:
		v1[1] = '"'+v1[1]+'"'
	if random.randint(0,1) != 0:
		v1[0] = v1[1]
	return v1

if __name__ == "__main__":
	blk = ListableVariableBlock(0x4000,0x8000)
	#
	#		Pick a random seed, but one we can retry if required.
	#
	random.seed()
	seed = random.randint(0,65535)
	#seed = 1
	print("***** ROOT SEED {0} *****".format(seed))
	random.seed(seed)
	#
	#		Create a pile of variable objects
	#
	variables = []
	for i in range(0,100):
		variables.append(IntegerVariable())
		variables.append(StringVariable())
	#
	#		Generate code to check that the variable does equal the value.
	#
	for i in range(0,400):
		v1 = pickOne(variables,False)
		v2 = pickOne(variables,True)
		# 	abs(x)
		blk.addBASICLine("assert abs({0}) = {1}".format(v1[0],abs(v1[1])))
		#   sgn(x)
		blk.addBASICLine("assert sgn({0}) = {1}".format(v1[0],sgn(v1[1])))
		# 	len(x)
		blk.addBASICLine("assert len({0}) = {1}".format(v2[0],len(v2[1])-2))
	#
	#		Create variables in memory (done after program)
	#
	for v in variables:
		v.importVariable(blk)
	#
	#blk.listVariables()
	blk.showStatus()
	blk.exportFile("temp/basic.bin")
