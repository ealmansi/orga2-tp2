extern printf

;%macro tiempo_datos 0
section .data
	__tiempo_antes__: 		DQ 0
	__tiempo_despues__: 	DQ 0
	__tiempo_fmt_print__: 	DB "%llu, ",10, 0

;%endmacro

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

%macro print_time 1

%ifdef IMPRIMIR_MEDICIONES
	PUSH rdi
	PUSH rsi
	PUSH rax
	SUB rsp, 8
	MOV rdi, __tiempo_fmt_print__
	MOV rsi, %1
	CALL printf
	ADD rsp, 8
	POP rax
	POP rsi
	POP rdi
%endif

%endmacro

%macro empezar_medicion 0
	
	get_timestamp [__tiempo_antes__]

%endmacro

%macro terminar_medicion 0

	get_timestamp [__tiempo_despues__]

	MOV r8, [__tiempo_despues__]
	SUB r8, [__tiempo_antes__]

	print_time r8

%endmacro