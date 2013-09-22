#include <string.h>
#include "utils.h"
#include "tiempo.h"

#include <mmintrin.h>  // MMX
#include <xmmintrin.h> // SSE
#include <emmintrin.h> // SSE2
#include <pmmintrin.h> // SSE3
#include <tmmintrin.h> // SSSE3

#define     src(i,j)        (src[(3 * (i)) * width + (3 * (j))])
#define     dst(i,j)        (dst[(3 * (i)) * width + (3 * (j))])

#define     ____            ((char)0x80)

__m128i img_fila_0;                 // XMM0
__m128i img_fila_1;                 // XMM1
__m128i img_fila_2;                 // XMM2
__m128i img_fila_3;                 // XMM3
__m128i img_fila_4;                 // XMM4

__m128i mat_fila_0;                 // XMM10
__m128i mat_fila_1;                 // XMM11
__m128i mat_fila_2;                 // XMM12

__m128i masc_desempaq;              // XMM8
__m128  masc_denom;                 // XMM9

__m128i acum_r, acum_g, acum_b;     // XMM5, XMM6, XMM7
__m128i temp_1, temp_2, temp_3;     // XMM13, XMM14, XMM15

void acumular_fila_izq(__m128i *img_fila, __m128i *mat_fila)
{
    /* azules */
    temp_1 = *img_fila;                                   // temp_1 <- [b3,b2,b1,b0,b3,b2,b1,b0]
    temp_1 = _mm_shuffle_epi8(temp_1, masc_desempaq);

    temp_2 = *mat_fila;                                // temp_2 <- [18,5,1,0,5,18,5,1]
    temp_3 = _mm_setzero_si128();
    temp_2 = _mm_unpackhi_epi8(temp_2, temp_3);
    temp_3 = temp_1;
    temp_3 = _mm_madd_epi16(temp_3, temp_2);            // temp_3 = [b3*18+b2*5,b1*1+b0*0,b3*5+b2*18,b1*5+b0*1]

    temp_2 = _mm_slli_epi64(temp_2, 32);                // temp_2 <- [1 0 0 0 5 1 0 0]
    temp_2 = _mm_madd_epi16(temp_2, temp_1);            // temp_2 = [b3*1+b2*0,b1*0+b0*0,b3*5+b2*1,b1*0+b0*0]

    temp_3 = _mm_hadd_epi32(temp_3, temp_2);            // temp_3 = [px3, px2, px1, px0] (suma de azules fila 0)
    acum_b = _mm_add_epi32(acum_b, temp_3);             // acum_b += temp_3

    /* verdes */
    temp_1 = _mm_srli_si128(*img_fila, 1);             // temp_1 <- [g3,g2,g1,g0,g3,g2,g1,g0]
    temp_1 = _mm_shuffle_epi8(temp_1, masc_desempaq);

    temp_2 = *mat_fila;                                // temp_2 <- [18,5,1,0,5,18,5,1]
    temp_3 = _mm_setzero_si128();
    temp_2 = _mm_unpackhi_epi8(temp_2, temp_3);
    temp_3 = _mm_madd_epi16(temp_1, temp_2);            // temp_3 = [g3*18+g2*5,g1*1+g0*0,g3*5+g2*18,g1*5+g0*1]
    
    temp_2 = _mm_slli_epi64(temp_2, 32);                // temp_2 <- [1 0 0 0 5 1 0 0]
    temp_2 = _mm_madd_epi16(temp_1, temp_2);            // temp_2 = [g3*1+g2*0,g1*0+g0*0,g3*5+g2*1,g1*0+g0*0]

    temp_3 = _mm_hadd_epi32(temp_3, temp_2);            // temp_3 = [px3, px2, px1, px0] (suma de verdes fila 0)
    acum_g = _mm_add_epi32(acum_g, temp_3);             // acum_g += temp_3

    /* rojos */
    temp_1 = _mm_srli_si128(*img_fila, 2);             // temp_1 <- [r3,r2,r1,r0,r3,r2,r1,r0]
    temp_1 = _mm_shuffle_epi8(temp_1, masc_desempaq);

    temp_2 = *mat_fila;                                // temp_2 <- [18,5,1,0,5,18,5,1]
    temp_3 = _mm_setzero_si128();
    temp_2 = _mm_unpackhi_epi8(temp_2, temp_3);
    temp_3 = _mm_madd_epi16(temp_1, temp_2);            // temp_3 = [r3*18+r2*5,r1*1+r0*0,r3*5+r2*18,r1*5+r0*1]
    
    temp_2 = _mm_slli_epi64(temp_2, 32);                // temp_2 <- [1 0 0 0 5 1 0 0]
    temp_2 = _mm_madd_epi16(temp_1, temp_2);            // temp_2 = [r3*1+r2*0,r1*0+r0*0,r3*5+r2*1,r1*0+r0*0]

    temp_3 = _mm_hadd_epi32(temp_3, temp_2);            // temp_3 = [px3, px2, px1, px0] (suma de rojos fila 0)
    acum_r = _mm_add_epi32(acum_r, temp_3);             // acum_r += temp_3
}

void acumular_fila_der(__m128i *img_fila, __m128i *mat_fila)
{
    /* azules */
    temp_1 = *img_fila;
    temp_1 = _mm_shuffle_epi8(temp_1, masc_desempaq);

    temp_2 = _mm_slli_si128(*mat_fila, 8);
    temp_3 = _mm_setzero_si128();
    temp_2 = _mm_unpackhi_epi8(temp_2, temp_3);
    temp_3 = _mm_madd_epi16(temp_1, temp_2);
    
    temp_2 = _mm_srli_epi64(temp_2, 32);
    temp_2 = _mm_madd_epi16(temp_1, temp_2);

    temp_3 = _mm_hadd_epi32(temp_2, temp_3);
    acum_b = _mm_add_epi32(acum_b, temp_3);

    /* verdes */
    temp_1 = _mm_srli_si128(*img_fila, 1);
    temp_1 = _mm_shuffle_epi8(temp_1, masc_desempaq);

    temp_2 = _mm_slli_si128(*mat_fila, 8);
    temp_3 = _mm_setzero_si128();
    temp_2 = _mm_unpackhi_epi8(temp_2, temp_3);
    temp_3 = _mm_madd_epi16(temp_1, temp_2);
    
    temp_2 = _mm_srli_epi64(temp_2, 32);
    temp_2 = _mm_madd_epi16(temp_1, temp_2);

    temp_3 = _mm_hadd_epi32(temp_2, temp_3);
    acum_g = _mm_add_epi32(acum_g, temp_3);

    /* rojos */
    temp_1 = _mm_srli_si128(*img_fila, 2);
    temp_1 = _mm_shuffle_epi8(temp_1, masc_desempaq);

    temp_2 = _mm_slli_si128(*mat_fila, 8);
    temp_3 = _mm_setzero_si128();
    temp_2 = _mm_unpackhi_epi8(temp_2, temp_3);
    temp_3 = _mm_madd_epi16(temp_1, temp_2);
    
    temp_2 = _mm_srli_epi64(temp_2, 32);
    temp_2 = _mm_madd_epi16(temp_1, temp_2);

    temp_3 = _mm_hadd_epi32(temp_2, temp_3);
    acum_r = _mm_add_epi32(acum_r, temp_3);
}

void acumular_sumas_parciales_izq()
{
    acumular_fila_izq(&img_fila_0, &mat_fila_0);
    acumular_fila_izq(&img_fila_1, &mat_fila_1);
    acumular_fila_izq(&img_fila_2, &mat_fila_2);
    acumular_fila_izq(&img_fila_3, &mat_fila_1);
    acumular_fila_izq(&img_fila_4, &mat_fila_0);
}

void acumular_sumas_parciales_der()
{
    acumular_fila_der(&img_fila_0, &mat_fila_0);
    acumular_fila_der(&img_fila_1, &mat_fila_1);
    acumular_fila_der(&img_fila_2, &mat_fila_2);
    acumular_fila_der(&img_fila_3, &mat_fila_1);
    acumular_fila_der(&img_fila_4, &mat_fila_0);
}

void normalizar_acumuladores()
{
    acum_b = _mm_castps_si128(_mm_cvtepi32_ps(acum_b));
    acum_b = _mm_castps_si128(_mm_mul_ps(_mm_castsi128_ps(acum_b), masc_denom));
    acum_b = _mm_cvtps_epi32(_mm_castsi128_ps(acum_b));
    acum_g = _mm_castps_si128(_mm_cvtepi32_ps(acum_g));
    acum_g = _mm_castps_si128(_mm_mul_ps(_mm_castsi128_ps(acum_g), masc_denom));
    acum_g = _mm_cvtps_epi32(_mm_castsi128_ps(acum_g));
    acum_r = _mm_castps_si128(_mm_cvtepi32_ps(acum_r));
    acum_r = _mm_castps_si128(_mm_mul_ps(_mm_castsi128_ps(acum_r), masc_denom));
    acum_r = _mm_cvtps_epi32(_mm_castsi128_ps(acum_r));
}

void empaquetar_resultado()
{
    temp_1 = _mm_set_epi8(____,____,____,____,____,____,0x0C,____,____,0x08,____,____,0x04,____,____,0x00);
    acum_b = _mm_shuffle_epi8(acum_b, temp_1);
    acum_g = _mm_shuffle_epi8(acum_g, temp_1);
    acum_g = _mm_slli_si128(acum_g, 1);
    acum_r = _mm_shuffle_epi8(acum_r, temp_1);
    acum_r = _mm_slli_si128(acum_r, 2);

    temp_1 = acum_b;
    temp_1 = _mm_add_epi8(temp_1, acum_g);
    temp_1 = _mm_add_epi8(temp_1, acum_r);
}

void actualizar_pixeles(unsigned char *src, unsigned char *dst, int i, int j, int width)
{
    acum_r = acum_g = acum_b = _mm_setzero_si128();

    acumular_sumas_parciales_izq();

    img_fila_0 = _mm_loadu_si128((__m128i *) &src(i - 2, j + 2));
    img_fila_1 = _mm_loadu_si128((__m128i *) &src(i - 1, j + 2));
    img_fila_2 = _mm_loadu_si128((__m128i *) &src(i + 0, j + 2));
    img_fila_3 = _mm_loadu_si128((__m128i *) &src(i + 1, j + 2));
    img_fila_4 = _mm_loadu_si128((__m128i *) &src(i + 2, j + 2));

    acumular_sumas_parciales_der();

    normalizar_acumuladores();

    empaquetar_resultado();

    _mm_storeu_si128((__m128i *) &dst(i, j), temp_1);
}

void procesar_fila(unsigned char *src, unsigned char *dst, int i, int width)
{
    img_fila_0 = _mm_loadu_si128((__m128i *) &src(i - 2, 0)),
    img_fila_1 = _mm_loadu_si128((__m128i *) &src(i - 1, 0)),
    img_fila_2 = _mm_loadu_si128((__m128i *) &src(i + 0, 0)),
    img_fila_3 = _mm_loadu_si128((__m128i *) &src(i + 1, 0)),
    img_fila_4 = _mm_loadu_si128((__m128i *) &src(i + 2, 0));

    int j;
    for (j = 2; j < width - 2; j += 4)
        actualizar_pixeles(src, dst, i, j, width);

    // corrijo los primeros 4 bytes de dst(i, j)
    img_fila_2 = _mm_loadu_si128((__m128i *) &src(i, j));
    _mm_storeu_si128((__m128i *) &dst(i, j), img_fila_2);
}

void inicializar_mascaras()
{
    mat_fila_0 = _mm_set_epi8( 18,   5,   1,   0,   5,  18,   5,   1,  1,   5,  18,   5,   0,   1,   5,  18);
    mat_fila_1 = _mm_set_epi8( 64,  32,   5,   0,  32,  64,  32,   5,  5,  32,  64,  32,   0,   5,  32,  64);
    mat_fila_2 = _mm_set_epi8(100,  64,  18,   0,  64, 100,  64,  18, 18,  64, 100,  64,   0,  18,  64, 100);
    
    masc_desempaq = _mm_set_epi8(____,0x09,____,0x06,____,0x03,____,0x00,____,0x09,____,0x06,____,0x03,____,0x00);
    
    float recip_suma_matriz = 1.0/600;
    masc_denom = _mm_load1_ps(&recip_suma_matriz);
}

void miniature_c(
                unsigned char *src,
                unsigned char *dst,
                int width, int height,
                float coeff_top_plane, float coeff_bottom_plane,
                int iters) {

    int top_plane = coeff_top_plane * height,
        bottom_plane = coeff_bottom_plane * height;

    int top_plane_delta = coeff_top_plane * height / iters,
        bottom_plane_delta = (1 - coeff_bottom_plane) * height / iters;

    memcpy(dst, src, 3 * width * height);
    
    inicializar_mascaras();

    int it, i;
    for (it = 0; it < iters; ++it)
    {
        for (i = 2; i <= top_plane; ++i)
            procesar_fila(src, dst, i, width);
            
        for (i = bottom_plane; i < height - 2; ++i)
            procesar_fila(src, dst, i, width);

        top_plane -= top_plane_delta;
        bottom_plane += bottom_plane_delta;

        memcpy(src, dst, 3 * width * height);
    }
}