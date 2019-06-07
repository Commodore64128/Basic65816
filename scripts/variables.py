# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		variables.py
#		Purpose :	Variables Import system
#		Date :		7th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import re,os,sys,random
from gentokens import *
from tokeniser import *
from basicblock import *

# *******************************************************************************************
#
#								Variable Classes
#
# *******************************************************************************************

class Variable(object):
	#
	def __init__(self,isString,name = None,defValue = None):
		self.name = name.lower() if name is not None else name 					# Set default values
		self.isString = isString		 										
		while self.name is None or self.name in Variable.usedIdentifiers:		# Generate unique name if required
			self.name = self.generateIdentifier().lower()
		Variable.usedIdentifiers[self.name] = True								# Mark as used
		self.value = self.defaultValue() if defValue is None else defValue 		# Generate def value if required
		if Variable.tokeniser is None:											# create tokeniser shared.
			Variable.tokeniser = Tokeniser()
	#
	#		Get identifiers - name only, full description and one used to tokenise.
	#
	def getIdentifier(self):
		return self.name 
	def getFullIdentifier(self):
		return self.getIdentifier()+"$" if self.isString else self.getIdentifier()
	def getTokenIdentifier(self):
		return self.getFullIdentifier()
	#
	def getValue(self):
		return self.value
	#
	#		Get the default value for this object if none is provided
	#
	def defaultValue(self):
		if self.isString:														# Random string
			return "".join([chr(random.randint(65,90)) for x in range(0,random.randint(0,5))])
		n = random.randint(-250000,250000)										# Random large integer
		return n if random.randint(0,2) > 0 else random.randint(-100,100)		# reduce range often
	#
	#		Generate a legal identifier name randomly.
	#
	def generateIdentifier(self):
		s1 = chr(random.randint(1,26)+96)										# first is A-Z
		for n in range(0,random.randint(0,3)):									# add A-Z0-9 on.
			s1 = s1 + chr(random.randint(1,26)+96 if random.randint(0,2) > 0 else random.randint(48,57))
		return s1
	#
	#		Convert to a displayable format.
	#
	def toString(self):
		return "{0}:={1}".format(self.getFullIdentifier(),self.valueToString(self.getValue()))
	#
	#		Helper function, converts value of object to text representation
	#
	def valueToString(self,n):
		return '"'+n+'"' if self.isString else str(n)
	#
	#		Convert to a token list. This will normally be a sequence 0 (empty link) ID:<name>
	#		ArraySize if array, followed by numeric or ST:Data. The numbers are in final format
	#		but space needs to be allocated for the identifiers and strings.
	#
	def convertToTokens(self):
		tokens = self.getTokenHeader()
		value = self.getValue()
		value = value if isinstance(value,list) else [ value ]
		for t in value:
			if isinstance(t,str):
				tokens.append("ST:"+t)
			else:
				t = t & 0xFFFFFFFF
				tokens.append(t & 0xFFFF)
				tokens.append(t >> 16)
		return tokens
	#
	#		Get the token header, which is normally an empty link and identifier.
	#
	def getTokenHeader(self):
		return [0,"ID:"+self.getTokenIdentifier()]
	#
	#		Check if fast variable.
	#
	def isFastVariable(self):
		return False			
	#
	#		Import the given variable into the variable structure
	#
	def importVariables(self,varBlock):
		tokenList = self.convertToTokens()										# convert to tokens.
		#
		if self.isFastVariable():												# Fast variables simpler.
			fvAddress = BasicBlock.FASTVARIABLES+varBlock.baseAddress 			# base address of fasts
			fvAddress += ((ord(self.getIdentifier()[0].upper())-ord('A')) * 4)	# adjust it.
			varBlock.writeWord(fvAddress,tokenList[0])							# Write LONG out.
			varBlock.writeWord(fvAddress+2,tokenList[1])
			return
		#
		self.memoryVariableCreated = True 										# no more code.
		address = self.allocateLowMemory(len(tokenList)*2)						# allocate memory for new variable.
		for i in range(0,len(tokenList)):										# for each token.
			pass																# copy, allocating if reqd.
		# 	Patch into selected hash table.

Variable.usedIdentifiers = {}													# Stops duplicate identifiers
Variable.tokeniser = None														# Shared tokeniser

#
#		Integer variable subclass
#
class IntegerVariable(Variable):
	def __init__(self,name = None,defaultValue = None):
		Variable.__init__(self,False,name,defaultValue)
	#
	def getTokenHeader(self):
		return [] if self.isFastVariable() else Variable.getTokenHeader(self)	# Fast variables have no header
	#		
	def isFastVariable(self):													# A-Z
		return len(self.name) == 1
#
#		String variable subclass
#
class StringVariable(Variable):
	def __init__(self,name = None,defaultValue = None):
		Variable.__init__(self,True,name,defaultValue)

# *******************************************************************************************
#
#									Array Classes
#
# *******************************************************************************************

class Array(Variable):
	def __init__(self,isString,highSub = None,name = None,defaultValue = None):
		highsub = highSub if highSub is not None else random.randint(2,6)		# allocate random size
		self.highSubscript = highsub 											# store high subscript
		Variable.__init__(self,isString,name,defaultValue)						# and initialise
	#
	#		Here the full identifier and token identifier are different.
	#
	def getFullIdentifier(self):
		return Variable.getFullIdentifier(self)+"("+str(self.highSubscript)+")"
	def getTokenIdentifier(self):
		return Variable.getFullIdentifier(self)+"("
	#
	#		The token header has the array high subscript added as the third word.
	#
	def getTokenHeader(self):
		header = Variable.getTokenHeader(self)									# get standard
		header.append(self.highSubscript)										# add subscript.
		return header
	#
	#		The default value is a list of default values. Note there is one extra value
	#		as a$(10) has a$(0) -> a$(10) e.g. 11 strings.
	#
	def defaultValue(self):
		value = []
		for i in range(0,self.highSubscript+1):
			value.append(Variable.defaultValue(self))
		return value 
	#
	#		This converts the list rather than a single value.
	#
	def valueToString(self,v):
		return "["+(",".join([Variable.valueToString(self,x) for x in v]))+"]"

#
#		Integer Array class
#
class IntegerArray(Array):
	def __init__(self,highSub = None,name = None,defaultValue = None):
		Array.__init__(self,False,highSub,name,defaultValue)

#
#		String Array class
#
class StringArray(Array):
	def __init__(self,highSub = None,name = None,defaultValue = None):
		Array.__init__(self,True,highSub,name,defaultValue)


# *******************************************************************************************
#
#							Block Object with Imported Variables
#
# *******************************************************************************************

class VariableBlock(BasicBlock):
	def __init__(self,baseAddress = 0x0000,size = 0xFFFF,debug = False):
		BasicBlock.__init__(self,baseAddress,size,debug)

if __name__ == "__main__":
	blk = VariableBlock(0x4000,0x8000)
	random.seed(42)
	blk.debug = True
	#blk.addBASICLine(10,'((2+3)*(4+5)*2)+1')
	#blk.export("temp/basic.bin")	
	for i in range(0,2):
		print()
		v1 = IntegerVariable()
		print(v1.toString())
		print(v1.convertToTokens())
		v1.importVariables(blk)

