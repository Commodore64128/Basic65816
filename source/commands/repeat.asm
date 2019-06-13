; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		repeat.asm
;		Purpose : 	REPEAT .. UNTIL
;		Date :		13th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;												REPEAT
;
; *******************************************************************************************

Function_REPEAT: ;; repeat
		ldx 	DStack 						; point Y to the stack.
		;
		lda 	DCodePtr 					; save code ptr
		sta 	$02,x 						; save pos at +2
		lda 	DLineNumber 				; save line number at +4
		sta 	$04,x
		lda 	#repeatTokenID 				; save repeat token at +6
		sta 	$06,x

		txa 								; advance stack by 6.
		clc
		adc 	#6
		sta 	DStack

		rts

; *******************************************************************************************
;
;										UNTIL <expression>
;
; *******************************************************************************************

Function_UNTIL: ;; until
		ldx 	DStack 						; check top token is REPEAT
		lda 	$00,x
		cmp 	#repeatTokenID 			
		bne 	_FUNFail
		;
		jsr 	EvaluateInteger 			; .... until what.
		cpy 	#0 							; exit if non-zero
		bne 	_FUNExit 
		cmp 	#0
		bne 	_FUNExit
		;
		lda 	DStack 						; unpick stack but don't remove it.
		sec
		sbc 	#6
		tax
		lda 	$02,x 						; copy code pointer out.
		sta 	DCodePtr
		lda 	$04,x 						; copy line number out
		sta 	DLineNumber
		rts

_FUNExit:		
		lda 	DStack 						; unpick stack.
		sec
		sbc 	#6
		sta 	DStack
		rts

_FUNFail:
		#error 	"Until without Repeat"
