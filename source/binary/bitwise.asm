; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		bitwise.asm
;		Purpose : 	Bitwise operators
;		Date :		2nd June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;												32 bit and
;
; *******************************************************************************************

Binary_And: ;; &
	jsr 	CheckBothNumeric 					; check both values are numeric
	lda		EXSValueL+0,x
	and 	EXSValueL+EXSNext,x
	sta 	EXSValueL+0,x
	lda		EXSValueH+0,x
	and 	EXSValueH+EXSNext,x
	sta 	EXSValueH+0,x
	rts
	
; *******************************************************************************************
;
;												32 bit or
;
; *******************************************************************************************

Binary_Or: ;; |
	jsr 	CheckBothNumeric 					; check both values are numeric
	lda		EXSValueL+0,x
	ora 	EXSValueL+EXSNext,x
	sta 	EXSValueL+0,x
	lda		EXSValueH+0,x
	ora 	EXSValueH+EXSNext,x
	sta 	EXSValueH+0,x
	rts

; *******************************************************************************************
;
;												32 bit xor
;
; *******************************************************************************************

Binary_Xor: ;; ^
	jsr 	CheckBothNumeric 					; check both values are numeric
	lda		EXSValueL+0,x
	eor 	EXSValueL+EXSNext,x
	sta 	EXSValueL+0,x
	lda		EXSValueH+0,x
	eor 	EXSValueH+EXSNext,x
	sta 	EXSValueH+0,x
	rts
