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

void miniature_c(
                unsigned char *src,
                unsigned char *dst,
                int width, int height,
                float topPlane, float bottomPlane,
                int iters) {

    TIMER_BEGIN();

    TIMER_PRINT_STATUS("t0");

    for (int i = 0; i < 2 * width * height; ++i)
        dst[i] = src[i];

    TIMER_PRINT_STATUS("t1");

    for (int i = 2 * width * height; i < 3 * width * height; ++i)
        dst[i] = MIN(255, 3 * src[i]);

    TIMER_PRINT_STATUS("t2");

    TIMER_END();
}