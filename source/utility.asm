; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		utility.asm
;		Purpose : 	General Utility functions
;		Date :		6th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Report Error, at return address
;
; *******************************************************************************************
	
ErrorHandler:
		rep 	#$30 						; in case we changed it.
		plx 								; address of error message -1
		nop
_EH1:	bra 	_EH1

; *******************************************************************************************
;
;				Default handler for keywords, produces error if not implemented
;
; *******************************************************************************************

IllegalToken:
		#error 	"Illegal Token"

; *******************************************************************************************
;
;										Report Syntax Error
;
; *******************************************************************************************

SyntaxError:
		#error 	"Syntax Error"

; *******************************************************************************************
;
;								Check what the next token is
;
; *******************************************************************************************

ExpectToken:
		cmp 	(DCodePtr) 					; does it match the next token
		bne 	_CTKError					; error if not
		inc 	DCodePtr 					; skip the token
		inc 	DCodePtr
		rts	
_CTKError:
		#error	"Missing token"

; *******************************************************************************************

ExpectRightBracket:							; shorthand because right parenthesis common
		pha
		lda 	#rparenTokenID
		jsr 	ExpectToken
		pla
		rts

ExpectComma:
		pha
		lda 	#commaTokenID 				; shorthand because comma is used a fair bit.
		jsr 	ExpectToken
		pla
		rts

; *******************************************************************************************
;
;							Check if both L + R values are Numeric
;
; *******************************************************************************************

CheckBothNumeric:
		lda 	EXSPrecType+0,x 			; OR together their prec/type
		ora 	EXSPrecType+2,x
		bmi 	_CBNFail 					; need to both be zero in bit 15
		rts
_CBNFail:
		#error 	"Operator integer only"	

; *******************************************************************************************
;
;								Set the return type as integer
;
; *******************************************************************************************

ResetTypeInteger:
		lda 	EXSPrecType+0,x 			; clear bit 15
		and 	#$7FFF
		sta 	EXSPrecType+0,x
		rts

; *******************************************************************************************
;
;								Set the return type as string
;
; *******************************************************************************************

ResetTypeString:
		lda 	EXSPrecType+0,x 			; clear bit 15
		ora 	#$8000
		sta 	EXSPrecType+0,x
		rts

