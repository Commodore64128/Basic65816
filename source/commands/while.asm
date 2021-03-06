; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		while.asm
;		Purpose : 	WHILE..WEND
;		Date :		13th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									WHILE
;
; *******************************************************************************************

Command_WHILE: ;; while
		lda 	DCodePtr 					; get the current instruction
		pha 								; save on stack

		jsr 	EvaluateInteger 			; while what.
		cpy 	#0 							; do the body if non-zero.
		bne 	_FWHExecute
		cmp 	#0
		bne 	_FWHExecute
		;
		;		Skip over the body, the test failed.
		;
		pla 								; throw away current instruction
		lda 	#wendTokenID 				; skip to WEND
		ldx 	#0
		jsr 	ScanForwardLevel 			; scan forward checking structures
		inc 	DCodePtr 					; and skip over the WEND.
		inc 	DCodePtr
		rts
		;
		;		Execute the loop body.
		;
_FWHExecute:		
		ldx 	DStack 						; point Y to the stack.
		;
		pla 								; save code ptr-2 so we re-execute the WHILE.
		dec 	a
		dec 	a
		sta 	$02,x 						; save pos at +2
		lda 	DLineNumber 				; save line number at +4
		sta 	$04,x
		lda 	#whileTokenID 				; save while token at +6
		sta 	$06,x

		txa 								; advance stack by 6.
		clc
		adc 	#6
		sta 	DStack
		rts

; *******************************************************************************************
;
;										WEND
;
; *******************************************************************************************

Command_WEND: ;; wend
		ldx 	DStack 						; check top token is WHILE
		lda 	$00,x
		cmp 	#whileTokenID 			
		bne 	_FWEFail
		;
		txa 								; unpick stack and always loop back.
		sec 								; we do the check at the top.
		sbc 	#6
		sta 	DStack
		tax
		lda 	$02,x 						; copy code pointer out.
		sta 	DCodePtr 					; goes back to the WHILE token.
		lda 	$04,x 						; copy line number out
		sta 	DLineNumber
		rts

_FWEFail:
		#error 	"Wend without While"
