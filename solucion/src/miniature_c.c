#include <string.h>
#include "utils.h"
#include "tiempo.h"

#include <mmintrin.h>  // MMX
#include <xmmintrin.h> // SSE
#include <emmintrin.h> // SSE2
#include <pmmintrin.h> // SSE3
#include <tmmintrin.h> // SSSE3


/*  topPlane:
        Numero entre 0 y 1 que representa el porcentaje de imagen desde el cual
        va a comenzar la primera iteración de blur (habia arriba)

    bottomPlane:
        Numero entre 0 y 1 que representa el porcentaje de imagen desde el cual
        va a comenzar la primera iteración de blur (hacia abajo)

    iters:
        Cantidad de iteraciones. Por cada iteración se reduce el tamaño de
        ventana que deben blurear, con el fin de generar un blur más intenso
        a medida que se aleja de la fila centro de la imagen.
*/

#define     OFFSET_PX_RED           2
#define     OFFSET_PX_GREEN         1
#define     OFFSET_PX_BLUE          0

#define     red(arr, i, j)          ((arr)[(3 * (i)) * width + (3 * (j)) + OFFSET_PX_RED])
#define     green(arr, i, j)        ((arr)[(3 * (i)) * width + (3 * (j)) + OFFSET_PX_GREEN])
#define     blue(arr, i, j)         ((arr)[(3 * (i)) * width + (3 * (j)) + OFFSET_PX_BLUE])

#define     lin_index(i, j)         ((3 * (i)) * width + (3 * (j)))

void update_pixel(unsigned char *dst, int i, int j, unsigned char *src, int width)
{
    static int transf_mat[] = { 01, 05, 18,  05, 01,
                         05, 32, 64,  32, 05,
                         18, 64, 100, 64, 18,
                         05, 32, 64,  32, 05,
                         01, 05, 18,  05, 01 };
                         
    int red_accum = 0,
        green_accum = 0,
        blue_accum = 0;

    int di, dj, n = 0;
    for (di = -2; di < 3; ++di)
        for (dj = -2; dj < 3; ++dj)
        {
            red_accum += (transf_mat[n] * red(src, i + di, j + dj));
            green_accum += (transf_mat[n] * green(src, i + di, j + dj));
            blue_accum += (transf_mat[n] * blue(src, i + di, j + dj));

            ++n;     
        }

    red(dst, i, j) = (red_accum / 600);
    green(dst, i, j) = (green_accum / 600);
    blue(dst, i, j) = (blue_accum / 600);
}

void procesar_fila(__m128i *fila, __m128i *mat_fila, __m128i *sumas_parciales,
    __m128i *masc_descomp_rojos, __m128i *masc_descomp_verdes, __m128i *masc_descomp_azules, __m128i *masc_limpiar)
{
    __m128i sumas_fila;
    __m128i temp1, temp2;

    temp1 = _mm_shuffle_epi8(*fila, *masc_descomp_azules);
    temp1 = _mm_mullo_epi16(temp1, *mat_fila);
    temp2 = temp1;
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp1 = _mm_and_si128(temp1, *masc_limpiar);
    sumas_fila = temp1;

    temp1 = _mm_shuffle_epi8(*fila, *masc_descomp_verdes);
    temp1 = _mm_mullo_epi16(temp1, *mat_fila);
    temp2 = temp1;
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp1 = _mm_and_si128(temp1, *masc_limpiar);
    temp1 = _mm_slli_si128(temp1, 4);
    sumas_fila = _mm_or_si128(sumas_fila, temp1);

    temp1 = _mm_shuffle_epi8(*fila, *masc_descomp_rojos);
    temp1 = _mm_mullo_epi16(temp1, *mat_fila);
    temp2 = temp1;
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp2 = _mm_srli_si128(temp2, 2);
    temp1 = _mm_add_epi16(temp1, temp2);
    temp1 = _mm_and_si128(temp1, *masc_limpiar);
    temp1 = _mm_slli_si128(temp1, 8);
    sumas_fila = _mm_or_si128(sumas_fila, temp1);
    
    *sumas_parciales = _mm_add_epi32(*sumas_parciales, sumas_fila);
}

void modificar_pixel_del_medio(__m128i *fila3, __m128i *sumas_parciales,
                                __m128 *masc_denom, __m128i *masc_dw_a_px, __m128i *masc_medio, __m128i *masc_negacion)
{
    __m128 temp = _mm_cvtepi32_ps(*sumas_parciales);
    temp = _mm_mul_ps(temp, *masc_denom);
    *sumas_parciales = _mm_cvtps_epi32(temp);
    *sumas_parciales = _mm_shuffle_epi8(*sumas_parciales, *masc_dw_a_px);

    *fila3 = _mm_and_si128(*fila3, _mm_xor_si128(*masc_medio, *masc_negacion));
    *fila3 = _mm_add_epi8(*fila3, _mm_and_si128(*sumas_parciales, *masc_medio));
}

void update_pixel_sse(unsigned char *dst, int i, int j, unsigned char *src, int width)
{
    __m128i mat_fila_1 = _mm_set_epi16(0, 0, 0, 1,  5,  18,  5,  1);
    __m128i mat_fila_2 = _mm_set_epi16(0, 0, 0, 5,  32, 64,  32, 5);
    __m128i mat_fila_3 = _mm_set_epi16(0, 0, 0, 18, 64, 100, 64, 18);
    float mat_recip_suma = 1.0/600;

    __m128 masc_denom = _mm_load1_ps(&mat_recip_suma);
    __m128i masc_descomp_rojos = _mm_set_epi8(0x080,0x080,0x080,0x080,0x080,0x080,0x080,0x0E,0x080,0x0B,0x080,0x08,0x080,0x05,0x080,0x02);
    __m128i masc_descomp_verdes = _mm_set_epi8(0x080,0x080,0x080,0x080,0x080,0x080,0x080,0x0D,0x080,0x0A,0x080,0x07,0x080,0x04,0x080,0x01);
    __m128i masc_descomp_azules = _mm_set_epi8(0x080,0x080,0x080,0x080,0x080,0x080,0x080,0x0C,0x080,0x09,0x080,0x06,0x080,0x03,0x080,0x00);
    __m128i masc_limpiar = _mm_set_epi8(0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFF);
    __m128i masc_dw_a_px = _mm_set_epi8(0x080,0x080,0x080,0x080,0x080,0x080,0x080,0x08,0x04,0x00,0x080,0x080,0x080,0x080,0x080,0x80);
    __m128i masc_medio = _mm_set_epi8(0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00);
    __m128i masc_negacion = _mm_set_epi8(0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF);

    __m128i fila1, fila2, fila3, fila4, fila5;
    __m128i sumas_parciales = _mm_setzero_si128();    

    fila1 = _mm_loadu_si128((__m128i *)(dst + lin_index(i - 2, j - 2)));
    fila2 = _mm_loadu_si128((__m128i *)(dst + lin_index(i - 1, j - 2)));
    fila3 = _mm_loadu_si128((__m128i *)(dst + lin_index(i - 0, j - 2)));
    fila4 = _mm_loadu_si128((__m128i *)(dst + lin_index(i + 1, j - 2)));
    fila5 = _mm_loadu_si128((__m128i *)(dst + lin_index(i + 2, j - 2)));
    
    procesar_fila(&fila1, &mat_fila_1, &sumas_parciales, &masc_descomp_rojos, &masc_descomp_verdes, &masc_descomp_azules, &masc_limpiar);
    procesar_fila(&fila2, &mat_fila_2, &sumas_parciales, &masc_descomp_rojos, &masc_descomp_verdes, &masc_descomp_azules, &masc_limpiar);
    procesar_fila(&fila3, &mat_fila_3, &sumas_parciales, &masc_descomp_rojos, &masc_descomp_verdes, &masc_descomp_azules, &masc_limpiar);
    procesar_fila(&fila4, &mat_fila_2, &sumas_parciales, &masc_descomp_rojos, &masc_descomp_verdes, &masc_descomp_azules, &masc_limpiar);
    procesar_fila(&fila5, &mat_fila_1, &sumas_parciales, &masc_descomp_rojos, &masc_descomp_verdes, &masc_descomp_azules, &masc_limpiar);

    modificar_pixel_del_medio(&fila3, &sumas_parciales, &masc_denom, &masc_dw_a_px, &masc_medio, &masc_negacion);

    _mm_storeu_si128((__m128i *)(dst + lin_index(i - 0, j - 2)), fila3);
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

    int it, i , j;

    memcpy(dst, src, 3 * width * height);

    for (it = 0; it < iters; ++it)
    {
        for (i = 2; i <= top_plane; ++i)
            for (j = 2; j < width - 2; ++j)
                    update_pixel(dst, i, j, src, width);

        for (i = bottom_plane; i < height - 2; ++i)
            for (j = 2; j < width - 2; ++j)
                    update_pixel(dst, i, j, src, width);

        top_plane -= top_plane_delta;
        bottom_plane += bottom_plane_delta;

        memcpy(src, dst, 3 * width * height);
    }
}