%{
  #include "hashtable.h"
  extern hashtable_t *ht = NULL;
  void tabulate_token(char* lexeme, char* token);
  void count_comment(char* s);
  void print_token(char *token);
%}


SINGLE_LINE_COMMENT   \/\/(.*)
MULTI_LINE_COMMENT    \/\*(.|\n)*\*\/

LETTER 			          [A-Za-z]
LETTER_			          {LETTER}|_
WHITESPACE	          [ \t]+
LIBRARY			          #include{WHITESPACE}*[<"]{LETTER_}+\.h[>"]

fl					          (f|F|l|L)
ul					          (u|U|l|L)
hex					          [a-fA-F0-9]
EXP					          [Ee][+-]?{DIGITS}
DIGIT				          [0-9]
DIGITS			          {DIGIT}+
NUMBER			          {DIGIT}*(\.{DIGITS})?{EXP}?
NUMERIC_CONST         {NUMBER}|{NUMBER}{ul}|0{DIGITS}{ul}?|0[xX]{hex}+{ul}?

ARITHMETIC_OP   			"+"|"-"|"/"|"*"|"%"
UNARY_OP        			"&"|"!"|"~"
LOGICAL_OP      			\!|\&\&|\|\|
COMPARISON_OP   			\>|\<|\=\=|\!\=|\>\=|\<\=
ASSIGNMENT_OP         "="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="
OPERATOR  						{UNARY_OP}|{LOGICAL_OP}|{COMPARISON_OP}|{ASSIGNMENT_OP}|{ARITHMETIC_OP}

STRING			          \".*\"
INCOMPLETE_STRING			\"[^\"\n]*

IDENTIFIER	          {LETTER_}({LETTER_}|{DIGIT})*
NEWLINE			          \n
MACRO 			          #define({WHITESPACE}){IDENTIFIER}(.)+

SYMBOL                "("|")"|"{"|"}"|";"|":"|","|"["|"]"

%{
// int yylineno;
#include <stdio.h>
#include "y.tab.h"

void display();
%}

%%

{NEWLINE}   		              { yylineno++;display();}
{MULTI_LINE_COMMENT}					{ count_comment(yytext); }
{SINGLE_LINE_COMMENT}					{ /*do nothing*/ }
{LIBRARY} 		                { display(); }
{MACRO} 			                { display(); tabulate_token(yytext,"Constant"); }
{NUMERIC_CONST}			          { display(); tabulate_token(yytext,"Constant"); return CONSTANT; }

{STRING}			                { display(); tabulate_token(yytext,"Constant"); return STRING_LITERAL; }
{INCOMPLETE_STRING}           { display(); yyerror("<- Error! Incomplete string"); exit(1);}

{SYMBOL}                      { display(); return(yytext[0]);}
=			                        { display(); return '='; }

"--"	                        { display(); return DEC_OP; }
"++"                          { display(); return INC_OP; }
"<<"    	                    { display(); return LEFT_OP; }
">>"                          { display(); return RIGHT_OP; }
"<="    	                    { display(); return LE_OP; }
">="    	                    { display(); return GE_OP; }
"=="                          { display(); return EQ_OP; }
"!="	                        { display(); return NE_OP; }

"&&"			                    { display(); return AND_OP; }
"||"			                    { display(); return OR_OP; }

"*="                          { display(); return MUL_ASSIGN; }
"/="                          { display(); return DIV_ASSIGN; }
"%="                          { display(); return MOD_ASSIGN; }
"+="                          { display(); return ADD_ASSIGN; }
"-="                          { display(); return SUB_ASSIGN; }
"<<="                         { display(); return LEFT_ASSIGN; }
">>="                         { display(); return RIGHT_ASSIGN; }
"&="                          { display(); return AND_ASSIGN; }
"^="                          { display(); return XOR_ASSIGN; }
"|="                        	{ display(); return OR_ASSIGN; }


"char"			                  { display(); tabulate_token(yytext,"Keyword"); return CHAR; }
"int"			                    { display(); tabulate_token(yytext,"Keyword"); return INT; }
"void"			                  { display(); tabulate_token(yytext,"Keyword"); return VOID; }

"if"				                  { display(); tabulate_token(yytext,"Keyword"); return IF; }
"else"			                  { display(); tabulate_token(yytext,"Keyword"); return ELSE; }

"while"			                  { display(); tabulate_token(yytext,"Keyword"); return WHILE; }
"do"			                    { display(); tabulate_token(yytext,"Keyword"); return DO; }

"continue"		                { display(); tabulate_token(yytext,"Keyword"); return CONTINUE; }
"break"			                  { display(); tabulate_token(yytext,"Keyword"); return BREAK; }


"return"		                  { display(); tabulate_token(yytext,"Keyword"); return RETURN; }




"."			                      { display(); return('.'); }

{ARITHMETIC_OP}               { display(); tabulate_token(yytext,"Operator"); return(yytext[0]);}

{IDENTIFIER}    		          { display(); tabulate_token(yytext,"Identifier"); return IDENTIFIER; }
[ \t\v\n\f]		                { display(); }
.			                        { return yytext[0]; }

%%

int yywrap(){
	return(1);
}

void display(){
	ECHO;
}

void tabulate_token(char* lexeme, char* token){
  if(ht==NULL){
    ht = ht_create(100);
  }
  if(ht_get(ht, lexeme) == NULL){
    ht_set(ht, lexeme, token);
  }
}

void count_comment(char* s){
  int i;
  for(i=0; s[i]!= '\0'; i++)
    if(s[i]=='\n')
      yylineno++;
}
