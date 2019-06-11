# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		make_gc.py
#		Purpose :	Create a program to create garbage collectable strings.
#		Date :		10th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random
from variables import *

# *******************************************************************************************
#
#									String class
#
# *******************************************************************************************

class StringItem(object):
	def __init__(self,identifier):
		self.identifier = identifier
		self.currentValue = ""
		self.isUpdated = False
	#
	def createUsing(self,crange):
		s = "".join([crange[random.randint(0,len(crange)-1)] for x in range(0,random.randint(3,7))])
		return s


# *******************************************************************************************
#
#								Create a new identifier.
#
# *******************************************************************************************

identifiersUsed = {}

def newIdentifier():
	s1 = chr(random.randint(65,90))+chr(random.randint(65,90))+chr(random.randint(48,57))+"$"
	if s1 in identifiersUsed:
		s1 = newIdentifier()
	identifiersUsed[s1] = True
	return s1.lower()

variables = []

if __name__ == "__main__":
	print("Creation test code.")
	random.seed()
	startSeed = random.randint(0,99999)
	print("Testing G/C with key "+str(startSeed))
	random.seed(startSeed)
	arrayCount = 20
	varCount = 100
	bs = BasicSource()
	#
	#		Create everything.
	#
	for i in range(0,varCount):														# create single variables
		variables.append(StringItem(newIdentifier()))
	for i in range(0,arrayCount):													# create arrays.
		identifier = newIdentifier()
		arraySize = random.randint(2,8)
		bs.append("dim {0}({1})".format(identifier,arraySize))		
		for j in range(0,arraySize+1):												# create array elements.
			variables.append(StringItem("{0}({1})".format(identifier,j)))
	#
	#		Give everything an initial value.
	#
	for v in variables:
		v.currentValue = "" if random.randint(0,5)==0 else v.createUsing("jklm")	# JKLM are the initial values.
		bs.append("let {0} = \"{1}\"".format(v.identifier,v.currentValue))			# these will all be in low memory.
	#
	#		Scan through all of them, changing some, not others to values with WXYZ in them.
	#
	for n in range(0,len(variables)):
		sel = random.randint(0,len(variables)-1)									# pick one
		var = variables[sel]
		newValue = var.createUsing("WXYZ")										
		bs.append('let {0} = \"{1}\"+""'.format(var.identifier,newValue))
		var.currentValue = newValue
		var.isUpdated = True
	#
	#		Scan through them again. Any that are WXYZ type, e.g. have been updated, replace with abcd
	#
	for v in variables:
		if v.isUpdated:
			newValue = var.createUsing("abcd")
			bs.append('{0} = \"{1}\"+""'.format(v.identifier,newValue))
			v.currentValue = newValue
	#
	#		Force a garbage collection.
	#
	bs.append("collect")															# force garbage collection
	#
	#		Check everything adds up afterwards.
	#
	for v in variables:
		bs.append("assert {0} = \"{1}\"".format(v.identifier,v.currentValue))
	bs.save()
	blk = BasicBlock(0x4000,0x8000)
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	
