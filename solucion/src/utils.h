#ifndef __UTILS__H__
#define __UTILS__H__

#include <mmintrin.h>  // MMX
#include <xmmintrin.h> // SSE
#include <emmintrin.h> // SSE2
#include <pmmintrin.h> // SSE3
#include <tmmintrin.h> // SSSE3

void copiar_bordes (
	unsigned char *src,
	unsigned char *dst,
	int m,
	int n,
	int row_size
);

void voltear_horizontal (
	unsigned char *src,
	unsigned char *dst,
	int m,
	int n,
	int row_size
);

void pintar_bordes_negro(unsigned char *frame, int m, int n);

typedef union float4{
    __m128		x;
    float		v[4];
} float4;

typedef union dword4{
    __m128i		x;
    int		v[4];
} dword4;

typedef union word8{
    __m128i		x;
    short		v[8];
} word8;

typedef union byte16{
    __m128i		x;
    char		v[16];
} byte16;

void print_vector_f (__m128 x);
void print_vector_dw (__m128i x);
void print_vector_w (__m128i x);
void print_vector_uw (__m128i x);
void print_vector_b (__m128i x);
void print_vector_ub (__m128i x);

#endif /* !__UTILS__H__ */
