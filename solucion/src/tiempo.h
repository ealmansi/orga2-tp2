#ifndef __TIEMPO_H__
#define __TIEMPO_H__

#include <stdio.h>

#define MEDIR_TIEMPO_START(start)							\
{															\
	unsigned int start_high, start_low;						\
	/* warn up ... */										\
	__asm__ __volatile__ (									\
		"cpuid\n\t"											\
		"rdtsc\n\t"											\
		"mov %%edx, %0\n\t"									\
		"mov %%eax, %1\n\t"									\
		: "=r" (start_high), "=r" (start_low)               \
		: /* no input */                                    \
		: "%eax"                                            \
	);                                                      \
	                                                        \
	__asm__ __volatile__ (									\
		"cpuid\n\t"                                         \
		"rdtsc\n\t"                                         \
		"mov %%edx, %0\n\t"                                 \
		"mov %%eax, %1\n\t"                                 \
		: "=r" (start_high), "=r" (start_low)               \
		: /* no input */									\
		: "%eax"                                            \
	);                                                      \
	                                                        \
	__asm__ __volatile__ (                                  \
		"cpuid\n\t"                                         \
		"rdtsc\n\t"											\
		"mov %%edx, %0\n\t"                                 \
		"mov %%eax, %1\n\t"                                 \
		: "=r" (start_high), "=r" (start_low)               \
		: /* no input */                                    \
		: "%eax"                                            \
	);														\
															\
	start = (((unsigned long long int) start_high) << 32) | \
		(unsigned long long int) (start_low);				\
}

#define MEDIR_TIEMPO_STOP(end)								\
{															\
	unsigned int end_high, end_low;							\
															\
	__asm__ __volatile__ (									\
		"cpuid\n\t"                                         \
		"rdtsc\n\t"                                         \
		"mov %%edx, %0\n\t"                                 \
		"mov %%eax, %1\n\t"                                 \
		: "=r" (end_high), "=r" (end_low)                   \
		: /* no input */                                    \
		: "%eax"											\
	);                                                      \
				                                            \
	end = (((unsigned long long int) end_high) << 32) | 	\
		(unsigned long long int) (end_low);					\
}

/* los sucesivos llamados a TIMER_PRINT_STATUS tienen que ser desde la misma función */
#define         TIMER_BEGIN()                   					\
unsigned long long int __timer_t0__;            					\
{																	\
	MEDIR_TIEMPO_START(__timer_t0__);           					\
}																	

#define         TIMER_END()     \
{                               \
    unsigned long long int tn;                              \
    MEDIR_TIEMPO_START(tn);                                 \
    printf("%llu,\n", tn - __timer_t0__);    				\
}

#endif /* !__TIEMPO_H__ */
