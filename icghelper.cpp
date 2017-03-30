// #include "hashtable.h"
#include<string>

// typedef struct attr_s{
//   int ival;
//   char* id_name;
//   char* code;
//   type_e type;
// } attr_t;

class Expr {
  char* var;
  type_e type;

  public:
    Expr(){var = NULL; type = Void;}

    Expr(char* lexeme){
      if(lexeme != NULL)
        var = strdup(lexeme);
    }

    Expr(int i){
      char* tempvar = "t";
      char index[3];
      sprintf(index, "%d", i);
      var = strcat(tempvar, index);
    }

    void gen(char opcode, Expr* arg1, Expr* arg2){
      char inst[20];
      sprintf(inst, "%s = %s %c %s", var, arg1->var, opcode, arg2->var);
      printf("%s", inst);
    }
};

Expr* newTemp(char* lexeme){
  return new Expr(lexeme);
}

Expr* newTemp(int i){
  return new Expr(i);
}
