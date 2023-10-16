%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
%}

%token PRINT LP STRING RP SEMICOLON

%%
s :a '\n' { printf("valid syntax\n");return 0;}
  ;
a :PRINT LP STRING RP SEMICOLON 
  ;
%%

int main(){
    printf("Enter Statement:");
    yyparse();

}

int yyerror(char *err){
    fprintf(stderr,"%s\n","invalid syntax");
}