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
int yylineno;
#include <stdio.h>
#include "y.tab.h"

void display();
%}

%%

{NEWLINE}   		              { yylineno++;display();}
{MULTI_LINE_COMMENT}					{ count_comment(yytext); }
{SINGLE_LINE_COMMENT}					{ /*do nothing*/ }
{LIBRARY} 		                { display();}
{MACRO} 			                { display(); tabulate_token(yytext,"Constant"); return DEF;}
{NUMERIC_CONST}			          { display(); tabulate_token(yytext,"Constant"); return CONSTANT; }

{STRING}			                { display(); tabulate_token(yytext,"Constant"); return STRING_LITERAL; }
{INCOMPLETE_STRING}           { display(); yyerror("<- Error! Incomplete string"); exit(1);}

{SYMBOL}                      { display(); return(yytext[0]);}
=			                        { display(); return '='; }

"++"|"--"	                    { display(); return INC_DEC_OP; }
"<<"|">>"	                    { display(); return SHIFT_OP; }
"<="|">="	                    { display(); return LE_GE_OP; }
"=="|"!="	                    { display(); return EQ_NE_OP; }

"&&"			                    { display(); return AND_OP; }
"||"			                    { display(); return OR_OP; }

"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="	{ display(); return OP_ASSIGN; }


"char"			                  { display(); tabulate_token(yytext,"Keyword"); return CHAR; }
"int"			                    { display(); tabulate_token(yytext,"Keyword"); return INT; }
"signed"		                  { display(); tabulate_token(yytext,"Keyword"); return SIGNED; }
"unsigned"		                { display(); tabulate_token(yytext,"Keyword"); return UNSIGNED; }
"const"|"volatile"			      { display(); tabulate_token(yytext,"Keyword"); return TYPE_QUALIFIER; }
"void"			                  { display(); tabulate_token(yytext,"Keyword"); return VOID; }

"if"				                  { display(); tabulate_token(yytext,"Keyword"); return IF; }
"else"			                  { display(); tabulate_token(yytext,"Keyword"); return ELSE; }

"while"			                  { display(); tabulate_token(yytext,"Keyword"); return WHILE; }
"do"			                    { display(); tabulate_token(yytext,"Keyword"); return DO; }

"continue"		                { display(); tabulate_token(yytext,"Keyword"); return CONTINUE; }
"break"			                  { display(); tabulate_token(yytext,"Keyword"); return BREAK; }

"goto"			                  { display(); tabulate_token(yytext,"Keyword"); return GOTO; }

"return"		                  { display(); tabulate_token(yytext,"Keyword"); return RETURN; }




"."			                      { display(); return('.'); }

{UNARY_OP}			              { display(); tabulate_token(yytext,"Operator"); return UNARY_OP; }
{ARITHMETIC_OP}               { display(); tabulate_token(yytext,"Operator"); return(yytext[0]);}

"<"|">"			                  { display(); return LG_OP; }
"^"			                      { display(); return('^'); }
"|"			                      { display(); return('|'); }
"?"			                      { display(); return('?'); }
{IDENTIFIER}    		          { display(); tabulate_token(yytext,"Identifier"); return IDENTIFIER; }
[ \t\v\n\f]		                { display(); }
.			                        { /* ignore bad characters */ }

%%

yywrap(){
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
