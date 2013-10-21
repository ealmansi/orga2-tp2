#ifndef __TIEMPO_H__
#define __TIEMPO_H__

#include <stdio.h>

extern long long unsigned int get_timestamp();

void imprimir_resultado(long long unsigned int res);

#define EMPEZAR_MEDICION() 								\
	long long unsigned int __time_begin__, __time_end__;		\
	__time_begin__ = get_timestamp();

#define TERMINAR_MEDICION() 							\
	__time_end__ = get_timestamp(); 					\
	imprimir_resultado(__time_end__ - __time_begin__);

#endif /* !__TIEMPO_H__ */
