# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		showdump.py
#		Purpose :	Block object that can display variables.
#		Date :		10th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import re,os,sys,random
from basicblock import *

# *******************************************************************************************
#
#							Block Object with Imported Variables
#
# *******************************************************************************************

class ListableVariableBlock(BasicBlock):
	#
	#		List variables.
	#
	def listVariables(self,handle = sys.stdout):
		self.lowestString = 0x10000
		self.listFastVariables(handle)
		for typeID in range(0,4):
			hashTable = self.baseAddress+BasicBlock.HASHTABLE+BasicBlock.HASHMASKENTRYSIZE * typeID * 2
			self.listVariableType(handle,hashTable,typeID,["Integer","Integer Array","String","String Array"][typeID])
	#
	#		List all non-zero fast variables.
	#
	def listFastVariables(self,handle = sys.stdout):
		handle.write("\nType : Fast Integer Variables A-Z (non-zero only)\n")
		for i in range(0,26):
			name = chr(i+97)
			address = self.baseAddress+BasicBlock.FASTVARIABLES+i * 4
			data = self.readLong(address)
			if data != 0:
				self.output(handle,name,address,"**",self._formatList([data],False,False))
	#
	#		List all variables of a particular type.
	#
	def listVariableType(self,handle,hashTableBase,typeID,typeName):
		handle.write("\nType : {0:16} Hash Table at : ${1:04x}\n".format(typeName,hashTableBase))
		for hashEntry in range(0,BasicBlock.HASHMASKENTRYSIZE):
			addr = self.readWord(hashTableBase+hashEntry*2)						# first record
			while addr != 0:													# follow the links.
				#
				if typeID % 2 == 0:												# single element
					dataCount = 1
					dataBase = addr + 4
				else:															# array
					dataCount = self.readWord(addr+4)+1 						# +1, it's a high subscript
					dataBase = addr + 6
				#
				data = []				
				for i in range(0,dataCount):
					data.append(self.readLong(i*4+dataBase))
					if typeID >= 2 and data[-1] > self.readWord(self.baseAddress+BasicBlock.LOWPTR):
						self.lowestString = min(self.lowestString,data[-1])
				#
				name = self.decodeIdentifier(self.readWord(addr+2))
				self.output(handle,name,addr,"#{0:x}".format(hashEntry),self._formatList(data,typeID >= 2,typeID % 2 != 0))
				addr = self.readWord(addr)
	#
	#		Decode identifier
	#
	def decodeIdentifier(self,addr):
		s = ""
		done = False
		firstToken = self.readWord(addr)
		while not done:
			token = self.readWord(addr)
			t1 = token & 0x07FF
			s = s + self._diChar(t1 % 45) + self._diChar(int(t1/45))
			addr += 2
			done = (token & 0x0800) == 0
		if (firstToken & 0x2000) != 0:
			s = s + "$"
		if (firstToken & 0x1000) != 0:
			s = s + "()"
		return s.lower()
	#
	def _diChar(self,c):
		if c == 0:
			return ""		
		return chr(c+96) if c <= 26 else str(c-27)
	#
	#		Output information on one variable.
	#
	def output(self,handle,identifier,address,hashInfo,data):
		handle.write("\t{0:12} {3} @${1:04x} : {2}\n".format(identifier,address,data,hashInfo))
	#
	def _formatList(self,dataList,isString,isArray):
		slist = ",".join([self._formatItem(item,isString) for item in dataList])
		return "["+slist+"]" if isArray else slist
	#
	def _formatItem(self,item,isString):
		if not isString:
			#return "{0}${0:x}".format(item)
			return "{0}".format(item)
		if item == 0:
			return "*BUG*"
		s = "".join([chr(self.readByte(item+1+i)) for i in range(0,self.readByte(item))])
		return '"{0}"@${1:04x}'.format(s,item)
		return '"{0}"'.format(s)
	#
	#		Complete G/C Check (see make_gc.py). make_gc creates initial values jklmn. It then assigns
	#		lots of values with WXYZ in. Lastly, anything which has WXYZ in is overwritten with abcd
	#
	#		After garbage collection, the WXYZ should have all been removed. This combined with the 
	#		consistency check in the generated BASIC tests the garbage collection.
	#
	def completeGCCheck(self,pos):
		#pos = self.readWord(self.baseAddress+BasicBlock.HIGHPTR)
		while pos < self.endAddress:
			size = self.readByte(pos)
			name = "".join([chr(self.readByte(pos+i+1)) for i in range(0,size)])
			#print("{0:x} {1} {2}".format(pos,self.readByte(pos),name))
			assert name.lower() == name,"Value "+name+" found"
			pos = pos + size + 1
		print("String area is all lower case.")

if __name__ == "__main__":
	blk = ListableVariableBlock(0x4000,0x8000)
	blk.importFile("basic.dump")	
	if len(sys.argv) == 2:
		blk.listVariables(open(os.devnull,"w"))
		print("Lowest string is at ${0:04x}".format(blk.lowestString))
		blk.completeGCCheck(blk.lowestString)
	else:
		#blk.listVariables(open("var.txt","w"))
		blk.listVariables()
