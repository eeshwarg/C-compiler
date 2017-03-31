//Type mismatch
#include <stdio.h>
#define A 5

void main ()
{
	int a = 9 , b = 6, c=1;
	char d = c;

	if(a>c){
		b = a;
	}
	else{
		b = c;
	}

}
