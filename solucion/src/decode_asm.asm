global decode_asm

section .data

align 16
__mascara_01: DB 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03
__mascara_23: DB 0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c
__mascara_unos: DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

__mascara_sumar_1: DB 0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04
__mascara_restar_1: DB 0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08
__mascara_invertir: DB  0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03

__mascara_filtrar: DD 0xFF000000,0xFF000000,0xFF000000,0xFF000000

section .text
;void decode_asm(unsigned char *src,
;              unsigned char *code,
;              int width,
;              int height);

decode_asm:
	PUSH rbp; Alineada
	MOV rbp, rsp;
	PUSH rbx;

	xor r9,r9; r9 va a ser el contador.
	xor r10, r10

	;______Se traen las máscaras a registro
	MOVDQA xmm15, [__mascara_01];
	MOVDQA xmm14, [__mascara_23];
	MOVDQA xmm13, [__mascara_unos];
	MOVDQA xmm12, [__mascara_sumar_1];
	MOVDQA xmm11, [__mascara_restar_1];
	MOVDQA xmm10, [__mascara_invertir];
	MOVDQA xmm9, [__mascara_filtrar];

	
	ciclo:
	MOVDQU xmm0, [rdi+r9];
	MOVDQA xmm1, xmm0;

	PAND xmm0, xmm15; en xmm0 quedan los bits 0 y 1.
	PAND xmm1, xmm14; en xmm1 quedan los bits 3 y 2.

	MOVDQA xmm2, xmm1; Copio para no perder datos.

	PCMPEQB xmm2, xmm12; Esto produce en xmm2 una máscara con 1's donde hay que sumar 1.
	PAND xmm2, xmm13; ahora en xmm2 hay un uno sólo onde hay que sumar 1.
	PADDB xmm0, xmm2; Se suma 1 donde hace falta.
	PAND xmm0, xmm15; Para que no quede nada raro.

	MOVDQA xmm2, xmm1;
	
	PCMPEQB xmm2, xmm11; Se verifica cuales indican que hay que restar 1.
	PAND xmm2, xmm13; Ahora hay un uno sólo donde hay que restar 1.
	PSUBB xmm0, xmm2; Se resta 1 donde corresponde.
	PAND xmm0, xmm15; Para que no quede nada raro.

	PCMPEQB xmm1, xmm10;
	PAND xmm1, xmm10;
	PXOR xmm0, xmm1; Se invierten los lugares correspondientes.

	
	MOVDQA xmm1, xmm0;
	MOVDQA xmm2, xmm0;
	MOVDQA xmm3, xmm0;

	PSLLDQ xmm1, 1;
	PSLLDQ xmm2, 2;
	PSLLDQ xmm3, 3;

	PSLLD xmm1, 2;
	PSLLD xmm2, 4;
	PSLLD xmm3, 6;

	PADDB xmm0, xmm1;
	PADDB xmm0, xmm2;
	PADDB xmm0, xmm3;

	PAND xmm0, xmm9;

	PEXTRB rbx, xmm0, 15 ;
	MOV al, bl;
	
	CMP al, 0 ;
		JNE continuar_ciclo
		MOV [rsi+r10], al ;
		JMP salida

continuar_ciclo:
	SHL rax, 8;

	PEXTRB rbx, xmm0, 00001011b ;
	MOV al, bl;
	CMP al, 0 ;
		JNE continuar_ciclo2
		MOV [rsi+r10], ax ;
		JMP salida
	
continuar_ciclo2:
	
	PEXTRB rbx, xmm0, 00000111b;

	CMP bl, 0 ;
		JNE continuar_ciclo3;
		MOV [rsi+r10], ax;
		ADD r10, 2;
		MOV [rsi+r10], bl;
		JMP salida;

continuar_ciclo3:

	SHL rax, 8;
	MOV al, bl;
	SHL rax, 8

	PEXTRB rbx, xmm0, 00000000b;
	MOV al, bl;
	MOV [rsi+r10], eax; Esto lo voy a tener que grabar si o si.
	CMP al, 0 ;
		JE salida;
		

continuar_ciclo4:

	ADD r9, 16 ;
	ADD r10, 4;

	CMP r9d, r8d;
	JL ciclo;

salida:
	POP rbx
	POP rbp
    ret
