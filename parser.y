%{
	#include "symbol_table.cpp"
	#include<cstdio>
	using namespace std;

	sym_table st;
	type_e dtype, ntype;
	token_e dtoken=FUNC;

	int yylex(void);
	void yyerror(char *);

	int type_error(type_e t1, type_e t2){ //returns 1 if error, 0 if not
		if(t1 != t2){
			yyerror("Type mismatch!\n");
			return 1;
		}
		return 0;
	}
%}

%union{
	int ival;
	char* str;
	type_e type;
}

%nonassoc NO_ELSE
%nonassoc  ELSE

%token IDENTIFIER CONSTANT STRING_LITERAL CHAR_CONST
%token INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN

%token CHAR INT VOID

%token IF ELSE WHILE DO CONTINUE BREAK RETURN

%start translation_unit
%%

primary_expression: IDENTIFIER	{ value_s* v = st.find_id( $<str>1 );
																	if(v == NULL)
																	{
																		yyerror("Undeclared identifier!");
																		/*YYABORT;*/
																	}
																	else
																		$<type>$ = v->type;}
									| CONSTANT		{$<type>$ = Int;}
									| CHAR_CONST 	{$<type>$ = Char;}
									| STRING_LITERAL	{ $<type>$ = Char;}
									| '(' expression ')' {$<str>$ = $<str>2;}
									;

postfix_expression: primary_expression	{ $<type>$ = $<type>1; }
									| postfix_expression '(' ')'
									| postfix_expression '(' argument_expression_list ')'
									| postfix_expression INC_OP
									| postfix_expression DEC_OP
									;

argument_expression_list: assignment_expression
												| argument_expression_list ',' assignment_expression
												;

unary_expression: postfix_expression  { $<type>$ = $<type>1; }
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

cast_expression	: unary_expression { $<type>$ = $<type>1; }
								| '(' datatype ')' cast_expression { $<type>$ = dtype; }
								;

multiplicative_expression	: cast_expression { $<type>$ = $<type>1; }
													| multiplicative_expression '*' cast_expression {if( !type_error($<type>1, $<type>3) )
													 																										$<type>$ = $<type>1;}
													| multiplicative_expression '/' cast_expression {if( !type_error($<type>1, $<type>3) )
													 																										$<type>$ = $<type>1;}
													| multiplicative_expression '%' cast_expression {if( !type_error($<type>1, $<type>3) )
													 																										$<type>$ = $<type>1;}
													;

additive_expression	: multiplicative_expression { $<type>$ = $<type>1; }
										| additive_expression '+' multiplicative_expression	{if( !type_error($<type>1, $<type>3) )
																																				$<type>$ = $<type>1;}
										| additive_expression '-' multiplicative_expression	{if( !type_error($<type>1, $<type>3) )
																																				$<type>$ = $<type>1;}
										;

shift_expression: additive_expression { $<type>$ = $<type>1; }
								| shift_expression LEFT_OP additive_expression	{if( !type_error($<type>1, $<type>3) )
																																		$<type>$ = $<type>1;}
								| shift_expression RIGHT_OP additive_expression {if( !type_error($<type>1, $<type>3) )
																																		$<type>$ = $<type>1;}
								;

relational_expression	: shift_expression { $<type>$ = $<type>1; }
											| relational_expression '<' shift_expression {if( !type_error($<type>1, $<type>3) )
																																					$<type>$ = $<type>1;}
											| relational_expression '>' shift_expression {if( !type_error($<type>1, $<type>3) )
																																					$<type>$ = $<type>1;}
											| relational_expression LE_OP shift_expression {if( !type_error($<type>1, $<type>3) )
																																					$<type>$ = $<type>1;}
											| relational_expression GE_OP shift_expression {if( !type_error($<type>1, $<type>3) )
																																					$<type>$ = $<type>1;}
											;

equality_expression	: relational_expression { $<type>$ = $<type>1; }
										| equality_expression EQ_OP relational_expression {if( !type_error($<type>1, $<type>3) )
																																				$<type>$ = $<type>1;}
										| equality_expression NE_OP relational_expression {if( !type_error($<type>1, $<type>3) )
																																				$<type>$ = $<type>1;}
										;

and_expression: equality_expression { $<type>$ = $<type>1; }
							| and_expression '&' equality_expression {if( !type_error($<type>1, $<type>3) )
																																	$<type>$ = $<type>1;}
							;

exclusive_or_expression	: and_expression { $<type>$ = $<type>1; }
												| exclusive_or_expression '^' and_expression {if( !type_error($<type>1, $<type>3) )
																																						$<type>$ = $<type>1;}
												;

inclusive_or_expression	: exclusive_or_expression { $<type>$ = $<type>1; }
												| inclusive_or_expression '|' exclusive_or_expression {if( !type_error($<type>1, $<type>3) )
																																						$<type>$ = $<type>1;}
												;

logical_and_expression: inclusive_or_expression { $<type>$ = $<type>1; }
											| logical_and_expression AND_OP inclusive_or_expression {if( !type_error($<type>1, $<type>3) )
																																					$<type>$ = $<type>1;}
											;

logical_or_expression	: logical_and_expression { $<type>$ = $<type>1; }
											| logical_or_expression OR_OP logical_and_expression {if( !type_error($<type>1, $<type>3) )
																																					$<type>$ = $<type>1;}
											;

conditional_expression: logical_or_expression { $<type>$ = $<type>1; }
											| logical_or_expression '?' expression ':' conditional_expression
											;

assignment_expression	: conditional_expression { $<type>$ = $<type>1; }
											| unary_expression assignment_operator assignment_expression { type_error($<type>1, $<type>3);}
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

expression: assignment_expression { $<type>$ = $<type>1; }
						| expression ',' assignment_expression
						;

declaration	: datatype init_declarator_list ';'
						;

init_declarator_list: init_declarator
										| init_declarator_list ',' init_declarator
										;

init_declarator	: declarator
								| declarator '=' initializer {value_s* v = st.find_id( $<str>1 );
																								if( !type_error(v->type, $<type>3) )
																									$<type>$ = $<type>3;}
								;

datatype: VOID 	{dtype = Void;}
				| CHAR	{dtype = Char;}
				| INT		{dtype = Int;}
				;

declarator: IDENTIFIER		{	$<str>$ = $<str>1;
														value_s* v = make_value(VAR,dtype,NULL);
														if( st.save_id( $<str>1 , v ) == 0)
														{
															yyerror("Variable already declared!");
															/*YYABORT;*/
														}

													}
					| '(' declarator ')'
					| declarator '(' parameter_type_list ')'
					| declarator '(' identifier_list ')'
					| declarator '(' ')'	{value_s* v = make_value(FUNC,dtype,NULL);
																 st.update_id($<str>1, v);}
					;

parameter_type_list	: parameter_list
										;

parameter_list: parameter_declaration
							| parameter_list ',' parameter_declaration
							;

parameter_declaration	: datatype declarator
											| datatype
											;

identifier_list	: IDENTIFIER
								| identifier_list ',' IDENTIFIER
								;

initializer	: assignment_expression	{$<type>$ = $<type>1;}
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
					| declaration
					;

compound_statement: start_scope '{' '}' { st.close_scope(); }
									| start_scope '{' statement_list '}'	{  st.close_scope(); }
									;

start_scope	:		{ st.new_scope(); }
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

function_definition	: datatype declarator declaration_list compound_statement
										| datatype declarator compound_statement
										| declarator declaration_list compound_statement
										| declarator compound_statement
										;

%%
#include"lex.yy.c"
#include<ctype.h>
#include <stdio.h>

void yyerror(char *s) {
	printf("\nLine %d : %s\n", (yylineno), s);
}

int main(int argc, char *argv[])
{
	yyin = fopen(argv[1], "r");
	//st = new sym_table();

  if(!yyparse())
		printf("\nParsing complete\n");
	else
		printf("\nParsing failed\n");
	fclose(yyin);
	return 0;
}

extern char *yytext;
