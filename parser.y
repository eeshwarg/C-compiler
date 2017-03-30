%{
	#include "hashtable.h"
	#include "symbol_table.cpp"
	#include "icghelper.cpp"
	#include<cstdio>
	using namespace std;

	sym_table st;
	type_e dtype, ntype;
	token_e dtoken=FUNC;

	int temp_var_no = 1;
	int param_no;

	int yylex(void);
	void yyerror(char *);

	int type_error(type_e t1, type_e t2){ //returns 1 if error, 0 if not
		if(t1 != t2){
			yyerror("Type mismatch!\n");
			return 1;
		}
		return 0;
	}

	int temp_global = 1;

%}

%union{
	Expr* E;
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

primary_expression: IDENTIFIER	{ value_s* v = st.find_id( $<E->var>1 );
																	if(v == NULL)
																	{
																		yyerror("Undeclared identifier!");
																	}
																	else{
																		$<E>$ = $<E>1;
																		$<E->type>$ = v->type;
																		/*printf("[Type(%s)=%s]", $<E->var>$, ($<E->type>$==Int?"int":"char"));*/
																	}
																}
									| CONSTANT		{$<E>$ = $<E>1;}
									| CHAR_CONST 	{$<E>$ = $<E>1;}
									| STRING_LITERAL	{ $<E->type>$ = Char;}
									| '(' expression ')' {$<E>$ = $<E>2;}
									;

postfix_expression: primary_expression	{ $<E>$ = $<E>1; }
									| postfix_expression '[' expression ']'
									| postfix_expression '(' ')' {	Expr* temp=newTemp(temp_var_no++);
																									temp->type = $<E->type>1;
																									temp->call($<E>1, 0);
																									$<E>$ = temp;
																								}
									| postfix_expression '(' {param_no = 0;} argument_expression_list ')' {	Expr* temp=newTemp(temp_var_no++);
																																					temp->type = $<E->type>1;
																																					temp->call($<E>1, param_no);
																																					param_no = 0;
																																					$<E>$ = temp;
																																				}
									| postfix_expression INC_OP {	Expr* constant = newTemp("1");
																								Expr* tempvar = newTemp(temp_var_no++);
																								tempvar->type = constant->type = $<E->type>1;
																								tempvar->gen('+', $<E>1, constant);
																								$<E>$ = $<E>1;
																								Expr* assgn = $<E>$;
																								assgn->gen(tempvar);
																								}
									| postfix_expression DEC_OP {	Expr* constant = newTemp("1");
																								Expr* tempvar = newTemp(temp_var_no++);
																								tempvar->type = constant->type = $<E->type>1;
																								tempvar->gen('-', $<E>1, constant);
																								$<E>$ = $<E>1;
																								Expr* assgn = $<E>$;
																								assgn->gen(tempvar);
																								}
									;

argument_expression_list: assignment_expression {	$<E>$ = $<E>1;
																									Expr* temp = $<E>$;
																									temp->param();
																									param_no++;
																								}
												| argument_expression_list ',' assignment_expression {	$<E>$ = $<E>3;
																																								Expr* temp = $<E>$;
																																								temp->param();
																																								param_no++;
																																							}
												;

unary_expression: postfix_expression  { $<E>$ = $<E>1; }
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

cast_expression	: unary_expression { $<E>$ = $<E>1; }
								| '(' datatype ')' cast_expression { $<E>$ = $<E>4; $<E->type>$ = dtype; }
								;

multiplicative_expression	: cast_expression { $<E>$ = $<E>1; }
													| multiplicative_expression '*' cast_expression	{	if( !type_error($<E->type>1, $<E->type>3) ){
																																										Expr* temp = newTemp(temp_var_no++);
																																										temp->type = $<E->type>1;
																																										temp->gen('*', $<E>1, $<E>3);
																																										$<E>$ = temp;
																																									}
																																					}
													| multiplicative_expression '/' cast_expression {if( !type_error($<E->type>1, $<E->type>3) ){
																																										Expr* temp = newTemp(temp_var_no++);
																																										temp->type = $<E->type>1;
																																										temp->gen('/', $<E>1, $<E>3);
																																										$<E>$ = temp;
																																									}
																																					}
													| multiplicative_expression '%' cast_expression { if( !type_error($<E->type>1, $<E->type>3) ){
																																										Expr* temp = newTemp(temp_var_no++);
																																										temp->type = $<E->type>1;
																																										temp->gen('%', $<E>1, $<E>3);
																																										$<E>$ = temp;
																																									}
																																					}
													;

additive_expression	: multiplicative_expression { $<E>$ = $<E>1; }
										| additive_expression '+' multiplicative_expression	{	if( !type_error($<E->type>1, $<E->type>3) ){
																																							Expr* temp = newTemp(temp_var_no++);
																																							temp->type = $<E->type>1;
																																							temp->gen('+', $<E>1, $<E>3);
																																							$<E>$ = temp;
																																						}
																																				}
										| additive_expression '-' multiplicative_expression	{if( !type_error($<E->type>1, $<E->type>3) ){
																																							Expr* temp = newTemp(temp_var_no++);
																																							temp->type = $<E->type>1;
																																							temp->gen('-', $<E>1, $<E>3);
																																							$<E>$ = temp;
																																						}
																																					}
										;

shift_expression: additive_expression { $<E>$ = $<E>1; }
								| shift_expression LEFT_OP additive_expression	{if( !type_error($<E->type>1, $<E->type>3) )
																																		$<E->type>$ = $<E->type>1;}
								| shift_expression RIGHT_OP additive_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																		$<E->type>$ = $<E->type>1;}
								;

relational_expression	: shift_expression { $<E>$ = $<E>1; }
											| relational_expression '<' shift_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																					$<E->type>$ = $<E->type>1;}
											| relational_expression '>' shift_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																					$<E->type>$ = $<E->type>1;}
											| relational_expression LE_OP shift_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																					$<E->type>$ = $<E->type>1;}
											| relational_expression GE_OP shift_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																					$<E->type>$ = $<E->type>1;}
											;

equality_expression	: relational_expression { $<E>$ = $<E>1; }
										| equality_expression EQ_OP relational_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																				$<E->type>$ = $<E->type>1;}
										| equality_expression NE_OP relational_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																				$<E->type>$ = $<E->type>1;}
										;

and_expression: equality_expression { $<E>$ = $<E>1; }
							| and_expression '&' equality_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																	$<E->type>$ = $<E->type>1;}
							;

exclusive_or_expression	: and_expression { $<E>$ = $<E>1; }
												| exclusive_or_expression '^' and_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																						$<E->type>$ = $<E->type>1;}
												;

inclusive_or_expression	: exclusive_or_expression { $<E>$ = $<E>1; }
												| inclusive_or_expression '|' exclusive_or_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																						$<E->type>$ = $<E->type>1;}
												;

logical_and_expression: inclusive_or_expression { $<E>$ = $<E>1; }
											| logical_and_expression AND_OP inclusive_or_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																					$<E->type>$ = $<E->type>1;}
											;

logical_or_expression	: logical_and_expression { $<E>$ = $<E>1; }
											| logical_or_expression OR_OP logical_and_expression {if( !type_error($<E->type>1, $<E->type>3) )
																																					$<E->type>$ = $<E->type>1;}
											;

conditional_expression: logical_or_expression { $<E>$ = $<E>1; }
											| logical_or_expression '?' expression ':' conditional_expression
											;

assignment_expression	: conditional_expression { $<E>$ = $<E>1; }
											| unary_expression assignment_operator assignment_expression { if(!type_error($<E->type>1, $<E->type>3)){
																																												$<E>$ = $<E>1;
																																												Expr* temp = $<E>$;
																																												temp->gen($<E>3);
																																											};
																																										}
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

expression: assignment_expression { $<E>$ = $<E>1; }
						| expression ',' assignment_expression
						;

declaration	: datatype init_declarator_list ';'
						;

init_declarator_list: init_declarator
										| init_declarator_list ',' init_declarator
										;

init_declarator	: declarator
								| declarator '=' initializer {value_s* v = st.find_id( $<E->var>1 );
																								if( !type_error(v->type, $<E->type>3) ){
																										$<E>$ = $<E>1;
																										$<E->type>$ = v->type;
																										Expr* temp = $<E>$;
																										temp->gen($<E>3);
																								}
																							}
								;

datatype: VOID 	{dtype = Void;}
				| CHAR	{dtype = Char;}
				| INT		{dtype = Int;}
				;

declarator: IDENTIFIER		{	$<E>$ = $<E>1;
														$<E->type>$ = dtype;
														/*printf("[Type(%s)=%d]", $<E->var>$,$<E->type>$);*/
														value_s* v = make_value(VAR,dtype,NULL);
														if( st.save_id( $<E->var>1 , v ) == 0)
														{
															yyerror("Variable already declared!");
															/*YYABORT;*/
														}

													}
					| declarator '[' conditional_expression ']'
					| declarator '[' ']'
					| '(' declarator ')'
					| declarator '(' parameter_type_list ')' { value_s* v = make_value(FUNC,dtype,NULL);
																 										 st.update_id($<E->var>1, v);
																									 }
					| declarator '(' identifier_list ')' 		{	value_s* v = make_value(FUNC,dtype,NULL);
																 										st.update_id($<E->var>1, v);

																									}
					| declarator '(' ')'										{	value_s* v = make_value(FUNC,dtype,NULL);
																 										st.update_id($<E->var>1, v);
																									}
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

initializer	: assignment_expression	{$<E>$ = $<E>1;}
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
									| start_scope '{' statement_list '}'	{ st.close_scope(); }
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
