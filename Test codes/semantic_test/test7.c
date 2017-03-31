// Undeclared identifier because of scope

#include<stdio.h>

void main(){

	int a,b;
	a = 5;
	{
		int x = a;
	}
	{
		int z = x;
	}
}
