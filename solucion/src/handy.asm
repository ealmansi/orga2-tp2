;	;	;	;	;	Externas ;	;	;	;	;	;

extern printf
extern exit

;	;	;	;	;	Datos ;	;	;	;	;	;

section .data

msj_debug:				DB 	'__________DEBUG_________', 10, 0
msj_debug_delim: 		DB 	'________________________', 10, 0
msj_newline: 			DB 	10, 0
fmt_debug_ud:			DB 	'%u ', 0
fmt_debug_w:			DB 	'%d ', 0
fmt_debug_uw:			DB 	'%u ', 0
fmt_debug_ub:			DB 	'%d ', 0
fmt_debug_float:		DB 	'%f ', 0
fmt_debug_uint:			DB 	'%u ', 0
fmt_imprimir_tiempo: 	DB 	'%u,',10, 0

;	;	;	;	;	Macros ;	;	;	;	;	;


;_*_*_*_*_*_*_ MACROS DE TIEMPO _*_*_*_*_*_*_*_*_



; INFO: este macro tiene que estar si o si en el .data del código.
%macro define_format 0

__formato_printf: DB "{ 'total_before': 0 , 'total_after': %lu } ,",0

%endmacro


; INFO: Este macro es súper sencillo: Agarra, lee el timestamp
; y lo mete en lo que sea que uno le pase como parámetro.
; El parámetro puede ser tranquilamente un acceso a memoria porque esto
; va a estar afuera del ciclo.
%macro get_timestamp 1

	PUSH rax
	PUSH rdx
	RDTSC
	SHL rdx, 32
	ADD rax, rdx;
	MOV %1, rax;
	POP rdx
	POP rax

%endmacro


; INFO: Para llamar a este macro es el que imprime en pantalla.
; Para llamarlo la PILA DEBE ESTAR ALINEADA.
%macro print_time 1

	PUSH rdi
	PUSH rsi
	PUSH rax
	SUB rsp, 8
	MOV rdi, __formato_printf
	MOV rsi, %1
	CALL printf
	ADD rsp, 8
	POP rax
	POP rsi
	POP rdi

%endmacro
	
;_*_*_*_*_*_*_*_ FIN MACROS DE TIEMPO _*_*_*_*_*_*_*


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

%macro debug_xmm_ub 1
	push_defensivo

	debug_string msj_debug_delim

	pextrb 		RDI, %1, 0
	debug_ub DIL
	pextrb 		RDI, %1, 1
	debug_ub DIL
	pextrb 		RDI, %1, 2
	debug_ub DIL
	pextrb 		RDI, %1, 3
	debug_ub DIL
	pextrb 		RDI, %1, 4
	debug_ub DIL
	pextrb 		RDI, %1, 5
	debug_ub DIL
	pextrb 		RDI, %1, 6
	debug_ub DIL
	pextrb 		RDI, %1, 7
	debug_ub DIL
	pextrb 		RDI, %1, 8
	debug_ub DIL
	pextrb 		RDI, %1, 9
	debug_ub DIL
	pextrb 		RDI, %1, 10
	debug_ub DIL
	pextrb 		RDI, %1, 11
	debug_ub DIL
	pextrb 		RDI, %1, 12
	debug_ub DIL
	pextrb 		RDI, %1, 13
	debug_ub DIL
	pextrb 		RDI, %1, 14
	debug_ub DIL
	pextrb 		RDI, %1, 15
	debug_ub DIL

	debug_newline
	debug_string msj_debug_delim

	pop_defensivo
%endmacro

%macro debug_xmm_words 1
	push_defensivo

	debug_string msj_debug_delim

	pextrw 		RDI, %1, 0
	debug_w DI
	pextrw 		RDI, %1, 1
	debug_w DI
	pextrw 		RDI, %1, 2
	debug_w DI
	pextrw 		RDI, %1, 3
	debug_w DI
	pextrw 		RDI, %1, 4
	debug_w DI
	pextrw 		RDI, %1, 5
	debug_w DI
	pextrw 		RDI, %1, 6
	debug_w DI
	pextrw 		RDI, %1, 7
	debug_w DI

	debug_newline
	debug_string msj_debug_delim

	pop_defensivo
%endmacro

%macro debug_xmm_uw 1
	push_defensivo

	debug_string msj_debug_delim

	pextrw 		RDI, %1, 0
	debug_uw DI
	pextrw 		RDI, %1, 1
	debug_uw DI
	pextrw 		RDI, %1, 2
	debug_uw DI
	pextrw 		RDI, %1, 3
	debug_uw DI
	pextrw 		RDI, %1, 4
	debug_uw DI
	pextrw 		RDI, %1, 5
	debug_uw DI
	pextrw 		RDI, %1, 6
	debug_uw DI
	pextrw 		RDI, %1, 7
	debug_uw DI

	debug_newline
	debug_string msj_debug_delim

	pop_defensivo
%endmacro

%macro debug_xmm_ud 1
	push_defensivo

	debug_string msj_debug_delim

	pextrd 		EDI, %1, 0
	debug_ud EDI
	pextrd 		EDI, %1, 1
	debug_ud EDI
	pextrd 		EDI, %1, 2
	debug_ud EDI
	pextrd 		EDI, %1, 3
	debug_ud EDI

	debug_newline
	debug_string msj_debug_delim

	pop_defensivo
%endmacro

%macro debug_delim 0

	debug_string msj_debug_delim

%endmacro

%macro debug_string 1
	push_defensivo

	mov  		RDI, %1
	mov  		RAX, 0
	call printf

	pop_defensivo
%endmacro

%macro debug_ud 1
	push_defensivo

	xor 		RAX, RAX
	mov 		EAX, %1

	mov  		RSI, RAX
	mov  		RDI, fmt_debug_ud
	mov  		RAX, 0
	call printf

	pop_defensivo
%endmacro

%macro debug_w 1
	push_defensivo

	mov 		AX, %1
	cwde
	cdqe

	mov  		RSI, RAX
	mov  		RDI, fmt_debug_w
	mov  		RAX, 0
	call printf

	pop_defensivo
%endmacro

%macro debug_uw 1
	push_defensivo

	xor 		RAX, RAX
	mov 		AX, %1
	mov  		RSI, RAX
	mov  		RDI, fmt_debug_uw
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

	debug_newline

	pop_defensivo
%endmacro

%macro debug_ub 1
	push_defensivo

	xor 		RSI, RSI
	mov  		SIL, %1
	mov  		RDI, fmt_debug_ub
	mov  		RAX, 0
	call printf

	pop_defensivo
%endmacro

%macro debug_float 1
	push_defensivo

	movdqu 		XMM0, %1
	cvtss2sd 	XMM0, XMM0
	mov  		RDI, fmt_debug_float
	mov  		RAX, 1
	call printf

	debug_newline

	pop_defensivo
%endmacro

%macro debug_xmm_floats 1
	push_defensivo

	debug_string msj_debug_delim

	debug_float %1
	
	psrldq 		%1, 4
	debug_float %1

	psrldq 		%1, 4
	debug_float %1

	psrldq 		%1, 4
	debug_float %1

	pop_defensivo
%endmacro

%macro debug_newline 0
	push_defensivo

	debug_string msj_newline

	pop_defensivo
%endmacro

%macro debug_kill 0
	mov 	RDI, 0
	call exit
%endmacro

; 	;	;	;	Macros para tomar tiempos 	;	;	;	
; pisan R14, R15, RDX, RAX y la variable que se use como contador

%macro medir_clock 0

	rdtsc
	shl 			RDX, 32
	add 			RAX, RDX 	; el tiempo actual queda en RAX

%endmacro

%macro iniciar_tiempo 1

	push 			RAX
	push 			RDX

	medir_clock
	mov 			[%1], RAX

	pop 			RDX
	pop 			RAX

%endmacro

%macro parar_tiempo 1
	
	medir_clock
	mov 			RDX, [%1]
	sub 			RAX, RDX
	mov 			[%1], RAX
	mov 			RDI, fmt_imprimir_tiempo
	mov 			RSI, [%1]
	mov 			RAX, 0
	call printf

%endmacro
