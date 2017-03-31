// To demonstrate ICG for conditional and looping statements

#include<stdio.h>

int main() {
  int i = 3,j,n = 5;
  while(n > 0){
    int in_loop_one = 1;
    do{
      int in_loop_two = in_loop_one + n;
      if(n < 0)
        n++;
    }while(n>0);
    if(in_loop_one == n)
      n = i + 4;
    else
    {
      i = j * 5;
      n = i + j;
    }
  }
  return 0;
}
