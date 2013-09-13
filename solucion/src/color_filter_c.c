#include "utils.h"
#include "tiempo.h"

#define 	OFFSET_RED			2
#define 	OFFSET_GREEN		1
#define 	OFFSET_BLUE			0

#define 	red(arr, i) 		((arr)[(i) + OFFSET_RED])
#define 	green(arr, i) 		((arr)[(i) + OFFSET_GREEN])
#define 	blue(arr, i) 		((arr)[(i) + OFFSET_BLUE])

void color_filter_c(unsigned char *src,
                    unsigned char *dst,
                    unsigned char rc,
                    unsigned char gc,
                    unsigned char bc,
                    int threshold,
                    int width,
                    int height)
{
	int r, g, b, diff_r, diff_g, diff_b, dist;
	for (int i = 0; i < 3 * width * height; i += 3)
	{
		r = red(src, i);
		g = green(src, i);
		b = blue(src, i);

		diff_r = r - rc;
		diff_g = g - gc;
		diff_b = b - bc;
		dist = diff_r * diff_r + diff_g * diff_g + diff_b * diff_b;

		if(dist > threshold)
			r = g = b = ((r + g + b) / 3);

		red(dst, i) = r;
		green(dst, i) = g;
		blue(dst, i) = b;
	}
}