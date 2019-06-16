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
		nop
		