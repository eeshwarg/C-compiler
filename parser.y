%nonassoc NO_ELSE
%nonassoc  ELSE

%left '<' '>' '=' LE_GE_OP EQ_NE_OP LG_OP ASSIGNMENT_OP
%left  '+' '-'
%left  '*' '/' '%'
%left  '|'
%left  '&'

%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_DEC_OP SHIFT_OP UNARY_OP
%token AND_OP OR_OP OP_ASSIGN
%token TYPE_NAME DEF

%token ADD_OP MULTIPLICATIVE_OP COMPARISON_OP LOGICAL_OP

%token CHAR SHORT INT LONG SIGNED UNSIGNED TYPE_QUALIFIER VOID

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start translation_unit
%glr-parser
%%



primary_expression
	: IDENTIFIER
	| CONSTANT
	| DEF
	| STRING_LITERAL
	| '(' expression ')'
	| Define primary_expression
	;

Define							//Macros
	: DEF ;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_DEC_OP
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_DEC_OP unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' type_name ')'
	;

unary_operator
	: UNARY_OP
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression SHIFT_OP additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression LG_OP shift_expression
	| relational_expression LE_GE_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression																		//Bitwise OR?
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
	: '='
	| OP_ASSIGN
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression
	;

declaration
	: declaration_specifiers ';'
	| declaration_specifiers init_declarator_list ';'
	;

declaration_specifiers
	: type_specifier
	//| type_specifier declaration_specifiers					//removed because there is a need to check for declarations like 'int int', 'unsigned unsigned', 'usigned signed signed signed ... int' etc which the grammar presently accepts as valid
	//| type_qualifier																	//Is this required if the next one is removed?
	//| type_qualifier declaration_specifiers						//Need to remove this too?
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator
	| declarator '=' initializer
	;

type_specifier
	: VOID
	| CHAR
	//| SHORT
	| INT
	//| LONG
	//| SIGNED
	//| UNSIGNED				//Are we supporting all these?
	//| TYPE_NAME
	;


specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

type_qualifier
	: TYPE_QUALIFIER
	;

declarator
	: direct_declarator
	;

direct_declarator
	: IDENTIFIER
	| '(' declarator ')'
	| direct_declarator '[' constant_expression ']'
	| direct_declarator '[' ']'
	| direct_declarator '(' parameter_type_list ')'
	| direct_declarator '(' identifier_list ')'
	| direct_declarator '(' ')'
	;

parameter_type_list
	: parameter_list
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' constant_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' constant_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: assignment_expression
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| initializer_list ',' initializer
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	//| selection_statement1
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

statement_list
	: statement
	| statement_list statement
	;

expression_statement
	: ';'
	| expression ';'
	;

selection_statement
	: IF '(' expression ')' statement					%prec NO_ELSE
	| IF '(' expression ')' statement ELSE statement
	;


iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	| Define translation_unit
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
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
    else
      printf("%d - NULL\n", i);
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
