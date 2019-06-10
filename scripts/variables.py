# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		variables.py
#		Purpose :	Variable/Data sources for tests, code generated version.
#		Date :		10th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random
from tokensrc import *
from basicblock import *

# *******************************************************************************************
#
#								Single element variable class
#
# *******************************************************************************************

class SimpleVariable(object):
	def __init__(self,stringType,identifier = None,value = None):
		self.isString = stringType													# set up.
		self.identifier = self.defaultIdentifier() if identifier is None else identifier
		self.value = self.defaultValue() if value is None else value
	#
	#		Accessors
	#
	def getIdentifier(self):
		return self.identifier
	def getValue(self):
		return self.value
	def getCodeValue(self):
		return '"'+self.value+'"' if self.isString else str(self.value)
	#
	#		Code to do initial setup, assign value, and check value still holds.
	#
	def setupCode(self):
		return ""
	def assignCode(self):
		return "{2} {0}={1}".format(self.getIdentifier(),self.getCodeValue(),"let" if random.randint(0,1) == 0 else "")
	def checkCode(self):
		return "assert {0}={1}".format(self.getIdentifier(),self.getCodeValue())
	#
	#		Return string representation
	#
	def toString(self):
		return "{0:10} := {1}".format(self.getIdentifier(),self.getCodeValue())
	#
	#		Create a dummy identifier. The 2nd character is always a number, so it can't be a token.
	#
	def defaultIdentifier(self):
		s = ""
		for i in range(0,random.randint(1,5)):										# 1-5 characters
			c = random.randint(65,90)												# letter
			if (i > 0 and random.randint(0,3) == 0) or i == 1:						# number ?
				c = random.randint(48,57)
			s = s + chr(c).lower()													# build up
		s = s + ("$" if self.isString else "")										# add type
		if s in SimpleVariable.usedIdentifiers:										# check duplicate
			s = self.defaultIdentifier()	
		SimpleVariable.usedIdentifiers[s] = True 									# mark used.
		return s
	#	
	#		Create a default value.
	#
	def defaultValue(self):
		if self.isString:
			s1 = ""
			for i in range(0,random.randint(0,11)):
				s1 += chr(random.randint(65,90)) if random.randint(0,4) > 0 else " "
			return s1.strip()
		else:
			r = 200 if random.randint(0,3) == 0 else 200000
			return random.randint(-r,r)
	#
	#		Pick one of the values in this entity at random. If it's a single variable
	#		there's only one anyway Returns [ identifier, value, isString ]
	#
	def selectOne(self):
		return [self.getIdentifier(),self.getValue(),self.isString]
	#
	#		Pick one representation of the value, so for each variable this returns a list
	#		with the variable *or* the value, and the value and type
	#
	def pickOne(self):
		return [self.getIdentifier() if random.randint(0,1) == 0 else self.getCodeValue(),self.getValue(),self.isString]

SimpleVariable.usedIdentifiers = {}													# used identifiers

# *******************************************************************************************
#
#									Simple classes for both types
#
# *******************************************************************************************

class IntegerVariable(SimpleVariable):
	def __init__(self,identifier = None,value = None):
		SimpleVariable.__init__(self,False,identifier,value)

class StringVariable(SimpleVariable):
	def __init__(self,identifier = None,value = None):
		SimpleVariable.__init__(self,True,identifier,value)

# *******************************************************************************************
#
#								Container with multiple variables
#
# *******************************************************************************************

class EntityBucket(object):
	def __init__(self,randomSeed=-1,iCount=60,sCount=60,iaCount=10,isCount=10):
		self.bucket = []
		if randomSeed < 0:
			random.seed()
			randomSeed = random.randint(0,999999)
			print("Using generated seed {0}".format(randomSeed))
		random.seed(randomSeed)
		for i in range(0,iCount):
			self.add(IntegerVariable())
		for i in range(0,sCount):
			self.add(StringVariable())

	def add(self,entity):
		self.bucket.append(entity)

	def selectOneInteger(self):
		return self._selectOne(False).selectOne()
	def selectOneString(self):
		return self._selectOne(True).selectOne()
	def selectOne(self):
		return self.bucket[random.randint(0,len(self.bucket)-1)].selectOne()
	def pickOneInteger(self):
		return self._selectOne(False).pickOne()
	def pickOneString(self):
		return self._selectOne(True).pickOne()
	def pickOne(self):
		return self.bucket[random.randint(0,len(self.bucket)-1)].pickOne()

	def _selectOne(self,requireString):
		count = 0
		while True:
			n = random.randint(0,len(self.bucket)-1)
			if n.isString == requireString:
				return self.bucket[n]
			count += 1
			assert count < 9999

	def toString(self):
		return "\n".join([x.toString() for x in self.bucket])

	def setupCode(self):
		return [x for x in [x.setupCode() for x in self.bucket] if x != ""]
	def assignCode(self):
		return [x for x in [x.assignCode() for x in self.bucket] if x != ""]
	def checkCode(self):
		return [x for x in [x.checkCode() for x in self.bucket] if x != ""]


# *******************************************************************************************
#
#									Basic Source program
#
# *******************************************************************************************

class BasicSource(object):
	def __init__(self,fileName = "basic.bas"):
		self.handle = open(fileName,"w")
	#
	def append(self,code):
		code = code if isinstance(code,list) else [code]
		for l in code:
			self.handle.write(l.strip()+"\n")
	#
	def save(self):
		self.handle.close()

if __name__ == "__main__":
	random.seed(42)
	eb = EntityBucket(42,3,3,0,0)
	print(eb.toString())
	print(eb.setupCode())
	print(eb.assignCode())
	print(eb.checkCode())
	#
	bs = BasicSource()
	bs.append(eb.setupCode())
	bs.append(eb.assignCode())
	bs.append(eb.checkCode())
	bs.save()
	#
	blk = BasicBlock(0x4000,0x8000)
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	
