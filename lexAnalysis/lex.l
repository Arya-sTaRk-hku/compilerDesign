%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include "./src/symbolTable.txt"


//symbol table operation:insertion , update , search
void lookInSymbolTable(int index,tokenNode *hashTable[],char yytext[],char type[],int yyleng,int yylineno){


    if(!strcmp(type,"Identifier")){
        if(yyleng > 10)
            printf("\n\x1B[31merror! max length exceeded for Identifier \nat line:%d\x1B[0m\n",yylineno);
    }


    // INSERT,UPDATES IN SYMBOL TABLE GOES HERE...
    tokenNode *head = hashTable[index];
    tokenNode *temp = head->next;
    //if already exists update lineno
    int is_exist = 0;
    
    while(temp){

        // mistake: we cant compare 2 string using ==  operator
        if(!(strcmp(temp->name,yytext))){

            is_exist = 1;
            Ref *head = temp->lineOfRef;
            Ref *new = (Ref*)malloc(sizeof(Ref));
            new->lineNo = yylineno;
            new->next = head->next;
            head->next = new;
            // printf("\n leaving while loop\n");
            break;
        }
        temp = temp->next;
    }

    if(!is_exist){
        // printf("\n if not present\n");
        tokenNode *new = (tokenNode*)malloc(sizeof(tokenNode));
        strcpy(new->name,yytext);
        strcpy(new->type,type);
        new->length = yyleng;
        new->scope = 1;

        Ref *lineHead = (Ref*)malloc(sizeof(Ref));
        lineHead->lineNo = yylineno;
        lineHead->next = NULL;
        new->lineOfRef = lineHead;

        new->next = head->next;
        head->next = new;

    }
    

    return ;
    //not exists in symbol table create a new entry

}

// print symbol table
void printTable(tokenNode *hashTable[]){
    for(int i = 0;i < 14;i++){
        tokenNode *temp = hashTable[i]->next;
        while(temp){
            printf("\n\t%s\t\t%d\t\t%d\t",temp->name,temp->length,temp->scope);
            Ref * lineHead = temp->lineOfRef;
            while(lineHead){
                printf("%d ",lineHead->lineNo);
                lineHead = lineHead->next;
            }
            printf("\t\t %s\n",temp->type);
            temp = temp->next;
        }
    }
}

// validate multiline comment
void validateMultilineComment(char com[],int yyleng){
    if(com[yyleng-1] != '/' && com[yyleng-2] != '*')
        printf("\n\x1B[31merror! multiline comment starting at line %d not terminated with'*/'\x1B[0m\n",yylineno);
    // printf("\t %c \n",com[yyleng-1]);
}
 
// handle line count in multiline comment 
void handleLineCount(char mltLineCom[],int* yylineno,int yyleng){
    printf("\n< MULTILINE_COMMENT >\nthrough:[%d->",*yylineno);
    for(int i = 0;i < yyleng;i++)
        if(yytext[i] == '\n')   (*yylineno)++;
    printf("%d]\n",*yylineno);
    
}

int countSpace = 0;

tokenNode *hashTable[14];

%}

%option noyywrap

/* Rule's for Token's */



/* Rule for Keyword's */
KEYWORD "auto"|"double"|"int"|"struct"|"break"|"else"|"long"|"switch"|"case"|"enum"|"register"|"typedef"|"char"|"extern"|"return"|"union"|"const"|"float"|"short"|"unsigned"|"continue"|"for"|"signed"|"void"|"default"|"goto"|"sizeof"|"volatile"|"do"|"if"|"static"|"while"

/* Rule for Identifier's */
IDENTIFIER [a-zA-Z_][a-zA-Z0-9]* 

/* Rules for Operator's */
COMPARISON_OPERATOR "=="|"<="|">="|">"|"<"
SHIFT_OPERATOR ">>"|"<<"
LOGICAL_OPERATOR "&&"|"||"|"!"
ARITHMETIC_OPERATOR "+"|"-"|"*"|"/"|"%"
BITWISE_OPERATOR "&"|"^"|"|"|"~"
ASSIGNMENT_OPERATOR "="|"+="|"-="|"%="|"*="|"/="|"&="|"^="|"|="|"~="|">>="|"<<="

OPERATOR {COMPARISON_OPERATOR}|{SHIFT_OPERATOR}|{LOGICAL_OPERATOR}|{ARITHMETIC_OPERATOR}|{BITWISE_OPERATOR}|{ASSIGNMENT_OPERATOR}

/* Rules for Constant's */
INTEGER [+-]?[0-9]+ 
FLOAT [-+]?[0-9]+"."[0-9]+[f]?|[-+]?[0-9]+"."|[-+]?"."[0-9]+[f]?|[-+]?[0-9]+[e,E]"-"[0-9]+
CHAR "'"."'"|"'\\n'"|"'\\b'"|"'\\t'"|"'\\a'"|"'\\v'"|"'\\0'"|"'\\r'"|"'\\\"'"|"'\\\''"|"'\\f'"|"'\\'"
CHAR_ERROR "'".
MORE_CHAR_ERROR "'"...*"'"
/* string <mistake1:included new line in between string but fixed> */
STRING "\"".*"\""
STRING_ERROR "\""


/* Rule for Symbol's */
SYMBOL "`"|"!"|"@"|"#"|"$"|"%"|"("|")"|"-"|"_"|"="|"+"|"["|"]"|"{"|"}"|"\\"|":"|"\""|"'"|"<"|"."|">"|"?"

/* Rules for comments */
SINGEL_LINE_COMMENT "//".*
str "/*"
/* character '*' is not allowed but string "/*' allowed in this defenition of multiline comment */
MULTILINE_COMMENT "/*"([a-zA-Z0-9 \n]|{SYMBOL}|{BITWISE_OPERATOR}|{DELIMITER}|{str}|[/])*"*/"
MULTILINE_COMMENT_ERROR "/*"

/* nested comment: not able to implement*/
/* THERE IS NOTHING KNOWN AS " NESTED COMMENT " */




CONSTANT {INTEGER}|{FLOAT}|{STRING}|{CHAR}


/* DETECT PREPROCESSOR DERECTIVE */
PREPROCESSOR "#"[ ]*"include"[ ]*"<"{IDENTIFIER}".h>"|"#"[ ]*"include"[ ]*"\""{IDENTIFIER}".txt\""
PREPROCESSOR_VALUE_DEFENITION "#"[ ]*"define"[ ]*{IDENTIFIER}[ ]*{CONSTANT}

/* other rules */
DELIMITER [,;]
NEW_LINE \n


%%    
{PREPROCESSOR}              ;
{PREPROCESSOR_VALUE_DEFENITION} ;/* NEED TO UPDATE SYMBOL TABLE HERE */  
[ ]                         countSpace++;
{NEW_LINE}                  yylineno++;
{KEYWORD}                   lookInSymbolTable(0,hashTable,yytext,"Keyword",yyleng,yylineno);
{IDENTIFIER}                lookInSymbolTable(1,hashTable,yytext,"Identifier",yyleng,yylineno);
{FLOAT}                     lookInSymbolTable(2,hashTable,yytext,"Float Constant",yyleng,yylineno);
{INTEGER}                   lookInSymbolTable(3,hashTable,yytext,"Integer Constant",yyleng,yylineno);
{CHAR}                      lookInSymbolTable(4,hashTable,yytext,"Char Literal",yyleng,yylineno);

{CHAR_ERROR}                printf("\n\x1B[31merror! expected terminating ' character\nat line:%d\n\x1B[0m",yylineno);
{MORE_CHAR_ERROR}        printf("\n\x1B[31merror! too many character for \" Char Literal \"\nat line:%d\n\x1B[0m",yylineno);

{STRING}                    lookInSymbolTable(5,hashTable,yytext,"String Literal",yyleng,yylineno);
{STRING_ERROR}              printf("\n\x1B[31merror! expected terminating \" character\nat line:%d\n\x1B[0m",yylineno); 
{SYMBOL}              lookInSymbolTable(6,hashTable,yytext,"Special Character",yyleng,yylineno);
{DELIMITER}                 lookInSymbolTable(7,hashTable,yytext,"Seperator",yyleng,yylineno);
{SINGEL_LINE_COMMENT}       printf("\n< SINGEL_LINE_COMMENT >\nat line:%d\n",yylineno);
{MULTILINE_COMMENT}         handleLineCount(yytext,&yylineno,yyleng);
{MULTILINE_COMMENT_ERROR}   printf("\n\x1B[31merror! multiline comment starting at line %d not terminated with'*/'\x1B[0m\n",yylineno);
{ARITHMETIC_OPERATOR}       lookInSymbolTable(8,hashTable,yytext,"Arithmetic Operator",yyleng,yylineno);
{LOGICAL_OPERATOR}          lookInSymbolTable(9,hashTable,yytext,"Logical Operator",yyleng,yylineno);
{ASSIGNMENT_OPERATOR}       lookInSymbolTable(10,hashTable,yytext,"Assignment Operator",yyleng,yylineno);
{COMPARISON_OPERATOR}       lookInSymbolTable(11,hashTable,yytext,"Comparison Operator",yyleng,yylineno);
{BITWISE_OPERATOR}          lookInSymbolTable(12,hashTable,yytext,"Bitwise Operator",yyleng,yylineno);
{SHIFT_OPERATOR}            lookInSymbolTable(13,hashTable,yytext,"Shift Operator",yyleng,yylineno);

%%

int main(){

    FILE *inputFile = fopen("./Testcases/input.txt","r");
    if(!inputFile){
        printf("\nERROR! unablE tO opeN filE\n");
        return 0;
    }

    //file opened successfully
    //read input from given input file "input.txt"
    yyin = inputFile;

    // hash table
    for(int i = 0;i<14;i++)
    {
        tokenNode *new = (tokenNode*)malloc(sizeof(tokenNode));
        new->next = NULL;
        hashTable[i] = new;
    }

   
    yylex();

    // printf("total space:%d\n",countSpace);
    
    //print symbol table
    printf("\n\x1B[35m::::::::::::::::::::::::::::::Symbol Table::::::::::::::::::::::::::::::\x1B[0m\n");
    printf("\x1B[36m\tTokenName\tTokenLength\tScope\tLineOfRef\tTokenType\t\x1B[0m\n");
    printTable(hashTable);

    fclose(inputFile);
    return 0;
}

