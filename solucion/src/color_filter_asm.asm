; RDI,RSI,RDX,RCX,R8,R9
; XMM0,XMM1,XMM2,XMM3,XMM4,XMM5,XMM6,XMM7
; Preservar RBX, R12, R13, R14, R15
; resultado en RAX o XMM0
; Byte: AL, BL, CL, DL, DIL, SIL, BPL, SPL, R8L - R15L
; Word: AX, BX, CX, DX, DI, SI, BP, SP, R8W - R15W
; DWord: EAX, EBX, ECX, EDX, EDI, ESI, EBP, ESP, R8D - R15D
; QWord: RAX, RBX, RCX, RDX, RDI, RSI, RBP, RSP, R8 - R15

;	;	;	;	;	Exporta	;	;	;	;	;	;

global color_filter_asm

;	;	;	;	;	Includes ;	;	;	;	;	;

%include "handy.asm"

;	;	;	;	;	Datos	;	;	;	;	;	;

align 16
masc_denom_prom: 	DD 3.0,3.0,3.0,3.0
masc_limpiar: 		DB 0x00,0x01,0x02,0x03,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80
masc_dw_a_px: 		DB 0x00,0x00,0x00,0x04,0x04,0x04,0x08,0x08,0x08,0x0C,0x0C,0x0C,0x80,0x80,0x80,0x80

;	;	;	;	;	Macros ;	;	;	;	;	;

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

%macro cargar_masc_negacion 0

	pxor  		XMM10, XMM10
	cmpeqps 	XMM10, XMM10

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_denom_prom 0

	movdqa  		XMM11, [masc_denom_prom]
	rcpps 			XMM11, XMM11

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_thres 0

	cvtsi2ss 	 	XMM12, R13D
	shufps 			XMM12, XMM12, 0

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_sustr 0

	pinsrd	 		XMM13, R12D, 0
	pinsrd	 		XMM13, R11D, 1
	pinsrd	 		XMM13, R10D, 2
	pinsrd	 		XMM13, R12D, 3
	cvtdq2ps 		XMM13, XMM13
	
%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_limpiar 0

	movdqa 			XMM14, [masc_limpiar]

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_masc_dw_a_px 0

	movdqa 			XMM15, [masc_dw_a_px]

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro cargar_mascaras 0

	cargar_masc_negacion
	cargar_masc_denom_prom
	cargar_masc_thres
	cargar_masc_sustr
	cargar_masc_limpiar
	cargar_masc_dw_a_px

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro separar_pixeles 0
; toma XMM1 - XMM4
; libres XMM5 - XMM10
	
	pxor			XMM5, XMM5

	movdqa 			XMM1, XMM0 		; quedan los tres canales del primer pixel
	punpcklbw 		XMM1, XMM5 		; convertidos en floats en XMM1
	punpcklwd 		XMM1, XMM5
	cvtdq2ps 		XMM1, XMM1

	movdqa 			XMM2, XMM0 		; idem segundo pixel
	psrldq 			XMM2, 3
	punpcklbw 		XMM2, XMM5
	punpcklwd 		XMM2, XMM5
	cvtdq2ps 		XMM2, XMM2

	movdqa 			XMM3, XMM0 		; idem tercer pixel
	psrldq 			XMM3, 6
	punpcklbw 		XMM3, XMM5
	punpcklwd 		XMM3, XMM5
	cvtdq2ps 		XMM3, XMM3

	movdqa 			XMM4, XMM0 		; idem cuarto pixel
	psrldq 			XMM4, 9
	punpcklbw 		XMM4, XMM5
	punpcklwd 		XMM4, XMM5
	cvtdq2ps 		XMM4, XMM4

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro calcular_flags_comparacion 0
; toma XMM5
; libres XMM6 - XMM10
	
	movdqa 			XMM6, XMM1
	subps 			XMM6, XMM13 		; mascara con rc, gc, bc
	mulps 			XMM6, XMM6
	movdqa 			XMM7, XMM6
	psrldq 			XMM6, 4
	addps 			XMM7, XMM6
	psrldq 			XMM6, 4
	addps 			XMM7, XMM6
	pshufb 			XMM7, XMM14 		; limpia los floats que no se usan
	movdqa 			XMM5, XMM7 			; lo guarda en XMM5

	movdqa 			XMM6, XMM2
	subps 			XMM6, XMM13 		; mascara con rc, gc, bc
	mulps 			XMM6, XMM6
	movdqa 			XMM7, XMM6
	psrldq 			XMM6, 4
	addps 			XMM7, XMM6
	psrldq 			XMM6, 4
	addps 			XMM7, XMM6
	pshufb 			XMM7, XMM14 		; limpia los floats que no se usan
	pslldq 			XMM7, 4				; lo guarda en XMM5, al lado del anterior
	por 			XMM5, XMM7

	movdqa 			XMM6, XMM3
	subps 			XMM6, XMM13 		; mascara con rc, gc, bc
	mulps 			XMM6, XMM6
	movdqa 			XMM7, XMM6
	psrldq 			XMM6, 4
	addps 			XMM7, XMM6
	psrldq 			XMM6, 4
	addps 			XMM7, XMM6
	pshufb 			XMM7, XMM14 		; limpia los floats que no se usan
	pslldq 			XMM7, 8				; lo guarda en XMM5, al lado del anterior
	por 			XMM5, XMM7

	movdqa 			XMM6, XMM4
	subps 			XMM6, XMM13 		; mascara con rc, gc, bc
	mulps 			XMM6, XMM6
	movdqa 			XMM7, XMM6
	psrldq 			XMM6, 4
	addps 			XMM7, XMM6
	psrldq 			XMM6, 4
	addps 			XMM7, XMM6
	pshufb 			XMM7, XMM14 		; limpia los floats que no se usan
	pslldq 			XMM7, 12			; lo guarda en XMM5, al lado del anterior
	por 			XMM5, XMM7

	movdqa 			XMM6, XMM12 		; compara las 4 distancias con el threshold
	cmpltps 		XMM6, XMM5
	movdqa 			XMM5, XMM6
	pshufb 			XMM5, XMM15 		; distribuye el resultado a cada byte de cada pixel
	
%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro calcular_promedios 0

	movdqa 			XMM7, XMM1 			; calcula el promedio del pixel 1
	movdqa 			XMM8, XMM7
	psrldq 			XMM8, 4
	addps 			XMM7, XMM8
	psrldq 			XMM8, 4
	addps 			XMM7, XMM8
	pshufb 			XMM7, XMM14 		; limpia los floats que no se usan
	movdqa 			XMM6, XMM7 			; guarda en XMM6

	movdqa 			XMM7, XMM2 			; calcula el promedio del pixel 2
	movdqa 			XMM8, XMM7
	psrldq 			XMM8, 4
	addps 			XMM7, XMM8
	psrldq 			XMM8, 4
	addps 			XMM7, XMM8
	pshufb 			XMM7, XMM14 		; limpia los floats que no se usan
	pslldq 			XMM7, 4				; guarda en XMM6, al lado del anterior
	por 			XMM6, XMM7

	movdqa 			XMM7, XMM3 			; calcula el promedio del pixel 3
	movdqa 			XMM8, XMM7
	psrldq 			XMM8, 4
	addps 			XMM7, XMM8
	psrldq 			XMM8, 4
	addps 			XMM7, XMM8
	pshufb 			XMM7, XMM14 		; limpia los floats que no se usan
	pslldq 			XMM7, 8				; guarda en XMM6, al lado del anterior
	por 			XMM6, XMM7

	movdqa 			XMM7, XMM4 			; calcula el promedio del pixel 4
	movdqa 			XMM8, XMM7
	psrldq 			XMM8, 4
	addps 			XMM7, XMM8
	psrldq 			XMM8, 4
	addps 			XMM7, XMM8
	pshufb 			XMM7, XMM14 		; limpia los floats que no se usan
	pslldq 			XMM7, 12			; guarda en XMM6, al lado del anterior
	por 			XMM6, XMM7

	mulps 			XMM6, XMM11 		; divide por 3
	cvtps2dq 		XMM6, XMM6 			; transforma a enteros
	pshufb 			XMM6, XMM15 		; asigna el promedio de cada pixel a los bytes correspondientes

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro actualizar_datos 0

	movdqa 		XMM7, XMM5 				; obtengo los flags negados
	pxor 		XMM7, XMM10 			

	pand 		XMM0, XMM7 				; XMM0 <- datos originales AND flags negados
	pand 		XMM6, XMM5 				; XMM6 <- promedios AND flags
	paddb 		XMM0, XMM6 				; XMM0 <- XMM0 + XMM6

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro leer_datos 0

	movdqu 		XMM0, [R8 + RCX]							; leer 16 bytes de imagen src

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro escribir_datos 0

	movdqu 		[R9 + RCX], XMM0 							; escribo a imagen dst

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

	levantar_parametros					; R8 	-	src		; R12B 	-	bc
										; R9 	-	dst		; R13D 	-	threshold
										; R10B 	-	rc		; R14D 	-	width
										; R11B 	-	gc		; R15D 	-	height
															
	imul 		R14, R15 				; R14 <- 3 * width * height
	imul 		R14, 3

	cargar_mascaras 					; libres XMM0 - XMM10

.for:
	mov 		RCX, 0					; RCX <- 0, indice del ciclo

.cond:
	cmp 		RCX, R14
	jge 		.endfor

	leer_datos

	separar_pixeles

	calcular_flags_comparacion
	
	calcular_promedios

	actualizar_datos

	escribir_datos

.inc:
	add 		RCX, 12 				; adelanto los 4 pixeles procesados
	jmp 		.cond
.endfor:

	pop_regs
    ret