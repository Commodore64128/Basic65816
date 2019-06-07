; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		expression.asm
;		Purpose : 	Expression Evaluation
;		Date :		6th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;										Base Evaluate.
;
;		Evaluate expression at (DCodePtr), returning value in YA.
;		This is used when called from a keyword
;
;		When calling from a non-base, e.g. inside a unary function, use EvaluateNext
;		functions.
;
; *******************************************************************************************

Evaluate:
		ldx		#EXSBase 					; reset the stack
		lda 	#0<<9 						; start at the lowest precedence level.
											; fall through.

; *******************************************************************************************
;
;		Evaluate a term/operator sequence at the current precedence level. A contains the
;		precedence level shifted 9 left (matching the keyword position). X contains the 
;		expression stack offset.
;
;		Returns value in YA and CS if string.
;
;		Precedence climber : See expression.py in documents
;
; *******************************************************************************************

EvaluateLevel:
		and 	#$7FFF 						; zero type bit.
		sta 	EXSPrecType+0,x 			; save precedence level.

		lda 	(DCodePtr)					; look at the next token
		cmp 	#$C000 						; if $C000-$CFFF then variable.
		bcs 	_ELVariable
		cmp 	#$4000 						; if $4000-$BFFF then constant
		bcs 	_ELConstant
		cmp 	#$1000 						; if $0000-$00FF then it's a end of line or string.
		bcc 	_ELStringConstant 
		cmp 	#$2000 						; if $1000-$1FFF then it's a constant shift
		bcc 	_ELConstantShift
		brl 	_ELUnaryKeyword 			; if $2000-$3FFF then it's a unary operator/keyword
		;
		;		Constant Shift $1000-$1FFF.
		;
_ELConstantShift:		
		and 	#$0FFF 						; mask out bits 11-0
		sta 	DConstantShift 				; save in constant shift
		inc 	DCodePtr 					; skip over the token.
		inc 	DCodePtr
		;
		;		Constant $4000-$BFFF
		;
_ELConstant:
		lda 	(DCodePtr)					; get the constant value
		asl 	a 							; shift it left, losing bit 15
		lsr 	DConstantShift 				; shift constant right into carry.
		ror 	a 							; rotate that into the constant value
		sta 	EXSValueL+0,x 				; save as low word
		lda 	DConstantShift 				; constant shift is high word.
		sta 	EXSValueH+0,x
		stz 	DConstantShift 				; clear the constant shift
		inc 	DCodePtr 					; skip over constant
		inc 	DCodePtr
		;
		;		We have a legal atom now. Look for a binary operator.
		;
_ELGotAtom:
		lda 	(DCodePtr) 					; get code pointer.
		tay 								; save in Y
		and 	#$F000 						; is it 0010 xxxk e.g. a binary operator.
		cmp 	#$2000 						; if not then exit
		bne 	_ELExit
		;
		lda 	EXSPrecType+0,x 			; get precedence/type
		and 	#15 << 9 					; mask out the precedence bits.
		sta 	DTemp1 						; save in temporary register
		;
		tya 								; get the keyword token back
		and 	#15 << 9 					; mask out the precedence bits.
		cmp 	DTemp1 						; compare against precedence.
		bcc 	_ELExit 					; precedence too low, then exit.
		;
		;		Found a legal binary operator. Calculate the right hand side.
		;
		phy 								; save the binary operator on the stack
		inc 	DCodePtr 					; skip over the binary operator.
		inc 	DCodePtr
		clc 								; try the next level up
		adc 	#1 << 9
		inx 								; calculate the RHS at the next stack level.
		inx
		jsr 	EvaluateLevel 
		dex
		dex
		ply 								; get operator token back into Y
		;
		;		Execute code associated with the token, which is in Y
		;
_ELExecuteY:
		tya
		and 	#$01FF 						; keyword ID.
		asl 	a 							; double it as keyword vector table is word data
		txy 								; save X in Y
		tax 								; double keyword ID in X
		lda 	CommandJumpTable,x 			; this is the vector address
		tyx 								; restore X.
		sta 	_ELCallRoutine+1 			; Self modifying, will not work in ROM.
		;
_ELCallRoutine:
		jsr 	_ELCallRoutine 				; call the new address *MODIFIED*
		bra 	_ELGotAtom 					; go round operator level again.
		;
		;		Exit evaluation at this level.
		;
_ELExit:lda 	EXSPrecType+0,x 			; type into carry
		asl 	a
		lda 	EXSValueL+0,x 				; put result into YA
		ldy 	EXSValueH+0,x
		rts		
		;
		;		Variable code. Executed when found $C000-$FFFF as its an identifier.
		;
_ELVariable:
		jsr 	VariableFindCreate 			; this will be 'find variable, create if required', get value.
		sta 	EXSValueL+0,x 				; save variable contents in stack
		sty 	EXSValueH+0,x
		bra 	_ELGotAtom
		;
		;		Branch to syntax error
		;
_ELSyntax
		brl 	SyntaxError
		;
		;		String constant. Executed when found $0000-$0FFF
		;
_ELStringConstant:
		ora 	#0000 						; if it is $0000 then we have an error, end of line.
		beq 	_ELSyntax
		lda 	DCodePtr 					; get the code pointer and add 2, to point to the string
		inc 	a
		inc 	a
		sta 	EXSValueL+0,x 				; this is the low word
		stz 	EXSValueH+0,x 				; high word is zero.	
		lda 	(DCodePtr)					; get length to skip
		clc 								; add to string constant.
		adc 	DCodePtr 				
		sta 	DCodePtr
		lda 	EXSPrecType+0,x 			; set type to string
		ora 	#$8000
		sta 	EXSPrecType+0,x
		bra 	_ELGotAtom
		;
		;		Keyword. Executed when $2000-$3FFF. This can be one of three things - a unary
		; 		function, a unary operator (- only for now) or a parenthesised expression (<expr>)
		;
_ELUnaryKeyword:
		lda 	(DCodePtr)					; look at the next token
		tay 								; put the token in Y.
		inc 	DCodePtr 					; skip over it
		inc 	DCodePtr
		and 	#$1E00 						; mask out the keyword type.
		cmp 	#$1000 						; if it is xxx1 000x then it's a unary function
		beq 	_ELExecuteY					; go back and execute it
		;
		;		Check parenthesised expression, then get the atom and do something with it :)
		;
		cpy 	#lparenTokenID 				; is it an open bracket ?
		bne 	_ELUnaryOperator 			; it not, try unary operators.
		jsr 	EvaluateNext 				; evaluate the expression
		jsr 	ExpectRightBracket 			; consume the right bracket.
_ELCopy:
		lda 	EXSValueL+2,x 				; just copy the value 
		sta 	EXSValueL+0,x
		lda 	EXSValueH+2,x
		sta 	EXSValueH+0,x
		brl 	_ELGotAtom 					; and continue.
		;
		;		Unary Operators.
		;
		;
		;		Unary Operator - ! ? $ which are all followed by an atom. So first get the atom.
		;
_ELUnaryOperator:
		phy 								; save the operator on the stack.
		inx 								; this is like evaluate next
		inx
		lda 	#7<<9 						; except we use a very high precedence to make it atomic
		jsr 	EvaluateLevel 	
		dex 								; unwind the stack.						
		dex 		
		pla 								; restore the unary operator.
		;
		cmp 	#minusTokenID				; -xxx is unary negation
		beq 	_ELMinus
		jmp 	SyntaxError
		;
		;		Unary negation.
		;
_ELMinus:
		sec 								; do the negation calculation.
		lda 	#0
		sbc 	EXSValueL+2,x
		sta 	EXSValueL+0,x
		lda 	#0
		sbc 	EXSValueH+2,x
		sta 	EXSValueH+0,x
		brl 	_ELGotAtom					; and continue.

; *******************************************************************************************
;
;		 Evaluate at the next level down with A containing the precedence level.
;
; *******************************************************************************************

EvaluateNext:
		inx
		inx
		lda 	#0<<9
		jsr 	EvaluateLevel
		dex
		dex
		rts

; *******************************************************************************************
;
;					Evaluate and check result is integer or string
;
;		  Four of these, one for each type, one for inline function/main function
;
; *******************************************************************************************

EvaluateInteger:
		jsr 	Evaluate
		bcs 	EIType
		rts
EIType:		
		#error 	"Number expected"

EvaluateNextInteger:
		jsr 	EvaluateNext
		bcs 	EIType
		rts

EvaluateString:
		jsr 	Evaluate
		bcc 	ESType
		rts
ESType:		
		#error 	"String expected"

EvaluateNextString:
		jsr 	EvaluateNext
		bcc 	ESType
		rts

