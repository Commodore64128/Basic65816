# *******************************************************************************************
# *******************************************************************************************
#
#		Name : 		tokensrc.py
#		Purpose :	Tokens source as Python Class
#		Date :		10th June 2019
#		Author : 	Paul Robson (paul@robsons.org.uk)
#
# *******************************************************************************************
# *******************************************************************************************

class TokenSource(object):
	def get(self):
		return """
## ********************************************************************************
##
##							Tokens defined in Basic
##
## ********************************************************************************

[0]
	&	|	^									## bitwise operators.

[1]	
	< 	> 	= 	<= 	>= 	<> 						## signed comparators

[2]
	+	- 										## additive operators

[3]	
	*		/		%							## multiply and divide, modulus, signed
	>> 		<< 									## logical shift left and right, zeros shifted in


[unary]
	rnd() 										## random number 32 bit							
	sgn( 	abs( 	len(	 					## standard
	val(	str$(								## string to integer,integer to string.
		
[syntax]
	, 	;	:	(	)	'	

[keyword]										
	let 										## assignment	
	assert 										## debugging helper
	end 										## end program
	run 										## run program.
	clear 										## clear all variables.
	dim 										## array dimension.
	collect 									## garbage collection.
	cls 										## clear screen
	print 		? 								## print and shorthand print.
				
[keyword+]
	while

[keyword-]
	wend

""".split("\n")

if __name__ == "__main__":
	print(TokenSource().get())