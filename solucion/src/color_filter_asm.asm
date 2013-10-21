;	;	;	;	;	Exporta	;	;	;	;	;	;

global color_filter_asm

; 	;	;	;	;	Macros de medicion 	;	;	;

%include "tiempo_asm.asm"

;	;	;	;	;	Datos	;	;	;	;	;	;

align 16
masc_denom_prom: 		DD 3.0,3.0,3.0,3.0
masc_empaquetar: 		DB 0x00,0x00,0x00,0x04,0x04,0x04,0x08,0x08,0x08,0x0C,0x0C,0x0C,0x80,0x80,0x80,0x80
masc_desempaquetar_r:	DB 0x02,0x80,0x80,0x80,0x05,0x80,0x80,0x80,0x08,0x80,0x80,0x80,0x0B,0x80,0x80,0x80
masc_desempaquetar_g:	DB 0x01,0x80,0x80,0x80,0x04,0x80,0x80,0x80,0x07,0x80,0x80,0x80,0x0A,0x80,0x80,0x80
masc_desempaquetar_b:	DB 0x00,0x80,0x80,0x80,0x03,0x80,0x80,0x80,0x06,0x80,0x80,0x80,0x09,0x80,0x80,0x80

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

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro levantar_parametros 0

	xor 		R10, R10
	xor 		R11, R11
	xor 		R12, R12
	mov 		R10B, DL									; rc
	mov 		R11B, CL									; gc
	mov 		R12B, R8B									; bc
	mov 		R13D, R9D									; threshold
	mov 		R14D, [RSP + OFFSET_OPS_STACK]				; width
	mov 		R15D, [RSP + OFFSET_OPS_STACK + 8]			; height
	mov 		R8, RDI										; src
	mov 		R9, RSI										; dst

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro leer_datos 1

	movdqu 		%1, [R8 + RCX]							; leer 16 bytes de imagen src

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro escribir_datos 1

	movdqu 		[R9 + RCX], %1 							; escribo a imagen dst

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_desempaquetar_r 1

	movdqa 		%1, [masc_desempaquetar_r]

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_desempaquetar_g 1

	movdqa 		%1, [masc_desempaquetar_g]

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_desempaquetar_b 1

	movdqa 		%1, [masc_desempaquetar_b]

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_sustraendo_r 1

	pinsrd 		%1, R10D, 0
 	pinsrd 		%1, R10D, 1
 	pinsrd 		%1, R10D, 2
 	pinsrd 		%1, R10D, 3

%endmacro
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_sustraendo_g 1

	pinsrd 		%1, R11D, 0
 	pinsrd 		%1, R11D, 1
 	pinsrd 		%1, R11D, 2
 	pinsrd 		%1, R11D, 3

%endmacro
; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_sustraendo_b 1

	pinsrd 		%1, R12D, 0
 	pinsrd 		%1, R12D, 1
 	pinsrd 		%1, R12D, 2
 	pinsrd 		%1, R12D, 3

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_denom_prom 1

	movdqu  		%1, [masc_denom_prom]
	rcpps 			%1, %1

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_empaquetar 1

	movdqu  		%1, [masc_empaquetar]

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_threshold 1

	imul 		R13D, R13D
	pinsrd 		%1, R13D, 0
 	pinsrd 		%1, R13D, 1
 	pinsrd 		%1, R13D, 2
 	pinsrd 		%1, R13D, 3

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cuerpo_ciclo 0

	pxor 		XMM1, XMM1 									; prom <- [0,0,0,0]
	pxor 		XMM2, XMM2 									; dist <- [0,0,0,0]

	movdqa		XMM3, XMM0 									; desempaquetar rojos
	pshufb 		XMM3, XMM4 									; rojos <- [r1 r2 r3 r4]
	paddd 		XMM1, XMM3 									; prom += rojos
	psubd 		XMM3, XMM7 									; rojos -= [rc, rc, rc, rc]
	pmulld 		XMM3, XMM3 									; rojos *= rojos
	paddd 		XMM2, XMM3 									; dist += rojos

	movdqa		XMM3, XMM0 									; desempaquetar verdes
	pshufb 		XMM3, XMM5 									; verdes <- [g1 g2 g3 g4]
	paddd 		XMM1, XMM3 									; prom += verdes
	psubd 		XMM3, XMM8 									; verdes -= [gc, gc, gc, gc]
	pmulld 		XMM3, XMM3 									; verdes *= verdes
	paddd 		XMM2, XMM3 									; dist += verdes

	movdqa		XMM3, XMM0 									; desempaquetar azules
	pshufb 		XMM3, XMM6 									; azules <- [b1 b2 b3 b4]
	paddd 		XMM1, XMM3 									; prom += azules
	psubd 		XMM3, XMM9 									; azules -= [bc, bc, bc, bc]
	pmulld 		XMM3, XMM3 									; azules *= azules
	paddd 		XMM2, XMM3 									; dist += azules

	cvtdq2ps 	XMM1, XMM1									; prom <- int2float(prom)
	mulps 		XMM1, XMM10 								; prom /= [3 3 3 3]
	cvtps2dq 	XMM1, XMM1 									; prom <- float2int(prom)
	pshufb 		XMM1, XMM11 								; asigno el promedio a cada uno
															; de los bytes del pixel

	pcmpgtd 	XMM2, XMM12 								; dist <- dist > threshold ?
	pshufb 		XMM2, XMM11 								; asigno el flag a cada uno
															; de los bytes del pixel

 	movdqa 		XMM3, XMM2 									; temp <- datos AND ~flags
 	pandn 		XMM3, XMM0 									; 
 	movdqa 		XMM0, XMM3 									; datos <- temp
	pand 		XMM1, XMM2 									; prom <- prom AND flags
 	paddb 		XMM0, XMM1 									; datos += prom

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro resolver_caso_borde 0
	
	sub 			RCX, 4 									; retrocedo 4 bytes para no leer
															; memoria invalida
	leer_datos 		XMM0

	psrldq 		XMM0, 4 									; muevo los pixeles al comienzo
															; del registro

	cuerpo_ciclo 											; los proceso igual que en el
															; caso normal

	pslldq 		XMM0, 4 									; deshago el corrimiento que hice
															; al principio de la iteracion

 	movdqu 		XMM13, [R9+RCX] 							; los primeros 4 bytes se perdieron
 	movss 		XMM0, XMM13									; los recupero de dst porque ya fueron
 															; procesados en la anteultima iteracion

	escribir_datos 	XMM0

%endmacro

;	;	;	;	;	Código	;	;	;	;	;	;

section .text

; void color_filter_asm(unsigned char *src,
;                       unsigned char *dst,
;                       unsigned char rc,
;                       unsigned char gc,
;                       unsigned char bc,
;                       int threshold,
;                       int width,
;                       int height);

color_filter_asm:
	push_regs

	empezar_medicion

	levantar_parametros					; R8 	-	src		; R12B 	-	bc
										; R9 	-	dst		; R13D 	-	threshold
										; R10B 	-	rc		; R14D 	-	width
										; R11B 	-	gc		; R15D 	-	height
															
	cargar_masc_desempaquetar_r 	XMM4
	cargar_masc_desempaquetar_g 	XMM5
	cargar_masc_desempaquetar_b 	XMM6
	cargar_masc_sustraendo_r 		XMM7
	cargar_masc_sustraendo_g 		XMM8
	cargar_masc_sustraendo_b 		XMM9
	cargar_masc_denom_prom 			XMM10
	cargar_masc_empaquetar 			XMM11
	cargar_masc_threshold 			XMM12

	imul 		R14, R15 				; R14 <- 3 * width * height
	imul 		R14, 3
	sub 		R14, 12 				; la última iteracion se hace aparte

.for:
	mov 		RCX, 0					; RCX <- 0, indice del ciclo

.cond:
	cmp 		RCX, R14
	jge 		.endfor

	leer_datos XMM0

	cuerpo_ciclo

	escribir_datos XMM0

.inc:
	add 		RCX, 12 				; adelanto los 4 pixeles procesados
	jmp 		.cond
.endfor:

	resolver_caso_borde
	
	terminar_medicion

	pop_regs
    ret
