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

Command_ASSERT: ;; assert
		jsr 	EvaluateInteger 			; something that returns an integer.
		sty 	DTemp1 						; check if result is zero.
		ora 	Dtemp1
		beq 	_FAssFail
		rts
_FAssFail:
		nop
		#error 	"assert failed"

; *******************************************************************************************
;
;										CLS Clear screen
;
; *******************************************************************************************

Command_CLS: ;; cls
		jsr 	HWClearScreen
		rts

; *******************************************************************************************
;
;									REM "remark"
;
; *******************************************************************************************

Command_REM: ;; rem 
		lda 	(DCodePtr) 					; get code ptr.
		beq 	_FRemExit 					; no comment present
		cmp 	#colonTokenID
		beq 	_FRemExit 					; no comment present

		cmp 	#$0100 						; if not $00xx syntax error
		bcs 	_FRemSyntax
		clc 								; add to DCodePtr
		adc 	DCodePtr
		sta 	DCodePtr
_FRemExit:		
		rts
_FRemSyntax:
		brl 	SyntaxError


; *******************************************************************************************
;
;						LINK <value> loads/saves AXY from variables
;
; *******************************************************************************************

Command_LINK: ;; link
		jsr 	EvaluateInteger 			; call address same page.
		sta 	DTemp1 						; target address
		sty 	DTemp1+2
		;
		tda 								; work out what the actual address is
		clc
		adc 	#DTemp1
		sta 	_FLIExecuteIt+1 			; and overwrite it. Surely to fuck there has
											; to be a better way without reserving an abs address
		;
		ldy 	DBaseAddress 				; point Y to DBaseAddress + Load
		lda 	("A"-"A")*4+Block_FastVariables,y
		pha
		lda 	("X"-"A")*4+Block_FastVariables,y
		tax
		lda 	("Y"-"A")*4+Block_FastVariables,y
		tay
		pla
		;
		jsl 	_FLIExecuteIt
		;
		phy 								; save Y
		ldy 	DBaseAddress 				; point Y to DBaseAddress + Save
		sta 	("A"-"A")*4+Block_FastVariables,y
		txa
		sta 	("X"-"A")*4+Block_FastVariables,y
		pla
		sta 	("Y"-"A")*4+Block_FastVariables,y
		iny 								; point to their high bytes and clear them
		iny 	
		lda 	#0
		sta 	("A"-"A")*4+Block_FastVariables,y
		sta 	("X"-"A")*4+Block_FastVariables,y
		sta 	("Y"-"A")*4+Block_FastVariables,y
		rts

_FLIExecuteIt:
		jmp 	[DTemp1]					; go wherever.

; *******************************************************************************************
;
;									VDU <expr>[;,]<expr>
;
; *******************************************************************************************

Command_VDU: 	;; vdu
		jsr 	EvaluateInteger 			; get integer to YA.
		tay 								; put into Y
		and 	#$00FF 						; mask out LSB
		jsr 	HWPrintChar 				; print the LSB.		
		lda 	(DCodePtr)
		cmp 	#commaTokenID 				; if , goto next
		beq 	_CVDUNext
		cmp 	#semicolonTokenID 			; if ; print MSB and goto next
		beq 	_CVDUHighByte
_CVDUExit:		
		rts
_CVDUHighByte:
		tya 								; get back.
		xba 								; byte swap
		and 	#$00FF 						; mask and print
		jsr 	HWPrintChar
_CVDUNext:
		inc 	DCodePtr 					; skip , ;
		inc 	DCodePtr
		lda 	(DCodePtr)					; continue ?
		beq		_CVDUExit
		cmp 	#colonTokenID
		beq 	_CVDUExit
		bra 	Command_VDU				