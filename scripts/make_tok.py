# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		make_tok.py
#		Purpose :	Create tokenisation test.
#		Date :		12th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

import random
from basicblock import *
from tokeniser import *
from gentokens import *

def generateVariable():
	v = "".join([_vc(i > 0) for i in range(0,random.randint(1,3))])
	v = v if random.randint(0,1) == 0 else v + "$"
	v = v if random.randint(0,1) == 0 else v + "("
	return v

def _vc(allowDigits):
	if allowDigits and random.randint(0,2) == 0:
		return str(random.randint(0,9))
	c = chr(random.randint(65,90))
	return c if random.randint(0,1) == 0 else c.lower()

def punc():
	s = ":+-*/%,;'()  "
	return s[random.randint(0,len(s)-1)]
#
#		Prepare the seed.
#
random.seed()
seed = random.randint(0,99999)
#seed = 42
print("Seed is {0}".format(seed))
random.seed(seed)
#
#		Build the string
#
tokens = [x.name for x in TokenList().getList()]
#
checkString = ""
while len(checkString) < 128:
	n = random.randint(0,3)
	if n == 0:
		checkString += str(random.randint(0,999999))+punc()
	if n == 1:
		t = tokens[random.randint(0,len(tokens)-1)]
		checkString += (t.upper() if random.randint(0,1) == 0 else t.lower())+punc()
	if n == 2:
		checkString += generateVariable()+punc()

print(checkString)		
#
#checkString = '92 36666 -67890 "" "abc" "abcd" dem1 dem1$ dem1$( > >= < <= <> right$( list'
#
#
#		Create block and set up call to routine.
#
blk = BasicBlock(0x4000,0x8000)
blk.addBASICLine("list:link {0}:stop".format(0x1F000))
#
#		Copy untokenised string into memory at B000
#
b = [ord(x) for x in checkString+chr(0)]
for i in range(0,len(b)):
	blk.writeWord(0xB000+i,b[i])
#
#		Tokenise it and copy that to B200
#
toks = Tokeniser().tokenise(checkString)
toks.append(0)
assert len(toks) < 128
for i in range(0,len(toks)):
	#print("{0:02x} : {1:04x}".format(i,toks[i]))
	blk.writeWord(0xB200+i*2,toks[i])
#
print("Original size {0} Tokenised {1}".format(len(checkString)+1,len(toks)*2))
#
blk.exportFile("temp/basic.bin")	


