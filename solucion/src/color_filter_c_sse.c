#include <mmintrin.h>  // MMX
#include <xmmintrin.h> // SSE
#include <emmintrin.h> // SSE2
#include <pmmintrin.h> // SSE3
#include <tmmintrin.h> // SSSE3

#include "utils.h"
#include "tiempo.h"

void separar_pixeles(__m128i *data, __m128 *data_px1_f, __m128 *data_px2_f, __m128 *data_px3_f, __m128 *data_px4_f)
{
	__m128i temp = _mm_setzero_si128();
	
	*data_px1_f = _mm_castsi128_ps(*data);
	*data_px1_f = _mm_castsi128_ps(_mm_unpacklo_epi8(_mm_castps_si128(*data_px1_f), temp));
	*data_px1_f = _mm_castsi128_ps(_mm_unpacklo_epi16(_mm_castps_si128(*data_px1_f), temp));
	*data_px1_f = _mm_cvtepi32_ps(_mm_castps_si128(*data_px1_f));

	*data_px2_f = _mm_castsi128_ps(_mm_srli_si128(*data, 3));
	*data_px2_f = _mm_castsi128_ps(_mm_unpacklo_epi8(_mm_castps_si128(*data_px2_f), temp));
	*data_px2_f = _mm_castsi128_ps(_mm_unpacklo_epi16(_mm_castps_si128(*data_px2_f), temp));
	*data_px2_f = _mm_cvtepi32_ps(_mm_castps_si128(*data_px2_f));

	*data_px3_f = _mm_castsi128_ps(_mm_srli_si128(*data, 6));
	*data_px3_f = _mm_castsi128_ps(_mm_unpacklo_epi8(_mm_castps_si128(*data_px3_f), temp));
	*data_px3_f = _mm_castsi128_ps(_mm_unpacklo_epi16(_mm_castps_si128(*data_px3_f), temp));
	*data_px3_f = _mm_cvtepi32_ps(_mm_castps_si128(*data_px3_f));

	*data_px4_f = _mm_castsi128_ps(_mm_srli_si128(*data, 9));
	*data_px4_f = _mm_castsi128_ps(_mm_unpacklo_epi8(_mm_castps_si128(*data_px4_f), temp));
	*data_px4_f = _mm_castsi128_ps(_mm_unpacklo_epi16(_mm_castps_si128(*data_px4_f), temp));
	*data_px4_f = _mm_cvtepi32_ps(_mm_castps_si128(*data_px4_f));
}

void calcular_promedios(__m128 *data_px1_f, __m128 *data_px2_f, __m128 *data_px3_f, __m128 *data_px4_f, __m128i *promedios,
							__m128 *masc_denom_prom, __m128i *masc_limpiar, __m128i *masc_dw_a_px)
{
	__m128 temp;
	temp = *data_px1_f;
	temp = _mm_add_ss(temp, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(*data_px1_f), 4)));
	temp = _mm_add_ss(temp, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(*data_px1_f), 8)));
	temp = _mm_castsi128_ps(_mm_shuffle_epi8(_mm_castps_si128(temp), *masc_limpiar));
	*promedios = _mm_castps_si128(temp);

	temp = *data_px2_f;
	temp = _mm_add_ss(temp, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(*data_px2_f), 4)));
	temp = _mm_add_ss(temp, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(*data_px2_f), 8)));
	temp = _mm_castsi128_ps(_mm_shuffle_epi8(_mm_castps_si128(temp), *masc_limpiar));
	temp = _mm_castsi128_ps(_mm_slli_si128(_mm_castps_si128(temp), 4));
	*promedios = _mm_or_si128(*promedios, _mm_castps_si128(temp));

	temp = *data_px3_f;
	temp = _mm_add_ss(temp, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(*data_px3_f), 4)));
	temp = _mm_add_ss(temp, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(*data_px3_f), 8)));
	temp = _mm_castsi128_ps(_mm_shuffle_epi8(_mm_castps_si128(temp), *masc_limpiar));
	temp = _mm_castsi128_ps(_mm_slli_si128(_mm_castps_si128(temp), 8));
	*promedios = _mm_or_si128(*promedios, _mm_castps_si128(temp));

	temp = *data_px4_f;
	temp = _mm_add_ss(temp, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(*data_px4_f), 4)));
	temp = _mm_add_ss(temp, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(*data_px4_f), 8)));
	temp = _mm_castsi128_ps(_mm_shuffle_epi8(_mm_castps_si128(temp), *masc_limpiar));
	temp = _mm_castsi128_ps(_mm_slli_si128(_mm_castps_si128(temp), 12));
	*promedios = _mm_or_si128(*promedios, _mm_castps_si128(temp));

	*promedios = _mm_castps_si128(_mm_mul_ps(_mm_castsi128_ps(*promedios), *masc_denom_prom));
	*promedios = _mm_cvtps_epi32(_mm_castsi128_ps(*promedios));
	*promedios = _mm_shuffle_epi8(*promedios, *masc_dw_a_px);
}

void calcular_flags_comparacion(__m128 *data_px1_f, __m128 *data_px2_f, __m128 *data_px3_f, __m128 *data_px4_f, __m128i *flags,
							__m128 *masc_sustr, __m128 *masc_thres, __m128i *masc_limpiar, __m128i *masc_dw_a_px,
							unsigned char rc, unsigned char gc, unsigned char bc, int threshold)
{
	__m128 temp1, temp2;
	temp1 = _mm_sub_ps(*data_px1_f, *masc_sustr);
	temp1 = _mm_mul_ps(temp1, temp1);
	temp2 = temp1;
	temp2 = _mm_add_ss(temp2, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(temp1), 4)));
	temp2 = _mm_add_ss(temp2, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(temp1), 8)));
	temp2 = _mm_castsi128_ps(_mm_shuffle_epi8(_mm_castps_si128(temp2), *masc_limpiar));
	*flags = _mm_castps_si128(temp2);

	temp1 = _mm_sub_ps(*data_px2_f, *masc_sustr);
	temp1 = _mm_mul_ps(temp1, temp1);
	temp2 = temp1;
	temp2 = _mm_add_ss(temp2, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(temp1), 4)));
	temp2 = _mm_add_ss(temp2, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(temp1), 8)));
	temp2 = _mm_castsi128_ps(_mm_shuffle_epi8(_mm_castps_si128(temp2), *masc_limpiar));
	temp2 = _mm_castsi128_ps(_mm_slli_si128(_mm_castps_si128(temp2), 4));
	*flags = _mm_or_si128(*flags, _mm_castps_si128(temp2));

	temp1 = _mm_sub_ps(*data_px3_f, *masc_sustr);
	temp1 = _mm_mul_ps(temp1, temp1);
	temp2 = temp1;
	temp2 = _mm_add_ss(temp2, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(temp1), 4)));
	temp2 = _mm_add_ss(temp2, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(temp1), 8)));
	temp2 = _mm_castsi128_ps(_mm_shuffle_epi8(_mm_castps_si128(temp2), *masc_limpiar));
	temp2 = _mm_castsi128_ps(_mm_slli_si128(_mm_castps_si128(temp2), 8));
	*flags = _mm_or_si128(*flags, _mm_castps_si128(temp2));

	temp1 = _mm_sub_ps(*data_px4_f, *masc_sustr);
	temp1 = _mm_mul_ps(temp1, temp1);
	temp2 = temp1;
	temp2 = _mm_add_ss(temp2, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(temp1), 4)));
	temp2 = _mm_add_ss(temp2, _mm_castsi128_ps(_mm_srli_si128(_mm_castps_si128(temp1), 8)));
	temp2 = _mm_castsi128_ps(_mm_shuffle_epi8(_mm_castps_si128(temp2), *masc_limpiar));
	temp2 = _mm_castsi128_ps(_mm_slli_si128(_mm_castps_si128(temp2), 12));
	*flags = _mm_or_si128(*flags, _mm_castps_si128(temp2));

	*flags = _mm_castps_si128(_mm_cmpgt_ps(_mm_castsi128_ps(*flags), *masc_thres));
	*flags = _mm_shuffle_epi8(*flags, *masc_dw_a_px);
}

void actualizar_datos(__m128i *data, __m128i *promedios, __m128i *flags)
{
	__m128i temp;
	temp = _mm_xor_si128(temp, temp);
	temp = _mm_castpd_si128(_mm_cmpeq_pd(_mm_castsi128_pd(temp), _mm_castsi128_pd(temp)));

	*data = _mm_and_si128(*data, _mm_xor_si128(*flags, temp));
	*data = _mm_add_epi8(*data, _mm_and_si128(*promedios, *flags));
}

#define 		____ 		((char)0x80)

void color_filter_c(unsigned char *src,
                    unsigned char *dst,
                    unsigned char rc,
                    unsigned char gc,
                    unsigned char bc,
                    int threshold,
                    int width,
                    int height)
{
	float un_tercio = 1.0/3;
	float threshold_f = (float) threshold;
	float px_target[4] = {bc, gc, rc, 0};

	__m128 masc_denom_prom, masc_thres, masc_sustr;
	__m128i masc_limpiar, masc_dw_a_px;
	masc_denom_prom = _mm_load1_ps(&un_tercio);
	masc_thres = _mm_load1_ps(&threshold_f);
	masc_sustr = _mm_load_ps(px_target);
	masc_limpiar = _mm_set_epi8(____,____,____,____,____,____,____,____,____,____,____,____,0x03,0x02,0x01,0x00);
	masc_dw_a_px = _mm_set_epi8(____,____,____,____,0x0C,0x0C,0x0C,0x08,0x08,0x08,0x04,0x04,0x04,0x00,0x00,0x00);

	__m128i data, promedios, flags;
	__m128 data_px1_f, data_px2_f, data_px3_f, data_px4_f;
	int i = 0;
	for (i = 0; i < 3 * width * height; i += 12)
	{
		data = _mm_loadu_si128((__m128i *)(src + i));

		separar_pixeles(&data, &data_px1_f, &data_px2_f, &data_px3_f, &data_px4_f);

		calcular_flags_comparacion(&data_px1_f, &data_px2_f, &data_px3_f, &data_px4_f, &flags,
									&masc_sustr, &masc_thres, &masc_limpiar, &masc_dw_a_px,
									rc, gc, bc, threshold);

		calcular_promedios(&data_px1_f, &data_px2_f, &data_px3_f, &data_px4_f, &promedios,
									&masc_denom_prom, &masc_limpiar, &masc_dw_a_px);

		actualizar_datos(&data, &promedios, &flags);

		_mm_storeu_si128((__m128i *)(dst + i), data);
	}	
}