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
import os

fileImport = sys.argv[1].replace("/",os.sep).replace("\\",os.sep)
print("Importing {0}.".format(fileImport))
blk = BasicBlock(0x4000,0x8000)
blk.loadProgram(fileImport)
blk.exportFile("temp/basic.bin")	
