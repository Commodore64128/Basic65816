# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		basicblock.py
#		Purpose :	Basic code block manipulator, with BASIC program addition.
#		Date :		6th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import re,os,sys
from gentokens import *
from tokeniser import *

# *******************************************************************************************
#
#										Basic Block Object
#
# *******************************************************************************************

class BasicBlock(object):
	def __init__(self,baseAddress = 0x0000,size = 0xFFFF,debug = False):
		self.baseAddress = baseAddress											# Block information
		self.blockSize = size
		self.endAddress = baseAddress + size
		self.data = [ 0 ] * size 												# containing data
		for i in range(0,4):													# set 4 byte header
			self.data[i] = ord(BasicBlock.ID[i])
		self.debug = False
		self.clearMemory()														# same as clear
		self.memoryVariableCreated = False 										# allocated memory
		self.debug = debug
		self.tokeniser = Tokeniser()											# tokenises things
		self.variables = {}														# variable info
		self.lastProgramLineNumber = 0
	#
	#		Check we haven't run out of space.
	#
	def check(self):
		low = self.readWord(self.baseAddress+BasicBlock.LOWPTR)					# get low/high
		high = self.readWord(self.baseAddress+BasicBlock.HIGHPTR)
		assert low+1024 < high," *** PROGRAM FULL ***"
	#
	#		Show memory status
	#
	def showStatus(self):
		low = self.readWord(self.baseAddress+BasicBlock.LOWPTR)					# get low/high
		high = self.readWord(self.baseAddress+BasicBlock.HIGHPTR)
		print("Low memory ${0:04x} High Memory ${1:04x} Free Memory ${2:04x}".format(low,high,high-low))
	#
	#	Write binary out
	#
	def importFile(self,fileName):
		h = open(fileName,"rb")													# write data as bytes
		self.data = bytes(h.read(-1))
		h.close()

	#
	#	Write binary out
	#
	def exportFile(self,fileName):
		self.check()
		h = open(fileName,"wb")													# write data as bytes
		h.write(bytes(self.data))
		h.close()
	#
	#	Erase all variables and code
	#
	def clearMemory(self):
		self.writeWord(self.baseAddress+BasicBlock.HIGHPTR,self.endAddress)		# reset high memory
		self.writeWord(self.baseAddress+BasicBlock.PROGRAM,0x0000)				# erase program
		self.resetLowMemory()													# reset low memory
	#
	#	Rewrite the spacer and low memory
	#
	def resetLowMemory(self):
		ptr = self.baseAddress+BasicBlock.PROGRAM 								# Where code starts
		while self.readWord(ptr) != 0x0000:										# follow the code link chain
			ptr = ptr + self.readWord(ptr)										# to the end.
		self.writeWord(ptr+2,0xEEEE)											# write EEEE twice after it
		self.writeWord(ptr+4,0xEEEE)											# visibility marker.
		self.writeWord(self.baseAddress+BasicBlock.LOWPTR,ptr+6)				# free memory starts here.
		return ptr 																# return where next line goes
	#
	#		Allocate low memory (e.g. from program end up)
	#
	def allocateLowMemory(self,count):
		addr = self.readWord(self.baseAddress+BasicBlock.LOWPTR)				# address to use
		self.writeWord(self.baseAddress+BasicBlock.LOWPTR,addr+count)			# update offset
		self.check()
		return addr 
	#
	#		Allocate high memory (e.g. from top down)
	#
	def allocateHighMemory(self,count):
		addr = self.readWord(self.baseAddress+BasicBlock.HIGHPTR) - count		# address to use
		self.writeWord(self.baseAddress+BasicBlock.HIGHPTR,addr)				# update new high address
		self.check()
		return addr
	#
	#		Read a byte from memory
	#
	def readByte(self,addr):
		assert addr >= self.baseAddress and addr <= self.endAddress 			# validate
		return self.data[addr - self.baseAddress]								# offset in data
	#
	#		Read a word from memory
	#
	def readWord(self,addr):
		assert addr >= self.baseAddress and addr <= self.endAddress 			# validate
		addr = addr - self.baseAddress 											# offset in data
		return self.data[addr] + self.data[addr+1] * 256 						# return it
	#
	#		Write a word to memory
	#
	def writeWord(self,addr,data):
		assert addr >= self.baseAddress and addr <= self.endAddress 			# validate it
		data = data & 0xFFFF 													# force into 16 bit
		self.data[addr-self.baseAddress] = data & 0xFF 							# store in structure
		self.data[addr-self.baseAddress+1] = data >> 8
		if self.debug:															# debug display
			print("{0:04x} : {1:04x}".format(addr,data))
	#
	#		Read long as signed int
	#
	def readLong(self,addr):
		val = self.readWord(addr)+(self.readWord(addr+2) << 16)					# read as 32 bit unsigned
		if (val & 0x80000000) != 0:												# convert to signed
			val = val - 0x100000000
		return val
	#
	#		Add a program in BASIC from a source text file.
	#
	def loadProgram(self,fileName = "basic.bas"):
		for l in [x.strip() for x in open(fileName).readlines()]:
			m = re.match("^(\d*)(.*)$",l)
			assert m is not None
			self.addBASICLine(m.group(2),None if m.group(1) == "" else int(m.group(1)))
		self.showStatus()
	#
	#		Add a line of BASIC
	#
	def addBASICLine(self,code,lineNumber = None):
		assert not self.memoryVariableCreated									# check not created variables
		if lineNumber is None or lineNumber == 0:								# default line number
			lineNumber = self.lastProgramLineNumber + 1
		assert lineNumber > self.lastProgramLineNumber and lineNumber <= 32767 	# check line number
		pos = self.resetLowMemory()												# where does it go
		self.lastProgramLineNumber = lineNumber 								# remember last
		#print("{0:5} {1}".format(lineNumber,code))
		codeLine = self.tokeniser.tokenise(code) 								# convert to tokens
		codeLine.append(0)														# EOL
		codeLine.insert(0,lineNumber) 											# insert line number
		codeLine.insert(0,len(codeLine)*2+2)									# skip
		codeLine.append(0)														# final program end marker
		for t in codeLine:														# write it out
			self.writeWord(pos,t)  
			pos += 2
		self.resetLowMemory() 													# and reset low memory
		self.check()
	#
	#		Export constants
	#
	def exportConstants(self,fileName):
		self.handle = open(fileName.replace("/",os.sep),"w")
		self._export("Block_FastVariables",BasicBlock.FASTVARIABLES)
		self._export("Block_HashTable",BasicBlock.HASHTABLE)
		self._export("Block_HashMask",BasicBlock.HASHMASK)
		self._export("Block_LowMemoryPtr",BasicBlock.LOWPTR)
		self._export("Block_HighMemoryPtr",BasicBlock.HIGHPTR)
		self._export("Block_ProgramStart",BasicBlock.PROGRAM)
		self._export("Block_HashTableEntrySize",BasicBlock.HASHMASKENTRYSIZE)
		self.handle.close()
	#
	def _export(self,name,value):
		self.handle.write("{0} = ${1:04x}\n".format(name,value))

BasicBlock.ID = "BASC"															# ID
BasicBlock.FASTVARIABLES = 0x10 												# Fast Variable Base
BasicBlock.HASHTABLE = 0x80 													# Hash Table Base
BasicBlock.LOWPTR = 0x08 														# Low Memory Allocation
BasicBlock.HIGHPTR = 0x0A 														# High Memory Allocation
BasicBlock.PROGRAM = 0x100 														# First line of program
BasicBlock.HASHMASK = 15 														# Hash mask (0,1,3,7,15)
BasicBlock.HASHMASKENTRYSIZE = 16 												# Entries per table.

if __name__ == "__main__":
	blk = BasicBlock(0x4000,0x8000)
	blk.addBASICLine('((2+3)*(4+5)*2)+1',10)
	blk.exportFile("temp/basic.bin")	
	blk.exportConstants("temp/block.inc")
