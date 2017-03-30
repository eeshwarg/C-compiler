// #include "hashtable.h"
#include<iostream>
using namespace std;
// typedef struct attr_s{
//   int ival;
//   char* id_name;
//   char* code;
//   type_e type;
// } attr_t;

class Expr {
public:
  char* var;
  type_e type;
  Expr(){var = NULL; type = Void;}

  Expr(char* lexeme){
    if(lexeme != NULL)
      var = strdup(lexeme);
  }

  Expr(int i){
    char tindex[4];
    sprintf(tindex, "t%d", i);
    var = strdup(tindex);
  }

  void gen(char* opcode, Expr* arg1, Expr* arg2){
    char inst[20];
    sprintf(inst, "%s = %s %s %s", var, arg1->var, opcode, arg2->var);
    cout << inst << endl;
  }

  void gen(Expr* arg1){
    char inst[20];
    sprintf(inst, "%s = %s", var, arg1->var);
    cout << inst << endl;
  }

  void gen(Expr* id, Expr* index, char* size){
    char inst[20];
    sprintf(inst, "%s = %s + %s * %s", var, id->var, index->var, size);
    cout << inst << endl;
  }

  void param(){
    char inst[20];
    sprintf(inst, "param %s", var);
    cout << inst << endl;
  }

  void call(Expr* proc, int n){
    char inst[20];
    sprintf(inst, "%s = call %s, %d", var, proc->var, n);
    cout << inst << endl;
  }

  void set_array(Expr* id, Expr* index){
    sprintf(var, "%s[%s]", id->var, index->var);
  }
};

Expr* newTemp(char* lexeme){
  return new Expr(lexeme);
}

Expr* newTemp(int i){
  return new Expr(i);
}
