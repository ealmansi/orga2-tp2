global decode_asm

%include "tiempo_asm.asm"

section .data

tiempo_datos 10

align 16
__mascara_01: DB 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03 ;MÃ¡scara usada para filtrar los 2 bits menos significativos de cada byte
__mascara_23: DB 0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c ;MÃ¡scara usada para filtrar los bits 2 y 3 de cada byte.
__mascara_unos: DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1	; MÃ¡scara que contiene 16 unos consecutivos.

__mascara_sumar_1: DB 0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04 ; MÃ¡scara usada para verificar si hay que sumar 1
__mascara_restar_1: DB 0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08 ; MÃ¡sra usada para verificar si hay que restar 1
__mascara_invertir: DB  0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c ; MÃ¡scara usada para verificar si hay que invertir los bytes

__mascara_filtrar: DD 0x000000FF,0x000000FF,0x000000FF,0x000000FF ; MÃ¡scara usada al final, para eliminar la basura una vez obtenidos los 4 bytes de cada iteraciÃ³n.
__mascara_shuffle: DB 0x00,0x04,0x08,0x0c,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80 ; MÃ¡scara usada al final para reacomodar los 4 bytes obtenidos.


__antes: DQ 0 ; PosiciÃ³n de memoria donde se va a acumular el contador de tiempo al principio
__despues: DQ 0 ; PosiciÃ³n de memoria donde se va a acumular el contador de tiempo del final






section .text
;		void decode_asm(unsigned char *src,
;		                unsigned char *code,
;		   			    int size,
;		                int width,
;		                int height);


	


decode_asm:
	PUSH rbp							; Alineada
	MOV rbp, rsp;		
	PUSH rbx							; Desalineada
	PUSH r12							; Alineada
	PUSH r13							; Desalineada
	PUSH r14							; Alineada
	PUSH r15							; Desalineada
	SUB rsp, 8							; Alineada
	
	empezar_medicion

	XOR r9,r9							; r9 va a ser el contador del destino
	XOR r10, r10						; r10 va a ser el contador de la fuente

	;		______Se traen las mÃ¡scaras a registro
	MOVDQA xmm15, [__mascara_01];
	MOVDQA xmm14, [__mascara_23];		
	MOVDQA xmm13, [__mascara_unos];		
	MOVDQA xmm12, [__mascara_sumar_1];		
	MOVDQA xmm11, [__mascara_restar_1];		
	MOVDQA xmm10, [__mascara_invertir];		
	MOVDQA xmm9, [__mascara_filtrar];		
	MOVDQA xmm8, [__mascara_shuffle];		



	MOVDQA xmm0, [rdi+r9]				; Antes de entrar al ciclo se hace la primera lectura de memoria para emparejar el entubado de cÃ³digo en 2 etapas.
	ADD r9, 16							; Luego de cada lectura se hace avanzar el contador de fuente.	


;------------- Este bloque de cÃ³digo empareja las iteraciones con respecto al size para poder iterar sin pasarse del buffer asignado en memoria.
;				AsÃ­ sÃ³lo no tiene sentido, hace falta mirar el final del ciclo.

	SUB rdx, 5 							; Se resta 5, uno porque el cero cuenta y otros 4 para no pasarse nunca. - 
										; Por como estÃ¡ armado el ciclo siempre se escribe 4 por delante de la posiciÃ³n - 
										; del contador. Al tener un contador 4 mas abajo de lo deseado se va a terminar en la - 
										; posiciÃ³n correcta.
	MOV r8, rdx							; Se crea uan copia de size
	SHL r8, 62							;	Se hace esto para averiguar el resto mÃ³dulo 4 de size
	SHR r8, 62							; 
	MOV rcx, 4							;		
	SUB rcx, r8							; Ahora en rcx estÃ¡ cuanto le falta a size para ser mÃ³dulo 4		
	SHL rcx, 2							; Se multiplica por 4 - 
									; A esta altura en rcx estÃ¡ la cantidad exacta de posiciones que va a haber que retroceder en la fuente para el Ãºltimo ciclo.
	ADD rcx, 16							; Esto Ãºltimo es para compensar que siempre se estÃ¡ 16 bits mÃ¡s adelante en el contador por la optimizaciÃ³n.
										; de esta manera cuando en la lÃ³gica del final se haga la lectura extra se estarÃ¡ leyendo el lugar correcto

	

	XOR r8, r8 							; A partir de ahora r8 solo funciona como un flag que indica si se entrÃ³ o no a la lÃ³gica final del ciclo que indica sirve para los tamaÃ±os de size que no son
;										 0 mÃ³dulo 16

	
ciclo:

	MOVDQU	 xmm7, [rdi+r9]		; Se traen datos nuevos y se guardan en un registro auxiliar.
	MOVDQA	 xmm1, xmm0			; Los datos con los que se va a trabajar en esta vuelta del ciclo ya estÃ¡n en xmm0. Se hace una copia



	PAND	 xmm0, xmm15		; Se filtran los bits 0 y 1 de cada byte en xmm0.
	PAND	 xmm1, xmm14		; Se filtran los bits 2 y 3 de cada byte en xmm1.



; A continuaciÃ³n se comprobarÃ¡ si hay que hacer alguna de las 3 posibles operaciones:
; Sumar uno, restar 1 o invertir. En cada caso lo que se hace es comparar mediante mÃ¡scaras
; modificar mediante mÃ¡scaras y acumular el resultado final.

	MOVDQA	 xmm2, xmm1			; Se guarda copian los bits 2 y 3 para no perder los datos originales.
		
	PCMPEQB	 xmm2, xmm12		; Se compara los bits 2 y 3 con la mÃ¡scara de sumar uno. Ahora hay 0xFF sÃ³lo en las posiciones de bytes a los hay que sumar uno. En el resto hay 0x00.
	PAND	 xmm2, xmm13		; Mediante un and empaquetado se logra que haya un 1 sÃ³lo en aquellas posiciones donde hay que sumar 1. En el resto hay ceros.
	PADDB	 xmm0, xmm2			; Se realiza una suma empaquetada.
	PAND	 xmm0, xmm15		; Se filtran los datos. para eliminar posible apariciÃ³n de basuta.
		

	MOVDQA	 xmm2, xmm1			; Se vuelven a guardar copiar los datos.
			
	PCMPEQB	 xmm2, xmm11		; Ahora se compara con la mÃ¡scara de restar 1.
	PAND	 xmm2, xmm13		; SÃ³lo queda 0xFF en aquellas posiciones donde efectivamente hay que restar 1.
	PSUBB	 xmm0, xmm2			; Se realiza una resta empaquetada entre los datos y la mÃ¡sraca.
	PAND	 xmm0, xmm15		; Se elimina posible basura.
		
	; No se vuelven a copiar los bits 2 y 3 porque de acÃ¡ en adelante ya no van a hacer falta.		
	PCMPEQB	 xmm1, xmm10		; Se compara para saber donde hay que invertir.
	PAND	 xmm1, xmm15		; Se crea una mÃ¡scara con que contiene 0x03 sÃ³lo donde hay que invertir.
	PXOR	 xmm0, xmm1			; Se invierte usando XOR. x XOR 0 = x. x XOR 1 = -x.
		
		
; En este punto ya se tienen los datos procesados. SÃ³lo falta acomodarlos.

	MOVDQA	 xmm1, xmm0			; Se realizan 3 copias de los datos.
	MOVDQA	 xmm2, xmm0		
	MOVDQA 	 xmm3, xmm0		
		
	PSRLDQ	 xmm1, 1			; Se alinean los datos de las copias
	PSRLDQ	 xmm2, 2			; La idea es que los pares de bits que pertenecen a un mismo byte decodificado estÃ©n en la misma posiciÃ³n.
	PSRLDQ	 xmm3, 3			; SÃ³lo hay datos Ãºtiles en las posiciones 0, 4, 8 y 12.

	PSLLD	 xmm1, 2			; Ahora se acomodan los bits. Cada par de bits estaba en la misma posiciÃ³n -
	PSLLD	 xmm2, 4			; lo que se hace ahora es hacer qeu cada uno quede ocupando la posiciÃ³n que debe ocupar en el byte decodificado.
	PSLLD	 xmm3, 6			;
		
	PADDB	 xmm0, xmm1			; Se acumulan los datos obtenidos. No hay posibilidad de que haya datos basura dentro del byte porque previamente
	PADDB	 xmm0, xmm2			; se fultraron todos los datos. De esta manera se pueden sumar todos los datos en un mismo registro
	PADDB	 xmm0, xmm3			; y quedan completos. Sin embargo hay basura en las otras posiciones
		
	PAND	 xmm0, xmm9			; Se limpian todas las posiciones menos las 0,4,8 y 12.
		
	PSHUFB	 xmm0, xmm8			; Ahora se acomodan los datos en los 4 bits menos significativos del registro.
		
	MOVD	 [rsi+r10], xmm0	; Se acumula el resultado en el destino.
		
				
		
		
	MOVDQA	 xmm0, xmm7			; Se traen nuevos datos para utilizar en la prÃ³xima vuelta del ciclo.
		
	ADD		 r9, 16 			; Se hace avanzar el contador de la fuente
	ADD		 r10, 4				; Se hace avanzar el contador del destino
		
	CMP		 r10, rdx			; Se comprueba si el contador de destino llegÃ³ a tener tamaÃ±o "size"
	JL		 ciclo				; Si sigue siendo mas chico que "size" se vuelve a ciclar.
		


;----Esta es la lÃ³gica especial para asegurarse de que no se pasa de largo el ciclado.

	MOV		 r10, rdx			; Primero se pone como contador a size (Recordemos que size estÃ¡ reducido en 4)
	SUB		 r9, rcx			; A continuaciÃ³n se le resta al contador de fuente el nÃºmero calculado al principio.
	MOVDQU	 xmm0, [rdi+r9]		; Se traen datos en xmm0.
	CMP		 r8, 0 				; Se merifica si el r8 estÃ¡ en cero. Notar que r8 funciona como un flag "ya pasaste por acÃ¡".
	MOV		 r8, 1 				; Se le asigna 1 a r8. el MOV no modifica los flags
	JE		 ciclo				; SÃ³lo si r8 era cero en el momento se la comparaciÃ³n se hace un ciclado mÃ¡s.
		
salida:		
		
		
	terminar_medicion




	ADD rsp, 8
	POP r15
	POP r14
	POP r13
	POP r12
	POP rbx
	POP rbp
    ret
