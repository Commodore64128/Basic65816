# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		make_editor.py
#		Purpose :	Create a BASIC program and make one edit to it.
#		Date :		17th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from basicblock import *
import random
#
#		Make up some line.
#
def createLine(n):
	return 'rem "Line number {0}" {1}'.format(n,"".join([getChr(x) for x in range(0,n>>4)]))

def getChr(x):
	if x % 4 == 0:
		return chr(random.randint(48,57))
	return chr(random.randint(65,90))
#
#		Create block and seed the random number
#
blk = BasicBlock(0x4000,0x8000)
random.seed()
seed = random.randint(0,999999)
random.seed(seed)
print("Seed ",seed)

#
#		Add some lines.
#
linesInProgram = {}
lineNumbers = []
print("Initial program")
for i in range(0,random.randint(0,4)):
	lineNumber = i * 20 + 100
	code = createLine(lineNumber)
	blk.addBASICLine(code,lineNumber)
	linesInProgram[lineNumber] = code
	lineNumbers.append(lineNumber)
	print(code,lineNumber)
print()
option = random.randint(0,2)
while option != 1 and len(linesInProgram) == 0:
	option = random.randint(0,2)
#
#		Option #0 : Delete a randomly chosen line.
#
if option == 0 and len(linesInProgram) > 0:
	lineNo = lineNumbers[random.randint(0,len(lineNumbers))-1]
	blk.setBoot(str(lineNo),False)
	linesInProgram[lineNo] = None
	print("Deleting ",lineNo)
#
#		Option #1 : Insert a new line
#
if option == 1:
	lineNumber = random.randint(0,4) * 20 + 90
	code = createLine(lineNumber)
	linesInProgram[lineNumber] = code
	lineNumbers.append(lineNumber)
	blk.setBoot(str(lineNumber)+" "+code,False)
	print("Inserting ",lineNumber,code)
#
#		Option #2: Overwrite a line.
#	
if option == 2:
	lineNo = lineNumbers[random.randint(0,len(lineNumbers))-1]
	code = createLine(lineNumber)
	linesInProgram[lineNumber] = code
	blk.setBoot(str(lineNumber)+" "+code,False)
	print("Overwriting ",lineNo,code)
#
#		Export the basic block
#
blk.exportFile("temp/basic.bin")	
#
#		Write out what should be there.
#
h = open("temp/edit.final","w")
keys = [x for x in linesInProgram.keys() if linesInProgram[x] is not None]
keys.sort()
for l in keys:
	h.write("{0} {1}\n".format(l,linesInProgram[l]))
	print(l,linesInProgram[l])
h.close()
