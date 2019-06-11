#
#			Integer to String algorithm.
#
data = [ 0 ] * 32

def integerToString(n,base):
	assert base >= 2 and base <= 16 						# valid. Unary will not work :) 

	stack = [] 												# subtractor stack
	divisor = 1												# build a stack of subtractor numbers.
	while divisor < n:										# not there yet
		stack.append(divisor) 								# push subtractor
		divisor = divisor * base 							# special cases of 10 and 16.
	bytePtr = 1 											# where the digit goes.
	data[0] = 1 											# character count.

	subtractor = stack.pop()								# get first subtractor, can be folded into while.
	while subtractor != 1:
		data[bytePtr] = 0 									# zero count, increment chars
		data[0] += 1
		while n >= subtractor:								# subtract it until we can do no more.
			n = n - subtractor
			data[bytePtr] += 1
		subtractor = stack.pop()	 						# get next one, folded into top.
		bytePtr += 1
	data[bytePtr] = n 										# last bit,
	data[bytePtr+1] = 0										# ASCIIZ in case.

x = integerToString(65534,16)
print(data)

