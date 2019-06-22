# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		string_usage.py
#		Purpose :	Analyse high memory string usage.
#		Date :		19th June 2019
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

class StringAnalysisBlock(BasicBlock):
	def analyse(self):
		self.usedStrings = 0
		self.usedStringSize = 0
		self.freeStrings = 0
		self.freeStringSize = 0
		pos = self.readWord(self.baseAddress+BasicBlock.HIGHPTR)
		stringCount = 0
		stringAllocated = 0
		stringUsed = 0
		while pos != self.endAddress:
			link = self.readByte(pos)
			stringCount += 1
			stringAllocated += link
			stringUsed += (1 + self.readByte(pos+1))
			pos = pos + link  + 2
		if stringCount != 0:
			print("Strings",stringCount)
			print("Used",stringUsed)			
			print("Allocated",stringAllocated)
			print("Efficiency",int(stringUsed*100/stringAllocated))

if __name__ == "__main__":
	blk = StringAnalysisBlock(0x4000,0x8000)
	blk.importFile("basic.dump")	
	blk.analyse()
