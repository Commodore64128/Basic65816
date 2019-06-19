# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		stringusage.py
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
		while self.readWord(pos) != 0:
			link = self.readWord(pos)
			if (link & 0x8000) != 0:
				self.freeStrings += 1
				self.freeStringSize += (link & 0x7FFF)
			else:
				self.usedStrings += 1
				self.usedStringSize += (link & 0x7FFF)
			pos = pos + (link & 0x7FFF) + 2
			
		if self.usedStrings != 0:
			print("{0} used strings totalling {1} bytes averaging {2}".format(self.usedStrings,self.usedStringSize,self.usedStringSize/self.usedStrings))
		if self.freeStrings != 0:				
			print("{0} free strings totalling {1} bytes averaging {2}".format(self.freeStrings,self.freeStringSize,self.freeStringSize/self.freeStrings))
		print("String usage {0}%".format(int(100*self.usedStringSize/(self.usedStringSize+self.freeStringSize))))

if __name__ == "__main__":
	blk = StringAnalysisBlock(0x4000,0x8000)
	blk.importFile("basic.dump")	
	blk.analyse()
