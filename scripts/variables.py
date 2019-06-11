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
		identifier = identifier if identifier is not None else "*"
		self.identifier = identifier.replace("*",self.defaultIdentifier())
		self.setValue(value if value is not None else self.singleDefaultValue())
	#
	#		Accessors/Manipulators
	#
	def getIdentifier(self):
		return self.identifier
	def getValue(self):
		return self.value
	def getEither(self):
		return self.getCodeValue() if random.randint(0,1) == 0 else self.getIdentifier()
	def getCodeValue(self):
		return '"'+self.value+'"' if self.isString else str(self.value)
	def setValue(self,value):
		self.value = self.defaultValue() if value is None else value
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
		return "{0}:={1}".format(self.getIdentifier(),self.getCodeValue())
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
		return self.singleDefaultValue()
	#
	def singleDefaultValue(self):
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
	#		there's only one anyway.
	#
	def pickOne(self):
		return self

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
#										Array Classes
#
# *******************************************************************************************

class ArrayVariable(SimpleVariable):
	def __init__(self,isString,size = None,identifier = None,value = None):
		self.isString = isString
		self.size = random.randint(2,6) if size is None else size
		if value is not None:
			self.size = len(value)
		self.identifier = identifier if identifier is not None else self.defaultIdentifier()
		self.elements = []
		for i in range(0,self.size+1):
			name = "{1}({0})".format(i,self.identifier)
			self.elements.append(SimpleVariable(isString,name,None if value is None else value[i]))

	def toString(self):
		return self.identifier+"("+str(self.size)+"):=["+",".join([x.getCodeValue() for x in self.elements])+"]"

	def setupCode(self):
		return "dim {0}({1})".format(self.identifier,self.size)
	def assignCode(self):
		return ":".join(["{0}({1})={2}".format(self.identifier,i,self.elements[i].getCodeValue()) for i in range(0,self.size+1)])
	def checkCode(self):
		return ":".join(["assert {0}({1})={2}".format(self.identifier,i,self.elements[i].getCodeValue()) for i in range(0,self.size+1)])

	def pickOne(self):
		return self.elements[random.randint(0,self.size)]
class IntegerArray(ArrayVariable):
	def __init__(self,size = None,identifier = None,value = None):
		ArrayVariable.__init__(self,False,size,identifier,value)

class StringArray(ArrayVariable):
	def __init__(self,size = None,identifier = None,value = None):
		ArrayVariable.__init__(self,True,size,identifier,value)

# *******************************************************************************************
#
#								Container with multiple variables
#
# *******************************************************************************************

class EntityBucket(object):
	def __init__(self,randomSeed=-1,iCount=60,sCount=60,iaCount=10,saCount=10):
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
		for i in range(0,iaCount):
			self.add(IntegerArray())
		for i in range(0,saCount):
			self.add(StringArray())

	def add(self,entity):
		self.bucket.append(entity)

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
			if self.bucket[n].isString == requireString:
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
			#print("==== "+l+" ====")
			self.handle.write(l.strip()+"\n")
	#
	def save(self):
		self.handle.close()

if __name__ == "__main__":
	eb = EntityBucket(42,1,1,1,1)
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
