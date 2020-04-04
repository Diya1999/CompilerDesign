%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#define LIMIT 1024

//	extern int lineno = 0;
	void yyerror(const char*);
	int yylex();
	int temp_no = 0;
	int label = 0;
	FILE *outfile;

	void arithmetic_gen(char op[5]);
	void display_stack();
	void push(char *);
	char *pop();
	void label_push(int);
	char *label_pop();

	typedef struct Stack {
		char *items[LIMIT];
		int top;
	}Stack;
	Stack stack;
	Stack label_stack;

	

%}
%union
{
	char string[128];
}




%token PREPROC  STDIO  MATH STRING 

%token	IDENTIFIER INTEGER_LITERAL FLOAT_LITERAL STRING_LITERAL HEADER_LITERAL CHARACTER_LITERAL

%token	INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP LT GT 

%token  AND_LOG OR_LOG NOT

%token	ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN  

%token	CHAR INT FLOAT VOID MAIN BREAK SWITCH CASE DEFAULT RETURN

%token  SUB ADD MUL DIV MOD

%token	STRUCT

%token	WHILE 

%type <string> IDENTIFIER INTEGER_LITERAL FLOAT_LITERAL STRING_LITERAL HEADER_LITERAL CHARACTER_LITERAL primary_expression

%type <string> postfix_expression unary_expression  assignment_expression init_declarator unary_operator expression

%start translation_unit
%%
headers
	: PREPROC HEADER_LITERAL 		
	| PREPROC LT libraries GT	
	;

libraries
	: STDIO		
	| MATH		
	| STRING	
	;

primary_expression
	: IDENTIFIER	{push($1); $$ = $1;}
	| INTEGER_LITERAL {push($1); $$ = $1;}
	| FLOAT_LITERAL {push($1); $$ = $1;}
	| STRING_LITERAL {push($1); $$ = $1;}	
	| '(' expression ')' {$$=$2;}
    | CHARACTER_LITERAL {push($1); $$ = $1;}	
	;
postfix_expression
	: primary_expression	{$$=$1;}
	| postfix_expression '(' ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression '[' expression ']'
	| postfix_expression INC_OP {push($1); push("1"); arithmetic_gen("+"); fprintf(outfile, "%s = %s\n", pop(), pop());}
	| postfix_expression DEC_OP {push($1); push("1"); arithmetic_gen("-"); fprintf(outfile, "%s = %s\n", pop(), pop());}
	| INC_OP primary_expression {push($2); push("1"); arithmetic_gen("+"); fprintf(outfile, "%s = %s\n", pop(), pop());}
	| DEC_OP primary_expression {push($2); push("1"); arithmetic_gen("-"); fprintf(outfile, "%s = %s\n", pop(), pop());}
	;
unary_expression
	: postfix_expression 	{$$=$1;}
	| unary_operator unary_expression {char temp[5]; strcpy(temp, pop()); push("0"); push(temp); arithmetic_gen($1);}
	;
unary_operator
	: NOT		
	;
multiplicative_expression
	: unary_expression
	| multiplicative_expression MUL unary_expression {arithmetic_gen("*");}
	| multiplicative_expression DIV unary_expression {arithmetic_gen("/");}
	| multiplicative_expression MOD unary_expression {arithmetic_gen("%");}
	;
additive_expression
	: multiplicative_expression
	| additive_expression ADD multiplicative_expression {arithmetic_gen("+");}
	| additive_expression SUB multiplicative_expression {arithmetic_gen("-");}
	;
relational_expression
	: additive_expression
	| relational_expression LT additive_expression {arithmetic_gen("<");}
	| relational_expression GT additive_expression {arithmetic_gen(">");}
	| relational_expression LE_OP additive_expression {arithmetic_gen("<=");}
	| relational_expression GE_OP additive_expression {arithmetic_gen(">=");}
	;
equality_expression
	: relational_expression 
	| equality_expression EQ_OP relational_expression {arithmetic_gen("==");}
	| equality_expression NE_OP relational_expression {arithmetic_gen("!=");}
	;

logical_and_expression
	: equality_expression								
	| logical_and_expression AND_LOG equality_expression{arithmetic_gen("&&");}
	;

logical_or_expression
	: logical_and_expression							
	| logical_or_expression OR_LOG logical_and_expression{arithmetic_gen("||");}
	;

conditional_expression
	: logical_or_expression 	 
	| logical_or_expression 	 {fprintf(outfile, "ifFalse %s goto L%d\n", pop(), ++label); char temp[5]; sprintf(temp, "t%d", temp_no++); push(temp);} '?' expression {gen_true_code();} ':' conditional_expression {gen_false_code();}
	;
assignment_expression
	: conditional_expression
	| unary_expression '=' assignment_expression  {fprintf(outfile, "%s = %s\n", pop(), pop());}
	| unary_expression ADD_ASSIGN assignment_expression  {arithmetic_gen("+"); fprintf(outfile, "%s = %s\n", $1, pop());}
	| unary_expression SUB_ASSIGN assignment_expression  {arithmetic_gen("-"); fprintf(outfile, "%s = %s\n", $1, pop());}
	;
expression
	: assignment_expression 
	| expression ',' assignment_expression
	;

declaration
	: type_specifier ';'
	| type_specifier init_declarator_list ';'
	;
init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;
init_declarator
	//: IDENTIFIER {push($1); $$=$1;} '=' assignment_expression {fprintf(outfile, "%s = %s\n", $1, pop());}
//	| IDENTIFIER '=' equality_expression {fprintf(outfile, "if not %s goto L%d\n", pop(), ++label);} '?' expression {fprintf(outfile, "%s = %s\n", $1, pop());fprintf(outfile, "goto L%d\n", ++label);} ':'  conditional_expression {fprintf(outfile, "L%d :\n%s = %s\n", label-1, $1, pop()); pop(); fprintf(outfile, "goto L%d\n", label);}
	: IDENTIFIER {push($1); $$=$1;}
	| IDENTIFIER array 									
	;


array
: '['INTEGER_LITERAL']' array					
| '['INTEGER_LITERAL']'							
;

type_specifier
	: VOID
	| CHAR
	| INT
	| FLOAT
	| struct_specifier
	;
struct_specifier
	: STRUCT '{' struct_declaration_list '}'
	| STRUCT IDENTIFIER '{' struct_declaration_list '}'
	| STRUCT IDENTIFIER
	;
struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;
struct_declaration
	: specifier_qualifier_list ';'	
	| specifier_qualifier_list struct_declarator_list ';'
	;
specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	;
struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;
struct_declarator
	: IDENTIFIER
	| IDENTIFIER array
	;
statement
	: compound_statement
	| expression_statement
	|  while_statement	
	| switch_statement	
	| BREAK ';' 
	;

switch_statement
: SWITCH '(' expression ')' '{' case_statement '}' 
;
case_statement
: case_statement_int 
| case_statement case_statement_int 
;

case_statement_int
: CASE conditional_expression ':' block_item_list
| DEFAULT ':' block_item_list 
;
compound_statement
	: '{' '}' 
	| '{' block_item_list '}'
	;
block_item_list
	: block_item
	| block_item_list block_item
	;
block_item
	: declaration
	| statement
	;
expression_statement
	: ';'
	| expression ';'
	;
while_statement
	: WHILE '(' expression ')''{' block_item_list '}' 
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;
external_declaration
	: INT MAIN '(' ')' compound_statement
	| declaration
	| headers 	
	;
%%
void yyerror(const char *str)
{
	fflush(stdout);
	fprintf(stderr, "%s at line\n", str);
}
int main(){
	stack.top = -1;
	push("$");
	outfile = fopen("output_file.txt", "w");
	if (yyparse() != 0)
	{
		printf("Parse failed\n");
		exit(0);
	}
	printf("success\n");
	int i = 0;
	fclose(outfile);
	system("cat output_file.txt");
	return 0;
}
void push(char *str)
{
	stack.items[++stack.top] = (char*)malloc(LIMIT);
	strcpy(stack.items[stack.top], str);
}
char *pop()
{
	if (stack.top <= -1) {
		printf("\nError in evaluating expression\n");
		exit(0);
	}
	char *str = (char*)malloc(LIMIT);
	strcpy(str, stack.items[stack.top--]);
	free(stack.items[stack.top+1]);
	return str;
}
char *top(int off)
{
	return stack.items[stack.top-off];
}
void arithmetic_gen(char op[5])
{
	char temp[5];
	sprintf(temp,"t%d",temp_no++);
  	fprintf(outfile,"%s = %s %s %s\n",temp,top(1),op,top(0));
	pop(); pop(); push(temp);
}

void display_stack()
{
	int i;
	for(i=0; i<=stack.top; i++)
		printf("%s ", stack.items[i]);
		printf("\n");
}
void gen_true_code()
{
	if (stack.top > -1)
	{
		fprintf(outfile, "%s = %s\ngoto L%d\n", top(0), pop(), label+1);
		label_push(label+1);
		fprintf(outfile, "L%d :\n", label);
		label_push(label+1);
	}
	else
		fprintf(outfile, "%s\ngoto L%d\n", pop(), ++label);
}
void gen_false_code()
{
	if (stack.top > -1)
	{
		fprintf(outfile, "%s = %s\ngoto %s\n", top(0), pop(), label_pop());
		fprintf(outfile, "%s :\n", label_pop());
		label++;
	}
	else
		fprintf(outfile, "%s\ngoto L%d\n", pop(), label-1);
}
void label_push(int label)
{
	char temp[5];
	sprintf(temp, "L%d", label);
	label_stack.items[++label_stack.top] = malloc(LIMIT);
	strcpy(label_stack.items[label_stack.top], temp);
	
}
char *label_pop()
{
	if (label_stack.top <= -1) {
		printf("\nError in evaluating expression\n");
		exit(0);
	}
	char *str = (char*)malloc(LIMIT);
	strcpy(str, label_stack.items[label_stack.top--]);
	free(label_stack.items[label_stack.top+1]);
	return str;
}
