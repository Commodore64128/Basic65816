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
	eb = EntityBucket(1,4,4,0,0)
	#
	bs = BasicSource()
	bs.append(eb.setupCode())
	bs.append(eb.assignCode())
	print()
	#
	for i in range(0,15):
		ok = False
		while not ok:
			v1 = eb.pickOne()
			v2 = eb.pickOne()
			ok = v1[4] == v2[4]
		if random.randint(0,1) == 10:
			newValue = v2[2]
		else:
			newValue = v2[5].singleDefaultValue()
		#v1[5].updateValue(v1[6],newValue)
		bs.append("let {0} = {1}".format(v1[0],newValue if not v2[4] else '"'+newValue+'"'))
	#
	print()
	bs.append(eb.checkCode())
	blk = BasicBlock(0x4000,0x8000)
	blk.loadProgram()
	blk.exportFile("temp/basic.bin")	
	bs.save()
