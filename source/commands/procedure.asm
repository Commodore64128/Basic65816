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
		;
		;		Set up the parameters.
		;
_FPROParameter:
		brl 	SyntaxError 				; syntax error otherwise.

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
		