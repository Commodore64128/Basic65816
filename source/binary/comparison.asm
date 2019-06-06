; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		comparison.asm
;		Purpose : 	Comparison operators (integer and string)
;		Date :		2nd June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;										Equality
;
; *******************************************************************************************

Binary_Equals: ;; = 
	jsr 	CompareTypeCheck 				; which types are we comparing ?
	bcs 	_BEString
	lda 	EXSValueL,x 					; numeric comparison
	cmp 	EXSValueL+2,x
	bne 	Compare_Fail
	lda 	EXSValueH,x
	cmp 	EXSValueH+2,x
	bne 	Compare_Fail
	bra 	Compare_Succeed

_BEString: 									; string comparison
	ora 	#$0000
	beq 	Compare_Succeed
	bra 	Compare_Fail

; *******************************************************************************************
;
;										InEquality
;
; *******************************************************************************************

Binary_NotEquals: ;; <> 
	jsr 	CompareTypeCheck 				; which types are we comparing ?
	bcs 	_BNEString
	lda 	EXSValueL,x 					; numeric comparison
	cmp 	EXSValueL+2,x
	bne 	Compare_Succeed
	lda 	EXSValueH,x
	cmp 	EXSValueH+2,x
	bne 	Compare_Succeed
	bra 	Compare_Fail

_BNEString:									; string comparison
	ora 	#$0000
	bne 	Compare_Succeed
	bra 	Compare_Fail

; *******************************************************************************************
;
;										Less
;
; *******************************************************************************************

Binary_Less: ;; < 	
	jsr 	CompareTypeCheck 				; which types are we comparing ?
	bcs 	_BLString
	sec
	lda 	EXSValueL,x 					; signed numeric <
	sbc 	EXSValueL+2,x
	lda 	EXSValueH,x
	sbc 	EXSValueH+2,x
	bvc 	*+5
	eor 	#$8000
	bmi 	Compare_Succeed
	bra 	Compare_Fail

_BLString:
	cmp 	#$FFFF 							; string
	beq 	Compare_Succeed
	bra 	Compare_Fail

; *******************************************************************************************
;
;									Return true or false
;
; *******************************************************************************************

Compare_Succeed:
	lda 	#$FFFF
	sta 	EXSValueL,x
	sta 	EXSValueH,x
	rts
Compare_Fail:
	stz 	EXSValueL,x
	stz 	EXSValueH,x
	rts

; *******************************************************************************************
;
;									Greater/Equals
;
; *******************************************************************************************

Binary_GreaterEqual: ;; >= 
	jsr 	CompareTypeCheck 				; which types are we comparing ?
	bcs 	_BGEString
	sec
	lda 	EXSValueL,x 					; numeric >= signed
	sbc 	EXSValueL+2,x
	lda 	EXSValueH,x
	sbc 	EXSValueH+2,x
	bvc 	*+5
	eor 	#$8000
	bpl 	Compare_Succeed
	bra 	Compare_Fail

_BGEString: 								; string
	ora 	#$0000
	bpl 	Compare_Succeed
	bra 	Compare_Fail

; *******************************************************************************************
;
;									  Less/Equals
;
; *******************************************************************************************

Binary_LessEqual: ;; <= 	
	jsr 	CompareTypeCheck 				; which types are we comparing ?
	bcs 	_BLEString
	clc 									; numeric <= signed
	lda 	EXSValueL,x
	sbc 	EXSValueL+2,x
	lda 	EXSValueH,x
	sbc 	EXSValueH+2,x
	bvc 	*+5
	eor 	#$8000
	bmi 	Compare_Succeed
	bra 	Compare_Fail

_BLEString:
	cmp 	#$0001 							; string
	bne 	Compare_Succeed
	bra 	Compare_Fail

; *******************************************************************************************
;
;									  Greater
;
; *******************************************************************************************

Binary_Greater: ;; > 
	jsr 	CompareTypeCheck 				; which types are we comparing ?
	bcs 	_BGString
	clc 									; numeric > signed
	lda 	EXSValueL,x
	sbc 	EXSValueL+2,x
	lda 	EXSValueH,x
	sbc 	EXSValueH+2,x
	bvc 	*+5
	eor 	#$8000
	bpl 	Compare_Succeed
	bra 	Compare_Fail

_BGString: 									; string
	cmp 	#$0001
	beq 	Compare_Succeed
	bra 	Compare_Fail

; *******************************************************************************************
;
;				String check. Checks if the types are compatible, error if not.
;				If both integer, return with CC.
;				If both string, return with CS and A = 1,0,-1 as in strcmp()
;
; *******************************************************************************************

CompareTypeCheck:
	lda 	EXSPrecType+0,x 				; xor the type bits (bit 15)
	eor 	EXSPrecType+2,x 		
	bmi 	_CTCFail 						; if different types cannot be compared, must be the same !
	;
	lda 	EXSPrecType+0,x 				; get the type they (both) are.
	bmi 	_CTCStringCompare 				; if strings, do a string comparison.
	clc 									; if numbers return with carry clear and calculate it.
	rts

_CTCFail: 									; mixed comparison types
	#error 	"Comparison mixed types"

_CTCStringCompare:
	jsr 	ResetTypeInteger 				; two strings return integer not string.

	lda 	EXSValueL+0,x 					; copy address of string 1 -> DTemp1
	sta 	DTemp1
	lda 	EXSValueL+2,x 					; copy address of string 2 -> DTemp2
	sta 	DTemp2

	lda 	#$0000 							; clear AY
	tay
	sep 	#$20 							; 8 bit data mode.

	lda 	(DTemp1) 						; get the length of the shorter string
	cmp 	(DTemp2)
	bcc 	_CTCSmallest 
	lda 	(DTemp2)
_CTCSmallest: 								; A now is the length of the shorter string.
	sta		DSignCount 						; use this as a comparison count. Check to see they match fires
	;
	;		String compare loop. Compare the characters the strings have in common length - e.g if one 3 chars, one 5 chars, check 3 chars.
	;
_CTCCompare:
	iny 									; look at next character (done first, first char is size)
	dec 	DSignCount 						; decrement counter
	bmi 	_CTCEqualSoFar 					; if -ve the strings are the same as far as the shortest.
	;	
	lda 	(DTemp1),y						; compare s1[y] - s2[y]
	cmp 	(DTemp2),y 	
	beq 	_CTCCompare 					; if zero, try the next character.
	bcs 	_CTCGreater 					; Strings are different in their common length. Return -ve then s2 > s1
	;
_CTCLess: 									; return -1 and CS
	rep 	#$20
	lda 	#$FFFF
	bra 	_CTCExit
	;
_CTCGreater:
	rep 	#$20
	lda 	#$0001 							; return +1 and CS
	bra 	_CTCExit
	;
	;		The strings have the same content as far as they go, so we compare the lengths. The longer
	;		string must be the larger one.
	;
_CTCEqualSoFar:
	lda 	(DTemp1) 						; if len(s1) < len(s2) then s1 is the smaller
	cmp 	(DTemp2)
	bcc 	_CTCLess 
	bne 	_CTCGreater 					; if len(s1) > len(s2) then s2 is the smaller

	rep 	#$20 	 						; if lengths are the same, then they're the same.
	lda 	#$0000 
_CTCExit:
	sec 									; return with CS indicating string comparison.
	rts
