%{
  #include <stdio.h>
  #include "y.tab.h"

  void display();
  void count_comment(char* s);
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

%%

{NEWLINE}   		              { yylineno++;display();}
{MULTI_LINE_COMMENT}					{ count_comment(yytext); }
{SINGLE_LINE_COMMENT}					{ /*do nothing*/ }
{LIBRARY} 		                { display(); }
{MACRO} 			                { display();  }
{NUMERIC_CONST}			          { display(); return CONSTANT; }

{STRING}			                { display(); return STRING_LITERAL; }
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


"char"			                  { display(); return CHAR; }
"int"			                    { display(); return INT; }
"void"			                  { display(); return VOID; }

"if"				                  { display(); return IF; }
"else"			                  { display(); return ELSE; }

"while"			                  { display(); return WHILE; }
"do"			                    { display(); return DO; }

"continue"		                { display(); return CONTINUE; }
"break"			                  { display(); return BREAK; }


"return"		                  { display(); return RETURN; }




"."			                      { display(); return('.'); }

{ARITHMETIC_OP}               { display(); return(yytext[0]);}

{IDENTIFIER}    		          { display(); return IDENTIFIER; }
[ \t\v\n\f]		                { display(); }
.			                        { return yytext[0]; }

%%

int yywrap(){
	return(1);
}

void display(){
	ECHO;
}

void count_comment(char* s){
  int i;
  for(i=0; s[i]!= '\0'; i++)
    if(s[i]=='\n')
      yylineno++;
}
