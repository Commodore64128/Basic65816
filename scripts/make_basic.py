# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		make_bas.py
#		Purpose :	Load build/basic.bas into position for assembly
#		Date :		12th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from basicblock import *

blk = BasicBlock(0x4000,0x8000)
blk.loadProgram("../build/basic.bas")
blk.exportFile("temp/basic.bin")	
