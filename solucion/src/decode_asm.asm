global decode_asm
extern printf


;		_*_*_*_*_*_*_ MACROS DE TIEMPO _*_*_*_*_*_*_*_*_

%macro get_timestamp 1 ;Macro que captura el timestamp

	PUSH rax
	PUSH rdx
	RDTSC
	SHL rdx, 32
	ADD rax, rdx;		
	MOV %1, rax;		
	POP rdx
	POP rax

%endmacro



%macro define_format 0 ; Macro para insertar el formato del printf.

__formato_printf: DB "%lu,",10, 0

%endmacro




%macro print_time 1 ; Macro que imprime lo pasado por pantalla con el formato definido en 'define_format'.

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
	
;		_*_*_*_*_*_*_*_ FIN MACROS DE TIEMPO _*_*_*_*_*_*_*



section .data

align 16
__mascara_01: DB 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03 ;Máscara usada para filtrar los 2 bits menos significativos de cada byte
__mascara_23: DB 0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c ;Máscara usada para filtrar los bits 2 y 3 de cada byte.
__mascara_unos: DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1	; Máscara que contiene 16 unos consecutivos.

__mascara_sumar_1: DB 0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04 ; Máscara usada para verificar si hay que sumar 1
__mascara_restar_1: DB 0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08 ; Másra usada para verificar si hay que restar 1
__mascara_invertir: DB  0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c ; Máscara usada para verificar si hay que invertir los bytes

__mascara_filtrar: DD 0x000000FF,0x000000FF,0x000000FF,0x000000FF ; Máscara usada al final, para eliminar la basura una vez obtenidos los 4 bytes de cada iteración.
__mascara_shuffle: DB 0x00,0x04,0x08,0x0c,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80 ; Máscara usada al final para reacomodar los 4 bytes obtenidos.


__antes: DQ 0 ; Posición de memoria donde se va a acumular el contador de tiempo al principio
__despues: DQ 0 ; Posición de memoria donde se va a acumular el contador de tiempo del final



define_format



section .text
;		void decode_asm(unsigned char *src,
;		              unsigned char *code,
;					   int size,
;		              int width,
;		              int height);


	


decode_asm:


	get_timestamp [__antes] ; Se mide el tiempo al comenzar.


	PUSH rbp;		 Alineada ; 
	MOV rbp, rsp;		
	PUSH rbx							; Desalineada
	PUSH r12							; Alineada
	PUSH r13							; Desalineada
	PUSH r14							; Alineada
	PUSH r15							; Desalineada
	SUB rsp, 8							; Alineada

	XOR r9,r9							; r9 va a ser el contador del destino
	XOR r10, r10						; r10 va a ser el contador de la fuente

	;		______Se traen las máscaras a registro
	MOVDQA xmm15, [__mascara_01];
	MOVDQA xmm14, [__mascara_23];		
	MOVDQA xmm13, [__mascara_unos];		
	MOVDQA xmm12, [__mascara_sumar_1];		
	MOVDQA xmm11, [__mascara_restar_1];		
	MOVDQA xmm10, [__mascara_invertir];		
	MOVDQA xmm9, [__mascara_filtrar];		
	MOVDQA xmm8, [__mascara_shuffle];		



	MOVDQA xmm0, [rdi+r9]				; Antes de entrar al ciclo se hace la primera lectura de memoria para emparejar el entubado de código en 2 etapas.
	ADD r9, 16							; Luego de cada lectura se hace avanzar el contador de fuente.	


;------------- Este bloque de código empareja las iteraciones con respecto al size para poder iterar sin pasarse del buffer asignado en memoria.
;				Así sólo no tiene sentido, hace falta mirar el final del ciclo.

	SUB rdx, 5 							; Se resta 5, uno porque el cero cuenta y otros 4 para no pasarse nunca. - 
										; Por como está armado el ciclo siempre se escribe 4 por delante de la posición - 
										; del contador. Al tener un contador 4 mas abajo de lo deseado se va a terminar en la - 
										; posición correcta.
	MOV r8, rdx							; Se crea uan copia de size
	SHL r8, 62							;	Se hace esto para averiguar el resto módulo 4 de size
	SHR r8, 62							; 
	MOV rcx, 4							;		
	SUB rcx, r8							; Ahora en rcx está cuanto le falta a size para ser módulo 4		
	SHL rcx, 2							; Se multiplica por 4 - 
									; A esta altura en rcx está la cantidad exacta de posiciones que va a haber que retroceder en la fuente para el último ciclo.
	ADD rcx, 16							; Esto último es para compensar que siempre se está 16 bits más adelante en el contador por la optimización.
										; de esta manera cuando en la lógica del final se haga la lectura extra se estará leyendo el lugar correcto

	

	XOR r8, r8 							; A partir de ahora r8 solo funciona como un flag que indica si se entró o no a la lógica final del ciclo que indica sirve para los tamaños de size que no son
;										 0 módulo 16

	
ciclo:

	MOVDQU	 xmm7, [rdi+r9]		; Se traen datos nuevos y se guardan en un registro auxiliar.
	MOVDQA	 xmm1, xmm0			; Los datos con los que se va a trabajar en esta vuelta del ciclo ya están en xmm0. Se hace una copia



	PAND	 xmm0, xmm15		; Se filtran los bits 0 y 1 de cada byte en xmm0.
	PAND	 xmm1, xmm14		; Se filtran los bits 2 y 3 de cada byte en xmm1.



; A continuación se comprobará si hay que hacer alguna de las 3 posibles operaciones:
; Sumar uno, restar 1 o invertir. En cada caso lo que se hace es comparar mediante máscaras
; modificar mediante máscaras y acumular el resultado final.

	MOVDQA	 xmm2, xmm1			; Se guarda copian los bits 2 y 3 para no perder los datos originales.
		
	PCMPEQB	 xmm2, xmm12		; Se compara los bits 2 y 3 con la máscara de sumar uno. Ahora hay 0xFF sólo en las posiciones de bytes a los hay que sumar uno. En el resto hay 0x00.
	PAND	 xmm2, xmm13		; Mediante un and empaquetado se logra que haya un 1 sólo en aquellas posiciones donde hay que sumar 1. En el resto hay ceros.
	PADDB	 xmm0, xmm2			; Se realiza una suma empaquetada.
	PAND	 xmm0, xmm15		; Se filtran los datos. para eliminar posible aparición de basuta.
		

	MOVDQA	 xmm2, xmm1			; Se vuelven a guardar copiar los datos.
			
	PCMPEQB	 xmm2, xmm11		; Ahora se compara con la máscara de restar 1.
	PAND	 xmm2, xmm13		; Sólo queda 0xFF en aquellas posiciones donde efectivamente hay que restar 1.
	PSUBB	 xmm0, xmm2			; Se realiza una resta empaquetada entre los datos y la másraca.
	PAND	 xmm0, xmm15		; Se elimina posible basura.
		
	; No se vuelven a copiar los bits 2 y 3 porque de acá en adelante ya no van a hacer falta.		
	PCMPEQB	 xmm1, xmm10		; Se compara para saber donde hay que invertir.
	PAND	 xmm1, xmm15		; Se crea una máscara con que contiene 0x03 sólo donde hay que invertir.
	PXOR	 xmm0, xmm1			; Se invierte usando XOR. x XOR 0 = x. x XOR 1 = -x.
		
		
; En este punto ya se tienen los datos procesados. Sólo falta acomodarlos.

	MOVDQA	 xmm1, xmm0			; Se realizan 3 copias de los datos.
	MOVDQA	 xmm2, xmm0		
	MOVDQA 	 xmm3, xmm0		
		
	PSRLDQ	 xmm1, 1			; Se alinean los datos de las copias
	PSRLDQ	 xmm2, 2			; La idea es que los pares de bits que pertenecen a un mismo byte decodificado estén en la misma posición.
	PSRLDQ	 xmm3, 3			; Sólo hay datos útiles en las posiciones 0, 4, 8 y 12.

	PSLLD	 xmm1, 2			; Ahora se acomodan los bits. Cada par de bits estaba en la misma posición -
	PSLLD	 xmm2, 4			; lo que se hace ahora es hacer qeu cada uno quede ocupando la posición que debe ocupar en el byte decodificado.
	PSLLD	 xmm3, 6			;
		
	PADDB	 xmm0, xmm1			; Se acumulan los datos obtenidos. No hay posibilidad de que haya datos basura dentro del byte porque previamente
	PADDB	 xmm0, xmm2			; se fultraron todos los datos. De esta manera se pueden sumar todos los datos en un mismo registro
	PADDB	 xmm0, xmm3			; y quedan completos. Sin embargo hay basura en las otras posiciones
		
	PAND	 xmm0, xmm9			; Se limpian todas las posiciones menos las 0,4,8 y 12.
		
	PSHUFB	 xmm0, xmm8			; Ahora se acomodan los datos en los 4 bits menos significativos del registro.
		
	MOVD	 [rsi+r10], xmm0	; Se acumula el resultado en el destino.
		
				
		
		
	MOVDQA	 xmm0, xmm7			; Se traen nuevos datos para utilizar en la próxima vuelta del ciclo.
		
	ADD		 r9, 16 			; Se hace avanzar el contador de la fuente
	ADD		 r10, 4				; Se hace avanzar el contador del destino
		
	CMP		 r10, rdx			; Se comprueba si el contador de destino llegó a tener tamaño "size"
	JL		 ciclo				; Si sigue siendo mas chico que "size" se vuelve a ciclar.
		


;----Esta es la lógica especial para asegurarse de que no se pasa de largo el ciclado.

	MOV		 r10, rdx			; Primero se pone como contador a size (Recordemos que size está reducido en 4)
	SUB		 r9, rcx			; A continuación se le resta al contador de fuente el número calculado al principio.
	MOVDQU	 xmm0, [rdi+r9]		; Se traen datos en xmm0.
	CMP		 r8, 0 				; Se merifica si el r8 está en cero. Notar que r8 funciona como un flag "ya pasaste por acá".
	MOV		 r8, 1 				; Se le asigna 1 a r8. el MOV no modifica los flags
	JE		 ciclo				; Sólo si r8 era cero en el momento se la comparación se hace un ciclado más.
		
salida:		
		
		
	get_timestamp [__despues]	; Se mide el tiempo al final	
		
	MOV		 r10, [__despues]	; Se opera para tener el DELTA tiempo
	SUB 	 r10, [__antes]		
		
	print_time r10				; Se imprime el tiempo por pantalla.
		





	ADD rsp, 8
	POP r15
	POP r14
	POP r13
	POP r12
	POP rbx
	POP rbp
    ret
