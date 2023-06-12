%option noyywrap
%option yylineno
D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

%{
#include <stdio.h>
#include "Structure.h"
#include "y.tab.h" 


/* Ne g�re pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%                                              /* dans miniC.y il y a des noms de tokens, je sais pas si il faut metre les memes */     
"break"                 return BREAK ;   
"case"                  return CASE ;
"const"                 return CONSTANTE ;
"default"               return DEFAULT ;  
"else"                  return ELSE ; 
"extern"                return EXTERN ;    
"for"                   return FOR ; 
"if"                    return IF ;
"int"                   return INT ;   
"return"                return RETURN ;     
"switch"                return SWITCH ; 
"void"                  return VOID ;
"while"                 return WHILE ; 

{L}({L}|{D})*           { int i=0; while(yytext[i] != NULL){yylval.name[i] = yytext[i]; i++;}; yylval.name[i] = '\0'; return IDENTIFICATEUR; }  /* variable, nom de fonction sans les () etc... */




">>"                    return RSHIFT ; 
"<<"                    return LSHIFT ; 
"&&"                    return BAND ; 
"||"                    return BOR ; 
"<="                    return LEQ ; 
">="                    return GEQ ; 
"=="                    return EQ ; 
"!="                    return NEQ ;
"+"                     return PLUS ;
"*"                     return MUL ;
"/"                     return DIV ;
"-"                     return MOINS ; 

{D}+                    {yylval.val = atof(yytext); return NOMBRE;} ;     /* j'ai ajouté */

\/\*[^\*\/]*\*\/        ;   /* commentaires */


[ \t\v\n\f]             ;
.                       return yytext[0] ; 
%%

