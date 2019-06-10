# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		test_change.py
#		Purpose :	Create lots of variables/arrays, change them and check contents.
#					Change by copying from another variable, or assigning a constant.
#		Date :		10th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random
from variables import *

if __name__ == "__main__":
	print("Change test code.")
	eb = EntityBucket(-1,100,100,10,10)
	#
	bs = BasicSource()
	bs.append(eb.setupCode())
	bs.append(eb.assignCode())
	#
	for i in range(0,1000):
		ok = False
		while not ok:
			v1 = eb.randomChoice()
			v2 = eb.randomChoice()
			ok = v1.isString == v2.isString

		if random.randint(0,1) == 0:
			newValue = v2.getValue()
			v1.setValue(newValue)
			bs.append("let {0} = {1}".format(v1.getIdentifier(),v2.getIdentifier()))
		else:
			newValue = v1.defaultValue()		
			v1.setValue(newValue)
			bs.append("let {0} = {1}".format(v1.getIdentifier(),v1.getCodeValue()))
	#
	blk = BasicBlock(0x4000,0x8000)
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	
	bs.append(eb.checkCode())
	bs.save()
