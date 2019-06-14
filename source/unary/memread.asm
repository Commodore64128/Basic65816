; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		memread.asm
;		Purpose : 	Memory read unary functions.
;		Date :		14th July 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;										PEEK / DEEK / LEEK
;
; *******************************************************************************************

Function_Peek: ;; peek( 
		jsr 	ResetTypeInteger 			; returns an integer
		jsr 	EvaluateNextInteger 		; get the value you are absoluting
		jsr 	ExpectRightBracket 			; check )
		sta 	DTemp1 						; save address in DTemp
		sty 	DTemp1+2
		ldy 	#0							; read data
		lda 	[DTemp1],y
		and 	#$00FF 						; mask
		sta 	EXSValueL+0,x 				; write out.
		stz 	EXSValueH+0,x
		rts		

Function_Deek: ;; deek( 
		jsr 	ResetTypeInteger 			; returns an integer
		jsr 	EvaluateNextInteger 		; get the value you are absoluting
		jsr 	ExpectRightBracket 			; check )
		sta 	DTemp1 						; save address in DTemp
		sty 	DTemp1+2
		ldy 	#0							; read data
		lda 	[DTemp1],y
		sta 	EXSValueL+0,x 				; write out.
		stz 	EXSValueH+0,x
		rts				

Function_Leek: ;; leek( 
		jsr 	ResetTypeInteger 			; returns an integer
		jsr 	EvaluateNextInteger 		; get the value you are absoluting
		jsr 	ExpectRightBracket 			; check )
		sta 	DTemp1 						; save address in DTemp
		sty 	DTemp1+2
		ldy 	#0							; read data
		lda 	[DTemp1],y
		sta 	EXSValueL+0,x 				; write out.
		iny
		iny
		lda 	[DTemp1],y
		sta 	EXSValueH+0,x
		rts						