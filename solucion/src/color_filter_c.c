#include <mmintrin.h>  // MMX
#include <xmmintrin.h> // SSE
#include <emmintrin.h> // SSE2
#include <pmmintrin.h> // SSE3
#include <tmmintrin.h> // SSSE3

#include "utils.h"
#include "tiempo.h"

extern unsigned long int get_timestamp();

typedef union float4{
    __m128		x;
    float		v[4];
} float4;

typedef union dword4{
    __m128i		x;
    int		v[4];
} dword4;

typedef union word8{
    __m128i		x;
    short		v[8];
} word8;

typedef union byte16{
    __m128i		x;
    char		v[16];
} byte16;

void print_vector_f (__m128 x){
	float4 u; u.x = x;
    printf("(f) %f,%f,%f,%f\n", u.v[0], u.v[1], u.v[2], u.v[3]);
}

void print_vector_dw (__m128i x){
	dword4 u; u.x = x;
    printf("(dw) %d,%d,%d,%d\n", u.v[0], u.v[1], u.v[2], u.v[3]);
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

void color_filter_c(unsigned char *src,
                    unsigned char *dst,
                    unsigned char rc,
                    unsigned char gc,
                    unsigned char bc,
                    int threshold,
                    int width,
                    int height)
{
	unsigned long int time_begin, time_end;

	time_begin = get_timestamp();


	float un_tercio = 1.0/3;
	float threshold_f = (float) threshold;
	float px_target[4] = {bc, gc, rc, 0};

	__m128 masc_denom_prom, masc_thres, masc_sustr;
	__m128i masc_limpiar, masc_dw_a_px;
	masc_denom_prom = _mm_load1_ps(&un_tercio);
	masc_thres = _mm_load1_ps(&threshold_f);
	masc_sustr = _mm_load_ps(px_target);
	masc_limpiar = _mm_set_epi8((char)0x80,(char)0x80,(char)0x80,(char)0x80,(char)0x80,(char)0x80,(char)0x80,(char)0x80,(char)0x80,(char)0x80,(char)0x80,(char)0x80,(char)0x03,(char)0x02,(char)0x01,(char)0x00);
	masc_dw_a_px = _mm_set_epi8((char)0x80,(char)0x80,(char)0x80,(char)0x80,(char)0x0C,(char)0x0C,(char)0x0C,(char)0x08,(char)0x08,(char)0x08,(char)0x04,(char)0x04,(char)0x04,(char)0x00,(char)0x00,(char)0x00);
	/* (5) masc_denom_prom, masc_thres, masc_sustr, masc_limpiar, masc_dw_a_px */

	__m128i data, promedios, flags;
	__m128 data_px1_f, data_px2_f, data_px3_f, data_px4_f;
	int i = 0;
	for (i = 0; i < 3 * width * height; i += 12)
	{
		data = _mm_loadu_si128((__m128i *)(src + i));
		/* (6) data, masc_denom_prom, masc_thres, masc_sustr, masc_limpiar, masc_dw_a_px */

		separar_pixeles(&data, &data_px1_f, &data_px2_f, &data_px3_f, &data_px4_f);
		/* (10) data, px1, px2, px3, px4, masc_denom_prom, masc_thres, masc_sustr, masc_limpiar, masc_dw_a_px */

		calcular_flags_comparacion(&data_px1_f, &data_px2_f, &data_px3_f, &data_px4_f, &flags,
									&masc_sustr, &masc_thres, &masc_limpiar, &masc_dw_a_px,
									rc, gc, bc, threshold);
		/* (11) data, px1, px2, px3, px4, flags, masc_denom_prom, masc_thres, masc_sustr, masc_limpiar, masc_dw_a_px */

		calcular_promedios(&data_px1_f, &data_px2_f, &data_px3_f, &data_px4_f, &promedios,
									&masc_denom_prom, &masc_limpiar, &masc_dw_a_px);
		/* (12) data, flags, promedios, masc_denom_prom, masc_thres, masc_sustr, masc_limpiar, masc_dw_a_px */

		actualizar_datos(&data, &promedios, &flags);
		/* (6) data, masc_denom_prom, masc_thres, masc_sustr, masc_limpiar, masc_dw_a_px */

		_mm_storeu_si128((__m128i *)(dst + i), data);
		/* (5) masc_denom_prom, masc_thres, masc_sustr, masc_limpiar, masc_dw_a_px */
	}	

	time_end = get_timestamp();
	
	printf("{ 'total_before': %lu, 'total_after': %lu }, ", time_begin, time_end);
}
