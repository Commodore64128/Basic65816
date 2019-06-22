# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		check_editor.py
#		Purpose :	Check to see if the edit worked properly.
#		Date :		17th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from basicblock import *

#
#		Create block and read dump in.
#
block = BasicBlock(0x4000,0x8000)
block.importFile("basic.dump")
#
#		Read the code that should be there.
#
lines = [x.strip() for x in open("../scripts/temp/edit.final").readlines() if x.strip() != ""]
#
#		Start Position
#
pos = block.baseAddress+BasicBlock.PROGRAM
#
#		Match each in turn.
#
for l in lines:
	print("Matching ",l)
	lineNumber = block.readWord(pos+2)
	m = re.match("^(\\d+)\\s*(.*)$",l)
	assert m is not None
	error = lineNumber != int(m.group(1))
	#
	tokens = block.tokeniser.tokenise(m.group(2).strip())
	tokens.append(0)
	for i in range(0,len(tokens)):
		if block.readWord(pos+4+i*2) != tokens[i]:
			error = True

	if block.readWord(pos) != len(tokens)*2+4:
		error = True
		
	if error:
		print("**** FAIL ****")
		while True:
			pass

	pos = pos + block.readWord(pos+0)

