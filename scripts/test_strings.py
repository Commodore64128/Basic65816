# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		test_strings.py
#		Purpose :	Bully the string system / local system
#		Date :		20th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random
from basicblock import *

def randomString():
	return "".join([chr(random.randint(48,90)) for i in range(0,random.randint(0,17))])

if __name__ == "__main__":
	print("String bullying test code.")
	blk = BasicBlock(0x4000,0x8000)
	random.seed()
	seed = random.randint(0,99999)
	print("Seed is ",seed)
	random.seed(seed)
	strings = {}
	stringCount = 30
	procCount = 10
	modsPerProc = 15
	#
	#		create strings.
	#
	for i in range(0,stringCount):
		strings[chr(i%26+65)+str(i)+"$"] = randomString()
	varNames = [x for x in strings.keys()]
	#
	# 		initialisation strings.
	#
	for s in varNames:
		blk.addBASICLine("let {0} = \"{1}\"+\"\"".format(s,strings[s]))
	#
	#		Call change procedures
	#
	for i in range(0,procCount):
		blk.addBASICLine("proc modify{0}".format(i))
	#
	# 		call validation procedure
	#
	blk.addBASICLine("Proc validate:End")		
	#
	#		create the modifier procedures.
	#
	for i in range(0,procCount):	
		localVars = {}
		for v in varNames:
			if random.randint(0,1) != 0:
				localVars[v] = True
		blk.addBASICLine("defproc modify{0}".format(i))
		for v in localVars:
			blk.addBASICLine("local "+v)
		for p in range(0,modsPerProc):
			cvar = varNames[random.randint(0,len(varNames)-1)]
			newVal = randomString()
			blk.addBASICLine("let {0} = \"{1}\"+\"\"".format(cvar,newVal))
			if cvar not in localVars:
				strings[cvar] = newVal
		blk.addBASICLine("endproc ".format(i))
	#
	#		proc to check they have the right values.
	#
	blk.addBASICLine("DefProc validate")
	for s in varNames:
		blk.addBASICLine("assert {0} = \"{1}\"".format(s,strings[s]))
	blk.addBASICLine("endproc")		
	blk.setBoot("run",False)
	blk.exportFile("temp/basic.bin")	
	n = 0
	for v in varNames:
		if strings[v] != "":
			n = n + 1
	print(n,"Non null strings")
	blk.showStatus()
