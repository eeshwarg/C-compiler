// To demonstrate ICG for functions

#include <stdio.h>

int sum(int a, int b)
{
  return a + b;
}

void func(){
  //do nothing
  int n = 1;
}

int main()
{
  int x = 1, y = 3;
  int z = sum(x,y);
  func();
  return 0;
}
