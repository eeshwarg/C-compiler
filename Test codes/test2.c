// To demonstrate use of functions

#include <stdio.h>

int sum(int a, int b)
{
  int s = a + b;
  return s;
}

void func(){
  //do nothing
}

int main()
{
  int x = 1, y = 3;
  int z = sum(x,y);
  func();
  return 0;
}
