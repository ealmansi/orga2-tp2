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

void acumular_fila(__m128i *fila_0, __m128i *mat_fila_0_A, __m128i *mat_fila_0_B,
                __m128i *acum_r, __m128i *acum_g, __m128i *acum_b)
{
    __m128i masc_extraer_r_A = _mm_set_epi8(____,0x05,____,0x02,____,0x05,____,0x02,____,0x05,____,0x02,____,0x05,____,0x02),
            masc_extraer_r_B = _mm_set_epi8(____,0x0B,____,0x08,____,0x0B,____,0x08,____,0x0B,____,0x08,____,0x0B,____,0x08),
            masc_extraer_g_A = _mm_set_epi8(____,0x04,____,0x01,____,0x04,____,0x01,____,0x04,____,0x01,____,0x04,____,0x01),
            masc_extraer_g_B = _mm_set_epi8(____,0x0A,____,0x07,____,0x0A,____,0x07,____,0x0A,____,0x07,____,0x0A,____,0x07),
            masc_extraer_b_A = _mm_set_epi8(____,0x03,____,0x00,____,0x03,____,0x00,____,0x03,____,0x00,____,0x03,____,0x00),
            masc_extraer_b_B = _mm_set_epi8(____,0x09,____,0x06,____,0x09,____,0x06,____,0x09,____,0x06,____,0x09,____,0x06);

    __m128i temp_A, temp_B;

    temp_A = _mm_shuffle_epi8(*fila_0, masc_extraer_r_A);
    temp_B = _mm_shuffle_epi8(*fila_0, masc_extraer_r_B);
    temp_A = _mm_madd_epi16(temp_A, *mat_fila_0_A);
    temp_B = _mm_madd_epi16(temp_B, *mat_fila_0_B);
    temp_A = _mm_add_epi32(temp_A, temp_B);
    *acum_r = _mm_add_epi32(*acum_r, temp_A);

    temp_A = _mm_shuffle_epi8(*fila_0, masc_extraer_g_A);
    temp_B = _mm_shuffle_epi8(*fila_0, masc_extraer_g_B);
    temp_A = _mm_madd_epi16(temp_A, *mat_fila_0_A);
    temp_B = _mm_madd_epi16(temp_B, *mat_fila_0_B);
    temp_A = _mm_add_epi32(temp_A, temp_B);
    *acum_g = _mm_add_epi32(*acum_g, temp_A);

    temp_A = _mm_shuffle_epi8(*fila_0, masc_extraer_b_A);
    temp_B = _mm_shuffle_epi8(*fila_0, masc_extraer_b_B);
    temp_A = _mm_madd_epi16(temp_A, *mat_fila_0_A);
    temp_B = _mm_madd_epi16(temp_B, *mat_fila_0_B);
    temp_A = _mm_add_epi32(temp_A, temp_B);
    *acum_b = _mm_add_epi32(*acum_b, temp_A);
}

void acumular_sumas_parciales_izq(__m128i *fila_0, __m128i *fila_1, __m128i *fila_2, __m128i *fila_3, __m128i *fila_4,
                                    __m128i *acum_r, __m128i *acum_g, __m128i *acum_b)
{
    __m128i mat_fila_0_A = _mm_set_epi16(0,     0,      0,     0,      1,     0,      5,     1),
            mat_fila_0_B = _mm_set_epi16(1,     0,      5,     18,     1,     5,      5,     18),
            mat_fila_1_A = _mm_set_epi16(0,     0,      0,     0,      0,     0,      0,     0),
            mat_fila_1_B = _mm_set_epi16(0,     0,      0,     0,      0,     0,      0,     0),
            mat_fila_2_A = _mm_set_epi16(0,     0,      0,     0,      0,     0,      0,     0),
            mat_fila_2_B = _mm_set_epi16(0,     0,      0,     0,      0,     0,      0,     0);

    acumular_fila(fila_0, &mat_fila_0_A, &mat_fila_0_B, acum_r, acum_g, acum_b);
    acumular_fila(fila_1, &mat_fila_1_A, &mat_fila_1_B, acum_r, acum_g, acum_b);
    acumular_fila(fila_2, &mat_fila_2_A, &mat_fila_2_B, acum_r, acum_g, acum_b);
    acumular_fila(fila_3, &mat_fila_1_A, &mat_fila_1_B, acum_r, acum_g, acum_b);
    acumular_fila(fila_4, &mat_fila_0_A, &mat_fila_0_B, acum_r, acum_g, acum_b);
}

void acumular_sumas_parciales_der(__m128i *fila_0, __m128i *fila_1, __m128i *fila_2, __m128i *fila_3, __m128i *fila_4,
                                    __m128i *acum_r, __m128i *acum_g, __m128i *acum_b)
{

}

void generar_pixeles(__m128i *acum_r, __m128i *acum_g, __m128i *acum_b)
{

}

void actualizar_pixels(unsigned char *src, unsigned char *dst, int i, int j, int width,
                        __m128i *fila_0, __m128i *fila_1, __m128i *fila_2, __m128i *fila_3, __m128i *fila_4)
{
    __m128i acum_r, acum_g, acum_b;
    acum_r = acum_g = acum_b = _mm_setzero_si128();

    acumular_sumas_parciales_izq(fila_0, fila_1, fila_2, fila_3, fila_4, &acum_r, &acum_g, &acum_b);

    *fila_0 = _mm_loadu_si128((__m128i *) &src(i - 2, j + 2));
    *fila_1 = _mm_loadu_si128((__m128i *) &src(i - 1, j + 2));
    *fila_2 = _mm_loadu_si128((__m128i *) &src(i + 0, j + 2));
    *fila_3 = _mm_loadu_si128((__m128i *) &src(i + 1, j + 2));
    *fila_4 = _mm_loadu_si128((__m128i *) &src(i + 2, j + 2));

    acumular_sumas_parciales_izq(fila_0, fila_1, fila_2, fila_3, fila_4, &acum_r, &acum_g, &acum_b);

    generar_pixeles(&acum_r, &acum_g, &acum_b);

    // _mm_storeu_si128((__m128i *) &dst(i, j), resultado);
}

void procesar_fila(unsigned char *src, unsigned char *dst, int i, int width)
{
    __m128i fila_0 = _mm_loadu_si128((__m128i *) &src(i - 2, 2)),
            fila_1 = _mm_loadu_si128((__m128i *) &src(i - 1, 2)),
            fila_2 = _mm_loadu_si128((__m128i *) &src(i + 0, 2)),
            fila_3 = _mm_loadu_si128((__m128i *) &src(i + 1, 2)),
            fila_4 = _mm_loadu_si128((__m128i *) &src(i + 2, 2));

    int j;
    for (j = 2; j < width - 2; j += 4)
        actualizar_pixels(src, dst, i, j, width, &fila_0, &fila_1, &fila_2, &fila_3, &fila_4);
}

void copiar_bordes_no_procesados(unsigned char *src, unsigned char *dst, int width, int height)
{

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

    int it, i;

    for (it = 0; it < iters; ++it)
    {
        for (i = 2; i <= top_plane; ++i)
            procesar_fila(src, dst, i, width);
            
        for (i = bottom_plane; i < height - 2; ++i)
            procesar_fila(src, dst, i, width);

        copiar_bordes_no_procesados(src, dst, width, height);

        top_plane -= top_plane_delta;
        bottom_plane += bottom_plane_delta;

        memcpy(src, dst, 3 * width * height);
    }
}

