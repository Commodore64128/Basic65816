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
		tax 								; success flag in X.

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
		cpx 	#0 							; was it successful.
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
		bra 	_FIFExtended

