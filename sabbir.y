%{
	#include<stdio.h>
	#include<stdlib.h>
	#include <string.h>
	FILE *yyin,*yyout;
	int yylex ();
	int yyerror();

	int switchdone = 0;
	int switchvar;

	int ifval[1000];
	int ifptr = -1;
	int ifdone[1000];

    int ptr = 0;
    int value[1000];
    char varlist[1000][1000];
	int isdeclared(char str[]){
        int i;
        for(i = 0; i < ptr; i++){
            if(strcmp(varlist[i],str) == 0) return 1;
        }
        return 0;
    }
    int addnewval(char str[],int val){
        if(isdeclared(str) == 1) return 0;
        strcpy(varlist[ptr],str);
        value[ptr] = val;
        ptr++;
        return 1;
    }

    int getval(char str[]){
        int indx = -1;
        int i;
        for(i = 0; i < ptr; i++){
            if(strcmp(varlist[i],str) == 0) {
                indx = i;
                break;
            }
        }
		if(indx==-1)
		{
			return 0;
		}
        return value[indx];
    }
    int setval(char str[], int val){
    	int indx = -1;
        int i;
        for(i = 0; i < ptr; i++){
            if(strcmp(varlist[i],str) == 0) {
                indx = i;
                break;
            }
        }
		if(indx!=-1)
        value[indx] = val;

	

    }


%}

%union {
  char text[10000];
  int val;
  double dval;
}


%token <text>  ID
%token <val>  NUM 
%token <dval> DNUM
%token <text> STR

%type <val> expression
%type <text> LoopStatement
%type <text> Lprint
%type <val> ifexp


%left LESS GREATER
%left PLUS MINUS
%left MULESS DIV

%token  EQUAL
%token SCAN WHILE
%token INT DOUBLE CHAR MAIN 
%token B1 B2 B3 E1 E2 E3 
%token DOT COMA ASGN END_STATEMENT
%token PRINTVAR PRINTSTR PRINTLN 
%token PLUS MINUS MULTIPLY DIVISION 
%token LESS GREATER LE GE 
%token IF ELSE ELIF 
%token FOR INC TO SWITCH CASE DEFAULT COL FUNCTION
%nonassoc IFX 
%nonassoc ELSE
%left SH


%%

starthere 	: {}
			|function program function {printf("start\n");}
		
			;

program :INT MAIN B1 E1 B2 statement E2 {printf("\nCompilation Successful..\n")}
            ;
statement	: 
			| statement declaration
			| statement print
			| statement expression 
			| statement ifelseladder
			| statement assign
			| statement forloop
			| statement switching
			| statement whileloop
			;


declaration : type variables END_STATEMENT {}
			;
type		: INT {printf("int defined\n")}
			| DOUBLE {printf("double defined\n")}	
			| CHAR {printf("char defined\n")}
			;
variables	: variable COMA variables {}
			| variable {}
			;
variable   	: ID 	
					{
						printf("%s\n",$1);
						int x = addnewval($1,0);
						if(!x) {
							printf("Compilation Error:Variable %s is already declared\n",$1);
							exit(-1);
						}

					}
			| ID ASGN expression 	
					{
						printf("%s %d\n",$1,$3);
						int x = addnewval($1,$3);
						if(!x) {
							printf("Compilation Error: Variable %s is already declared\n",$1);
							exit(-1);
							}
					}

			;


assign : ID ASGN expression END_STATEMENT
					{   printf("inside assign %s\n",$1);
						setval($1,$3);
					
				    }
		| SCAN B1 ID E1 END_STATEMENT
		{
			int tmp;
			tmp = 7;
			printf("scanning something\n");
			scanf("%d", &tmp);
			
			setval($3, tmp);
		}
		;



print		: PRINTVAR B1 ID E1 END_STATEMENT 	
					{
						if(!isdeclared($3)){
							printf("Compilation Error: Variable %s is not declared\n",$3);
							exit(-1);
						}
						else{
							int v = getval($3);
							printf("%d",v);
						}
					}
			| PRINTSTR B1 STR E1 END_STATEMENT
		 
					{
						int l = strlen($3);
						int i;
						for(i = 1;  i < l-1; i++) printf("%c",$3[i]);
					}
			| PRINTLN B1 E1 END_STATEMENT
		 	
					{
						printf("\n");
					}
			;



/*--------printing end------------*/




/*--------expression Begin--------*/

expression : NUM {$$ = $1;}
			|DNUM {$$ = $1;}
			| ID 	
					{  printf("assign\n");
						if(!isdeclared($1)) {
							printf("Compilation Error: Variable %s is not declared\n",$1);
							exit(-1);
						}
						else{
							printf("not declared\n");
							$$ = getval($1);
						}
				 	}
			| expression PLUS expression 
					{$$ = $1 + $3;}
			| expression MINUS expression 
					{$$ = $1 - $3;}
			| expression MULTIPLY expression 
					{$$ = $1 * $3;}
			| expression DIVISION expression 
					{
						if($3) {
 							$$ = $1 / $3;
							}
				  		else {
							$$ = 0;
							printf("\nRuntime Error: division by zero\t");
							exit(-1);
				  		} 
					}
			| expression LESS
			 expression	
					{ $$ = $1 < $3; }
			| expression GREATER  expression	
					{ $$ = $1 > $3; }
			| expression LE expression	
					{ $$ = $1 <= $3; }
			| expression GE expression	
					{ $$ = $1 >= $3; }
			| B1 expression E1  
					{$$ = $2;}
			;


/*--------expression End--------*/


/*---------ifelse begin----------*/

ifelseladder 	: IF B1 ifexp E1 B2 LoopStatement E2 elseif
					{   printf("inside ifelse\n");
						if($3)
						printf("%s", $6);
						ifdone[ifptr] = 0;
						ifptr--;
					}
		;
ifexp	: expression 
					{
						ifptr++;
						ifdone[ifptr] = 0;
						if($1){
							printf("\nIf executed\n");
							ifdone[ifptr] = 1;
						}
						$$ = $1;
					}
		;
elseif 	: /* empty */
		| elseif ELIF B1 expression E1 B2 LoopStatement E2 
					{
						if($4 && ifdone[ifptr] == 0){
							printf("%s", $7);
							printf("\nElse if block expressin %d executed\n",$4);
							ifdone[ifptr] = 1;
						}
					}
		| elseif ELSE B2 LoopStatement E2 
					{
						if(ifdone[ifptr] == 0){
							printf("%s", $4);
							printf("\nElse block executed\n");
							ifdone[ifptr] = 1;
						}
					}

		;


whileloop : WHILE B1 ID LESS NUM E1 B2 LoopStatement E2  
		{
			int tmp = getval($3);
			while(tmp<$5)
			{
				printf("%d ", tmp);
				printf("%s",$8);
				
				
				tmp = tmp+1;
			}
			setval($3, tmp);

		}
		| WHILE B1 ID GREATER   NUM E1 B2 LoopStatement E2  
		{
			int tmp = getval($3);
			while(tmp>$5)
			{
				printf("%d ", tmp);
				
				printf("%s",$8);
				
				tmp = tmp-1;
			}
			setval($3, tmp);

		}
		;

/*--------while end------------*/


/*------foor loop begin----------*/




forloop	: FOR B1 expression TO expression INC expression E1 B2 LoopStatement E2 
					{
						int st = $3;
						int ed = $5;
						int dif = $7;
						int cnt = 0;
						int k = 0;
						//printf(" hhel : \n%s\n", $10);
						for(k = st; k <= ed; k += dif){
							cnt++;
							int r ;
							if(strlen($10)!=0)
							printf("%s\n", $10);
						}	
						printf("Loop executes %d times\n",cnt+2);
					}
					;

LoopStatement: { strcpy($$,"");}
			| LoopStatement Lprint {
				 strcat($$, $2);
				}
			;

Lprint		: PRINTVAR B1 ID E1 END_STATEMENT 	
					{
						char val[1000];
						strcpy(val, "");
						if(!isdeclared($3)){
							strcat(val, "Compilation Error: Variable ");

							char tmp[20];
							sprintf(tmp, "%s ", $3);
							strcat(val, tmp);
							strcat( val,"is not declared\n");
							printf("%s", val);
							exit(-1);
							strcpy($$, val);
						}
						else{
							char val[1000];
							strcpy(val, "");
							int v = getval($3);
							char tmp[18];
							sprintf(tmp, "%d", v);
							//strcpy(tmp,atoi(v));
							//printf(" v er value : %d - %s\n ", v, tmp);
							strcat(val, tmp);
							strcpy($$, val);

							//printf("%d",v);
						}
					}
			| PRINTSTR B1 STR E1 END_STATEMENT
		 
					{
						char val[10000];
						strcpy(val, "");
						int l = strlen($3);
						int i;
						for(i = 1;  i < l-1; i++) 
						{
							char tmp[20];
							sprintf(tmp, "%c", $3[i]);
							strcat(val, tmp);
						}
						strcpy($$, val);
					}
			| PRINTLN B1 E1 END_STATEMENT
		 	
					{
						strcpy($$, "\n");
					}
			;




/*------foor loop end------------*/


/*------switch case begin--------*/

switching	: SWITCH B1 expswitch E1 B2 switchinside E2 
		;

expswitch 	:  expression 
					{
						switchdone = 0;
						switchvar = $1;
					}
			;


switchinside	: /* empty */
				| switchinside expression COL B2 statement E2 
					{
						if($2 == switchvar){
							printf("Executed %d\n",$2);
							switchdone = 1;
						}					
					}
				| switchinside DEFAULT COL B2 statement E2 
					{
						if(switchdone == 0){
							switchdone = 1;
							printf("Default Block executed\n");
						}
					}
				;


/*------switch case end----------*/

/*------function begin-----------*/

function 	: /* empty */
			| function func {printf("function called\n")}
			;

func 	: type FUNCTION B1 fparameter E1 B2 statement E2
					{
						printf("Function Declared\n");
					}
		;
fparameter 	: /* empty */
			| type ID fsparameter
			;
fsparameter : /* empty */
			| fsparameter COMA  type ID
			;


/*-------function end------------*/
%%


int yyerror(char *s){
	printf( "%s\n", s);
}
int main(){
	yyin = fopen("input.txt","r");
	yyout = fopen("output.txt","w");
	printf("working\n");
	yyparse();
}