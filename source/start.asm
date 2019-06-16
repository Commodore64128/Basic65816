; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		start.asm
;		Purpose : 	Test bed for BASIC
;		Date :		6th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

	* = 0
		clc											; switch into 65816 16 bit mode.
		xce	
		rep 	#$30 									
		.al	
		.xl
		ldx 	#DirectPage+CPUStack 				; 65816 Stack
		txs
		lda 	#DirectPage 						; set Direct Page.
		tcd
		lda 	#CodeSpace >> 16 					; put the page number in A ($2)
		ldx 	#CodeSpace & $FFFF 					; and the base address in X ($4000)
		ldy 	#CodeEndSpace & $FFFF				; and the end address in Y ($C000)
	
		jmp 	SwitchBasicInstance

;
;			The BASIC Rom image.
;
		* = $10000
		.include "basic.asm" 						; this is the BASIC image. Note currently
													; this has self modifying code at despatch
													; in expression.asm

; ******************************************************************************
;
;			This code is called by LINK to test the tokeniser at $1F000
;
;			The script make_tok.py sets this up to do one conversion test.
;
; ******************************************************************************

		* = $1F000													
		lda 	#$B000 								; the text is at $2B000
		ldy 	#2
		jsr 	Tokenise
		ldx 	#TOKWorkSpace
		ldy 	#0
_TokeniserTestLoop:
		lda 	$00,x								; compare workspace vs answer
		cmp 	$B200,y 		
_TokeniserError:
		bne 	_TokeniserError
		inx
		inx
		iny
		iny
		cmp 	#0
		bne 	_TokeniserTestLoop
		cop 	#0 									; exit successfully.			
		rtl



;
;		Demo BASIC instance.
;
		*=$24000 									; actual BASIC block goes here, demo at 02:4000
CodeSpace:
		.binary "temp/basic.bin"
CodeEndSpace:

