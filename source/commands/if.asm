; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		if.asm
;		Purpose : 	If/Then/Else/EndIf
;		Date :		13th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************
;
;		There are two types :-
;
;		IF <expr> THEN <command> 				(IF +1, THEN -1)
;
;		IF <expr> 								(IF +1, ENDIF -1)
;		<code>
;		ELSE 									(the ELSE clause is optional)
;		<code>
;		ENDIF
;
;		The first one is detected by the presence of the THEN keyword. If this is found, then 
; 		the expression is evaluated and the rest of the command skipped if it fails.
;		THEN allows THEN 50 as shorthand.
;
;		The second one is detected by the absence of THEN.
;		
;		(1)		the IF token is pushed on the stack.
;
;		(2a) 	if successful, execution continues until either ENDIF or ELSE
;				is found.
; 					ELSE 	check and throw the IF marker, scan forward to ENDIF at 
;							the same level.
;					ENDIF 	check and throw the IF marker, and continue.
;
;		(2b) 	if unsuccessful, scan forward to ELSE or ENDIF at the same level, and 
;				continue after that, throwing tos only if ENDIF is found.
;
; *******************************************************************************************

Function_IF: 	;; if
		jsr 	EvaluateInteger 			; check success.
		sty 	DTemp1 						; work out if non-zero
		ora 	DTemp1 						
		tay 								; success flag in Y.

		lda 	(DCodePtr) 					; does THEN follow
		cmp 	#thenTokenID
		bne 	_FIFExtended 				; if so, go to the extended IF.
		;
		; ************************************************************************************
		;
		;									IF ... THEN same line.
		;
		; ************************************************************************************
		;
		inc 	DCodePtr 					; skip over THEN token.
		inc 	DCodePtr
		cpy 	#0 							; was it successful.
		beq 	_FIFEndOfLine 				; if not, go to the end of the line.
		;
		lda 	(DCodePtr) 					; look to see if there is a number there.
		cmp 	#$4000 						; is it a numeric constant.
		bcc 	_FIFContinue 				; if not, just carry on exiting.
		cmp 	#$C000
		bcs 	_FIFContinue
		jmp		Function_GOTO 				; we have IF <expr> THEN <number> so we do GOTO code.
		;
		;		Skip the whole rest of the line.
		;
_FIFEndOfLine:
		lda 	(DCodePtr) 					; reached the end of the line.
		beq 	_FIFContinue 				; if done so, continue.
		cmp 	#$0100	 					; string constant ?
		bcc 	_FIFStringConstant 			
		inc 	DCodePtr 					; if not, just skip the token
		inc 	DCodePtr
		bra 	_FIFEndOfLine
		;
_FIFStringConstant:
		and 	#$00FF 						; add to CodePtr to skip string.
		clc
		adc 	DCodePtr
		sta 	DCodePtr
		bra 	_FIFEndOfLine
		;		
_FIFContinue:
		rts
		;
		; ************************************************************************************
		;
		;							IF .... <ELSE> .... ENDIF code
		;
		; ************************************************************************************
		;
_FIFExtended:
		inc 	DStack 						; put IF on the top of the stack
		inc 	DStack
		lda 	#ifTokenID 
		ldx 	DStack
		sta 	$00,x
		;
		tya 								; see if the test was passed.
		beq 	_FIXSkip 					; if zero then it has failed.
		rts 								; test passed, so continue executing
		;
		;		Test Failed.
		;
_FIXSkip:
		lda 	#elseTokenID 				; scan forward till found either ELSE or ENDIF
		ldx 	#endifTokenID 				; at the same level.
		jsr 	ScanForwardLevel 			; scan forward, returns what found in A.
		inc 	DCodePtr 					; skip over the ELSE or ENDIF
		inc 	DCodePtr
		cmp 	#endifTokenID 				; if ENDIF token ID, then throw the TOS as ended
		bne 	_FIXNoThrow
		dec 	DStack 						; throw the token IF on the stack top.
		dec 	DStack
_FIXNoThrow:
		rts
		;
		;		ELSE. If you execute ELSE, then skip forward to the ENDIF on this level.
		;
Handler_ELSE:	;; else 
		ldx 	DStack	 					; check the top of stack is IF.
		lda 	$00,x
		cmp 	#ifTokenID
		bne 	_HEBadStructure
		lda 	#endifTokenID 				; only searching one token.
		ldx 	#$0000			
		jsr 	ScanForwardLevel 			; so this will find the ENDIF
		;
		inc 	DCodePtr 					; skip over the ENDIF
		inc 	DCodePtr

		dec 	DStack 						; throw the token IF on the stack top.
		dec 	DStack
		rts

_HEBadStructure:	
		#error 	"Else without If"

		;
		;		ENDIF. If you execute ENDIF, then just test and throw TOS.
		;
Handler_ENDIF:	;; endif
		ldx 	DStack	 					; check the top of stack is IF.
		lda 	$00,x
		cmp 	#ifTokenID
		bne 	_HEIBadStructure
		;
		dec 	DStack 						; throw the token IF on the stack top.
		dec 	DStack
		rts

_HEIBadStructure:	
		#error 	"Else without If"

; *******************************************************************************************
;
;		Forward scanner. Work forward through the current position looking for either the
;		token in A or X (use 0 if you only want one). This allows for up and down counts
;		caused by keyword+ and keyword-
;
; *******************************************************************************************

ScanForwardLevel:
		sta 	DTemp1 						; save test in DTemp1 and DTemp1+2
		stx 	DTemp1+2 	
		lda 	DLineNumber 				; save original line number for error
		sta 	DTemp2				
		ldx 	#0 							; X is the level counter.
		;
		; 		Main loop. If not in a sub structure (e.g. in a loop in a loop) check to 
		;	 	see if matching keywords found.
		;
_SFLLoop:
		cpx 	#0 							; if X != 0 then don't test tokens for exit.
		bne 	_SFLNoCheck 				; we're in a substructure.
		;
		lda 	(DCodePtr)					; what's there
		beq 	_SFLNoCheck 				; don't check zero
		cmp 	DTemp1 						; does it match either token ?
		beq 	_SFLFound
		cmp 	DTemp1+2
		bne 	_SFLNoCheck
_SFLFound:
		rts
		;
		;		Advance forwards. Skip tokens, processing keyword+/keyword- to track structures.
		;
_SFLNoCheck:
		lda 	(DCodePtr) 					; what is the token.
		beq 	_SFLNextLine 				; if $0000 go to the next line (end of line marker)				
		cmp 	#$0100 						; is it a string.
		bcc 	_SFLSkipString 				; then handle that.
		;
		;		Not a string or end of line marker
		;
		inc 	DCodePtr 					; skip over the token
		inc 	DCodePtr
		tay 								; put token in Y temporarily.
		and 	#$E000 						; if not a keyword 010x xxxx xxxx xxxx
		cmp 	#$2000
		bne 	_SFLLoop
		;
		;		Have a token, so see what type it is.
		;
		tya 								; get the token back.
		and 	#15 << 9 					; get out token type xxxA AAAx xxxx xxxx
		cmp 	#15 << 9 					; 15 is a standard keyword
		beq 	_SFLLoop
		cmp 	#13 << 9 					; < 13 is also standard
		bcc 	_SFLLoop
		inx 								; increment the level.
		cmp 	#14 << 9 					; if keyword +, loop back.
		beq 	_SFLLoop
		dex 								; decrement the level
		dex 								; one overdoes the previous inx.
		bpl 	_SFLLoop 					; if gone -ve then error.
_SFLError:		
		lda 	DTemp2 						; get original line number
		sta 	DLineNumber
		#error	"Structure imbalance"
		;
		;		Skips a string constant.
		;
_SFLSkipString:
		and 	#$00FF 						; token length of string
		clc
		adc 	DCodePtr 					; add to code pointer and save out
		sta 	DCodePtr
		bra 	_SFLLoop 					; go round again.
		;
_SFLNextLine:
		ldy 	DCodePtr 					; put code pointer into Y
		lda 	$0002,y 					; look at the link for the next line.
		beq 	_SFLError 					; if zero, then there's no more code to search.
		lda 	$0004,y 					; update the line number so it's still correct.
		sta 	DLineNumber
		clc
		lda 	DCodePtr
		adc 	#6 							; skip $00 marker, link, new line
		sta 	DCodePtr
		bra 	_SFLLoop 					; and start this one.

