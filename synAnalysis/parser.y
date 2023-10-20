%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
%}


%union{
  int d;
  char* s;
  char c;
}





%token PRINT ID
%token  STRING SEMICOLON DATA_TYPE

// SYMBOL'S
%token LP RP LC RC LB RB COMMA

// OPERATOR
%token  LO_OP CO_OP AR_OP AND OR NOT

// CONDTIONAL STRING
%token IF ELSE

// CONSTANT
%token INT FLOAT  CHAR_LITERAL

%token BREAK CONTINUE RETURN
%%
s :b  { printf("valid syntax\n");return 0;}
  ;
b :component b
  |
  ;
component :stmt 
          |ifelse {printf("\tvalid ifelse\n");}
          |exp
          ;
stmt :dec {printf("\tvalid declaration\n");}
     |def {printf("\tvalid definition\n");}
     |funCall
     |dec_def {printf("\tvalid initialization at definition time\n");}
     |BREAK SEMICOLON {printf("\tvalid break Statement\n");}
     |CONTINUE SEMICOLON {printf("\tvalid continue Statement\n");}
     |RETURN SEMICOLON {printf("\tvalid return Statement\n");}
     ;
dec :DATA_TYPE ID SEMICOLON
    ;
def :ID '=' exp SEMICOLON
    ;
dec_def :DATA_TYPE ID '=' exp SEMICOLON
        ;
funCall :stdFun
        ;
stdFun :print {printf("\tvalid printf \n");}
       ;
print :PRINT LP STRING RP SEMICOLON 
      |PRINT LP STRING arg RP SEMICOLON 
      ;
arg :COMMA ID arg 
    |
    ;

ifelse :IF LP exp RP stmt 
       ;
exp :co_exp {printf("\tvalid comparison expression\n");}
    |ar_exp {printf("\tvalid arithmetic expression\n");}
    |lo_exp {printf("\tvalid logical expression\n");}
    |funCall
    |INT 
    |FLOAT 
    |CHAR_LITERAL
    ;
co_exp :x CO_OP x
       ;
x :INT
  |FLOAT
  |ID
  ;
ar_exp :x AR_OP x
       ;
lo_exp :exp AND exp
       |exp OR exp
       |NOT exp
       ;



%%

int main(){
    // printf("Enter Statement:");

      yyparse();
    
    

}

int yyerror(char *err){
    fprintf(stderr,"%s\n","invalid syntax");
}