#include "utils.h"
#include "tiempo.h"

#define 		MAX_THRESHOLD 		442				// techo(raiz(3) * 255)

void color_filter_c(unsigned char *src,
                    unsigned char *dst,
                    unsigned char rc,
                    unsigned char gc,
                    unsigned char bc,
                    int threshold,
                    int width,
                    int height)
{
	TIMER_BEGIN();

	threshold = MIN(MAX(0, threshold), MAX_THRESHOLD);
	int threshold_2 = threshold * threshold;

	TIMER_PRINT_STATUS("antes_del_ciclo");
	unsigned char r, g, b, diff_r, diff_g, diff_b;
	for (int i = 0; i < 3 * width * height; i += 3)
	{
		diff_r = (r = src[i + 0]) - rc;
		diff_g = (g = src[i + 1]) - gc;
		diff_b = (b = src[i + 2]) - bc;

		if(diff_r * diff_r + diff_g * diff_g + diff_b * diff_b > threshold_2)
			r = g = b = ((r + g + b) / 3);

		dst[i + 0] = r;
		dst[i + 1] = g;
		dst[i + 2] = b;
	}
	TIMER_PRINT_STATUS("despues_del_ciclo");

	TIMER_END();
}
