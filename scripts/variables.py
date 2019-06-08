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
		if Variable.tokeniser is None:											# create tokeniser shared.
			Variable.tokeniser = Tokeniser()

		self.name = name.lower() if name is not None else name 					# Set default values
		self.isString = isString		 										
		while self.name is None or self.name in Variable.usedIdentifiers:		# Generate unique name if required
			self.name = self.generateIdentifier().lower()
		Variable.usedIdentifiers[self.name] = True								# Mark as used
		self.value = self.defaultValue() if defValue is None else defValue 		# Generate def value if required
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
	#		Return the name and value for a randomly chosen part of this variable.
	#		(if it's not an array you have no choice, obviously)
	#
	def pickElement(self):
		return [self.getFullIdentifier(),self.getValue()]
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
		if Variable.tokeniser.findToken(s1):
			return self.generateIdentifier()
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
	def importVariable(self,varBlock):
		#print("IMPORTING: "+self.toString())
		tokenList = self.convertToTokens()										# convert to tokens.
		#
		if self.isFastVariable():												# Fast variables simpler.			
			fvAddress = BasicBlock.FASTVARIABLES+varBlock.baseAddress 			# base address of fasts
			fvAddress += ((ord(self.getIdentifier()[0].upper())-ord('A')) * 4)	# adjust it.
			if varBlock.debug:
				print("== Updating fast variable ==")
			varBlock.writeWord(fvAddress,tokenList[0])							# Write LONG out.
			varBlock.writeWord(fvAddress+2,tokenList[1])
			return
		#
		self.memoryVariableCreated = True 										# no more code.
		#
		if varBlock.debug:
			print("== allocating variable memory ==")
		address = varBlock.allocateLowMemory(len(tokenList)*2)					# allocate memory for new variable.
		#
		if varBlock.debug:
			print("== creating strings/identifiers ==")
		for i in range(0,len(tokenList)):										# for each token.
			if isinstance(tokenList[i],str):									# id/string tokens are stored
				tokenList[i] = self.convertString(tokenList[i],varBlock)		# in high memory.
		#				
		if varBlock.debug:
			print("== copying data in ==")
		for i in range(0,len(tokenList)):										# for each token.
			varBlock.writeWord(address+i*2,tokenList[i])
		#
		firstToken = varBlock.readWord(tokenList[1])							# get the first identifier token
		self.hashPointer = self.hashAddress(varBlock,firstToken) 				# get the hash addr first token
		#
		if varBlock.debug:
			print("== Linking in ==")
		varBlock.writeWord(address+0,varBlock.readWord(self.hashPointer))		# Patch into list.
		varBlock.writeWord(self.hashPointer,address)
		return self

	#
	#		Convert a string item - ID:x or ST:x to an identifier token or prefix string
	#
	def convertString(self,element,varBlock):
		if element[:3] == "ID:":												# identifier.
			if varBlock.debug:
				print("== Identifier ==")
			tokens = Variable.tokeniser.tokenise(element[3:])					# tokenise the name
			address = varBlock.allocateHighMemory(len(tokens)*2)				# allocate mem for it.
			for i in range(0,len(tokens)):										# copy it in.
				varBlock.writeWord(address+i*2,tokens[i])
			return address
		#
		if element[:3] == "ST:":												# string.
			if varBlock.debug:
				print("== String with length prefix ==")
			string = [ord(c) for c in element[3:]]								# string as integers
			string.insert(0,len(string)) 										# add length prefix.
			if len(string) % 2 != 0:											# make even size.
				string.append(0)
			address = varBlock.allocateHighMemory(len(string))					# allocate and copy.
			for i in range(0,len(string),2):
				varBlock.writeWord(address+i,string[i]+string[i+1]*256)
			return address

		assert False
	#
	#		Get the hash address of a token given its first token.
	#
	def hashAddress(self,block,firstToken):
		addr = block.baseAddress + BasicBlock.HASHTABLE							# Base of table
		addr = addr + ((firstToken >> 12) & 3) * BasicBlock.HASHMASKENTRYSIZE*2	# Table for this type.
		addr = addr + (firstToken & BasicBlock.HASHMASK) * 2					# offset in that table.
		return addr

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
		if highSub is None and defaultValue is not None:						# get length from data.
			highSub = len(defaultValue)-1
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
	#		Return the name and value for a randomly chosen part of this array
	#
	def pickElement(self):
		n = random.randint(0,len(self.getValue())-1)
		return [self.getTokenIdentifier()+str(n)+")",self.getValue()[n]]
	#
	#		Generate a legal identifier name randomly.
	#
	def generateIdentifier(self):
		s = Variable.generateIdentifier(self)
		if Variable.tokeniser.findToken(s+"("):
			return self.generateIdentifier()
		return s
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
	def __init__(self,name = None,defaultValue = None,highSub = None):
		Array.__init__(self,False,highSub,name,defaultValue)

#
#		String Array class
#
class StringArray(Array):
	def __init__(self,name = None,defaultValue = None,highSub = None):
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
	random.seed(43)
	#blk.debug = True
	v1 = IntegerVariable("a1",42)
	print(v1.toString(),v1.convertToTokens())
	v1.importVariable(blk)
	#
	v1 = StringVariable("s14","Hello")
	print(v1.toString(),v1.convertToTokens())
	v1.importVariable(blk)
	#
	v1 = IntegerArray("arri12",[4,5,8])
	print(v1.toString(),v1.convertToTokens())
	v1.importVariable(blk)
	#
	v1 = StringArray("strarr0",["I","like","chips"])
	print(v1.toString(),v1.convertToTokens())
	v1.importVariable(blk)
	#
	blk.exportFile("temp/basic.bin")	
