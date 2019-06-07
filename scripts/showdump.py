# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		showdump.py
#		Purpose :	Basic code block manipulator
#		Date :		7th July 2018
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import re,os,sys
from dispvariables import *

if __name__ == "__main__":
	blk = ListableVariableBlock(0x4000,0x8000)
	blk.importFile("basic.dump")
	blk.listVariables()

