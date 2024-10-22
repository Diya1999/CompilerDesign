%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <ctype.h>
	#define LIMIT 1024
	#define MAX_SYMBOLS 100			// defines max no of record in each symbol table
	#define MAX_SCOPE 10			// defines max no of scopes allowed 
	#define NEWSCOPE 1				// denoted new scope
	#define OLDSCOPE 0				// denotes old scope
	#define NO_OF_KEYWORD 7			// denotes no of keywords
	#define LENGTH_OF_KEYWORDS 7	// max length of keyword string
	#define MAX_MEMBER 10			// max number of member in struct
	#define TYPE_LENGTH 6			// length of type int float void ....
	#define MAX_NO_OF_STRUCT 10		// max_no of structure which can be defined in a scope
	#define STRUCT_FLAG 2			// Flag to know struct which is declared
	#define YY_USER_ACTION 
	//yylloc.first_line = yylloc.last_line = yylineno; 
	extern int yylineno;
	
	/* the start index for the member of nested struct in the parent struct  initialized at nested_struct rule */ 
	int nested_struct_start_index;
	
	// keyword_Array
	char keywords[NO_OF_KEYWORD][LENGTH_OF_KEYWORDS] = {"char","int","float","void","main","for","struct"};
	int c = 0;
	int scope = NEWSCOPE;
	void yyerror(const char*);
	int yylex();
	
	char buff[1000];
	int arr_size;

	// used for ternary construct to denote if condition is true or false
	int ternary_flag = 0;
	
	// flag to mark if the varaible is not_defined. Used to decide wheather to push the value in the symbol table or not.
	// 1 => the varaible is not defined.
	int not_defined = 0;
	
	int error = 0;
	struct symbol {
		char name[LIMIT];
		char type[LIMIT];
		char value[LIMIT];
		int lineno;
		int size;
	};
	
	struct struct_data{
		char struct_name[LIMIT];
		char member_type[MAX_MEMBER][TYPE_LENGTH];
		char member_name[MAX_MEMBER][LIMIT];
		int member_size[MAX_MEMBER];
		int member_lineno[MAX_MEMBER];
		int index_to_insert_member;				// to know at which index do we have to insert new member
	};
	
	struct stack_for_symbol_tables{
		int index_to_insert;
		int struct_index_to_insert;
		struct struct_data struct_defined[MAX_NO_OF_STRUCT];
		struct symbol symbol_table[MAX_SYMBOLS];
	}symbol_table_stack[MAX_SCOPE];
	
	/* used if know if struct is used as member to declare a variable of its type
	   1 means used 
	*/
	int struct_reference_used = 0;
	
	int top_stack_for_symbol_tables = -1;
	
	// called to perform all artihmatic operations
	void fun(char *result ,char *arg1,char *arg2,char *arg3);
	
	/* called to push the varaibles in the current scope */
	int push_my(char *type,char *name,char *value,int flag,int lineno,int size);
	
	// not used yet
	void struct_member_name(char* struct_name,int struct_index_to_insert);
	/* to pop the scope */
	int pop_my();
	
	float find_variable_value(char *name);
	/* to check if the varaible of current scope is declared or not
	   return value 1 if not else -1; 
	*/
	int search_my(char *name,int flag);
	
	/* to display the current scope */
	void display();
	void display_struct();
	void display_full();
	
	void struct_member(char *type,char *name,int lineno,int size);
	
	int find_size(char *type);
	
	/*  update the value of of varaible in symbol table by first checking if varaible is defined or not
		if not defined then this function return value -1  */
	int update_variable_value(char *name,char *value);
	
	int add_struct_member_in_symbol_table(char *struct_name);
	
	/*
		to check if the varaibles in an expression are defined or not
		return type is array of varaibles that are not defined.
	*/
	void check(char *arg1,char *arg3);
	
	void coercion(char *type,char *value);
	
	void init_symbol_table();
	
	void write_to_file();

	void find_arr(char *arr,char *type);
%}

%union
{
	int ival;
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

%type <string>  INTEGER_LITERAL AND_LOG OR_LOG NOT logical_and_expression assignment_operator conditional_expression logical_or_expression array multiplicative_expression unary_expression init_declarator_list init_declarator declaration type_specifier assignment_expression IDENTIFIER additive_expression relational_expression equality_expression expression primary_expression postfix_expression struct_specifier struct_declaration_list struct_declaration specifier_qualifier_list struct_declarator_list struct_declarator LE_OP GE_OP EQ_OP NE_OP ADD SUB LT GT DIV MUL MOD

%start translation_unit

%%

headers
	: PREPROC HEADER_LITERAL 		{printf("61\n");}
	| PREPROC LT libraries GT	{printf("62\n");}
	;

libraries
	: STDIO		{printf("66\n");}
	| MATH		{printf("68\n");}
	| STRING	{printf("69\n");}
	;

primary_expression
	: IDENTIFIER	{printf("$1 : %s $$ : %s\n",$1,$$);printf("74\n");}
	| INTEGER_LITERAL {printf("65\n");}
	| FLOAT_LITERAL		{}
	| STRING_LITERAL	{printf("76\n");}
	| CHARACTER_LITERAL {}	
	| '(' expression ')'	
							{
								printf("77\n");
								int flag = 1;
								int i=0;
								while($2[i] != '\0')
								{
									//printf("$2[%d] = %c \n",i,$2[i]);
									if(!isdigit($2[i]))
									{
										flag = 0;
										break;
									}
									i++;
								}
								//printf("$2 %s flag %d \n",$2,flag);
								if(!flag)
								{
									strcpy($$,"(");
									strcpy($$+1,$2);
									strcat($$,")");
									$$[strlen($$)] = '\0';
								}
								else
								{
									strcpy($$,$2);
									//printf("else $$ %s\n",$$);
								}
								//printf("from expression $$ %s\n",$$);
							}
							
	;

postfix_expression
	: primary_expression					{printf("81\n");}
	| postfix_expression '(' ')'			{printf("82\n");}
	| postfix_expression '[' expression ']'
	| postfix_expression '.' IDENTIFIER		{
												char temp[LIMIT];
												strcpy(temp,$1);
												strcat(temp,".");
												strcat(temp,$3);
												strcpy($$,temp); 
												int value = update_variable_value($$,"");
												if(value == -1)
												{
													FILE *fptr = fopen("error.txt","a");
													fprintf(fptr,"Varaible %s is not defined\n",$$);
													error = 1;
													fclose(fptr);
													not_defined = -1;
												}
												printf("83\n");
											}
	| postfix_expression INC_OP				{printf("84\n");float val = find_variable_value($1); 
												if(val)
												{
													float temp = val+1;
													char buff[20];
													sprintf(buff,"%f",temp);
													int value = update_variable_value($1,buff);
												}}
	| postfix_expression DEC_OP				{printf("85\n");
												float val = find_variable_value($1); 
												if(val)
												{
													float temp = val+1;
													char buff[20];
													sprintf(buff,"%f",temp);
													int value = update_variable_value($1,buff);
												}}
	| INC_OP primary_expression				{ float val = find_variable_value($2); 
												if(val)
												{
													float temp = val+1;
													char buff[20];
													sprintf(buff,"%f",temp);
													int value = update_variable_value($2,buff);
												}
											}
	| DEC_OP primary_expression				{
		float val = find_variable_value($2); 
												if(val)
												{
													float temp = val-1;
													char buff[20];
													sprintf(buff,"%f",temp);
													int value = update_variable_value($2,buff);
												}
	}
	;

unary_expression
	: postfix_expression				{printf("89\n");}
	| unary_operator unary_expression	{printf("90\n");}
	;

unary_operator
	: NOT		{printf("94\n");}
	;

multiplicative_expression
	: unary_expression {printf("99\n");}
	| multiplicative_expression MUL unary_expression	{
															//printf("100\n");
															//printf("In * part $1 : %s $3 : %s\n",$1,$3);
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
														}
	| multiplicative_expression DIV unary_expression	{
															//printf("In / part $1 : %s $3 : %s\n",$1,$3);
															printf("101\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
													 	}
	| multiplicative_expression MOD unary_expression  	{
															printf("102\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
														}
	;

additive_expression
	: multiplicative_expression {printf("106\n");printf("%s \n",$$);}
	| additive_expression ADD multiplicative_expression {
															printf("101\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
													 	}
	| additive_expression SUB multiplicative_expression	{
															printf("101\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
													 	}
	;

relational_expression
	: additive_expression 								{printf("112\n");printf("%s \n",$$);}
	| relational_expression LT additive_expression 	{
															printf("113\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
														}
	| relational_expression GT additive_expression		{
															printf("114\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
														}
	| relational_expression LE_OP additive_expression	{
															printf("121\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
														}
	| relational_expression GE_OP additive_expression	{
															printf("121\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
														}
	;

equality_expression
	: relational_expression 							{printf("120\n");printf("%s \n",$$);}
	| equality_expression EQ_OP relational_expression	{
															printf("121\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
														}
	| equality_expression NE_OP relational_expression	{
															printf("121\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
														}
	;
logical_and_expression
	: equality_expression								{printf("logicand\n");printf("%s \n",$$);}
	| logical_and_expression AND_LOG equality_expression{
															printf("logicand\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
														}
	;

logical_or_expression
	: logical_and_expression							{printf("logicor\n");printf("%s \n",$$);}
	| logical_or_expression OR_LOG logical_and_expression{
															printf("logicor\n");
															check($1,$3);	// to check if varaibles used are defined or not
															fun($$,$1,$2,$3);
														}
	;

conditional_expression
	: logical_or_expression 												{/*printf("126\n");printf("%s \n",$$);*/}
	| logical_or_expression '?'{ if( strlen($1) == 1 && !strcmp($1,"1") ) ternary_flag = 1; }expression ':' conditional_expression		{/*printf("127\n");*/}
	;

assignment_expression
	:  conditional_expression {/*printf("131\n");printf("%s \n",$$);*/} 
	| unary_expression assignment_operator assignment_expression	{
																																			//printf("132\n");
																		printf("assignment operator %s %s %s\n ",$1,$2,$3);
																																//printf("ternary_flag %d not_defined %d\n",ternary_flag,not_defined);
																		if(not_defined == 0 || ternary_flag == 1)
																		{
																			int value;
																			if(strcmp($2,"=")==0)													//printf("hello\n");
																				value = update_variable_value($1,$3);
																			else if(strcmp($2,"+=")==0)
																			{
																				char buffer[10];
																				float temp_val = find_variable_value($1);
																				if(temp_val)
																				{
																					sprintf(buffer, "%f",temp_val+atof($3)); 
																				value = update_variable_value($1,buffer);
																				}
																				else{
																					not_defined = 1;
																				FILE *fptr = fopen("error.txt","a");
																				fprintf(fptr,"Variable %s is not defined\n",$$);
																				error = 1;
																				fclose(fptr);
																				}
                                                                            }
                                                                            else{
																				char buffer[10];
                                                                                float temp_val = find_variable_value($1);
																				if(temp_val)
																				{
																					sprintf(buffer, "%f",temp_val-atof($3)); 
																				value = update_variable_value($1,buffer);
																				}
																				else{
																					not_defined = 1;
																				FILE *fptr = fopen("error.txt","a");
																				fprintf(fptr,"Varaible %s is not defined\n",$$);
																				error = 1;
																				fclose(fptr);
																				}
                                                                            }
																			//int value = update_variable_value($1,$3);
																			if(value == -1 )
																			{
																				not_defined = 1;
																				FILE *fptr = fopen("error.txt","a");
																				fprintf(fptr,"Varaible %s is not defined\n",$$);
																				error = 1;
																				fclose(fptr);
																			}
																		}
																		not_defined = 0;
																		ternary_flag = 0;
																	}
	;

assignment_operator
	: '='			{printf("136\n"); strcpy($$,"=");}
	| ADD_ASSIGN	{printf("137\n");strcpy($$,"+=");}
	| SUB_ASSIGN	{printf("138\n");strcpy($$,"-=");}
	;

expression
	: assignment_expression 				{printf("142\n");printf("%s \n",$$);}
	| expression ',' assignment_expression	{printf("143\n");}
	;



declaration
	: type_specifier ';'		{
									/*
									if(!strcmp($1,"struct"))
										display_struct();
									*/
										printf("151\n");
								}
	| type_specifier init_declarator_list ';'	{	printf("declaration %s %s \n", $1,$2);
																		printf("152\n");
																		char *temp_token;																	/* display struct member in cuurent scope only if $1 = "struct" */
														char * token = strtok_r($2, "#",&temp_token);
                                                        while( token != NULL ) 
                                                        {	
      													printf( "token %s\n", token ); //printing each token
														char *type = $1;
														int size = find_size(type);
														// this if is for an array
														if(index(token,',')!=NULL)
														{
															printf("after array1 %s",token);
															char arr1[10];
															char *_ = index(token, '(');
														   char *_1 = index(token, ')');
														/* to get the no of characher in the name string */
														int _index = (int)(_ - token);
														int _index1 = (int)(_1 - token);
														
														strncpy(arr1,_+1,_index1-_index-2);
														
														arr1[_index1-_index-2]= '\0';
														printf("arr1 : %s\n",arr1);
														
														find_arr(arr1,type);
														
														char name[_index];
														
														strncpy(name,token,_index);
														name[_index] = '\0';
														
														push_my(buff,name," ",scope,yylineno,arr_size);
														
														}																/* if the $2 has '_' character then varaible has value associated it*/
													else{if(index(token,'?') != NULL)
													{
														
														/* to get the index of '_' in $2 */
														char *_ = index(token, '?');
														
														/* to get the no of characher in the name string */
														int _index = (int)(_ - token);
														
														/* to get the no of characher in the value string */
														int value_length = strlen(token) - _index;
														
														char name[_index];
														strncpy(name,token,_index);
														name[_index] = '\0';
														
														char value[value_length];
														strncpy(value,token+_index+1,value_length);
														//printf("VALUE %s length %d\n",value,strlen(value));
														value[value_length] = '\0';
														
														coercion(type,value);
														//printf("VALUE %s length %d\n",value,strlen(value));
														//printf("not_defined %d\n",not_defined);
														if(not_defined == 0)
															push_my(type,name,value,scope,yylineno,size);
														not_defined = 0;
													}
													else if(!strcmp($1,"struct"))
													{
														//int struct_index_to_insert = symbol_table_stack[top_stack_for_symbol_tables].struct_index_to_insert;
														add_struct_member_in_symbol_table(token);
														//struct_member_name(token,struct_index_to_insert-1);
													}
													
													/* if varaible is declared without default value */
													else
													{
														//printf("good night");
														char name[strlen(token)+1];
														strcpy(name,token);
														//name[strlen(token)] = '\0';
														//printf("hi\n");
														push_my(type,name,"",scope,yylineno,size);
													}
												}
                                                    token = strtok_r(NULL, "#",&temp_token);
													printf("final changes token : %s\n",token);
                                                        }																					
																																			/*
																																		if(!strcmp($1,"struct"))
																																				display_struct();
																																			*/
																																			
																																			//printf("$$ %s\n",$$);
													//printf("152\n");
																																//display_struct();
																																//printf("%s \n",$1);
																																//printf("$2 %s\n",$2);
													
												}
	;

init_declarator_list
	: init_declarator							{    // printf("init_declator only value of $ :%s \n",$1); 
												}
	| init_declarator_list ',' init_declarator	{	  //printf("init_declator only with comma value of $ :%s  %s\n", $1,$3);
	strcpy($$,$1);
	strcat($$,"#");
	strcat($$,$3);
	}
	;

init_declarator
	: IDENTIFIER '=' assignment_expression 	{					// $$ value of this wil be of the form id?val
																											//printf("$1 : %s $3 : %s\n",$1,$3);
																											/*assigning value to init_declarator of form " 													  'var_name'_'var_default_value' */
																											
												printf("161\n");
																											//printf("$$ %s %d\n",$$,strlen($$));
												
												strncpy($$+strlen($$), "?", 2);
												$$[strlen($$)] = '\0';
																												//printf("$$ %s\n",$$);
																												//printf("$3 %s\n",$3);
												strncpy($$+strlen($$), $3, sizeof($3));
																													//$$[strlen($$)] = '\0';
																													//printf("$$ %s\n",$$);
											}
	| IDENTIFIER							{	// $$ value of this wil be of the form id
												/*assigning value to init_declarator of form " 													  'var_name' */
												//strncpy($$,$1,strlen($1) - 1);$$[strlen($$)] = '\0';
												strcpy($$,$1);
												printf("162\n");
											}	
	| IDENTIFIER array 				{ 				
													char buff[20];
													strcpy(buff,$1);
													strcat(buff,"(");
													//strcat(buff,$3);
													strcat(buff,$2);
													strcat(buff,")");
													strcpy($$,buff);
													printf("array1  :    %s\n",buff);
													
													}
	;

array
: '['INTEGER_LITERAL']' array					{	char buff[10];
							  						strcpy(buff,$2);
													strcat(buff,",");
													strcat(buff,$4);
													strcpy($$,buff);
													printf("array2  :    %s\n",buff);
							 					 }
| '['INTEGER_LITERAL']'							{
													char buff[10];
													strcpy(buff,$2);
													strcat(buff,",");
													strcpy($$,buff);
													printf("array3  :    %s\n",buff);
												}
;

type_specifier
	: VOID 					{}
	| CHAR 					{}
	| INT 					{}
	| FLOAT					{}
	| struct_specifier		{/*printf("Struct_specifier %s\n",$1);*/}
	;

struct_specifier
	: STRUCT '{' struct_declaration_list '}'				{printf("174\n");}
	| STRUCT IDENTIFIER '{' nested_struct struct_declaration_list '}'		
													{
														/* struct_flag is to tell the decleration is of structure 
														   and value is "" beacuse this push is used to put only the name of 															   struct declared in current scope*/ 
														   struct_member("",$2,yylineno,0);
														//push_my("",$2,"",STRUCT_FLAG);
														/*strcpy($$,$1.string);*/printf("175\n");
													}
	| STRUCT IDENTIFIER								{
														/* initialized to denote the member used in the struct decleration 															   is struct */
														struct_reference_used = 1;
														printf("176\n");
													}
	;
nested_struct
	:				{
						if(top_stack_for_symbol_tables != -1)
						{
							int struct_index_to_insert = symbol_table_stack[top_stack_for_symbol_tables].struct_index_to_insert;
							nested_struct_start_index = symbol_table_stack[top_stack_for_symbol_tables].struct_defined[struct_index_to_insert].index_to_insert_member;
						}
					}
	;
struct_declaration_list
	: struct_declaration							{printf("%s \n",$1);printf("180\n");}
	| struct_declaration_list struct_declaration	{printf("181\n");}
	;

struct_declaration	
	: specifier_qualifier_list ';'							{printf("185\n");}
	| specifier_qualifier_list struct_declarator_list ';'	{
																int size = find_size($1);

																struct_member($1,$2,yylineno,size);
																//push_my($1,$2,"",STRUCT_FLAG);
															 	/*printf("%s \n",$1);printf("%s \n",$2);*/printf("186\n");
															}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list				{printf("190\n");}
	| type_specifier										{/*strcpy($$,$1);printf("%s \n",$1);*/printf("191\n");}
	;

struct_declarator_list
	: struct_declarator									{/*strcpy($$,$1);printf("%s \n",$1);*/printf("195\n");}
	| struct_declarator_list ',' struct_declarator		{printf("196\n");}
	;

struct_declarator
	: IDENTIFIER								{/*strcpy($$,$1);printf("%s \n",$1);*/printf("202\n");}
	| IDENTIFIER array
	;

statement
	: compound_statement		{printf("206\n");}
	| expression_statement		{printf("207\n");}
	| while_statement{printf("while_statement\n");}
	| switch_statement	{printf("switch statement\n");}
	| BREAK ';'	{printf("break\n");}
	
	;
switch_statement
: SWITCH '(' expression ')' '{' case_statement '}' {printf("switch\n");}
;
constant_expression
: conditional_expression{printf("constant_expression\n");}
;
case_statement
: CASE constant_expression ':' block_item_list case_statement {printf("case1\n");}
| CASE constant_expression ':' block_item_list {printf("case2\n");}
|DEFAULT ':' block_item_list {printf("case3\n");}
;
compound_statement
	: '{' '}' 											{printf("212\n");}
	| '{' new_scope block_item_list '}' new_scope_end	{printf("213\n");}
	;
new_scope
	:		{printf("216\n"); scope = NEWSCOPE;}	
	;
new_scope_end
	:		{
				printf("219\n");
				scope = OLDSCOPE;
				//display();
				//printf("\n");
				write_to_file();
				pop_my();
			}
	;
block_item_list
	: block_item					{printf("222\n");}
	| block_item_list block_item	{printf("223\n");}
	;

block_item
	: declaration	{printf("227\n");}
	| statement		{printf("228\n");}
	;

expression_statement
	: ';'				{printf("232\n");}
	| expression ';'	{printf("233\n");}
	;

while_statement
	: WHILE '(' expression ')' '{' block_item_list '}' {printf("238\n");}
	;

translation_unit
	: external_declaration						{printf("244\n");}
	| translation_unit external_declaration		{printf("245\n");}
	;

external_declaration
	: INT MAIN '(' ')' compound_statement	{write_to_file();printf("249\n");}	
	| declaration 							{printf("250\n");}
	| headers 								{printf("251\n");}
	;

%%

void yyerror(const char *str)
{
	fflush(stdout);
	fprintf(stderr, "*** %s\n", str);
}
int main(){
	init_symbol_table();
	if(!yyparse())
	{
		display_full();
		printf("Successful\n");
	}
	else
		printf("Unsuccessful\n");

	return 0;
}

void find_arr(char *arr,char *type)
{	
	if(!index(arr,','))
		{
			arr_size=find_size(type)*atoi(arr);
			//printf("atoi last %d %d\n", find_size(type),atoi(arr));
			//printf("buff size :%d\n",arr_size);
			strcpy(buff,"array(");
			strcat(buff,arr);
			strcat(buff,",");
			strcat(buff,type);
			strcat(buff,")");
			//printf("buff in if :%s\n",buff);
		//	printf("atoi last %d %d\n", find_size(type),atoi(arr));
		//	printf("buff size :%d\n",arr_size);
		}
	else
		{	
			char *arr_sub=strtok(arr,",");
			//printf("attoi %d\n", atoi(arr_sub));
			//printf("buff size :%d\n",arr_size);
			char *arr_temp=arr+strlen(arr_sub)+1;
		//	printf("arr_temp :%s\n",arr_temp);
		//	printf("arr_sub :%s\n",arr_sub);
			find_arr(arr_temp,type);
			arr_size=arr_size*atoi(arr_sub);
		//	printf("buff :%s\n",buff);
			char buff1[1000];
			strcpy(buff1,"array(");
			strcat(buff1,arr_sub);
			strcat(buff1,",");
			strcat(buff1,buff);
			strcat(buff1,")");
			strcpy(buff,buff1);
		//	printf("buff1 :%s\n",buff1);
		}

}



void init_symbol_table()
{
	FILE *fptr = fopen("symbol_table.txt","w");
	fclose(fptr);
	FILE *fptr1 = fopen("error.txt","w");
	fclose(fptr1);
	top_stack_for_symbol_tables = 0;
	int *index_to_insert = &symbol_table_stack[top_stack_for_symbol_tables].index_to_insert;
	int i;
	//printf("index_to_insert %d\n",*index_to_insert);
	for(i=0;i<NO_OF_KEYWORD;i++)
	{
		strcpy(symbol_table_stack[top_stack_for_symbol_tables].symbol_table[*index_to_insert].name,keywords[i]);
		//printf("init_symbol_table %s\n",symbol_table_stack[top_stack_for_symbol_tables].symbol_table[*index_to_insert].name);
		strcpy(symbol_table_stack[top_stack_for_symbol_tables].symbol_table[*index_to_insert].type,"KEYWORD");
		strcpy(symbol_table_stack[top_stack_for_symbol_tables].symbol_table[*index_to_insert].value,"");
		symbol_table_stack[top_stack_for_symbol_tables].symbol_table[*index_to_insert].lineno=0;
		symbol_table_stack[top_stack_for_symbol_tables].symbol_table[*index_to_insert].size=0;
		//*(index_to_insert)++;
		symbol_table_stack[top_stack_for_symbol_tables].index_to_insert++;
		//printf("hello");
	}
	//display();
	//printf("\n");
	write_to_file();
}
int find_size(char *type)
{
	if(!strcmp(type,"int"))
		return 4;
	else if(!strcmp(type,"float"))
		return 4;
	else if(!strcmp(type,"char"))
		return 1;
}
void write_to_file()
{
	FILE *fptr = fopen("symbol_table.txt","a");
	int i = 0;
	if(top_stack_for_symbol_tables != -1)
	{
		int length = symbol_table_stack[top_stack_for_symbol_tables].index_to_insert;
		for(i=0;i<length;i++)
		{
			fprintf(fptr,"TYPE : %5s\t\t SIZE:%5d\t\t NAME : %5s\t\tVALUE : %5s\t\t SCOPE: %5d\t\t  LINENUMBER:%5d\t\t  \n ",symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].type,symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].size,symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].name,symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].value,top_stack_for_symbol_tables,symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].lineno);
		}
	}
	fprintf(fptr,"\n");
	fclose(fptr);
}

void struct_member_name(char* struct_name,int struct_index_to_insert)
{
	//printf("In struct_member_name function %s\n",symbol_table_stack[top_stack_for_symbol_tables].struct_defined[struct_index_to_insert].struct_name);
	int index_to_insert_member = symbol_table_stack[top_stack_for_symbol_tables].struct_defined[struct_index_to_insert].index_to_insert_member;
	int i;
	//printf("nested_struct_start_index %d\n",nested_struct_start_index);
	for(i=0;i<index_to_insert_member;i++)
	{
		strcat(symbol_table_stack[top_stack_for_symbol_tables].struct_defined[struct_index_to_insert].member_name[i],".");
		strcat(symbol_table_stack[top_stack_for_symbol_tables].struct_defined[struct_index_to_insert].member_name[i],struct_name);
		// not just structure name need to find the memnbers of this structure and concatenate all of them
		
	}
	//printf("nested struct name %s\n",symbol_table_stack[top_stack_for_symbol_tables].struct_defined[struct_index_to_insert].member_name[i-1]);
}

void coercion(char *type,char *value)
{	
	char buf[6];
	int i=0;
	int is_digit = 1;
	int is_decimal = 0;
	//printf("Type : %s Value : %s\n",type,value);
	while(value[i] != '\0')
	{
		if( isdigit(value[i]) || value[i] == '.')
		{
			if(value[i] == '.')
				is_decimal = 1; 
			//printf("value[%d] : %c\n",i,value[i]);
		}
		else
		{
			is_digit = 0;
			break;
		}
		i++;
	}
	//printf("is_digit : %d\n",is_digit);
	if(!strcmp(type,"int") && is_digit)
	{
		int temp = atoi(value);
		gcvt(temp,6,buf);
		buf[strlen(buf)] = '\0';
		strcpy(value,buf);
		if(is_decimal)
		{
			FILE *fptr = fopen("error.txt","a");
			error = 1;
			fprintf(fptr,"Warning : data loss may occur.Converting float to int\n");
			fclose(fptr);
		}
	}
	else if(!strcmp(type,"float") && is_digit)
	{
		float temp = atof(value);
		gcvt(temp,6,buf);
		buf[strlen(buf)] = '\0';
		strcpy(value,buf);
		//printf("Warning : Converting from int to float'\n");
	}
}


int search_my(char *name,int flag)
{
	//printf("Hello, I'm in search_my()");
	/*
	printf("-------------Inside Search--------------- \n");
	printf("scope %d\n",flag);
	printf("Name %s\n",name);
	printf("index_to_insert %d\n",symbol_table_stack[top_stack_for_symbol_tables].index_to_insert);
	printf("Symbol table's top Varaible Name %s\n",symbol_table_stack[top_stack_for_symbol_tables].symbol_table[0].name);
	printf("-------------Inside Search--------------- \n");
	*/
	if(!flag)
	{
		int length = symbol_table_stack[top_stack_for_symbol_tables].index_to_insert;
		int i = 0;
		while(i<length)
		{
			//printf("stuck here");
			if(!strcmp(name,symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].name))
				return -1;
			i++;
		}
	}

	return 1;
}

int push_my(char *type,char *name,char *value,int flag,int lineno,int size)
{
	if(top_stack_for_symbol_tables == MAX_SCOPE)
		printf("Cannot have more than %d Scope in a program",MAX_SCOPE);
	else
	{
		if( top_stack_for_symbol_tables != -1 && strlen(type) != 0 && search_my(name,flag) == -1 )
		//if(0)
		{
			FILE *fptr = fopen("error.txt","a");
			error = 1;
			fprintf(fptr,"Cannot have multiple decleration for same variable %s\n",name);
			fclose(fptr);
			return -1;	
		}
		else
		{
			if(flag == NEWSCOPE)
			{
				top_stack_for_symbol_tables++;
				scope = OLDSCOPE;
			}
			//if(flag != STRUCT_FLAG)
			{
				int index_to_insert = symbol_table_stack[top_stack_for_symbol_tables].index_to_insert;
				if(symbol_table_stack[top_stack_for_symbol_tables].index_to_insert <= MAX_SYMBOLS)
				{
					strcpy(symbol_table_stack[top_stack_for_symbol_tables].symbol_table[index_to_insert].name,name);
					strcpy(symbol_table_stack[top_stack_for_symbol_tables].symbol_table[index_to_insert].type,type);
					symbol_table_stack[top_stack_for_symbol_tables].symbol_table[index_to_insert].lineno=lineno;
					symbol_table_stack[top_stack_for_symbol_tables].symbol_table[index_to_insert].size=size;
					/*
					char buf[6];
					if(!strcmp(type,"float"))
					{
						float temp = atof(value);
						char buf[6];
						gcvt(temp,6,buf);
						buf[strlen(buf)] = '\0';
					}
					else if(!strcmp(type,"int"))
					{
						int temp = atoi(value);
						gcvt(temp,6,buf);
						buf[strlen(buf)] = '\0';
					}
					*/
					strcpy(symbol_table_stack[top_stack_for_symbol_tables].symbol_table[index_to_insert].value,value);
					symbol_table_stack[top_stack_for_symbol_tables].index_to_insert += 1;
					//printf("Name %s\n",symbol_table_stack[top_stack_for_symbol_tables].symbol_table[0].name);
					//printf("Value %s\n",symbol_table_stack[top_stack_for_symbol_tables].symbol_table[0].value);
					//printf("Type %s\n",symbol_table_stack[top_stack_for_symbol_tables].symbol_table[0].type);
				}
				else
				{
					printf("Cannot have more than %d Symbols in each scope",MAX_SYMBOLS);
					return -1;
				}
			}
			/*
			else
			{
				
			}
			*/
			return 0;
		}
	}
}

int pop_my()
{
	if(top_stack_for_symbol_tables == -1)
	{
		printf("No Scope Present");
		return -1;
	}
	// poping all the content of top_stack_for_symbol_tables by making corresponding index to zero.
	else
	{
		// setting index_to_insert of top_stack_for_symbol_tables to 0 
		symbol_table_stack[top_stack_for_symbol_tables].index_to_insert = 0;
		
		// setting struct_index_to_insert of top_stack_for_symbol_tables to 0 and also all the index_to_insert_member of struct_defined
		int struct_index_to_insert =  symbol_table_stack[top_stack_for_symbol_tables].struct_index_to_insert;
		int i;
		for(i = 0;i<struct_index_to_insert;i++)
			symbol_table_stack[top_stack_for_symbol_tables].struct_defined[i].index_to_insert_member = 0;
		symbol_table_stack[top_stack_for_symbol_tables].struct_index_to_insert = 0;
		
		// need to clear stack top before decrementing
		top_stack_for_symbol_tables--; 
		return 0;
	}
}

void display_struct()
{
	int i = 0;
	int j;
	if(top_stack_for_symbol_tables != -1)
	{
		int struct_index_to_insert = symbol_table_stack[top_stack_for_symbol_tables].struct_index_to_insert;
		for(i=0;i<struct_index_to_insert;i++)
		{
			//printf("Structure name %s\n",symbol_table_stack[top_stack_for_symbol_tables].struct_defined[i].struct_name);
			int index_to_insert_member = symbol_table_stack[top_stack_for_symbol_tables].struct_defined[i].index_to_insert_member;
			//printf("index_to_insert_member %d\n",index_to_insert_member);
			for(j=0;j<index_to_insert_member;j++)
			{
				printf("Type: %s NAME: %s LINE NUMBER: %d\n",symbol_table_stack[top_stack_for_symbol_tables].struct_defined[i].member_type[j],symbol_table_stack[top_stack_for_symbol_tables].struct_defined[i].member_name[j],symbol_table_stack[top_stack_for_symbol_tables].struct_defined[i].member_lineno[j]);
			}
			printf("\n");
		}
	}
}


void display()
{
	//printf("Display\n");
	int i = 0;
	if(top_stack_for_symbol_tables != -1)
	{
		//printf("Display\n");
		//printf("Display top_stack_for_symbol_tables %d \n",top_stack_for_symbol_tables);
		int length = symbol_table_stack[top_stack_for_symbol_tables].index_to_insert;
		//printf("Display index_to_insert %d \n",length);
		for(i=0;i<length;i++)
		{
			//printf("helllo");
			printf("TYPE : %s\tNAME : %s\tVALUE : %s\n",symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].type,symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].name,symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].value);
		}

		
	}
}


void display_full()
{
    FILE *f = fopen("display.txt","w");
	int i =0;
	for(i=0;i<10;i++)
	{
		fprintf(f,"scope/top of stack loop i %d\n\n",i );
		fprintf(f,"Index :%d\n",symbol_table_stack[i].index_to_insert);
		fprintf(f,"struct Index :%d\n",symbol_table_stack[i].struct_index_to_insert);
		for(int j=0;j<20;j++)
		{
			fprintf(f,"symbol table for each scope symbol j  %d\n",j );
			
			fprintf(f,"TYPE : %s\tNAME : %s\tVALUE : %s\n",symbol_table_stack[i].symbol_table[j].type,symbol_table_stack[i].symbol_table[j].name,symbol_table_stack[i].symbol_table[j].value);
		}

		for(int k=0;k<10;k++)
		{
			fprintf(f,"struct table for each scope struct   k %d\n",k );
			fprintf(f,"NAME: %s\n ",symbol_table_stack[i].struct_defined[k].struct_name);
	fprintf(f,"index to insert member: %d ",symbol_table_stack[i].struct_defined[k].index_to_insert_member);
			for(int h=0;h<10;h++)
			{
				fprintf(f,"struct table for each scope member h %d\n",h );
				fprintf(f,"struct table for each scope member name  %s\n", symbol_table_stack[i].struct_defined[k].member_name[h]);
                fprintf(f,"struct table for each scope member type  %s\n", symbol_table_stack[i].struct_defined[k].member_type[h]);
				
			}
			//frintf(f,"TYPE : %s\tNAME : %s\tVALUE : %s\n",symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].type,symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].name,symbol_table_stack[top_stack_for_symbol_tables].symbol_table[i].value);
		}
	}
fclose(f);
}

void fun(char *result ,char *arg1,char *arg2,char *arg3)
{

    printf("In function fun   arg1,arg2,arg3: %s %s %s\n", arg1,arg2,arg3);
	/*
	int i = 0;
	int flag = 0;
	if(arg1[i] == '(')
	{
		i+=1;
		flag = 1;
	}
	*/
	int arg1_length = strlen(arg1);
	int arg3_length = strlen(arg3);
	int i=arg1_length-1;
	int j = 0;
	if((isdigit(arg1[i]) | arg1[i] == '.') || (isdigit(arg3[j])  | arg3[j] == '.'))
	{
		float temp; 
		//if(!strcmp(arg2,"*"))
		{
			//printf("result %s arg1 %s arg2 %s arg3 %s\n",result,arg1,arg2,arg3);
			//int arg1_length = strlen(arg1);
			//int arg3_length = strlen(arg3);
			//int i=arg1_length-1;
			//int j = 0;
			while((i >= 0) && (isdigit(arg1[i]) | arg1[i] == '.'))
			{
				//printf("stuck\n");
				i--;
			}
			
			while((j < arg3_length) && (isdigit(arg3[j])  | arg3[j] == '.'))
			{
				//printf("stuck\n");
				j++;
			}
			
			if(i+1 <= arg1_length-1 && j-1 >= 0)
			{
				//printf("i %d\n",i);
				char temp_arg3[j];
				strncpy(temp_arg3,arg3,j);
				//printf("j %d\n",j-1);
				//printf("arg1 %s \n",arg1+(i+1));
				//printf("arg3 %s \n",temp_arg3);
				if(!strcmp(arg2,"*"))
					temp = atof(arg1+(i+1)) * atof(temp_arg3);
				else if(!strcmp(arg2,"/"))
					temp = atof(arg1+(i+1)) / atof(temp_arg3);
				else if(!strcmp(arg2,"%"))
					temp = atoi(arg1+(i+1)) % atoi(temp_arg3);
				else if(!strcmp(arg2,"+"))
					temp = atof(arg1+(i+1)) + atof(temp_arg3);
				else if(!strcmp(arg2,"-"))
					temp = atof(arg1+(i+1)) - atof(temp_arg3);
				else if(!strcmp(arg2,"<"))
					temp = atof(arg1+(i+1)) < atof(temp_arg3);
				else if(!strcmp(arg2,"&&"))
					temp = atof(arg1+(i+1)) && atof(temp_arg3);
				else if(!strcmp(arg2,"||"))
					temp = atof(arg1+(i+1)) || atof(temp_arg3);
				else if(!strcmp(arg2,">"))
					temp = atof(arg1+(i+1)) > atof(temp_arg3);
				else if(!strcmp(arg2,">="))
					temp = atof(arg1+(i+1)) >= atof(temp_arg3);
				else if(!strcmp(arg2,"<="))
					temp = atof(arg1+(i+1)) <= atof(temp_arg3);
				else if(!strcmp(arg2,"!="))
					temp = atof(arg1+(i+1)) != atof(temp_arg3);
				else if(!strcmp(arg2,"=="))
					temp = atof(arg1+(i+1)) == atof(temp_arg3);
				
				char buf[128];
				gcvt(temp,6,buf);
				
				strcat(buf,arg3+j);
				
				strncpy(arg1+i+1,buf,sizeof(buf));
				
				strcpy(result,arg1);
				
				return;
			}
			else
			{
				printf(" in else for finding value of arg3 %s:\n", arg3);
				if(isdigit(arg1[0]))    // arg1 is digit, arg 3 is not
                {
                    float value = find_variable_value(arg3);// call that function
                    if(!value)
                    { printf("no variable in scope: %s\n", arg3);strcpy(result,"");return;}
                    if(!strcmp(arg2,"*"))
					temp = atof(arg1) * value;
				else if(!strcmp(arg2,"/"))
					temp = atof(arg1) / value;
				else if(!strcmp(arg2,"%"))
					temp = atoi(arg1) % (int)value;
				else if(!strcmp(arg2,"+"))
					temp = atof(arg1) + value;
				else if(!strcmp(arg2,"-"))
					temp = atof(arg1) - value;
				else if(!strcmp(arg2,"<"))
					temp = atof(arg1) < value;
				else if(!strcmp(arg2,"&&"))
					temp = atof(arg1) && value;
				else if(!strcmp(arg2,"||"))
					temp = atof(arg1) || value;
				else if(!strcmp(arg2,">"))
					temp = atof(arg1) > value;
				else if(!strcmp(arg2,">="))
					temp = atof(arg1) >= value;
				else if(!strcmp(arg2,"<="))
					temp = atof(arg1) <= value;
				else if(!strcmp(arg2,"!="))
					temp =atof(arg1) != value;
				else if(!strcmp(arg2,"=="))
					temp = atof(arg1) == value;
				char buff[30];
				sprintf(buff,"%f",temp);
				strcpy(result,buff);
				
				return;

                }

                else
                {
					printf("in else for finding value of arg1 %s:\n", arg1);
                     float value = find_variable_value(arg1);// call that function
                     if(!value)
                    { printf("no variable in scope: %s\n", arg1);strcpy(result,"");return;}
                    if(!strcmp(arg2,"*"))
					temp = value * atof(arg3);
				else if(!strcmp(arg2,"/"))
					temp = value / atof(arg3);
				else if(!strcmp(arg2,"%"))
					temp = (int)value % atoi(arg3);
				else if(!strcmp(arg2,"+"))
					temp = value + atof(arg3);
				else if(!strcmp(arg2,"-"))
					temp = value - atof(arg3);
				else if(!strcmp(arg2,"<"))
					temp = value < atof(arg3);
				else if(!strcmp(arg2,"&&"))
					temp = value && atof(arg3);
				else if(!strcmp(arg2,"||"))
					temp = value || atof(arg3);
				else if(!strcmp(arg2,">"))
					temp = value > atof(arg3);
				else if(!strcmp(arg2,">="))
					temp = value >= atof(arg3);
				else if(!strcmp(arg2,"<="))
					temp = value <= atof(arg3);
				else if(!strcmp(arg2,"!="))
					temp = value != atof(arg3);
				else if(!strcmp(arg2,"=="))
					temp = value == atof(arg3);
				char buff[30];
				sprintf(buff,"%f",temp);
				strcpy(result,buff);
				
				return;
                }
				
				return;
			}
			//temp = atof(arg1) * atof(arg3);
		}
		/*
		else if(!strcmp(arg2,"/"))
			temp = atof(arg1) / atof(arg3);
		else if(!strcmp(arg2,"%"))
			temp = atoi(arg1) % atoi(arg3);
		else if(!strcmp(arg2,"+"))
			temp = atof(arg1) + atof(arg3);
		else if(!strcmp(arg2,"-"))
			temp = atof(arg1) - atof(arg3);
		else if(!strcmp(arg2,"<"))
			temp = atof(arg1) < atof(arg3);
		else if(!strcmp(arg2,">"))
			temp = atof(arg1) > atof(arg3);
		else if(!strcmp(arg2,"="))
		{
		}
		gcvt(temp,6,result);
		result[strlen(result)] = '\0';
		printf("In Else -> Result for %s * %s : %s\n",arg1,arg3,result);
		*/
	}
	else
	{
		float temp; 
		printf(" in outer else for finding value of arg1 and arg3  %s  %s:\n", arg1, arg3);
		float value = find_variable_value(arg1);// call that function
        float value1 = find_variable_value(arg3);
                     if(!value)
                    { printf("no variable in scope: %s\n", arg1);strcpy(result,"");return;}
                    if(!value1)
                    { printf("no variable in scope: %s\n", arg1);strcpy(result,"");return;}
                    if(!strcmp(arg2,"*"))
					temp = value * value1;
				else if(!strcmp(arg2,"/"))
					temp = value / value1;
				else if(!strcmp(arg2,"%"))
					temp = (int)value % (int)value1;
				else if(!strcmp(arg2,"+"))
					temp = value + value1;
				else if(!strcmp(arg2,"-"))
					temp = value - value1;
				else if(!strcmp(arg2,"<"))
					temp = value < value1;
				else if(!strcmp(arg2,"&&"))
					temp = value && value1;
				else if(!strcmp(arg2,"||"))
					temp = value || value1;
				else if(!strcmp(arg2,">"))
					temp = value > value1;
				else if(!strcmp(arg2,">="))
					temp = value >= value1;
				else if(!strcmp(arg2,"<="))
					temp = value <= value1;
				else if(!strcmp(arg2,"!="))
					temp = value != value1;
				else if(!strcmp(arg2,"=="))
					temp = value == value1;
				char buff[30];
				sprintf(buff,"%f",temp);
				strcpy(result,buff);
				
				return;
	}	
}

/*
void fun(char *result ,char *arg1,char *arg2,char *arg3)
{
	
	printf("fun:  %s %s %s\n",arg1,arg2,arg3);
	int arg1_length = strlen(arg1);
	int arg3_length = strlen(arg3);
	int i=arg1_length-1;
	int j = 0;
	if((isdigit(arg1[i]) | arg1[i] == '.') || (isdigit(arg3[j])  | arg3[j] == '.'))
	{
		float temp; 
		//if(!strcmp(arg2,"*"))
		{
			//printf("result %s arg1 %s arg2 %s arg3 %s\n",result,arg1,arg2,arg3);
			//int arg1_length = strlen(arg1);
			//int arg3_length = strlen(arg3);
			//int i=arg1_length-1;
			//int j = 0;
			while((i >= 0) && (isdigit(arg1[i]) | arg1[i] == '.'))
			{
				//printf("stuck\n");
				i--;
			}
			
			while((j < arg3_length) && (isdigit(arg3[j])  | arg3[j] == '.'))
			{
				//printf("stuck\n");
				j++;
			}
			
			if(i+1 <= arg1_length-1 && j-1 >= 0)
			{
				//printf("i %d\n",i);
				char temp_arg3[j];
				strncpy(temp_arg3,arg3,j);
				//printf("j %d\n",j-1);
				//printf("arg1 %s \n",arg1+(i+1));
				//printf("arg3 %s \n",temp_arg3);
				if(!strcmp(arg2,"*"))
					temp = atof(arg1+(i+1)) * atof(temp_arg3);
				else if(!strcmp(arg2,"/"))
					temp = atof(arg1+(i+1)) / atof(temp_arg3);
				else if(!strcmp(arg2,"%"))
					temp = atoi(arg1+(i+1)) % atoi(temp_arg3);
				else if(!strcmp(arg2,"+"))
					temp = atof(arg1+(i+1)) + atof(temp_arg3);
				else if(!strcmp(arg2,"-"))
					temp = atof(arg1+(i+1)) - atof(temp_arg3);
				else if(!strcmp(arg2,"<"))
					temp = atof(arg1+(i+1)) < atof(temp_arg3);
				else if(!strcmp(arg2,"&&"))
					temp = atof(arg1+(i+1)) && atof(temp_arg3);
				else if(!strcmp(arg2,"||"))
					temp = atof(arg1+(i+1)) || atof(temp_arg3);
				else if(!strcmp(arg2,">"))
					temp = atof(arg1+(i+1)) > atof(temp_arg3);
				else if(!strcmp(arg2,">="))
					temp = atof(arg1+(i+1)) >= atof(temp_arg3);
				else if(!strcmp(arg2,"<="))
					temp = atof(arg1+(i+1)) <= atof(temp_arg3);
				else if(!strcmp(arg2,"!="))
					temp = atof(arg1+(i+1)) != atof(temp_arg3);
				else if(!strcmp(arg2,"=="))
					temp = atof(arg1+(i+1)) == atof(temp_arg3);
				
				char buf[128];
				gcvt(temp,6,buf);
			
				//buf[strlen(buf)] = '\0';
				strcat(buf,arg3+j);
				//printf("result %s\n",result);
				//printf("arg1 %s \n",arg1);
				//printf("arg2 %s \n",arg2);
				//printf("arg3 %s \n",arg3);
				//printf("buf %s\n",buf);
				//printf("arg1+i+1 %s\n",arg1+i+1);
				//printf("arg1 %s\n",arg1);
				strncpy(arg1+i+1,buf,sizeof(buf));
				//arg1[strlen(arg1)] = '\0';
				
				//printf("\n");
				strcpy(result,arg1);
				//printf("arg1 %s \n",arg1);
				//printf("result %s \n",result);
				//strcat(result,buf);
				return;
			}
			else
			{

				printf("in else part of fun function arg1 =  %s arg3 = %s\n",arg1,arg3);
				strncpy(result,arg1,sizeof(arg1));
				strcat(result,arg2);
				//result[strlen(result)] = '\0';
				strcat(result,arg3);
				result[strlen(result)] = '\0';
				//printf("res %s\n",result);
				return;
			}
			//temp = atof(arg1) * atof(arg3);
		}
		
	}
	else
	{
		printf("in outer else part of fun function arg1 =  %s arg3 = %s\n",arg1,arg3);
		char *p[128];
		strncpy(result,arg1,sizeof(arg1));
		//strcat(result,arg1);
		result[strlen(result)] = '\0';
		//printf("result 1 %s\n",result);
		//printf("arg2 %s\n",arg2);
		//strncpy(result+strlen(result),arg2,2);
		strcat(result,arg2);
		result[strlen(result)] = '\0';
		//printf("result 2 %s \n",result);
		//printf("arg3 %s \n",arg3);
		//strncpy(result+strlen(result),arg3,strlen(arg3));
		strcat(result,arg3);
		result[strlen(result)] = '\0';
		//printf("In If -> Result for %s * %s : %s\n",arg1,arg3,result);
	}	
}
*/
float find_variable_value(char *name)
{
	char *temp_name;
	for(int i=top_stack_for_symbol_tables;i>=0;i--)
	{
		int index_to_insert = symbol_table_stack[i].index_to_insert;
	//printf("name : %s",name);
		for(int j=0;j<index_to_insert;j++)
		{
			temp_name = symbol_table_stack[i].symbol_table[j].name;
			//printf("temp_name : %s",temp_name);
			if(!strcmp(temp_name,name))
			{
					// if value is not there.. is it an error? 
				//strcpy(symbol_table_stack[i].symbol_table[j].value,value);
				return atof(symbol_table_stack[i].symbol_table[j].value);
			}
		}
	}
	return -1;
}

int update_variable_value(char *name,char *value)
{
	int i,j;
	int index_to_insert;
	char *temp_name;
	for(i=top_stack_for_symbol_tables;i>=0;i--)
	{
		index_to_insert = symbol_table_stack[i].index_to_insert;
	//printf("name : %s",name);
		for(j=0;j<index_to_insert;j++)
		{
			temp_name = symbol_table_stack[i].symbol_table[j].name;
			//printf("temp_name : %s",temp_name);
			if(!strcmp(temp_name,name))
			{
				if(strlen(value) == 0)
					return 1;
				value[strlen(value)] = '\0';	// to ensure value string is null terminated
				strcpy(symbol_table_stack[i].symbol_table[j].value,value);
				return 1;
			}
		}
	}
	return -1;	
}

void check(char *arg1,char *arg3)
{
	char temp_name[128];
	int i=0;
	//printf("arg1 : %s arg3 : %s\n",arg1,arg3);
	int flag_operator = 0;	// means argument passed doesn't have operator
	int value;
	if( !isdigit(arg1[0]) && arg1[0] != '(' )
	{
		// for ensuring no operator is present in argument passed. Ex = (p*q-1)	gives arg1 = p*q and arg3 = 1
		while( arg1[i] != '\0' )
		{
			if( !isalnum(arg1[i]) )
			{
				flag_operator = 1;				
				break;
			}
			i++;
		}
		//printf("check flag %d\n",flag_operator);	
		if( !flag_operator )
		{
			// check if varaible in arg1 is present in symbol table or not
			value = update_variable_value(arg1,"");
			if(value == -1)
			{
				not_defined = 1;
				FILE *fptr = fopen("error.txt","a");
				fprintf(fptr,"Varaible %s is not defined\n",arg1);
				error = 1;
				fclose(fptr);
			}
		}
	}
	i=0;
	flag_operator = 0;
	if( !isdigit(arg3[0]) && arg3[0] != '(' )
	{
		while( arg3[i] != '\0' )
		{
			if( !isalnum(arg3[i]) )
			{
				flag_operator = 1;				
				break;
			}
			i++;
		}
		if( !flag_operator )
		{
			//check if varaible in arg1 is present in symbol table or not
			value = update_variable_value(arg3,"");
			if(value == -1)
			{
				not_defined = 1;
				FILE *fptr = fopen("error.txt","a");
				fprintf(fptr,"Varaible %s is not defined\n",arg3);
				error = 1;
				fclose(fptr);
			}
		}
	}
	
}

int add_struct_member_in_symbol_table(char *struct_name)
{
	// to make sure struct_name is null terminated
	printf("add_struct_member_ struct name : %s\n",struct_name);
	struct_name[strlen(struct_name)] = '\0';
	
	//int index_to_insert = symbol_table_stack[top_stack_for_symbol_tables].index_to_insert;
	int last_struct_inserted_index = symbol_table_stack[top_stack_for_symbol_tables].struct_index_to_insert - 1;
	
	int last_insert_index_member_struct = symbol_table_stack[top_stack_for_symbol_tables].struct_defined[last_struct_inserted_index].index_to_insert_member;
	
	printf("add_struct_member_  last_struct_inserted_index( scope of struct )   : %d       last_insert_index_member_struct( which structure in a given scope):%d    \n",last_struct_inserted_index,last_insert_index_member_struct);
	int j=0,i;	// index for member of struct;
	char *type;
	char *var_name;
	int var_size;
	int var_lineno;
	char name[128];
	int mem_scope =scope;
	printf("%d memscope",mem_scope);
	for(i=0;i<last_insert_index_member_struct;i++)
	{
		printf("add_struct_member i: %d \n",i);
		type = symbol_table_stack[top_stack_for_symbol_tables].struct_defined[last_struct_inserted_index].member_type[j];
		var_name = symbol_table_stack[top_stack_for_symbol_tables].struct_defined[last_struct_inserted_index].member_name[j];
		var_lineno = symbol_table_stack[top_stack_for_symbol_tables].struct_defined[last_struct_inserted_index].member_lineno[j];
		var_size = symbol_table_stack[top_stack_for_symbol_tables].struct_defined[last_struct_inserted_index].member_size[j];
		strcpy(name,struct_name);
		strcat(name,".");
		strcat(name,var_name);
		name[strlen(name)] = '\0';
		j++;
		printf("type %s         var_name %s         name %s       scope %d \n",type,var_name,name,mem_scope);
		push_my(type,name,"",mem_scope,var_lineno,var_size);
	}
}

void struct_member(char *type,char *name,int lineno,int size)
{
	if(scope == NEWSCOPE)
	{
		++top_stack_for_symbol_tables;
		scope = OLDSCOPE;
		//printf("inside struct\n");
	}
	int *struct_index_to_insert = &symbol_table_stack[top_stack_for_symbol_tables].struct_index_to_insert;
	//int *index_to_insert_member = &symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].index_to_insert_member;
	if(strlen(type) != 0 && strlen(name) != 0)
	{
		//printf("Struct member name %s\n",name);
		//printf("Struct member type %s\n",type);
		int *index_to_insert_member;
		printf("struct_reference_used %d\n", struct_reference_used);
		if(struct_reference_used == 0 && !strcmp(type,"struct")) 
		{
			//printf("!!!!!!!!!!!!!\n");
			*struct_index_to_insert -= 1;
			symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].struct_name[0] = '\0';
			index_to_insert_member = &symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].index_to_insert_member;
			int i;
			//printf("nested_struct_start_index %d\n",nested_struct_start_index);
			char new_name[3*LIMIT];
	
			for(i=nested_struct_start_index;i<*index_to_insert_member;i++)
			{	printf("i in nested_struct_start_index  %d\n",i);
				strcpy(new_name,name);
				strcat(new_name,".");
				strcat(new_name,symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].member_name[i]);
				printf("new name %s\n",new_name);
				strcpy(symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].member_name[i],new_name);
				//strcat(symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].member_name[i],".");
				//strcat(symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].member_name[i],name);
			}
			//printf("nested struct name %s\n",symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].member_name[i-1]);
			//printf("nested struct name %s\n",symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].member_type[i-1]);
		}
		else
		{
			index_to_insert_member = &symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].index_to_insert_member;
			//printf("struct_index_to_insert %d\n",*struct_index_to_insert);

			//printf("index_to_insert_member %d\n",*index_to_insert_member);
			strcpy(symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].member_type[*index_to_insert_member],type);
			strcpy(symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].member_name[*index_to_insert_member],name);
			symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].member_lineno[*index_to_insert_member]=lineno;
			symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].member_size[*index_to_insert_member]=size;
			*index_to_insert_member += 1;
			struct_reference_used = 0;
		}
	}
	else
	{
		//printf("Struct name %s\n",name);
		strcpy(symbol_table_stack[top_stack_for_symbol_tables].struct_defined[*struct_index_to_insert].struct_name,name);
		*struct_index_to_insert += 1;
	}
}
