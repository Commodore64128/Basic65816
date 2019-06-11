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
	eb = EntityBucket()
	#
	bs = BasicSource()
	bs.append(eb.setupCode())
	bs.append(eb.assignCode())
	print()
	#
	for i in range(0,500):
		ok = False
		while not ok:
			v1 = eb.pickOne()
			v2 = eb.pickOne()
			ok = v1.isString == v2.isString
		if random.randint(0,1) != 10:
			newValue = v2.getIdentifier()
			updateValue = v2.getValue()
		else:
			newValue = v2.singleDefaultValue()
			updateValue = newValue
			newValue = str(newValue) if not v2.isString else '"'+newValue+'"'
		bs.append("let {0} = {1}".format(v1.getIdentifier(),newValue))
		v1.setValue(updateValue)
	#
	print()
	bs.append(eb.checkCode())
	bs.save()

	blk = BasicBlock(0x4000,0x8000)
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	
