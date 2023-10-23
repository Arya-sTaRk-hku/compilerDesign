%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    void yyerror(char*);
%}


// %union{
//   int d;
//   char* s;
//   char c;
// }





%token PRINT ID
%token  STRING SEMICOLON DATA_TYPE PTR_TYPE

// SYMBOL'S
%token LP RP LCB RCB LSB RSB COMMA DOUBLE_QUOTE
// OPERATOR
%token  LO_OP CO_OP AR_OP AND OR NOT LOP GOP

// CONDTIONAL STRING
%token IF ELSE

// CONSTANT
%token INT FLOAT  CHAR_LITERAL

%token BREAK CONTINUE RETURN

// OTHER TOKEN
%token HASH INCLUDE DEFINE HEADER_FILE MAIN FILE_NAME
%%
start :a  { printf("valid syntax\n");return 0;}
      ;
a :preprocessor mainFunction
  ;

preprocessor :header preprocessor
             |macro preprocessor
             |
             ;

header :HASH INCLUDE LOP HEADER_FILE GOP {printf("\tvalid preproccessor directive\n");}
       |HASH INCLUDE  FILE_NAME {printf("\tvalid preproccessor directive\n");}
       ;     /* grammer for external file */
      
macro :HASH DEFINE ID constant {printf("\tvalid macro\n");}
      ;
constant :INT
         |FLOAT
         |CHAR_LITERAL
         |STRING
         |ID
         ;

mainFunction :DATA_TYPE MAIN LP RP code {printf("\tvalid main function syntax\n");}
             ;
code :blockCode
     |stmt
     ;
blockCode :LCB localCode RCB
            ;

localCode :component localCode
          |
          ;

component :stmt {printf("\tvalid statement\n");}
          |ifelse
          |exp  
          ;

stmt :dec SEMICOLON 
     |def SEMICOLON 
     |funCall SEMICOLON 
     |dec_def SEMICOLON 
     |BREAK SEMICOLON 
     |CONTINUE SEMICOLON 
     |RETURN main_return_value SEMICOLON 
     |SEMICOLON 
     ;
main_return_value :constant
                  |
                  ;
dec :DATA_TYPE ID 
    |PTR_TYPE ID  
    |DATA_TYPE ID LSB INT RSB  
    |PTR_TYPE ID LSB INT RSB 
    ;

def :ID '=' exp 
    ;
dec_def :DATA_TYPE ID '=' exp 
        ;
funCall :stdFun
        ;
stdFun :print 
       ;
print :PRINT LP STRING RP  
      |PRINT LP STRING arg RP  
      ;
arg :COMMA ID arg 
    |
    ;

ifelse :IF LP exp RP code {printf("\tvalid standAlone if statement\n");}
       |IF LP exp RP code ELSE code {printf("\tvalid standAlone if-else statement\n");}
       |IF LP exp RP code ELSE IF LP exp RP code ELSE code {printf("\tvalid standAlone if-else if-else statement\n");}

       ;
exp :co_exp 
    |lo_exp 
    |funCall
    |constant
    ;
co_exp :constant comparison_operator constant
       ;
comparison_operator :CO_OP
                    |LOP
                    |GOP
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

void yyerror(char *err){
    fprintf(stderr,"%s\n",err);
}