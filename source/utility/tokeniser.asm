; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		tokeniser.asm
;		Purpose : 	ASCII -> Tokens converter.
;		Date :		15th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************
;
;		Tokenising Process
;
;		Quoted strings are stored as token 01xx - max size 256 
;
;		Constants (anything beginning with 0-9) are tokenised as the constant token
;		optionally with the constant shift token if needed.
;
;		Anything beginning with an alphabetic character is extracted, including any
;		trailing $( characters (1 of each). If this entire token exists in the token
;		table , return this token, otherwise convert it to identifier format.
;
;		Anything remaining, scan the token table looking for the longest complete
; 		match (non alphanumerics only) and place that token out.
;
;		Add a terminating $00 token.
;
;		The input for this is an ASCIIZ string, the output is a token word. 
;
;		The input string is at address YA *but* must all be in the same 64k page.
;		(it is initially modified by being capitalised except for that in quotes)
;
;		The output string is stored in the line buffer which is in the DirectPage 
; 		area.
;
; *******************************************************************************************

Tokenise:
		sta 	DTemp1						; DTemp1 is the string to tokenise.
		sty 	DTemp1+2
		lda 	#TOKWorkSpace 				; reset workspace pointer.
		sta 	DTemp2 						; which is DTemp2
		;
		;		Make anything not in quotes upper case.
		;
		ldy 	#-1 						; index
		ldx 	#0 							; bit 0 1 when in quotes.
_TOKCap:
		iny 								; go to next
		lda 	[DTemp1],y
		and 	#$00FF
		beq 	_TOKEndCap
		;
		cmp 	#'"'						; quote mark
		bne 	_TOKNotQuote
		inx  								; X counts them, bit 0 is yes/no.					
_TOKNotQuote:		
		cmp 	#"a"						; skip if L/C
		bcc 	_TOKCap
		cmp 	#"z"+1
		bcs 	_TOKCap
		txa 								; check if in quotes
		lsr 	a
		bcs 	_TOKCap
		lda 	[DTemp1],y 					; capitalise
		sec
		sbc 	#32
		sep 	#$20
		sta 	[DTemp1],y
		rep 	#$20
		bra 	_TOKCap
_TOKEndCap:		
		dec 	DTemp1
		;
		;		Main tokenising loop.
		;				
_TOKMainNext:								; next character.
		inc 	DTemp1
_TOKMainLoop:
		lda 	[DTemp1] 					; get first character
		and 	#$00FF
		cmp 	#32
		bcc 	_TOKExit 					; 0-31 exit.
		beq 	_TOKMainNext 				; 32 (space) skip.
		cmp 	#34 						; if 34 (quote marks) do a string.
		beq 	_TOKString
		cmp 	#48 						; 33-47 (not 34) check for punctuation.
		bcc 	_TOKPunctuation
		cmp 	#58 						; 48-57 tokenise a number
		bcc 	_TOKNumber
		cmp 	#65 						; 58-64 more punctuation
		bcc 	_TOKPunctuation
		cmp 	#91 						; 65-90 identifier/keyword.
		bcc 	_TOKIdentifier
		bra 	_TOKPunctuation 			; 91-   punctuation.
		;
		;		Write final $0000 token and exit.
		;
_TOKExit:
		lda 	#$0000
		jsr 	TOKWriteToken
		rts
		;
		;		Tokenise a string
		;
_TOKString:
		jsr 	TOKQuotedString	
		bra 	_TOKMainLoop
		;
		;		Scan the token table for the best punctuation match, if any.
		;
_TOKPunctuation:
		ldx 	#2 							; try 2 character tokens.
		jsr 	TOKKeywordSearch
		bcs 	_TOKFoundPunctuation
		ldx 	#1 							; failed, try 1 character token.
		jsr 	TOKKeywordSearch
		bcs 	_TOKFoundPunctuation
		#error 	"Cannot parse line"			; no idea what it is, shouldn't be there !
_TOKFoundPunctuation:
		jsr 	TOKWriteToken 				; output the token and go round again.		
		bra 	_TOKMainLoop
		;
		;		Tokenise a number.
		;
_TOKNumber:
		jsr 	TOKInteger 					; tokenise integer out of the token text.
		bra 	_TOKMainLoop
		;
		;		Tokenise an Identifier or Keyword
		;
_TOKIdentifier:
		bra 	_TOKIdentifier

; *******************************************************************************************
;
;					Write a word token to the token buffer, in A
;
; *******************************************************************************************

TOKWriteToken:
		phx
		ldx 	DTemp2						; address in DirectPage to write to.
		sta 	$00,x 						; save it.
		inx 								; bump pointer and write back
		inx
		stx 	DTemp2
		plx
		rts

; *******************************************************************************************
;
;					TOKInteger extract a constant out of the token
;
; *******************************************************************************************

TOKInteger:
		stz 	DTemp3 						; we're going to build it in DTemp3
		stz 	DTemp3+2
_TOKINLoop:
		lda 	DTemp3+2 					; push DTemp3+2 on the stack/A
		pha
		lda 	DTemp3 
		;
		asl 	DTemp3 						; multiply it by 4
		rol 	DTemp3+2
		asl 	DTemp3
		rol 	DTemp3+2
		;
		clc
		adc 	DTemp3 						; add saved value, so it's x 5
		sta 	DTemp3
		pla
		adc 	DTemp3+2
		sta 	DTemp3+2
		;
		asl 	DTemp3 						; multiply it by 2, e.g. x 10
		rol 	DTemp3+2
		;
		lda 	DTemp3+2 					; we can't cope with that big an integer
		and 	#$F000						; can't directly tokenise MAXINT.
		bne 	_TOKINSize
		;
		lda 	[DTemp1]					; get the character value, we know this is 0-9
		and 	#15
		clc
		adc 	DTemp3 						; add to the running count
		sta 	DTemp3
		bcc 	_TOKINNoCarry
		inc 	DTemp3+2		
_TOKINNoCarry:		
		;	
		inc 	DTemp1 						; look at next
		lda 	[DTemp1] 					; loop back if 0..9
		and 	#$00FF
		cmp 	#"0"
		bcc 	_TOKINGotInteger
		cmp 	#"9"+1
		bcc		_TOKINLoop
_TOKINGotInteger:
		;
		lda 	DTemp3 						; lower word
		and 	#$7FFF 						; convert to a token
		clc
		adc 	#$4000 				
		pha 								; save it.
		;
		asl 	DTemp3 						; shift bit15 into the high word
		rol 	DTemp3+2 					; which is the constant shift. 	
		;
		lda 	DTemp3+2 					; look at C/Shift
		cmp 	#$1000	 					; overflow ?
		bcs 	_TOKINSize 					; if so, we can't tokenise the number.
		and 	#$0FFF 						; get bits / check zero
		beq 	_TOKINNoShift 				; don't need constant shift.
		;
		ora 	#$1000	 					; make token $1xxx
		jsr 	TOKWriteToken
_TOKINNoShift:
		pla 								; get lower its token
		jsr 	TOKWriteToken 				; output it
		rts
_TOKINSize:
		#error 	"Integer too large"		

; *******************************************************************************************
;
;							Tokenise Quoted String
;
; *******************************************************************************************

TOKQuotedString:
		inc 	DTemp1 						; skip over the initial quote
		;
		lda 	DTemp1 						; save start of string in DTemp4
		sta 	DTemp4
		lda 	DTemp1+2
		sta 	DTemp4+2
		;
		;		Work out the string length.
		;
_TOKQFindSize:		
		lda 	[DTemp1]					; get character, bump pointer
		inc 	DTemp1
		and 	#$00FF						; mask 8 bits
		beq 	_TOQImbalance 				; end of line, and no quote found.
		cmp 	#34 
		bne 	_TOKQFindSize 				; at end DTemp1 points after quote.
		;
		lda 	DTemp1 						; work out length, save in DTemp3+2
		sec
		sbc 	DTemp4
		dec 	a 							; one less character for closing quote
		sta 	DTemp3+2
		;
		;		Work out the prefix token
		;
		clc
		adc 	#2+1+1 						; two for header, 1 for size, 1 for round up.
		and 	#$FFFE 						; force to even gives token.
		jsr 	TOKWriteToken
		;
		;		Write the length.
		;
		lda 	DTemp3+2 					; this is the count.
		jsr 	TOKWriteToken 				; effectively a byte-write.
		dec 	DTemp2
		;
		;		Write out the characters
		;
		ldx 	DTemp3+2 					; this the count.
		beq		_TOKQWriteEnd 				; if zero, no need to write anything
_TOKQWriteString:
		lda 	[DTemp4] 					; read character from start
		and 	#$00FF
		jsr 	TOKWriteToken 				; effectively a byte-write.
		dec 	DTemp2
		inc 	DTemp4 						; advance character
		dex 								; do X times
		bne 	_TOKQWriteString
_TOKQWriteEnd:
		;
		;		Make sure it's even.
		;
		lda 	DTemp2 						; are we on an even byte.
		and 	#1
		beq 	_TOKQExit
		;
		inc 	DTemp2 						; we wrote values with the high byte 0, so just correct
_TOKQExit:
		rts		
		;
_TOQImbalance:
		#error	"Missing closing quote"		

; *******************************************************************************************
;
;		Search token table for text at [DTemp1], length X. If found, return Carry
;		set and advance over text, and token in A. If failed, return Carry Clear
;
; *******************************************************************************************

TOKKeywordSearch:
		clc
		rts



