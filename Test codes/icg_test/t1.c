#include<stdio.h>

int main() {
  int n = 5;
  while(n > 0){
    int in_loop_one = 1;
    do{
      int in_loop_two = in_loop_one + n;
      // break;
      if(n < 0)
        n++;
    }while(n>0);
  }
  return 0;
}
