#include "tiempo.h"

void imprimir_resultado(long long unsigned int res)
{
	#ifdef IMPRIMIR_MEDICIONES
		printf("%llu, \n", res);
	#endif
}