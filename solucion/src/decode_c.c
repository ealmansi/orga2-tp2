# define _mask_23 0x0C
# define _mask_01 0x03
# define _negation_mask 0x03

extern unsigned long int get_timestamp();

void decode_c(unsigned char* src,
              unsigned char* code,
			  int size,
              int width,
              int height)
{
	unsigned long int total_before, total_after, comparaciones_before, comparaciones_after;

	total_before=get_timestamp();
	


	int j=0;// Contador para src
	int k=0;// Contador para code. no pueden ser el mismo porque este avanza 4 veces mas lento.

	while (j<width*height*3 && k<size) { //La única manera de salir del ciclo es que el string termine, como es de C se sabe que termina en NULL

		char partial_result = 0; // partial_result es un byte que se va a ir llenando de a poco.
		for(int bit_shift=0 ; bit_shift <=6 ; bit_shift+=2){ //bit_shift indica cuantos bits debe moverse a izquierda el bit actual. Se aumenta de a 2 y va de 0 a 6
			char a,b; // Se van a nacesitar 2 copias del byte
			a = src[j];

			b = a;

			a = a & _mask_23; //Una para los bits 2 y 3
			b = b & _mask_01; // y otra para los bits 0 y 1


			comparaciones_before = get_timestamp();
			if (a==0x04){ //Según el valor de a se decide que hacer.
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
			comparaciones_after = get_timestamp();
			b = b << bit_shift; //Se mueven los bits 1 y 0 al lugar correspondiente
			partial_result = partial_result + b; //se acumula el cacho de biy en partial result
			j++; //Se avanza el contador de src.
		}
		code[k]= partial_result; //Una vez que se tiene una partial result se lo acumula en code
		k++;
	//	printf(" %d %d ",j,k);
	//	if(partial_result==0){ //Si se llegó al null del final del string se terminó.
	//		break;
	//	}
	}


	
	total_after=get_timestamp();

	printf("[{'total_before':%lu, 'total_after':%lu, 'comparaciones_before':%lu, 'comparaciones_after':%lu}]\n", total_before, total_after,comparaciones_before, comparaciones_after);
}
