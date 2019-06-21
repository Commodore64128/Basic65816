; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		transfer.asm
;		Purpose : 	GOTO, GOSUB, RETURN, ON expr GOTO 
;		Date :		12th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									ON <expr> GOTO x,x,x
;
; *******************************************************************************************

Command_ONGOTO: ;; on
		jsr 	EvaluateInteger 			; on what GOTO :)
		cpy 	#0 							; check range. ON x GOTO x1,x2,x3,x4. 0 is illegal.
		bne 	_FOGoFail
		cmp 	#0
		beq 	_FOGoFail 					; we start with index = 1
		;
		pha 								; save count on stack
		lda 	#gotoTokenID 				; expect GOTO
		jsr 	ExpectToken
		plx 								; put count in X.
_FOGoLoop:
		lda 	(DCodePtr) 					; check the next value is a constant.
		cmp 	#$4000						; range 4000-BFFF
		bcc 	FGOFail 					; if not, then we have an error.
		cmp 	#$C000
		bcs 	FGOFail
		;
		dex 								; subtract one, if done, call GOTO code
		beq 	Command_GOTO
		;
		inc 	DCodePtr 					; step over the constant
		inc 	DCodePtr
		jsr 	ExpectComma 				; expect a comma
		bra 	_FOGoLoop 					; and loop round.

_FOGoFail:
		#error 	"Bad On..Goto value"

; *******************************************************************************************
;
;									GOTO <line number>
;
; *******************************************************************************************

Command_GOTO: ;; goto
		lda 	(DCodePtr) 					; look at the number
		cmp 	#$4000						; range 4000-BFFF
		bcc 	FGOFail 					; we don't do calculate line numbers.
		cmp 	#$C000
		bcs 	FGOFail
		sec 								; convert to 0-32767
		sbc 	#$4000 						; and put in X.
		tax
		;
		lda 	#Block_ProgramStart 		; start of program offset
		clc
		adc 	DBaseAddress 				; now an address into Y
		tay
		;
_FGOSearch:
		lda 	$0000,y 					; look at link , exit if zero, reached end of program.
		beq 	_FGOUnknown
		txa 								; does it match line number ?
		cmp 	$0002,y 					
		beq 	_FGOFound 					; yes, then found.
		tya 								; no follow the link
		clc
		adc 	$0000,y 					; add offset to address
		tay
		bra 	_FGOSearch 					; and keep looking
		;
		;		A is new line number, Y is the line pointer.
		;
_FGOFound:
		sta 	DLineNumber 				; store as new line number
		tya 								; Y + 4 is the code pointer.
		clc 								; (skipping link and line #)
		adc 	#4
		sta 	DCodePtr 					
		rts									; and continue
		;
_FGOUnknown:
		#error 	"Unknown Line Number"				
FGOFail:
		#error 	"Bad Line Number"


; *******************************************************************************************
;
;									GOSUB <line number>
;
; *******************************************************************************************

Command_GOSUB: ;; gosub
		ldx 	DStack 						; point Y to the stack.
		;
		lda 	DCodePtr 					; save code ptr at +0 , 2 added to skip line number
		clc
		adc 	#2
		sta 	$02,x 						; save pos at +2
		lda 	DLineNumber 				; save line number at +4
		sta 	$04,x
		lda 	#gosubTokenID 				; save gosub token at +6
		sta 	$06,x

		txa 								; advance stack by 6.
		clc
		adc 	#6
		sta 	DStack

		bra 	Command_GOTO 				; and do a GOTO.

; *******************************************************************************************
;
;											RETURN
;
; *******************************************************************************************

Command_RETURN: ;; return
		ldx 	DStack
		lda 	$00,x
		cmp 	#gosubTokenID 				; check top token.		
		bne 	_FRetFail
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

_FRetFail:
		#error 	"Return without Gosub"
