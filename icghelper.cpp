// #include "hashtable.h"
#include<iostream>
using namespace std;

/*
  Expr stores the data required for intermediate code generation. It also provides methods for the actual generation of code.
*/

class Expr {
public:
  //var stores the variable name which holds the results of the possible instructions below
  char* var;
  //type stores the datatype information of the variable. Can be Int, Char, Void. Look at enum type_e defined in hashtable.h for definition.
  type_e type;
  Expr(){var = NULL; type = Void;}

  //When var references a variable defined in the source code
  Expr(char* lexeme){
    if(lexeme != NULL)
      var = strdup(lexeme);
  }

  //When var references a new temporary variable corresponding to a register
  Expr(int i){
    char tindex[4];
    sprintf(tindex, "t%d", i);
    var = strdup(tindex);
  }

  //generates instruction for expressions
  void gen(char* opcode, Expr* arg1, Expr* arg2){
    char inst[20];
    sprintf(inst, "%s = %s %s %s", var, arg1->var, opcode, arg2->var);
    cout << inst << endl;
  }

  //generates instruction for assignment
  void gen(Expr* arg1){
    char inst[20];
    sprintf(inst, "%s = %s", var, arg1->var);
    cout << inst << endl;
  }

  //generates a temporary to handle correct index calculation for array accesses
  void gen(Expr* id, Expr* index, char* size){
    char inst[20];
    sprintf(inst, "%s = %s + %s * %s", var, id->var, index->var, size);
    cout << inst << endl;
  }

  //sets the var as a parameter for a future function call
  void param(){
    char inst[20];
    sprintf(inst, "param %s", var);
    cout << inst << endl;
  }

  //calls a function referenced by proc, having n parameters and stores result in var
  void call(Expr* proc, int n){
    char inst[20];
    sprintf(inst, "%s = call %s, %d", var, proc->var, n);
    cout << inst << endl;
  }

  //sets var to hold both array name and the index together as one string for easy referencing later
  void set_array(Expr* id, Expr* index){
    sprintf(var, "%s[%s]", id->var, index->var);
  }
};

//returns a reference to actual variable defined in source code
Expr* newTemp(char* lexeme){
  return new Expr(lexeme);
}

//returns a reference to a register variable
Expr* newTemp(int i){
  return new Expr(i);
}
