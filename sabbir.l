char [a-zA-Z]
digit [0-9]
special [$_@]
space " "
newline "\n"
Datatype "Integer"|"Double"|"Type_Char"|"Type_Void"
Operator "Op_Equ"|"Op_Plus"|"Op_Minus"|"Op_Divide"|"Op_Multiply"|"Op_And"|"Op_Or"|"Op_Mod"
Relational_Operator "Ro_GT"|"Ro_LT"|"Ro_GE"|"Ro_LE"|"Ro_And"|"Ro_Or"|"Ro_Equ"|"Ro_Equ"|"Ro_NEqu"

%{
	#include "sabbir.tab.h"
	#include<stdio.h>
	#include <string.h>
	#include<stdlib.h>
%}



%%
{space}|{newline} {}
"#".*"#" {/*This is comment*/}
"," {return COMA;}
{digit}+"."{digit}+	{
				yylval.val = atoi(yytext);
				return DNUM;
			}
{digit}+ 	{
				yylval.val = atoi(yytext);
				return NUM;
			}

"start" { return MAIN; }
"Print_Var" { return PRINTVAR;}
"Print_str" {return PRINTSTR;}
"Print_Line" {return PRINTLN;}

"Func_"({char}|{digit}|{special})+ {return FUNCTION;}

"$"({char}|{digit}|{special})+ { strcpy(yylval.text,yytext);return ID;}

"Integer" {  return INT;}
"DInt" { return DOUBLE;}
"Char" { return CHAR;}

"Scan" {return SCAN;}

"(_" { return B1; }
"_)"  { return E1; }
"{_" { return B2; }
"_}"  { return E2; }
"[_" { return B3; }
"_]"  { return E3; }

"<-" {return ASGN;}
"Plus" {return PLUS;}
"Minus" {return MINUS;}
"Multiply" {return MULTIPLY;}
"Divide" {return DIVISION;}

"greater" { return GREATER;}
"less" { return LESS;}
"=" {return EQUAL;}

"If" {return IF;}
"Elif" {return ELIF;}
"Else" {return ELSE;}

"loop" {return FOR;}
"IncrementBy" {return INC;}
"To" {return TO;}
"looping" {return WHILE;}

"options" {return SWITCH;}
"option" {return CASE;}
"none" {return DEFAULT;}

":" {return COL;}
";;" {return END_STATEMENT;}
. {}


"\""(.)*"\"" {strcpy(yylval.text,yytext);return STR;}




%%


int yywrap()
{
	return 1;
}


