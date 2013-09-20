global decode_asm
extern printf


%macro get_timestamp 1

	RDTSC
	SHL rdx,32;
	ADD rdx, rax;
	MOV %1, rdx;

%endmacro

%macro acum_time 3 ;antes después acum

	SUB %2, %1
	ADD %3, r15

%endmacro


section .data

align 16
__mascara_01: DB 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03
__mascara_23: DB 0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c
__mascara_unos: DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

__mascara_sumar_1: DB 0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04
__mascara_restar_1: DB 0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08
__mascara_invertir: DB  0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c

__mascara_filtrar: DD 0x000000FF,0x000000FF,0x000000FF,0x000000FF
__mascara_shuffle: DB 0x00,0x04,0x08,0x0c,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80

align 16

__comienzo: DQ 0 , 0 ;
__final: DQ 0 , 0 ;

__comparaciones_before: DQ 0 , 0 ;
__comparaciones_after: DQ 0 , 0 ;
__comparaciones: DQ 0 , 0 ;



__formato: DB "{'total_before' : %lu , 'total_after': %lu},",10,0



section .text
;void decode_asm(unsigned char *src,
;              unsigned char *code,
;			   int size,
;              int width,
;              int height);


	


decode_asm:
	PUSH rbp; Alineada
	MOV rbp, rsp;
	PUSH rbx; Desalineada
	PUSH r12; Alineada
	PUSH r13; Desalineada
	PUSH r14; Alineada
	PUSH r15; Desalineada
	SUB rsp, 8; Alineada

	xor r9,r9; r9 va a ser el contador.
	xor r10, r10
	xor r15, r15
	xor r13, r13

	;______Se traen las máscaras a registro
	MOVDQA xmm15, [__mascara_01];
	MOVDQA xmm14, [__mascara_23];
	MOVDQA xmm13, [__mascara_unos];
	MOVDQA xmm12, [__mascara_sumar_1];
	MOVDQA xmm11, [__mascara_restar_1];
	MOVDQA xmm10, [__mascara_invertir];
	MOVDQA xmm9, [__mascara_filtrar];
	MOVDQA xmm8, [__mascara_shuffle];

	MOVDQA xmm0, [rdi+r9];
	ADD r9, 16;


	SUB rdx, 5 ;
	MOV rcx, rdx;
	SHL rcx, 62;
	SHR rcx, 62;
	

	XOR r8, r8

	
	ciclo:

	MOVDQU xmm7, [rdi+r9];
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

	PCMPEQB xmm1, xmm10; Se verifica cuales hay que invertir
	PAND xmm1, xmm15;
	PXOR xmm0, xmm1; Se invierten los lugares correspondientes.


	
	MOVDQA xmm1, xmm0;
	MOVDQA xmm2, xmm0;
	MOVDQA xmm3, xmm0;

	PSRLDQ xmm1, 1;
	PSRLDQ xmm2, 2;
	PSRLDQ xmm3, 3;

	PSLLD xmm1, 2;
	PSLLD xmm2, 4;
	PSLLD xmm3, 6;

	PADDB xmm0, xmm1;
	PADDB xmm0, xmm2;
	PADDB xmm0, xmm3;

	PAND xmm0, xmm9;

	PSHUFB xmm0, xmm8;

	MOVD [rsi+r10], xmm0;

		

continuar_ciclo4:
	MOVDQA xmm0, xmm7

	ADD r9, 16 ;
	ADD r10, 4;

	CMP r10, rdx;
	JL ciclo;


	MOV r10, rdx
	SUB r9, 20;
	MOVDQU xmm0, [rdi+r9]
	CMP r8, 0 ;
	MOV r8, 1 ;
	JE ciclo

salida:






	ADD rsp, 8
	POP r15
	POP r14
	POP r13
	POP r12
	POP rbx
	POP rbp
    ret
