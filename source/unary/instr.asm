; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		instr.asm
;		Purpose : 	Substring search
;		Date :		15th July 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;						instr(toSearch,lookforString) => 0 or char index
;
; *******************************************************************************************

Function_INSTR:	;; instr(
		jsr 	ResetTypeInteger 			; returns a integer
		jsr 	EvaluateNextString 			; evaluate a string.
		pha 								; save string to search
		jsr 	ExpectComma
		jsr 	EvaluateNextString 			; string to search for
		jsr 	ExpectRightBracket
		sta 	DTemp1 						; DTemp1 is the string to search for
		pla
		sta 	DTemp2 						; DTemp2 is the string to search.
		;
		stz 	EXSValueH+0,x 				; set high word to zero.
		stz 	EXSValueL+0,x 				; zero low word.
		;
		sep 	#$20 						; calculate len(search)-len(lookfor)
		sec
		lda 	(DTemp2)
		sbc		(DTemp1)
		rep 	#$20
		bcc 	_FINSFail 					; if the string being searched is shorter, fail.
		;
		and 	#$00FF
		inc 	a
		sta 	DTemp3 						; this is the number of matches we can try.

		lda 	(DTemp1) 					; fail if first string is ""
		and 	#$00FF
		beq 	_FINSError
		;
		;		Loop back to try the next one.
		;
_FINSLoop:
		lda 	EXSValueL+0,x 				; pre-increment as we start indices at 1.
		inc 	a
		sta 	EXSValueL+0,x
		;
		lda 	(DTemp1) 					; characters to match
		and 	#$00FF
		tay									; start comparing at index 1.
_FINSCompare:
		lda 	(DTemp1),y 					; char match ?
		eor 	(DTemp2),y
		and 	#$00FF
		bne 	_FINSNext
		dey 	
		bne 	_FINSCompare
		bra 	_FINSExit
_FINSNext:
		inc 	DTemp2 						; bump pointer in string being searched
		dec 	DTemp3 						; keep trying this many times
		bne 	_FINSLoop
_FINSFail:
		stz 	EXSValueL+0,x 				; return 0
_FINSExit:		
		rts

_FINSError:	
		#error 	"No Search String"