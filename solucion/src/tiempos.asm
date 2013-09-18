global get_timestamp

section .text


get_timestamp:
	RDTSC
	SHL rdx, 32;
	ADD rax, rdx;
	RET
