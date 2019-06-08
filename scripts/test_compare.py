# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		test_compare.py
#		Purpose :	Create a pile of memory variables, check the comparison functions.
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

def pickOne(varSet,operator,reqString):
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

def calculate(op,a,b):
	if op == ">":
		return a > b
	if op == "<":
		return a < b
	if op == "=":
		return a == b
	if op == ">=":
		return a >= b
	if op == "<=":
		return a <= b
	if op == "<>":
		return a != b

	assert False
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
	operatorList = ["<","<=",">",">=","=","<>"]
	#
	variables = []
	for i in range(0,32):
		variables.append(IntegerVariable())
		variables.append(StringVariable())
		variables.append(IntegerArray())
		variables.append(StringArray())
	#
	#		Generate code to check that the variable does equal the value.
	#
	for i in range(0,900):
		operator = operatorList[random.randint(0,len(operatorList))-1]
		reqString = random.randint(0,1) == 0
		v1 = pickOne(variables,operator,reqString)
		v2 = pickOne(variables,operator,reqString)
		if random.randint(0,7) == 0:
			v1 = v2
		result = -1 if calculate(operator,v1[1],v2[1]) else 0
		line = "assert ({0} {1} {2}) = {3}".format(v1[0],operator,v2[0],result)
		blk.addBASICLine(None,line)
		#print(line)
	#
	#		Create variables in memory (done after program)
	#
	for v in variables:
		v.importVariable(blk)
	#
	#blk.listVariables()
	blk.showStatus()
	blk.exportFile("temp/basic.bin")
