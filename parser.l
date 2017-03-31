%{
  #include <stdio.h>
  #include "y.tab.h"
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

CHARACTER             \'.\'
STRING			          \".*\"
INCOMPLETE_STRING			\"[^\"\n]*

IDENTIFIER	          {LETTER_}({LETTER_}|{DIGIT})*
NEWLINE			          \n
MACRO 			          #define({WHITESPACE}){IDENTIFIER}(.)+

SYMBOL                "("|")"|"{"|"}"|";"|":"|","|"["|"]"

%%

{NEWLINE}   		              { yylineno++;}
{MULTI_LINE_COMMENT}					{ count_comment(yytext); }
{SINGLE_LINE_COMMENT}
{LIBRARY}
{MACRO}
{NUMERIC_CONST}			          { yylval.E = newTemp(yytext); yylval.E->type = Int; return CONSTANT; }

{CHARACTER}                   { yylval.E = newTemp(yytext); yylval.E->type = Char; return CHAR_CONST; }
{STRING}			                { return STRING_LITERAL; }
{INCOMPLETE_STRING}           { yyerror("<- Error! Incomplete string"); exit(1);}

{SYMBOL}                      { return(yytext[0]);}
=			                        { return('='); }

"--"	                        { return DEC_OP; }
"++"                          { return INC_OP; }
"<<"    	                    { return LEFT_OP; }
">>"                          { return RIGHT_OP; }
"<="    	                    { return LE_OP; }
">="    	                    { return GE_OP; }
"=="                          { return EQ_OP; }
"!="	                        { return NE_OP; }

"&&"			                    { return AND_OP; }
"||"			                    { return OR_OP; }

"*="                          { return MUL_ASSIGN; }
"/="                          { return DIV_ASSIGN; }
"%="                          { return MOD_ASSIGN; }
"+="                          { return ADD_ASSIGN; }
"-="                          { return SUB_ASSIGN; }
"<<="                         { return LEFT_ASSIGN; }
">>="                         { return RIGHT_ASSIGN; }
"&="                          { return AND_ASSIGN; }
"^="                          { return XOR_ASSIGN; }
"|="                        	{ return OR_ASSIGN; }


"char"			                  { return CHAR; }
"int"			                    { return INT; }
"void"			                  { return VOID; }

"if"				                  { return IF; }
"else"			                  { return ELSE; }

"while"			                  { return WHILE; }
"do"			                    { return DO; }

"continue"		                { return CONTINUE; }
"break"			                  { return BREAK; }


"return"		                  { return RETURN; }




"."			                      { return('.'); }

{ARITHMETIC_OP}               { return(yytext[0]);}

{IDENTIFIER}    		          { yylval.E = newTemp(yytext); return IDENTIFIER; }
[ \t\v\n\f]
.			                        { return yytext[0]; }

%%

int yywrap(){
	return(1);
}

//counts the nummber of lines passed in a multi-line comment to ensure line integrity for error checking
void count_comment(char* s){
  int i;
  for(i=0; s[i]!= '\0'; i++)
    if(s[i]=='\n')
      yylineno++;
}
