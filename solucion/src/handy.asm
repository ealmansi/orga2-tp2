;	;	;	;	;	Externas ;	;	;	;	;	;

extern printf

;	;	;	;	;	Datos ;	;	;	;	;	;

section .data

msj_debug:				DB 	'__________DEBUG_________', 10, 0
msj_debug_delim: 		DB 	'________________________', 10, 0
fmt_debug_udword:		DB 	'(udword) %u', 10, 0
fmt_debug_word:			DB 	'(word) %d', 10, 0
fmt_debug_uword:		DB 	'(uword) %u', 10, 0
fmt_debug_ubyte:		DB 	'(ubyte) %d', 10, 0
fmt_debug_uint:			DB 	'(uint) %u', 10, 0
fmt_debug_float:		DB 	'(float) %f', 10, 0

;	;	;	;	;	Macros ;	;	;	;	;	;

%macro alinear 0
	sub		RSP, 8
%endmacro

%macro desalinear 0
	add		RSP, 8
%endmacro

%macro push_regs 0
	push 	RBP
	mov		RBP, RSP
	push 	RBX
	push 	R12
	push 	R13
	push 	R14
	push 	R15
	alinear
%endmacro

%macro pop_regs 0
	desalinear
	pop 	R15
	pop 	R14
	pop 	R13
	pop 	R12
	pop 	RBX
	pop 	RBP
%endmacro

%define OFFSET_OPS_STACK	64

%macro push_xmm 1
	sub 		RSP, 16
	movdqu 		[RSP], %1
%endmacro

%macro pop_xmm 1
	movdqu 		%1, [RSP]
	add 		RSP, 16
%endmacro

%macro push_defensivo 0
	push_xmm 	XMM0
	push_xmm 	XMM1
	push_xmm 	XMM2
	push_xmm 	XMM3
	push_xmm 	XMM4
	push_xmm 	XMM5
	push_xmm 	XMM6
	push_xmm 	XMM7
	push_xmm 	XMM8
	push_xmm 	XMM9
	push_xmm 	XMM10
	push_xmm 	XMM11
	push_xmm 	XMM12
	push_xmm 	XMM13
	push_xmm 	XMM14
	push_xmm 	XMM15
	push 		RAX
	push 		RBX
	push 		RCX
	push 		RDX
	push 		RDI
	push 		RSI
	push 		RBP
	push 		RSP
	push 		R8
	push 		R9
	push 		R10
	push 		R11
	push 		R12
	push 		R13
	push 		R14
	push 		R15
	alinear
%endmacro

%macro pop_defensivo 0
	desalinear
	pop 		R15
	pop 		R14
	pop 		R13
	pop 		R12
	pop 		R11
	pop 		R10
	pop 		R9
	pop 		R8
	pop 		RSP
	pop 		RBP
	pop 		RSI
	pop 		RDI
	pop 		RDX
	pop 		RCX
	pop 		RBX
	pop 		RAX
	pop_xmm 	XMM15
	pop_xmm 	XMM14
	pop_xmm 	XMM13
	pop_xmm 	XMM12
	pop_xmm 	XMM11
	pop_xmm 	XMM10
	pop_xmm 	XMM9
	pop_xmm 	XMM8
	pop_xmm 	XMM7
	pop_xmm 	XMM6
	pop_xmm 	XMM5
	pop_xmm 	XMM4
	pop_xmm 	XMM3
	pop_xmm 	XMM2
	pop_xmm 	XMM1
	pop_xmm 	XMM0
%endmacro

%macro debug_xmm_ubytes 1
	push_defensivo

	debug_string msj_debug_delim

	pextrb 		RDI, %1, 0
	debug_ubyte DIL
	pextrb 		RDI, %1, 1
	debug_ubyte DIL
	pextrb 		RDI, %1, 2
	debug_ubyte DIL
	pextrb 		RDI, %1, 3
	debug_ubyte DIL
	pextrb 		RDI, %1, 4
	debug_ubyte DIL
	pextrb 		RDI, %1, 5
	debug_ubyte DIL
	pextrb 		RDI, %1, 6
	debug_ubyte DIL
	pextrb 		RDI, %1, 7
	debug_ubyte DIL
	pextrb 		RDI, %1, 8
	debug_ubyte DIL
	pextrb 		RDI, %1, 9
	debug_ubyte DIL
	pextrb 		RDI, %1, 10
	debug_ubyte DIL
	pextrb 		RDI, %1, 11
	debug_ubyte DIL
	pextrb 		RDI, %1, 12
	debug_ubyte DIL
	pextrb 		RDI, %1, 13
	debug_ubyte DIL
	pextrb 		RDI, %1, 14
	debug_ubyte DIL
	pextrb 		RDI, %1, 15
	debug_ubyte DIL

	pop_defensivo
%endmacro

%macro debug_xmm_words 1
	push_defensivo

	debug_string msj_debug_delim

	pextrw 		RDI, %1, 0
	debug_word DI
	pextrw 		RDI, %1, 1
	debug_word DI
	pextrw 		RDI, %1, 2
	debug_word DI
	pextrw 		RDI, %1, 3
	debug_word DI
	pextrw 		RDI, %1, 4
	debug_word DI
	pextrw 		RDI, %1, 5
	debug_word DI
	pextrw 		RDI, %1, 6
	debug_word DI
	pextrw 		RDI, %1, 7
	debug_word DI

	pop_defensivo
%endmacro

%macro debug_xmm_uwords 1
	push_defensivo

	debug_string msj_debug_delim

	pextrw 		RDI, %1, 0
	debug_uword DI
	pextrw 		RDI, %1, 1
	debug_uword DI
	pextrw 		RDI, %1, 2
	debug_uword DI
	pextrw 		RDI, %1, 3
	debug_uword DI
	pextrw 		RDI, %1, 4
	debug_uword DI
	pextrw 		RDI, %1, 5
	debug_uword DI
	pextrw 		RDI, %1, 6
	debug_uword DI
	pextrw 		RDI, %1, 7
	debug_uword DI

	pop_defensivo
%endmacro

%macro debug_xmm_udwords 1
	push_defensivo

	debug_string msj_debug_delim

	pextrd 		EDI, %1, 0
	debug_udword EDI
	pextrd 		EDI, %1, 1
	debug_udword EDI
	pextrd 		EDI, %1, 2
	debug_udword EDI
	pextrd 		EDI, %1, 3
	debug_udword EDI

	pop_defensivo
%endmacro

%macro debug_string 1
	push_defensivo

	mov  		RDI, %1
	mov  		RAX, 0
	call printf

	pop_defensivo
%endmacro

%macro debug_udword 1
	push_defensivo

	debug_string msj_debug_delim

	xor 		RAX, RAX
	mov 		EAX, %1

	mov  		RSI, RAX
	mov  		RDI, fmt_debug_udword
	mov  		RAX, 0
	call printf

	pop_defensivo
%endmacro

%macro debug_word 1
	push_defensivo

	mov 		AX, %1
	cwde
	cdqe

	mov  		RSI, RAX
	mov  		RDI, fmt_debug_word
	mov  		RAX, 0
	call printf

	pop_defensivo
%endmacro

%macro debug_uword 1
	push_defensivo

	xor 		RAX, RAX
	mov 		AX, %1

	mov  		RSI, RAX
	mov  		RDI, fmt_debug_uword
	mov  		RAX, 0
	call printf

	pop_defensivo
%endmacro

%macro debug_uint 1
	push_defensivo

	mov  		RSI, %1
	mov  		RDI, fmt_debug_uint
	mov  		RAX, 0
	call printf

	pop_defensivo
%endmacro

%macro debug_ubyte 1
	push_defensivo

	xor 		RSI, RSI
	mov  		SIL, %1
	mov  		RDI, fmt_debug_ubyte
	mov  		RAX, 0
	call printf

	pop_defensivo
%endmacro

%macro debug_float 1
	push_defensivo

	mov  		RDI, fmt_debug_float
	mov  		RAX, 1
	call printf

	pop_defensivo
%endmacro

%macro debug_xmm_floats 1
	push_defensivo

	debug_string msj_debug_delim

	cvtps2pd 	XMM0, %1
	debug_float XMM0
	
	psrldq 		%1, 4
	cvtps2pd 	XMM0, %1
	debug_float XMM0

	psrldq 		%1, 4
	cvtps2pd 	XMM0, %1
	debug_float XMM0

	psrldq 		%1, 4
	cvtps2pd 	XMM0, %1
	debug_float XMM0

	pop_defensivo
%endmacro

; 	;	;	;	Macros para tomar tiempos 	;	;	;	
; pisan R14, R15, RDX, RAX y la variable que se use como contador

%macro obtener_timestamp 0

	rdtsc
	shl 			RDX, 32
	add 			RAX, RDX 	; el tiempo actual queda en RAX

%endmacro

%macro inic_tiempo 0

	obtener_timestamp
	mov 			R14, RAX

%endmacro

%macro medir_tiempo 1

	obtener_timestamp
	mov 			R15, RAX
	sub 			R15, R14
	add 			%1, R15
	mov 			R14, RAX

%endmacro