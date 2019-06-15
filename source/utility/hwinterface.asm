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

HWCursorCharacter = $66

sWidth = 64					; this has to be powers of two in this really simple I/O code.
sHeight = 32

; *******************************************************************************************
;
;								Clear screen and home cursor
;
; *******************************************************************************************

HWClearScreen:
		pha
		phx
		ldx 	#sWidth*sHeight-2
_CS0:	lda 	#$2020
		sta 	$F0000,x
		dex
		bpl 	_CS0
		stz 	DCursor
		lda 	#$2000+HWCursorCharacter
		sta 	$F0000
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
		and 	#$00FF
		cmp 	#"a"
		bcc 	_HWPCNotLC
		cmp 	#"z"+1
		bcs 	_HWPCNotLC
		sec
		sbc 	#32
		ora 	#128
_HWPCNotLC:		
		and 	#$BF
		ldx 	DCursor
		sep 	#$20
		sta 	$F0000,x
		rep 	#$20
		inx
		txa
		cmp 	#(sWidth*sHeight)
		bne 	_HWNotEnd
		lda 	#0
_HWNotEnd:
		sta 	DCursor
		tax
		lda 	#HWCursorCharacter
		sep 	#$20
		sta 	$F0000,x
		rep 	#$20
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
		ldx 	#sWidth-1
HWMoveCursor:
		lda 	#32
		jsr 	HWPrintChar
		txa
		and 	DCursor
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
		lda 	$F8000
		rts

; *******************************************************************************************
;
;									Get a keystroke
;
; *******************************************************************************************

HWGetKey:
		lda 	$F8010
		bne 	HWGetKey
_HWGKWait:		
		lda 	$F8010
		beq 	_HWGKWait
		nop
		rts 	
		