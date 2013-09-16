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

;	;	;	;	;	Externas ;	;	;	;	;	;

extern printf

;	;	;	;	;	Includes ;	;	;	;	;	;

%include "handy.asm"

;	;	;	;	;	Datos	;	;	;	;	;	;

align 16
mascara_procesar_dos_pixeles_1: DW 0xFFFF, 0x0000, 0x0000, 0xFFFF, 0x0000, 0x0000, 0x0000, 0x0000
mascara_procesar_dos_pixeles_2: DW 0xFFFF, 0x0000, 0x0000, 0xFFFF, 0x0000, 0x0000, 0x0000, 0x0000

;	;	;	;	;	Macros ;	;	;	;	;	;

%macro generar_mascara_color_patron 0
	pinsrw 		XMM14, R12W, 0
	pinsrw 		XMM14, R11W, 1
	pinsrw 		XMM14, R10W, 2
	pinsrw 		XMM14, R12W, 3
	pinsrw 		XMM14, R11W, 4
	pinsrw 		XMM14, R10W, 5
	pinsrw 		XMM14, R12W, 6
	pinsrw 		XMM14, R11W, 7
%endmacro

%macro generar_mascara_threshold 0
	pinsrw 		XMM15, R13W, 0
	pinsrw 		XMM15, R13W, 1
	pinsrw 		XMM15, R13W, 2
	pinsrw 		XMM15, R13W, 3
	pinsrw 		XMM15, R13W, 4
	pinsrw 		XMM15, R13W, 5
	pinsrw 		XMM15, R13W, 6
	pinsrw 		XMM15, R13W, 7
%endmacro

%macro procesar_dos_pixeles 0
	debug_string msj_debug

	movdqa 		XMM2, XMM1 					; computo el cuadrado de la diferencia en
	psubw 		XMM2, XMM14					; cada canal
	pmullw 		XMM2, XMM2

	movdqa 		XMM3, XMM2					; computo la suma de los tres canales
	movdqa 		XMM4, XMM2 					; para cada pixel
	psrldq 		XMM3, 2
	psrldq 		XMM4, 4
	paddw 		XMM2, XMM3
	paddw 		XMM2, XMM4

	pcmpgtw 	XMM2, XMM15
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

	imul 		R14, R15 									; R14 <- 3 * width * height
	imul 		R14, 3

	generar_mascara_color_patron							; queda en XMM14
	generar_mascara_threshold								; queda en XMM15

.for:
	xor 		RCX, RCX									; RCX <- 0, indice del ciclo
.cond:
	cmp 		RCX, 1
	jge 		.endfor

	movdqu 		XMM0, [R8 + RCX]

	movdqa 		XMM1, XMM0 									; dejo en XMM1 los primeros dos pixeles
	pxor 		XMM2, XMM2									; transformados en words
	punpckhbw	XMM1, XMM2

	procesar_dos_pixeles									; modifica XMM0

	movdqa 		XMM1, XMM0									; dejo en XMM1 los proximos dos pixeles
	pslldq 		XMM1, 6										; transformados en words
	pxor 		XMM2, XMM2
	punpckhbw	XMM1, XMM2

	procesar_dos_pixeles									; modifica XMM0

	movdqu 		[R9 + RCX], XMM0 							; escribo a destino

.inc:
	add 		RCX, 4
	jmp 		.cond
.endfor:

	pop_regs
    ret