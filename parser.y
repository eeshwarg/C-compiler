%nonassoc NO_ELSE
%nonassoc  ELSE

%token IDENTIFIER CONSTANT STRING_LITERAL
%token INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN

%token CHAR INT VOID

%token IF ELSE WHILE DO CONTINUE BREAK RETURN

%start translation_unit
%%

primary_expression: IDENTIFIER
									| CONSTANT
									| STRING_LITERAL
									| '(' expression ')'
									;

postfix_expression: primary_expression
									| postfix_expression '(' ')'
									| postfix_expression '(' argument_expression_list ')'
									| postfix_expression INC_OP
									| postfix_expression DEC_OP
									;

argument_expression_list: assignment_expression
												| argument_expression_list ',' assignment_expression
												;

unary_expression: postfix_expression
								| INC_OP unary_expression
								| DEC_OP unary_expression
								| unary_operator cast_expression
								;

unary_operator: '&'
							| '*'
							| '+'
							| '-'
							| '~'
							| '!'
							;

cast_expression	: unary_expression
								| '(' type_specifier ')' cast_expression
								;

multiplicative_expression	: cast_expression
													| multiplicative_expression '*' cast_expression
													| multiplicative_expression '/' cast_expression
													| multiplicative_expression '%' cast_expression
													;

additive_expression	: multiplicative_expression
										| additive_expression '+' multiplicative_expression
										| additive_expression '-' multiplicative_expression
										;

shift_expression: additive_expression
								| shift_expression LEFT_OP additive_expression
								| shift_expression RIGHT_OP additive_expression
								;

relational_expression	: shift_expression
											| relational_expression '<' shift_expression
											| relational_expression '>' shift_expression
											| relational_expression LE_OP shift_expression
											| relational_expression GE_OP shift_expression
											;

equality_expression	: relational_expression
										| equality_expression EQ_OP relational_expression
										| equality_expression NE_OP relational_expression
										;

and_expression: equality_expression
							| and_expression '&' equality_expression
							;

exclusive_or_expression	: and_expression
												| exclusive_or_expression '^' and_expression
												;

inclusive_or_expression	: exclusive_or_expression
												| inclusive_or_expression '|' exclusive_or_expression
												;

logical_and_expression: inclusive_or_expression
											| logical_and_expression AND_OP inclusive_or_expression
											;

logical_or_expression	: logical_and_expression
											| logical_or_expression OR_OP logical_and_expression
											;

conditional_expression: logical_or_expression
											| logical_or_expression '?' expression ':' conditional_expression
											;

assignment_expression	: conditional_expression
											| unary_expression assignment_operator assignment_expression
											;

assignment_operator	: '='
										| MUL_ASSIGN
										| DIV_ASSIGN
										| MOD_ASSIGN
										| ADD_ASSIGN
										| SUB_ASSIGN
										| LEFT_ASSIGN
										| RIGHT_ASSIGN
										| AND_ASSIGN
										| XOR_ASSIGN
										| OR_ASSIGN
										;

expression: assignment_expression
						| expression ',' assignment_expression
						;

declaration	: type_specifier ';'
						| type_specifier init_declarator_list ';'
						;

init_declarator_list: init_declarator
										| init_declarator_list ',' init_declarator
										;

init_declarator	: declarator
								| declarator '=' initializer
								;

type_specifier: VOID
							| CHAR
							| INT
							;

declarator: IDENTIFIER
					| '(' declarator ')'
					| declarator '(' parameter_type_list ')'
					| declarator '(' identifier_list ')'
					| declarator '(' ')'
					;

parameter_type_list	: parameter_list
										;

parameter_list: parameter_declaration
							| parameter_list ',' parameter_declaration
							;

parameter_declaration	: type_specifier declarator
											| type_specifier
											;

identifier_list	: IDENTIFIER
								| identifier_list ',' IDENTIFIER
								;

initializer	: assignment_expression
						| '{' initializer_list '}'
						| '{' initializer_list ',' '}'
						;

initializer_list: initializer
								| initializer_list ',' initializer
								;

statement	: compound_statement
					| expression_statement
					| selection_statement
					| iteration_statement
					| jump_statement
					;

compound_statement: '{' '}'
									| '{' statement_list '}'
									| '{' declaration_list '}'
									| '{' declaration_list statement_list '}'
									;

declaration_list: declaration
								| declaration_list declaration
								;

statement_list: statement
							| statement_list statement
							;

expression_statement: ';'
										| expression ';'
										;

selection_statement	: IF '(' expression ')' statement									%prec NO_ELSE
										| IF '(' expression ')' statement ELSE statement
										;

iteration_statement	: WHILE '(' expression ')' statement
										| DO statement WHILE '(' expression ')' ';'
										;

jump_statement: CONTINUE ';'
							| BREAK ';'
							| RETURN ';'
							| RETURN expression ';'
							;

translation_unit: external_declaration
								| translation_unit external_declaration
								;

external_declaration: function_definition
										| declaration
										;

function_definition	: type_specifier declarator declaration_list compound_statement
										| type_specifier declarator compound_statement
										| declarator declaration_list compound_statement
										| declarator compound_statement
										;

%%
#include"lex.yy.c"
#include<ctype.h>
#include <stdio.h>

void display_symbol_table(){
	printf("---------------------------------\n");
  printf("Symbol Table - \n");
  int i = 0;
  for(i=0;i < ht->size; i++){
    if(ht->table[i])
      printf("%d - %s : %s\n",i, ht->table[i]->key, ht->table[i]->value);
    /*else
      printf("%d - NULL\n", i);*/
  }
}

yyerror(char *s) {
	printf("\nLine %d : %s\n", (yylineno), s);
}

int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");

  if(!yyparse())
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");
	fclose(yyin);
	printf("Symbol table - %p\n", ht);
	display_symbol_table();
	return 0;
}

extern char *yytext;
