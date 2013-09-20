#include <stdio.h>

#include <mmintrin.h>  // MMX
#include <xmmintrin.h> // SSE
#include <emmintrin.h> // SSE2
#include <pmmintrin.h> // SSE3
#include <tmmintrin.h> // SSSE3

#include "utils.h"

void copiar_bordes (
	unsigned char *src,
	unsigned char *dst,
	int m,
	int n,
	int row_size
) {
	for(int j = 0; j<n; j++) {
		// superior
		dst[0*row_size+j] = src[0*row_size+j];
		// inferior
		dst[(m-1)*row_size+j] = src[(m-1)*row_size+j];
	}

	for(int i = 0; i<m; i++) {
		// izquierdo
		dst[i*row_size+0] = src[i*row_size+0];
		// derecho
		dst[i*row_size+(n-1)] = src[i*row_size+(n-1)];
	}
}

void voltear_horizontal (
	unsigned char *src,
	unsigned char *dst,
	int m,
	int n,
	int row_size
) {
	unsigned char (*src_matrix)[row_size] = (unsigned char (*)[row_size]) src;
	unsigned char (*dst_matrix)[row_size] = (unsigned char (*)[row_size]) dst;

	for (int i = 0; i<m; i+=1) {
		for (int j = 0; j<n; j+=1) {
			dst_matrix[i][n-j-1] = src_matrix[i][j];
		}
	}
}

void pintar_bordes_negro(unsigned char *frame, int m, int n) {

    for (int i = 0; i < n * 3; i+=1) {
        frame[i] = 0;
        frame[n * 3 + i] = 0;
        frame[n * 6 + i] = 0;
    }

    for (int i = 0; i < m - 3; i+= 1) {
        for (int k = 0; k < 3 * 3; k++) {
             frame[k] = 0;
             frame[n * 3 - 1 - k] = 0;
        }
        frame += n * 3;
    }

    for (int i = 0; i < n * 3; i+=1) {
        frame[i] = 0;
        frame[n * 3 + i] = 0;
        frame[n * 6 + i] = 0;
    }
}

void print_vector_f (__m128 x){
	float4 u; u.x = x;
    printf("(f) %f,%f,%f,%f\n", u.v[0], u.v[1], u.v[2], u.v[3]);
}

void print_vector_dw (__m128i x){
	dword4 u; u.x = x;
    printf("(dw) %d,%d,%d,%d\n", u.v[0], u.v[1], u.v[2], u.v[3]);
}

void print_vector_udw (__m128i x){
	dword4 u; u.x = x;
    printf("(udw) %u,%u,%u,%u\n", u.v[0], u.v[1], u.v[2], u.v[3]);
}

void print_vector_w (__m128i x){
	word8 u; u.x = x;
    printf("(w) %d,%d,%d,%d,%d,%d,%d,%d\n", u.v[0], u.v[1], u.v[2], u.v[3], u.v[4], u.v[5], u.v[6], u.v[7]);
}

void print_vector_uw (__m128i x){
	word8 u; u.x = x;
    printf("(uw) %u,%u,%u,%u,%u,%u,%u,%u\n", (unsigned short)u.v[0],
    	(unsigned short)u.v[1], (unsigned short)u.v[2], (unsigned short)u.v[3], (unsigned short)u.v[4],
    	(unsigned short)u.v[5], (unsigned short)u.v[6], (unsigned short)u.v[7]);
}

void print_vector_b (__m128i x){
	byte16 u; u.x = x;
    printf("(b) %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n", u.v[0], u.v[1], u.v[2], u.v[3], u.v[4], u.v[5], u.v[6], u.v[7], u.v[8], u.v[9], u.v[10], u.v[11], u.v[12], u.v[13], u.v[14], u.v[15]);
}

void print_vector_ub (__m128i x){
	byte16 u; u.x = x;
    printf("(ub) %u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u\n", (unsigned char)u.v[0],
    	(unsigned char)u.v[1], (unsigned char)u.v[2], (unsigned char)u.v[3], (unsigned char)u.v[4],
    	(unsigned char)u.v[5], (unsigned char)u.v[6], (unsigned char)u.v[7], (unsigned char)u.v[8],
    	(unsigned char)u.v[9], (unsigned char)u.v[10], (unsigned char)u.v[11], (unsigned char)u.v[12],
    	(unsigned char)u.v[13], (unsigned char)u.v[14], (unsigned char)u.v[15]);
}