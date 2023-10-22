%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
%}


// %union{
//   int d;
//   char* s;
//   char c;
// }





%token PRINT ID
%token  STRING SEMICOLON DATA_TYPE PTR_TYPE

// SYMBOL'S
%token LP RP LCB RCB LSB RSB COMMA
// OPERATOR
%token  LO_OP CO_OP AR_OP AND OR NOT LOP GOP

// CONDTIONAL STRING
%token IF ELSE

// CONSTANT
%token INT FLOAT  CHAR_LITERAL

%token BREAK CONTINUE RETURN

// OTHER TOKEN
%token HASH INCLUDE DEFINE HEADER_FILE MAIN
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
       ;     /* grammer for external file */
      
macro :HASH DEFINE ID constant {printf("\tvalid macro\n");}
      ;
constant :INT
         |FLOAT
         |CHAR_LITERAL
         |STRING
         |ID
         ;
// ws :' ' ws
//    |
//    ;
mainFunction :DATA_TYPE MAIN LP RP LCB codeblock RCB {printf("\tvalid main function syntax\n");}
             ;

codeblock :component codeblock
          |
          ;

component :stmt 
          |ifelse {printf("\tvalid ifelse\n");}
          |exp
          ;
stmt :dec SEMICOLON {printf("\tvalid declaration \n");}
     |def SEMICOLON {printf("\tvalid definition\n");}
     |funCall SEMICOLON {printf("\tvalid function call \n");}
     |dec_def SEMICOLON {printf("\tvalid initialization at definition time\n");}
     |BREAK SEMICOLON {printf("\tvalid break Statement\n");}
     |CONTINUE SEMICOLON {printf("\tvalid continue Statement\n");}
     |RETURN main_return_value SEMICOLON {printf("\tvalid return Statement\n");}

     ;
main_return_value :INT
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

ifelse :IF LP exp RP stmt 
       ;
exp :co_exp {printf("\tvalid comparison expression\n");}
    |ar_exp {printf("\tvalid arithmetic expression\nresult:%d\n",$$);}
    |lo_exp {printf("\tvalid logical expression\n");}
    |funCall
    |ID
    |INT 
    |FLOAT 
    |CHAR_LITERAL
    |STRING
    ;
co_exp :ar_exp CO_OP ar_exp
       ;

ar_exp :x AR_OP x
       ;
x :INT
  |FLOAT
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