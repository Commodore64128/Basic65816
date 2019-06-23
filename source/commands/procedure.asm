; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		procedure.asm
;		Purpose : 	PROC ENDPROC
;		Date :		19th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									PROC (procedure)
;
; *******************************************************************************************

Command_PROC: ;; proc
		lda 	#Block_ProgramStart 		; go to start of program
		clc
		adc 	DBaseAddress
		tax 								; X is used to track it
		;
		;		Scan looking for a line beginning with DEFPROC.
		;
_FPROLoop:
		lda 	@w$0000,x 					; is the link zero
		beq 	_FPROUnknown		
		lda 	@w$0004,x 					; does it begin with DEFPROC
		cmp 	#defprocTokenID
		beq 	_FPROFoundDefProc
_FPRONext:
		txa 								; follow the link.
		clc
		adc 	@w$0000,x		
		tax
		bra 	_FPROLoop
		;
		;		Found a DefProc. Check if the first two tokens match.
		;
_FPROFoundDefProc:		
		lda 	@w$0006,x 					; compare the first tokens.
		cmp 	(DCodePtr)
		bne 	_FPRONext			
		;
		;		Compare the rest.
		;
		txa 								; DTemp1 points to the token.
		clc
		adc 	#6
		sta 	DTemp1 			
		ldy 	#0
_FPROCompare: 								; check loop
		lda 	(DTemp1),y
		cmp 	(DCodePtr),y
		bne 	_FPRONext 					; fails, different
		iny
		iny
		and 	#IDContMask 				; while there's more to test
		bne 	_FPROCompare
		;
		tya 								; this is the offset to the next element
		clc
		adc 	DTemp1 			
		pha 								; push the next command on the stack
		phx 								; push the record address on the stack.
		;
		;		Identify target, skip name.
		;
		ldx 	DStack 						; point Y to the stack.
		;
		tya 								; work out the return address
		clc
		adc 	DCodePtr
		sta 	$02,x 						; save pos at +2
		lda 	DLineNumber 				; save line number at +4
		sta 	$04,x
		lda 	#procTokenID 				; save proc token at +6
		sta 	$06,x

		txa 								; advance stack by 6.
		clc
		adc 	#6
		sta 	DStack
		;
		;		Update lineNumber and Code Pointer.
		;
		ply 								; line record address
		lda 	$0002,y 					; get line number
		sta 	DLineNumber
		pla 								; next command
		sta 	DCodePtr 
		;
		;		Parameters available ? - is the token for the DEFPROC an array (e.g. xxxx( )
		;
		ldy 	DCodePtr 					; get the new code address, the address after  DEFPROC x		
		dey 								; get the previous token
		dey
		lda 	$0000,y 					; read the token
		and 	#IDArrayMask 				; is it a function call - e.g. an array type ?
		bne 	_FPROParameter				; if not, set up the parameters.
		rts

_FPROUnknown:
		#error 	"Unknown procedure"

; *******************************************************************************************
;
;									Handle Parameters
;
;	The parameters are stored in a table "PRMBuffer". 
;
;	In the first phase, the parameter values (from caller) are evaluated and stored in
;	that buffer.
;
;	In the second phase, the parameter variables are localised and the buffer data is stored
;	in those addresses.
;
; *******************************************************************************************

_FPROParameter:		
		;
		;		Save code pointer on the stack, and set up to scan return address.
		;
		lda	 	DCodePtr 					; save code pointer
		pha
		lda 	DStack 						; get the stack.
		sec
		sbc 	#4 							; this is the address of that return value
		pha 								; save that on the stack.
		tax
		lda 	$00,x 						; get that return address
		sta 	DCodePtr 					; and set up the code pointer.
		;
		;		Now extract the parameter values, putting them in the buffer.
		;
		ldx 	#PRMBuffer 					; X points to the parameter buffer.
_FPROGetValues:
		phx 								; save X
		jsr 	Evaluate 					; Evaluate into YA, type into CS.
		plx 								; restore X
		sta 	$00,x 						; save value 
		tya
		sta 	$10,x
		lda 	#0 							; get the carry into A, so 0=int,1=string
		rol 	a 
		sta 	$20,x 						; write into type slot.
		inx 								; next entry into parameter table.
		inx 
		lda 	(DCodePtr) 					; get next token and skip it
		inc 	DCodePtr
		inc 	DCodePtr
		cmp 	#commaTokenID 				; if comma, another parameter.
		beq 	_FPROGetValues
		cmp 	#rParenTokenID 				; if not right bracket, then error.
		bne 	_FPROSyntax
		lda 	#$FFFF 						; store -1 in the next type slot.
		sta 	$20,x 						; marks the end of the parameters.
		;
		plx 								; address of return address
		lda 	DCodePtr 					; write return address back.
		sta 	$00,x
		;
		pla 								; restore old code pointer (the parameter addresses)
		sta 	DCodePtr
		;
		;		Now we localise the parameter variables, writing out the data to the target
		;		address as we go.
_FPROSetupParameters:
		ldx 	#PRMBuffer 					; start of buffer.
_FPROSetupLoop:
		lda 	$20,x 						; get the type
		bne 	_FPROSetupString
		;
		;		Set up an integer.
		;
		phx 								; localise variable, preserving X.
		jsr 	LocalProcessVariable
		plx 
		bcs 	_FPROTypeError 				; must be integer variable.
		tay  								; target address in Y.
		;
		lda 	$00,x 						; copy data
		sta 	$0000,y
		lda 	$10,x
		sta 	$0002,y
		bra 	_FPRONextParameterValue
		;
		;		Set up a string
		;
_FPROSetupString:		
		phx 								; localise variable, preserving X.
		jsr 	LocalProcessVariable
		plx 
		bcc 	_FPROTypeError 				; must be integer variable.
		tay  								; target address in Y.
		lda 	$00,x 						; address of new string in A
		phx 								; preserve X. 
		jsr 	StringAssign 				; assign the string using the function used by LET.
		plx
		;
		;		Go to next entry.
		;
_FPRONextParameterValue:
		inx 								; next parameter in parameter table.
		inx
		lda 	$20,x 						; type of next
		bmi 	_FPROComplete 				; if -ve then we have assigned everything.
		jsr 	ExpectComma 				; expect a comma
		bra 	_FPROSetupLoop 				; and do the next one.

_FPROComplete:
		jsr 	ExpectRightBracket 			; the right bracket closing the parameter list		
		rts

_FPROTypeError:
		#error 	"Bad parameter type"		


_FPROSyntax:
		brl 	SyntaxError

; *******************************************************************************************
;
;										ENDPROC
;
; *******************************************************************************************

Command_ENDPROC: ;; endproc
		jsr 	LocalRestore 				; restore any local variables.
		ldx 	DStack						; what's on the top of the stack.
		lda 	$00,x
		cmp 	#procTokenID 				; check top token.		
		bne 	_FENPFail
		txa 								; unpick stack.
		sec
		sbc 	#6
		sta 	DStack
		tax
		lda 	$02,x 						; copy code pointer out.
		sta 	DCodePtr
		lda 	$04,x 						; copy line number out
		sta 	DLineNumber
		rts

_FENPFail:
		#error 	"EndProc without Proc"
		