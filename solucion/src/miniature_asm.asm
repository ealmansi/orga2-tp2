; RDI,RSI,RDX,RCX,R8,R9
; XMM0,XMM1,XMM2,XMM3,XMM4,XMM5,XMM6,XMM7
; Preservar RBX, R12, R13, R14, R15
; resultado en RAX o XMM0
; Byte: AL, BL, CL, DL, DIL, SIL, BPL, SPL, R8L - R15L
; Word: AX, BX, CX, DX, DI, SI, BP, SP, R8W - R15W
; DWord: EAX, EBX, ECX, EDX, EDI, ESI, EBP, ESP, R8D - R15D
; QWord: RAX, RBX, RCX, RDX, RDI, RSI, RBP, RSP, R8 - R15

global miniature_asm

;	;	;	;	;	Includes ;	;	;	;	;	;

%include "handy.asm"

;	;	;	;	;	Datos	;	;	;	;	;	;

section .data

align 16
mat_fila_0_datos: 		DB  18,   5,   1,   0,   5,  18,   5,   1,  1,   5,  18,   5,   0,   1,   5,  18
mat_fila_1_datos: 		DB  64,  32,   5,   0,  32,  64,  32,   5,  5,  32,  64,  32,   0,   5,  32,  64
mat_fila_2_datos: 		DB 100,  64,  18,   0,  64, 100,  64,  18, 18,  64, 100,  64,   0,  18,  64, 100
masc_desempaq_datos: 	DB 0x00,0x80,0x03,0x80,0x06,0x80,0x09,0x80,0x00,0x80,0x03,0x80,0x06,0x80,0x09,0x80
masc_empaquet_datos: 	DB 0x00,0x80,0x80,0x04,0x80,0x80,0x08,0x80,0x80,0x0C,0x80,0x80,0x80,0x80,0x80,0x80
masc_denom_datos: 		DD 600.0
contador_clocks: 		DQ 0

define_format
__antes: DQ 0
__despues: DQ 0

;	;	;	;	;	Renombres ;	;	;	;	;	;

%define 	src							R8
%define 	dst							R9
%define 	width						R10
%define 	width_d						R10D
%define 	height						R11
%define 	height_d					R11D
%define 	iters						R12
%define 	iters_d						R12D
%define 	i 							R13
%define 	j 							R14
%define 	coeff_top_plane				XMM0
%define 	coeff_bottom_plane			XMM1
%define 	top_plane					RAX
%define 	top_plane_delta				RBX
%define 	bottom_plane				RCX
%define 	bottom_plane_delta			RDX
%define		temp_int_1					RDI
%define		temp_int_2					RSI
%define		temp_int_2_b				SIL
%define		temp_int_3					RSP

%define 	img_fila_0               		XMM0
%define 	img_fila_1               		XMM1
%define 	img_fila_2               		XMM2
%define 	img_fila_3               		XMM3
%define 	img_fila_4               		XMM4
%define 	acum_r							XMM5
%define  	acum_g							XMM6
%define  	acum_b							XMM7
%define  	resultado						XMM7
%define 	masc_desempaq            		XMM8
%define 	masc_denom               		XMM9
%define 	mat_fila_0               		XMM10
%define 	mat_fila_1               		XMM11
%define 	mat_fila_2               		XMM12
%define 	temp_1							XMM13
%define 	temp_2							XMM14
%define 	temp_3							XMM15
%define 	temp_4							XMM12

;	;	;	;	;	Macros ;	;	;	;	;	;


; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
; unsigned char *src,
; unsigned char *dst,
; int width,
; int height,
; float topPlane,
; float bottomPlane,
; int iters
%macro levantar_parametros 0
					
	xor 		iters, iters
	mov 		iters_d, R8D
	mov 		src, RDI
	mov 		dst, RSI
	xor 		width, width
	mov 		width_d, EDX
	xor 		height, height
	mov 		height_d, ECX

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro calcular_bandas 0

	cvtsi2ss	temp_1, height_d				; temp_1 <- int2float(height)
	cvtsi2ss	temp_2, iters_d				; temp_2 <- int2float(iters)

	movdqa	 	temp_3, coeff_top_plane		; temp_3 <- coeff_top_plane * height
	mulss 		temp_3, temp_1
	cvttss2si	top_plane, temp_3 			; top_plane <- float2int(temp_3)

	movdqa	 	temp_4, coeff_bottom_plane 	; temp_4 <- coeff_bottom_plane * height
	mulss 		temp_4, temp_1
	cvttss2si	bottom_plane, temp_4 			; bottom_plane <- float2int(temp_4)

	subss 		temp_1, temp_4 					; temp_1 <- (1 - coeff_bottom_plane) * height

	divss 		temp_3, temp_2 					; temp_3 <- temp_3 / iters
	divss 		temp_1, temp_2 					; temp_1 <- temp_1 / iters
	cvttss2si	top_plane_delta, temp_3 		; top_plane_delta <- float2int(temp_3)
	cvttss2si	bottom_plane_delta, temp_1 	; bottom_plane_delta <- float2int(temp_4)

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro copiar_src_a_dst 0

	mov 		temp_int_1, 3
	imul 		temp_int_1, width
	imul 		temp_int_1, height

	xor 		i, i

.for_copiar_src_a_dst:

	cmp 		i, temp_int_1
	jge 		.end_for_copiar_src_a_dst

	movdqu 		temp_1, [src + i]
	movdqu 		[dst + i], temp_1

	add 		i, 16
	jmp 		.for_copiar_src_a_dst

.end_for_copiar_src_a_dst:

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro copiar_dst_a_src 0

	mov 		temp_int_1, 3
	imul 		temp_int_1, width
	imul 		temp_int_1, height

	xor 		i, i

.for_copiar_dst_a_src:

	cmp 		i, temp_int_1
	jge 		.end_for_copiar_dst_a_src

	movdqu 		temp_1, [dst + i]
	movdqu 		[src + i], temp_1

	add 		i, 16
	jmp 		.for_copiar_dst_a_src

.end_for_copiar_dst_a_src:

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro inicializar_mascaras 0

	movdqa 		mat_fila_0, [mat_fila_0_datos]
	movdqa 		mat_fila_1, [mat_fila_1_datos]
	movdqa 		mat_fila_2, [mat_fila_2_datos]
	movdqa 		masc_desempaq, [masc_desempaq_datos]
	movss 		masc_denom, [masc_denom_datos]
	shufps 		masc_denom, masc_denom, 0
	rcpps 		masc_denom, masc_denom

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro acumular_fila_izq 2 			; img_fila, mat_fila

	; azules
	movdqa			temp_1, %1 					; desempaqueto todos los azules de la fila
	pshufb 			temp_1, masc_desempaq

	movdqa 			temp_2, %2 					; desempaqueto los coeficientes de la matriz
	pxor 			temp_3, temp_3
	punpckhbw		temp_2, temp_3

	movdqa 			temp_3, temp_1 				; hago todos los productos y hago una suma
	pmaddwd   		temp_3, temp_2 				; para cada pixel que esta siendo procesado
	psllq 			temp_2, 32 					; 4 pixeles -> 4 dwords con sumas parciales
	pmaddwd 		temp_2, temp_1
	phaddd 			temp_3, temp_2
	paddd 			acum_b, temp_3 				; sumo al acumulador general

	; verdes
	movdqa			temp_1, %1 					; desempaqueto todos los verdes de la fila
	psrldq 			temp_1, 1
	pshufb 			temp_1, masc_desempaq

	movdqa 			temp_2, %2 					; desempaqueto los coeficientes de la matriz
	pxor 			temp_3, temp_3
	punpckhbw		temp_2, temp_3

	movdqa 			temp_3, temp_1 				; hago todos los productos y hago una suma
	pmaddwd   		temp_3, temp_2 				; para cada pixel que esta siendo procesado
	psllq 			temp_2, 32 					; 4 pixeles -> 4 dwords con sumas parciales
	pmaddwd 		temp_2, temp_1
	phaddd 			temp_3, temp_2
	paddd 			acum_g, temp_3 				; sumo al acumulador general

	; rojos
	movdqa			temp_1, %1 					; desempaqueto todos los rojos de la fila
	psrldq 			temp_1, 2
	pshufb 			temp_1, masc_desempaq

	movdqa 			temp_2, %2 					; desempaqueto los coeficientes de la matriz
	pxor 			temp_3, temp_3
	punpckhbw		temp_2, temp_3

	movdqa 			temp_3, temp_1 				; hago todos los productos y hago una suma
	pmaddwd   		temp_3, temp_2 				; para cada pixel que esta siendo procesado
	psllq 			temp_2, 32 					; 4 pixeles -> 4 dwords con sumas parciales
	pmaddwd 		temp_2, temp_1
	phaddd 			temp_3, temp_2
	paddd 			acum_r, temp_3 				; sumo al acumulador general

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro acumular_fila_der 2 			; img_fila, mat_fila

	; azules
	movdqa			temp_1, %1 					; desempaqueto todos los azules de la fila
	pshufb 			temp_1, masc_desempaq

	movdqa 			temp_2, %2 					; desempaqueto los coeficientes de la matriz
	pslldq 			temp_2, 8
	pxor 			temp_3, temp_3
	punpckhbw		temp_2, temp_3

	movdqa 			temp_3, temp_1 				; hago todos los productos y hago una suma
	pmaddwd   		temp_3, temp_2 				; para cada pixel que esta siendo procesado
	psrlq 			temp_2, 32 					; 4 pixeles -> 4 dwords con sumas parciales
	pmaddwd 		temp_2, temp_1
	phaddd 			temp_2, temp_3
	paddd 			acum_b, temp_2 				; sumo al acumulador general

	; verdes
	movdqa			temp_1, %1 					; desempaqueto todos los verdes de la fila
	psrldq 			temp_1, 1
	pshufb 			temp_1, masc_desempaq

	movdqa 			temp_2, %2 					; desempaqueto los coeficientes de la matriz
	pslldq 			temp_2, 8
	pxor 			temp_3, temp_3
	punpckhbw		temp_2, temp_3

	movdqa 			temp_3, temp_1 				; hago todos los productos y hago una suma
	pmaddwd   		temp_3, temp_2 				; para cada pixel que esta siendo procesado
	psrlq 			temp_2, 32 					; 4 pixeles -> 4 dwords con sumas parciales
	pmaddwd 		temp_2, temp_1
	phaddd 			temp_2, temp_3
	paddd 			acum_g, temp_2 				; sumo al acumulador general

	; rojos
	movdqa			temp_1, %1 					; desempaqueto todos los rojos de la fila
	psrldq 			temp_1, 2
	pshufb 			temp_1, masc_desempaq

	movdqa 			temp_2, %2 					; desempaqueto los coeficientes de la matriz
	pslldq 			temp_2, 8
	pxor 			temp_3, temp_3
	punpckhbw		temp_2, temp_3

	movdqa 			temp_3, temp_1 				; hago todos los productos y hago una suma
	pmaddwd   		temp_3, temp_2 				; para cada pixel que esta siendo procesado
	psrlq 			temp_2, 32 					; 4 pixeles -> 4 dwords con sumas parciales
	pmaddwd 		temp_2, temp_1
	phaddd 			temp_2, temp_3
	paddd 			acum_r, temp_2 				; sumo al acumulador general

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro acumular_sumas_parciales_izq 0

	acumular_fila_izq 	img_fila_0, mat_fila_0
    acumular_fila_izq 	img_fila_1, mat_fila_1
    acumular_fila_izq 	img_fila_2, mat_fila_2
    acumular_fila_izq 	img_fila_3, mat_fila_1
    acumular_fila_izq 	img_fila_4, mat_fila_0

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro acumular_sumas_parciales_der 0

	acumular_fila_der 	img_fila_0, mat_fila_0
    acumular_fila_der 	img_fila_1, mat_fila_1
    acumular_fila_der 	img_fila_2, mat_fila_2
    acumular_fila_der 	img_fila_3, mat_fila_1
    acumular_fila_der 	img_fila_4, mat_fila_0

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro normalizar_acumuladores 0

	cvtdq2ps 		acum_b, acum_b
	mulps 			acum_b, masc_denom
	cvtps2dq 		acum_b, acum_b
	cvtdq2ps 		acum_g, acum_g
	mulps 			acum_g, masc_denom
	cvtps2dq 		acum_g, acum_g
	cvtdq2ps 		acum_r, acum_r
	mulps 			acum_r, masc_denom
	cvtps2dq 		acum_r, acum_r

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro empaquetar_resultado 0

	movdqa 		temp_1, [masc_empaquet_datos]

	pshufb 		acum_b, temp_1 						; acum_b <- [b4, 0, 0, b3, 0, 0, b2, ...]
	pshufb 		acum_g, temp_1 						; acum_g <- [0, g4, 0, 0, g3, 0, 0, ...]
	pslldq 		acum_g, 1
	pshufb 		acum_r, temp_1 						; acum_r <- [0, 0, r4, 0, 0, r3, 0, ...]
	pslldq 		acum_r, 2

	movdqa 		resultado, acum_b
	paddb 		resultado, acum_g
	paddb 		resultado, acum_r

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro procesar_pixeles 0

	pxor 		acum_b, acum_b 							; acum_b = acum_g = acum_r = [0, 0, 0, 0]
	pxor 		acum_g, acum_g
	pxor 		acum_r, acum_r

	;acumular_sumas_parciales_izq 						; acumula el aporte de los pixeles cargados (son los pixeles
														; que estan a la izquierda de los que se estan procesando)

														; carga datos que van a ser usados en esta y la prox iteracion
	mov 		temp_int_2, i 							;  src(i - 2, j + 2), src(i - 1, j + 2),
	sub 		temp_int_2, 2 							;  src(i, j + 2), src(i + 1, j + 2), src(i + 2, j + 2)
	imul 		temp_int_2, width
	add 		temp_int_2, j
	add 		temp_int_2, 2
	imul 		temp_int_2, 3
	add 		temp_int_2, src

	movdqu 		img_fila_0, [temp_int_2]
	add 		temp_int_2, width
	add 		temp_int_2, width
	add 		temp_int_2, width
	movdqu 		img_fila_1, [temp_int_2]
	add 		temp_int_2, width
	add 		temp_int_2, width
	add 		temp_int_2, width
	movdqu 		img_fila_2, [temp_int_2]
	add 		temp_int_2, width
	add 		temp_int_2, width
	add 		temp_int_2, width
	movdqu 		img_fila_3, [temp_int_2]
	add 		temp_int_2, width
	add 		temp_int_2, width
	add 		temp_int_2, width
	movdqu 		img_fila_4, [temp_int_2]

	;acumular_sumas_parciales_der						; acumula el aporte de los pixeles recien cargados (los que
														; estan a la derecha de los que se estan procesando)

	;normalizar_acumuladores 							; divide las sumas (ahora totales) por la suma de la matriz

	;empaquetar_resultado 								; empaqueta los acumuladores en 4 pixeles rgb

	mov 		temp_int_2, i 							; computa el indice dst(i, j)
	imul 		temp_int_2, width
	add 		temp_int_2, j
	imul 		temp_int_2, 3
	add 		temp_int_2, dst

	movdqu   	[temp_int_2], resultado 				; escribe el resultado en dst(i, j)

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro procesar_fila 0

	mov 		temp_int_2, i 							; carga los 20 pixeles a la izquierda de los que se
	sub 		temp_int_2, 2 							; van a procesar en la primera iteracion
	imul 		temp_int_2, width						; levanta src(i - 2, 0), src(i - 1, 0), src(i, 0),
	imul 		temp_int_2, 3							; src(i + 1, 0), src(i + 2, 0)
	add 		temp_int_2, src

	movdqu 		img_fila_0, [temp_int_2]
	add 		temp_int_2, width
	add 		temp_int_2, width
	add 		temp_int_2, width
	movdqu 		img_fila_1, [temp_int_2]
	add 		temp_int_2, width
	add 		temp_int_2, width
	add 		temp_int_2, width
	movdqu 		img_fila_2, [temp_int_2]
	add 		temp_int_2, width
	add 		temp_int_2, width
	add 		temp_int_2, width
	movdqu 		img_fila_3, [temp_int_2]
	add 		temp_int_2, width
	add 		temp_int_2, width
	add 		temp_int_2, width
	movdqu 		img_fila_4, [temp_int_2]

	mov 		temp_int_1, width 						; temp_int_1 <- width - 2
	sub 		temp_int_1, 2

.for_procesar_fila: 									; j = 2, 6, ... width - 2

	mov 		j, 2

.cond_procesar_fila:

	cmp 		j, temp_int_1
	jge 		.end_for_procesar_fila

	procesar_pixeles 									; procesa (i, j), (i, j + 1), (i, j + 2), (i, j + 3)

.inc_procesar_fila:

	add 		j, 4

	jmp 		.cond_procesar_fila
.end_for_procesar_fila:

	mov 		temp_int_1, i 						; hay que restaurar los primeros 4 bytes de la posicion
	imul    	temp_int_1, width 					; siguiente a la posicion de la ultima iteracion
	add 		temp_int_1, j 						
	imul 		temp_int_1, 3 						; calculo el indice (i, j)

	mov 		temp_int_2, src 					; dst(i, j) <- src(i, j)
	add 		temp_int_2, temp_int_1
	movdqu 		img_fila_2, [temp_int_2]

	mov 		temp_int_2, dst
	add 		temp_int_2, temp_int_1
	movdqu 		[temp_int_2], img_fila_2

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro procesar_top_plane 0
procesar_tp:

.for:

	mov 		i, 2

.cond:

	cmp 		i, top_plane 					; i = 2, ... top_plane
	jg 			.end_for

	procesar_fila

.inc:

	inc 		i

	jmp 		.cond
.end_for:

%endmacro

; ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

%macro procesar_bottom_plane 0
procesar_bp:

	sub 		height, 2

.for:

	mov 		i, bottom_plane 				; i = bottom_plane, ... height - 2

.cond:

	cmp 		i, height
	jge 		.end_for

	procesar_fila

.inc:

	inc 		i

	jmp 		.cond
.end_for:

	add 		height, 2

%endmacro

;	;	;	;	;	Código	;	;	;	;	;	;

section .text

; void miniature_asm(unsigned char *src,
;                unsigned char *dst,
;                int width,
;                int height,
;                float topPlane,
;                float bottomPlane,
;                int iters);
miniature_asm:
	push_regs

	get_timestamp [__antes]




	levantar_parametros

	calcular_bandas

	copiar_src_a_dst

	inicializar_mascaras

for:

cond:

	cmp 		iters, 0 								; #iters ejecuciones del cuerpo
	jle 		end_for

	procesar_top_plane

	procesar_bottom_plane

	sub 		top_plane, top_plane_delta 				; actualiza el ancho de las bandas
	add 		bottom_plane, bottom_plane_delta

	copiar_dst_a_src

incr:

	dec 		iters

	jmp 		for
end_for:


	get_timestamp [__despues]

	MOV rax, [__despues]
	SUB rax, [__antes]
	print_time rax


	pop_regs
    ret

