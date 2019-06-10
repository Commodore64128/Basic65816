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
	def getIdentifier(self):
		return self.identifier
	def getValue(self):
		return self.value
	def getCodeValue(self):
		return '"'+self.value+'"' if self.isString else str(self.value)
	#
	def assignCode(self):
		return "{2} {0}={1}".format(self.getIdentifier(),self.getCodeValue(),"let" if random.randint(0,1) == 0 else "")
	def checkCode(self):
		return "assert {0}={1}".format(self.getIdentifier(),self.getCodeValue())
	#
	def defaultIdentifier(self):
		s = ""
		for i in range(0,random.randint(1,5)):
			c = random.randint(65,90)
			if i > 0 and random.randint(0,3) == 0:
				c = random.randint(48,57)
			s = s + chr(c).lower()
		s = s + ("$" if self.isString else "")
		return s if s not in SimpleVariable.usedIdentifiers else self.defaultIdentifier()	
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

SimpleVariable.usedIdentifiers = {}

class IntegerVariable(SimpleVariable):
	def __init__(self,identifier = None,value = None):
		SimpleVariable.__init__(self,False,identifier,value)

class StringVariable(SimpleVariable):
	def __init__(self,identifier = None,value = None):
		SimpleVariable.__init__(self,True,identifier,value)

if __name__ == "__main__":
	random.seed(42)
	for i in range(0,10):
		v1 = IntegerVariable()
		print(v1.getIdentifier(),v1.getValue(),v1.getCodeValue(),v1.assignCode(),v1.checkCode())
		v1 = StringVariable()
		print(v1.getIdentifier(),v1.getValue(),v1.getCodeValue(),v1.assignCode(),v1.checkCode())

