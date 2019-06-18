; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		hwinterface.asm
;		Purpose : 	I/O Interface to fake emulated hardware (not part of BASIC)
;		Date :		12th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

HWCursor = $F8020 							; cursor position r/w
HWKeyPressed = $F8010 						; current key pressed (inkey) r
HWBreakKey = $F8000 						; non-zero if break pressed
HWScreen = $F0000							; screen RAM base

InputBuffer = $F8100 						; area of memory for input buffer.
LastKey = $F8200 							; last key pressed.

sWidth = 64									; this is a quick hack so these must be powers of 2
sHeight = 32 								; in this implementation.

; *******************************************************************************************
;
;								Clear screen and home cursor
;
; *******************************************************************************************

HWClearScreen:
		pha
		phx
		ldx 	#sWidth*sHeight-2 			; fill screen memory with space
_CS0:	lda 	#$2020
		sta 	$F0000,x
		dex
		bpl 	_CS0
		lda 	#0 							; reposition cursor
		sta 	HWCursor
		plx
		pla
		rts
		
; *******************************************************************************************
;
;			Output a single character (in A). This is an actual visible character
;			as all character values 0-255 can be in a string.
;
; *******************************************************************************************

HWPrintChar:
		pha
		phx
		phy 
		pha 								; cursor position -> X
		lda 	HWCursor
		tax
		pla
		sep 	#$20 						; write character to screen.
		sta 	$F0000,x
		rep 	#$20
		inx 								; bump cursor position.
		txa
		sta 	HWCursor
		cmp 	#(sWidth*sHeight) 			; reached end of screen
		bne 	_HWNotEnd
		sec 	 							; back up one line
		sbc 	#sWidth
		sta 	HWCursor
		ldx 	#0 							; scroll screen up.
_HWScrollUp:
		lda 	$F0000+sWidth,x		
		sta 	$F0000,x
		inx
		inx
		cpx 	#sWidth*sHeight
		bne 	_HWScrollUp
		ldx 	#(sWidth*(sHeight-1))		; clear bottom line.
_HWBlank:
		lda 	#$2020
		sta 	$F0000,x
		inx
		inx		
		cpx 	#sWidth*sHeight
		bne 	_HWBlank
_HWNotEnd:
		ply
		plx
		pla
		rts

; *******************************************************************************************
;
;								Print a new line and TAB (share code)
;
; *******************************************************************************************

HWNewLine:
		pha
		phx
		ldx 	#sWidth-1 					; print spaces until X & position = 0
HWMoveCursor:
		lda 	#32
		jsr 	HWPrintChar
		txa
		and 	HWCursor
		bne 	HWMoveCursor
		plx
		pla
		rts
		
HWTab:	pha 
		phx
		ldx 	#7
		bra 	HWMoveCursor		

; *******************************************************************************************
;
;									Return A != 0 if Break
;
; *******************************************************************************************

HWCheckBreak:
		lda 	HWBreakKey
		rts

; *******************************************************************************************
;
;									Get keyboard status
;
; *******************************************************************************************

HWInkey:
		lda 	HWKeyPressed
		rts 	
		
; *******************************************************************************************
;
;						  Read keyboard line return address in YA
;
; *******************************************************************************************

HWInputLine:
		jsr 	HWInkey 					; get a keystroke.
		cmp 	LastKey
		beq 	HWInputLine
_HWILWait:		
		jsr 	HWInkey
		cmp		#0
		beq 	_HWILWait
		sta 	LastKey
		cmp 	#32 						; control check
		bcc 	_HWILControl
		jsr 	HWPrintChar 				; print out.
		bra 	HWInputLine 				; loop back.
		;
_HWILBackSpace:
		lda 	HWCursor
		beq 	HWInputLine
		tax
		dex
		lda 	#" "
		sep 	#$20
		sta 	$F0000,x
		rep 	#$20
		ldx 	#-1
_HWILMove:
		txa
		clc
		adc 	HWCursor
		and 	#(sWidth*sHeight-1)
		sta 	HWCursor
		bra 	HWInputLine
		;
_HWILClear:
		jsr 	HWClearScreen
		bra 	HWInputLine
		;	
_HWILControl:
		cmp 	#8 							; backspace.
		beq 	_HWILBackSpace
		ldx 	#-sWidth 					; Ctrl IJKL move cursor
		cmp 	#9
		beq 	_HWILMove
		ldx 	#sWidth 				
		cmp 	#11
		beq 	_HWILMove
		ldx 	#-1
		cmp 	#10
		beq 	_HWILMove
		ldx 	#1
		cmp 	#12
		beq 	_HWILMove
		cmp 	#19 						; Ctrl S Clear Screen/Home
		beq 	_HWILClear
		cmp 	#13
		bne 	HWInputLine
		;
		lda 	HWCursor 					; cursor position
		and 	#$FFC0 						; start of line.
		sta 	DTemp1 						; pointer in DTemp1
		lda 	#$000F
		sta 	DTemp1+2
		ldy 	#0 							; set up for copy
_HWILCopy:
		tyx	
		lda 	[DTemp1],y
		sta 	InputBuffer,x
		iny
		iny
		cpy 	#64 						; done the whole line ?
		bne 	_HWILCopy
		lda 	#0
		tyx
		sta 	InputBuffer,x 				; add trailing zero.
		;
		jsr 	HWNewLine 					; next line.
		lda 	#InputBuffer & $FFFF
		ldy 	#InputBuffer >> 16
		rts