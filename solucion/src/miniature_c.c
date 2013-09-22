#include <string.h>
#include <stdio.h>
#include "utils.h"
#include "tiempo.h"

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

static inline void update_pixel(unsigned char *dst, int i, int j, unsigned char *src, int width)
{
    int transf_mat[] = { 01,  05,  18,  05,  01,
                         05,  32,  64,  32,  05,
                         18,  64, 100,  64,  18,
                         05,  32,  64,  32,  05,
                         01,  05,  18,  05,  01 };
    int  red_accum = 0,
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

    red(dst, i, j) = (red_accum/600);
    green(dst, i, j) = (green_accum/600);
    blue(dst, i, j) = (blue_accum/600);
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