; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		print.asm
;		Purpose : 	PRINT command
;		Date :		12th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;										PRINT commands
;
; *******************************************************************************************

Command_PRINT: 	;; print
		lda 	(DCodePtr) 					; look at first characteer
		beq 	_FPRExitCR 					; if zero, then exit with CR, maybe.
		cmp 	#colonTokenID 				; likewise if a colon.	
		beq 	_FPRExitCR
		cmp 	#semicolonTokenID 			; semicolon, skip it
		beq 	_FPRSkipLoop
		cmp 	#squoteTokenID 				; single quote is CR
		beq 	_FPRNewLine
		cmp 	#commaTokenID 				; , is tab.
		beq 	_FPRTab
_FPRExpression:
		;
		;		Look for an expression.
		;
		jsr 	Evaluate 					; evaluate a string or integer.
		bcs 	_FPRHaveString
		;
		;		Convert integer to string.
		;
		ldx 	#10 						; convert to string
		jsr 	ConvertToString
		;
_FPRHaveString:
		tay 								; print the basic String.
		jsr 	PrintBASICString
		bra 	Command_Print 				; and go round again.
		;
		;		Print TAB
		;
_FPRTab:									; , (tab)
		jsr 	HWTab
		bra 	_FPRSkipLoop
		;
		;		Print New Line
		;
_FPRNewLine:								; ; (newline)
		jsr 	HWNewLine
_FPRSkipLoop: 								; skip over token and go back
		inc 	DCodePtr
		inc 	DCodePtr
		bra 	Command_Print

_FPRExitCR:
		ldy 	DCodePtr 					; was the previous token a ; or ,
		dey
		dey
		lda 	$0000,y
		cmp 	#commaTokenID 	 			; if so, don't do a new line at the end of the instruction.
		beq 	_FPRExit
		cmp 	#semicolonTokenID 	
		beq 	_FPRExit
		jsr 	HWNewLine 					; print a new line.
_FPRExit:
		rts

