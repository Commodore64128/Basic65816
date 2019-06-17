; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		testing.asm
;		Purpose : 	Test routines
;		Date :		16th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

		* = $1F000													
		brl 	TokenCheckCode
		* = $1F004
		brl 	CommandExecCode

; ******************************************************************************
;
;			This code is called by LINK to test the tokeniser at $1F000
;
;	The script make_tok.py sets this up to do one conversion test. It generates
;	a string and tokenises it, and stores the ASCII version at $B000 and
;	the tokenised version at $B200. This routine tokenises the text at $B000
;	and compares it to the Python generated version at $B200, looping forever
;	if there's an error.
;
; ******************************************************************************

TokenCheckCode:
		lda 	#$B000 								; the text is at $2B000
		ldy 	#2
		jsr 	Tokenise
		ldx 	DBaseAddress
		ldy 	#0
_TokeniserTestLoop:
		lda 	Block_TokenBuffer,x					; compare workspace vs answer
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

; ******************************************************************************
;
;		This code is called by LINK to execute program lines at $1F004
;
;
; ******************************************************************************

CommandExecCode:
		lda 	#$B000 								; the text is at $2B000
		ldy 	#2
		jsr 	Tokenise
		nop

		