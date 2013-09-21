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

void acumular_fila(__m128i *fila_0, __m128i *mat_fila_0_px12, __m128i *mat_fila_0_px34,
                __m128i *acum_r, __m128i *acum_g, __m128i *acum_b)
{
    __m128i masc_extraer_r = _mm_set_epi8(____,0x0B,____,0x08,____,0x05,____,0x02,____,0x0B,____,0x08,____,0x05,____,0x02),
            masc_extraer_g = _mm_set_epi8(____,0x0A,____,0x07,____,0x04,____,0x01,____,0x0A,____,0x07,____,0x04,____,0x01),
            masc_extraer_b = _mm_set_epi8(____,0x09,____,0x06,____,0x03,____,0x00,____,0x09,____,0x06,____,0x03,____,0x00);

    __m128i temp_1, temp_2;

    temp_1 = _mm_shuffle_epi8(*fila_0, masc_extraer_r);
    temp_2 = temp_1;
    temp_1 = _mm_madd_epi16(temp_1, *mat_fila_0_px12);
    temp_2 = _mm_madd_epi16(temp_2, *mat_fila_0_px34);
    temp_1 = _mm_hadd_epi32(temp_1, temp_2);
    *acum_r = _mm_add_epi32(*acum_r, temp_1);

    temp_1 = _mm_shuffle_epi8(*fila_0, masc_extraer_g);
    temp_2 = temp_1;
    temp_1 = _mm_madd_epi16(temp_1, *mat_fila_0_px12);
    temp_2 = _mm_madd_epi16(temp_2, *mat_fila_0_px34);
    temp_1 = _mm_hadd_epi32(temp_1, temp_2);
    *acum_g = _mm_add_epi32(*acum_g, temp_1);

    temp_1 = _mm_shuffle_epi8(*fila_0, masc_extraer_b);
    temp_2 = temp_1;
    temp_1 = _mm_madd_epi16(temp_1, *mat_fila_0_px12);
    temp_2 = _mm_madd_epi16(temp_2, *mat_fila_0_px34);
    temp_1 = _mm_hadd_epi32(temp_1, temp_2);
    *acum_b = _mm_add_epi32(*acum_b, temp_1);
}

void acumular_sumas_parciales_izq(__m128i *fila_0, __m128i *fila_1, __m128i *fila_2, __m128i *fila_3, __m128i *fila_4,
                                    __m128i *acum_r, __m128i *acum_g, __m128i *acum_b)
{
    __m128i mat_fila_0_px12 = _mm_set_epi16(18,  5,  1,  0,  5, 18,  5,  1),
            mat_fila_0_px34 = _mm_set_epi16( 1,  0,  0,  0,  5,  1,  0,  0),
            mat_fila_1_px12 = _mm_set_epi16(64, 32,  5,  0, 32, 64, 32,  5),
            mat_fila_1_px34 = _mm_set_epi16( 5,  0,  0,  0, 32,  5,  0,  0),
            mat_fila_2_px12 = _mm_set_epi16(100,64, 18,  0, 64,100, 64, 18),
            mat_fila_2_px34 = _mm_set_epi16(18,  0,  0,  0, 64, 18,  0,  0);

    acumular_fila(fila_0, &mat_fila_0_px12, &mat_fila_0_px34, acum_r, acum_g, acum_b);
    acumular_fila(fila_1, &mat_fila_1_px12, &mat_fila_1_px34, acum_r, acum_g, acum_b);
    acumular_fila(fila_2, &mat_fila_2_px12, &mat_fila_2_px34, acum_r, acum_g, acum_b);
    acumular_fila(fila_3, &mat_fila_1_px12, &mat_fila_1_px34, acum_r, acum_g, acum_b);
    acumular_fila(fila_4, &mat_fila_0_px12, &mat_fila_0_px34, acum_r, acum_g, acum_b);
}

void acumular_sumas_parciales_der(__m128i *fila_0, __m128i *fila_1, __m128i *fila_2, __m128i *fila_3, __m128i *fila_4,
                                    __m128i *acum_r, __m128i *acum_g, __m128i *acum_b)
{
    __m128i mat_fila_0_px12 = _mm_set_epi16( 0,  0,  1,  5,  0,  0,  0,  1),
            mat_fila_0_px34 = _mm_set_epi16( 1,  5, 18,  5,  0,  1,  5, 18),
            mat_fila_1_px12 = _mm_set_epi16( 0,  0,  5, 32,  0,  0,  0,  5),
            mat_fila_1_px34 = _mm_set_epi16( 5, 32, 64, 32,  0,  5, 32, 64),
            mat_fila_2_px12 = _mm_set_epi16( 0,  0, 18, 64,  0,  0,  0, 18),
            mat_fila_2_px34 = _mm_set_epi16(18, 64,100, 64,  0, 18, 64, 100);

    acumular_fila(fila_0, &mat_fila_0_px12, &mat_fila_0_px34, acum_r, acum_g, acum_b);
    acumular_fila(fila_1, &mat_fila_1_px12, &mat_fila_1_px34, acum_r, acum_g, acum_b);
    acumular_fila(fila_2, &mat_fila_2_px12, &mat_fila_2_px34, acum_r, acum_g, acum_b);
    acumular_fila(fila_3, &mat_fila_1_px12, &mat_fila_1_px34, acum_r, acum_g, acum_b);
    acumular_fila(fila_4, &mat_fila_0_px12, &mat_fila_0_px34, acum_r, acum_g, acum_b);
}

void normalizar_acumuladores(__m128i *acum_r, __m128i *acum_g, __m128i *acum_b)
{
    float recip_suma_matriz = 1.0/600.0;
    __m128 masc_denom = _mm_load1_ps(&recip_suma_matriz);

    *acum_r = _mm_castps_si128(_mm_cvtepi32_ps(*acum_r));
    *acum_r = _mm_castps_si128(_mm_mul_ps(_mm_castsi128_ps(*acum_r), masc_denom));
    *acum_r = _mm_cvtps_epi32(_mm_castsi128_ps(*acum_r));
    *acum_g = _mm_castps_si128(_mm_cvtepi32_ps(*acum_g));
    *acum_g = _mm_castps_si128(_mm_mul_ps(_mm_castsi128_ps(*acum_g), masc_denom));
    *acum_g = _mm_cvtps_epi32(_mm_castsi128_ps(*acum_g));
    *acum_b = _mm_castps_si128(_mm_cvtepi32_ps(*acum_b));
    *acum_b = _mm_castps_si128(_mm_mul_ps(_mm_castsi128_ps(*acum_b), masc_denom));
    *acum_b = _mm_cvtps_epi32(_mm_castsi128_ps(*acum_b));
}

void empaquetar_resultado(__m128i *resultado, __m128i *acum_r, __m128i *acum_g, __m128i *acum_b)
{
    __m128i masc_empaq_r = _mm_set_epi8(____,____,____,____,0x0C,____,____,0x08,____,____,0x04,____,____,0x00,____,____),
            masc_empaq_g = _mm_set_epi8(____,____,____,____,____,0x0C,____,____,0x08,____,____,0x04,____,____,0x00,____),
            masc_empaq_b = _mm_set_epi8(____,____,____,____,____,____,0x0C,____,____,0x08,____,____,0x04,____,____,0x00);

    *acum_r = _mm_shuffle_epi8(*acum_r, masc_empaq_r);
    *acum_g = _mm_shuffle_epi8(*acum_g, masc_empaq_g);
    *acum_b = _mm_shuffle_epi8(*acum_b, masc_empaq_b);
    *resultado = *acum_r;
    *resultado = _mm_add_epi8(*resultado, *acum_g);
    *resultado = _mm_add_epi8(*resultado, *acum_b);
}

void actualizar_pixeles(unsigned char *src, unsigned char *dst, int i, int j, int width,
                        __m128i *fila_0, __m128i *fila_1, __m128i *fila_2, __m128i *fila_3, __m128i *fila_4)
{
    __m128i acum_r, acum_g, acum_b, resultado;
    acum_r = acum_g = acum_b = _mm_setzero_si128();

    acumular_sumas_parciales_izq(fila_0, fila_1, fila_2, fila_3, fila_4, &acum_r, &acum_g, &acum_b);

    *fila_0 = _mm_loadu_si128((__m128i *) &src(i - 2, j + 2));
    *fila_1 = _mm_loadu_si128((__m128i *) &src(i - 1, j + 2));
    *fila_2 = _mm_loadu_si128((__m128i *) &src(i + 0, j + 2));
    *fila_3 = _mm_loadu_si128((__m128i *) &src(i + 1, j + 2));
    *fila_4 = _mm_loadu_si128((__m128i *) &src(i + 2, j + 2));

    acumular_sumas_parciales_der(fila_0, fila_1, fila_2, fila_3, fila_4, &acum_r, &acum_g, &acum_b);

    normalizar_acumuladores(&acum_r, &acum_g, &acum_b);

    empaquetar_resultado(&resultado, &acum_r, &acum_g, &acum_b);

    _mm_storeu_si128((__m128i *) &dst(i, j), resultado);
}

void procesar_fila(unsigned char *src, unsigned char *dst, int i, int width)
{
    __m128i fila_0 = _mm_loadu_si128((__m128i *) &src(i - 2, 0)),
            fila_1 = _mm_loadu_si128((__m128i *) &src(i - 1, 0)),
            fila_2 = _mm_loadu_si128((__m128i *) &src(i + 0, 0)),
            fila_3 = _mm_loadu_si128((__m128i *) &src(i + 1, 0)),
            fila_4 = _mm_loadu_si128((__m128i *) &src(i + 2, 0));

    int j;
    for (j = 2; j < width - 2; j += 4)
        actualizar_pixeles(src, dst, i, j, width, &fila_0, &fila_1, &fila_2, &fila_3, &fila_4);

    // corrijo los primeros 4 bytes de dst(i, j)
    fila_2 = _mm_loadu_si128((__m128i *) &src(i, j));
    _mm_storeu_si128((__m128i *) &dst(i, j), fila_2);
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