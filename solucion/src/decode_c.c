# define _mask_23 0x0C
# define _mask_01 0x03
# define _negation_mask 0x03


void decode_c(unsigned char* src,
              unsigned char* code,
			  int size,
              int width,
              int height)
{
	
	int j=0;
	int k=0;

	while (1) {

		char partial_result = 0;
		for(int bit_shift=6 ; bit_shift >=0 ; bit_shift-=2){
			char a,b;
			a = src[j];

			b = a;

			a = a & _mask_23;
			b = b & _mask_01;

			if (a==0x04){
				b=b+1;
				b=b & _mask_01;
			}

			if (a== 0x08 ) {
				b=b-1;
				b=b & _mask_01;
			}
			if (a== 0xc){
				b= b ^ _negation_mask;
			}
			b = b << bit_shift;
			partial_result = partial_result + b;
			j++;
		}
		code[k]= partial_result;
		k++;
		if(partial_result==0){
			break;
		}
	}


	





}
