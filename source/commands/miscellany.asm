; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		miscellany.asm
;		Purpose : 	Things that don't belong anywhere else.
;		Date :		8th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;						Assert <expr> causes error if <expr> is zero
;
; *******************************************************************************************

Function_ASSERT: ;; assert
		jsr 	EvaluateInteger 			; something that returns an integer.
		sty 	DTemp1 						; check if result is zero.
		ora 	Dtemp1
		beq 	_FAssFail
		rts
_FAssFail:
		#error 	"assert failed"

; *******************************************************************************************
;
;										CLS Clear screen
;
; *******************************************************************************************

Function_CLS: ;; cls
		jsr 	HWClearScreen
		rts


; *******************************************************************************************
;
;									REM "remark"
;
; *******************************************************************************************

Function_REM: ;; rem 
		nop
		lda 	(DCodePtr) 					; get code ptr.
		beq 	_FRemSyntax 				; if 0, syntax error
		cmp 	#$0100 						; if not $00xx syntax error
		bcs 	_FRemSyntax
		clc 								; add to DCodePtr
		adc 	DCodePtr
		sta 	DCodePtr
		rts
_FRemSyntax:
		brl 	SyntaxError


