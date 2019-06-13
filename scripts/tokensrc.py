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
	rem 										## comment (note comment must be a quoted string)									
	let 										## assignment	
	assert 										## debugging helper
	end 										## end program
	run 										## run program.
	stop 										## stop program.
	clear 										## clear all variables.
	dim 										## array dimension (one dimension only)
	collect 									## garbage collection (forced)
	cls 										## clear screen
	print 		 								## print
	goto gosub return on 						## transfer of control goto/gosub stuff.

[keyword+]
	repeat										## repeat loop test at bottom

[keyword-]										## until for repeat.
	until

""".split("\n")

if __name__ == "__main__":
	print(TokenSource().get())