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
	rnd( 										## random number 32 bit							
	sgn( 	abs( 	len(	 					## standard
	val(	str$(								## string to integer,integer to string.
	chr$( 	asc(								## character to integer conversion.
	spc(										## space formatting
	peek(	deek( 	leek(						## peek byte/word/long
	lower$( upper$( 							## recasing.
	left$(	mid$(	right$(						## string subdivision.
					
[syntax]
	, 	;	:	(	)	'	

[keyword-syntax]	
	to  step 									## syntax words for for/next

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
	else 										## else for if .. else .. endif
	poke doke loke 								## byte/word/long write.
	list 										## Program list.

[keyword+]
	repeat										## repeat loop test at bottom
	while 										## repeat loop test at top
	if 											## conditional execution
	for 										## indexed loop

[keyword-]										## until for repeat.
	wend 										## repeat loop test at top
	until 										## and at bottom
	then 	endif 								## end for if statements.
	next 										## end of indexed loop
	
""".split("\n")

if __name__ == "__main__":
	print(TokenSource().get())