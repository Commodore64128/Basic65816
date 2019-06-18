# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		dump_export.py
#		Purpose :	Decode code in basic.dump file.
#		Date :		18th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

from basicblock import *
from gentokens import *
import datetime

class DumpFile(object):
	def __init__(self):
		self.binary = [x for x in open("basic.dump","rb").read(-1)]					
		self.tokens = TokenList().getList()
	def read(self,addr):
		return self.binary[addr]+self.binary[addr+1]*256

	def deTokenise(self,pos):
		s = ""
		self.constantShift = 0
		while self.read(pos) != 0:
			token = self.read(pos)
			pos = pos + 2
			if token < 0x100:
				s = s + '"'
				s = s + "".join([chr(self.binary[pos+1+i]) for i in range(0,self.binary[pos])])
				s = s + '"'
				pos = pos + token - 2
			elif token < 0x2000:
				self.constantShift = token & 0xFFF
			elif token < 0x4000:
				tokenID = token & 0x1FF
				s = s + " "+self.tokens[tokenID-1].name.upper()+" "
			elif token < 0xC000:
				n = (token - 0x4000)+(self.constantShift << 15)
				self.constantShift = 0
				s = s + str(n)
			else:
				n1 = token & 0x7FF
				c1 = n1 % 45
				c2 = int(n1 / 45)
				s = s + self.decodeC(c1) + self.decodeC(c2)
				if (token & 0x800) == 0:
					if (token & 0x2000) != 0:
						s = s + "$"
					if (token & 0x1000) != 0:
						s = s + "("
		return s

	def decodeC(self,c):
		if c >= 1 and c <= 26:
			return chr(96+c)
		if c >= 27 and c <= 36:
			return chr(c-27+48)
		return ""

	def decode(self):
		pos = BasicBlock.PROGRAM
		code = []
		while self.read(pos) != 0:
			lineNumber = self.read(pos+2)
			line = self.deTokenise(pos+4).strip()
			print(lineNumber,line)
			pos = self.read(pos)+pos
			code.append(str(lineNumber)+" "+line)
		return code

	def copyOut(self):
		code = self.decode()
		print("Written to basic.bas")
		h = open("basic.bas","w")
		h.write("\n".join(code))
		h.close()
		#
		fName = datetime.datetime.now().strftime("%y%m%d-%H%M%S")
		fName = "archive"+os.sep+fName+".list"
		print("Written to "+fName)
		h = open(fName,"w")
		h.write("\n".join(code))
		h.close()
DumpFile().copyOut()
