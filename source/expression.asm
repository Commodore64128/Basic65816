; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		expression.asm
;		Purpose : 	Expression Evaluation
;		Date :		6th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;					Evaluate and check result is integer or string
;
;		  Four of these, one for each type, one for inline function/main function
;
; *******************************************************************************************

EvaluateInteger:
		jsr 	Evaluate
		bcs 	EIType
		rts
EIType:		
		#error 	"Number expected"

EvaluateNextInteger:
		jsr 	EvaluateNext
		bcs 	EIType
		rts

EvaluateString:
		jsr 	Evaluate
		bcc 	ESType
		rts
ESType:		
		#error 	"String expected"

EvaluateNextString:
		jsr 	EvaluateNext
		bcc 	ESType
		rts


; *******************************************************************************************
;
;										Base Evaluate.
;
;		Evaluate expression at (DCodePtr), returning value in YA.
;		This is used when called from a keyword
;
;		When calling from a non-base, e.g. inside a unary function, use EvaluateNext
;		functions.
;
; *******************************************************************************************

Evaluate:
		ldx		#EXSBase 					; reset the stack
		lda 	#0<<9 						; start at the lowest precedence level.
											; fall through.

; *******************************************************************************************
;
;		Evaluate a term/operator sequence at the current precedence level. A contains the
;		precedence level shifted 9 left (matching the keyword position). X contains the 
;		expression stack offset.
;
;		Returns value in YA and CS if string.
;
;		Precedence climber : See expression.py in documents
;
; *******************************************************************************************

EvaluateLevel:
		and 	#$7FFF 						; zero type bit.
		sta 	EXSPrecType+0,x 			; save precedence level.

		lda 	(DCodePtr)					; look at the next token





; *******************************************************************************************
;
;		 Evaluate at the next level down with A containing the precedence level.
;
; *******************************************************************************************

EvaluateNext:
		inx
		inx
		jsr 	EvaluateLevel
		dex
		dex
		rts
