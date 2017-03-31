// Type mismatch within expressions

#include<stdio.h>

void main(){
	int a = 2, b;
	char d = '1';
	b = 6;
  int g = a*b;
	b = b & d;
	int h = a*d;
}
