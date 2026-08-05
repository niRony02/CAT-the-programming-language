%{
#define _POSIX_C_SOURCE 200809L
%{
#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
...

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

static char *duplicate_string(const char *s) {
    size_t len = strlen(s);
    char *buf = (char *)malloc(len + 1);
    if (buf) strcpy(buf, s);
    return buf;
}

static char *duplicate_substring(const char *s, size_t n) {
    char *buf = (char *)malloc(n + 1);
    if (buf) {
        strncpy(buf, s, n);
        buf[n] = '\0';
    }
    return buf;
}
%}

%option noyywrap
%option yylineno
%option nounput
%option noinput

%%

[ \t\r\n]+          { /* Ignore whitespace */ }
"//".*              { /* Ignore single-line comments */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* Ignore multi-line comments */ }

"let"               { return LET; }
"if"                { return IF; }
"else"              { return ELSE; }
"while"             { return WHILE; }
"print"             { return PRINT; }
"input"             { return INPUT; }

"=="                { return EQ; }
"!="                { return NEQ; }
"<="                { return LEQ; }
">="                { return GEQ; }

[0-9]+(\.[0-9]+)?   { yylval.num = atof(yytext); return NUMBER; }

\"([^\"\\]|\\.)*\"  { 
                        size_t len = strlen(yytext);
                        yylval.str = duplicate_substring(yytext + 1, len - 2);
                        return STRING; 
                    }

[a-zA-Z_][a-zA-Z0-9_]* { 
                        yylval.str = duplicate_string(yytext); 
                        return IDENTIFIER; 
                    }

"+"                 { return '+'; }
"-"                 { return '-'; }
"*"                 { return '*'; }
"/"                 { return '/'; }
"="                 { return '='; }
"<"                 { return '<'; }
">"                 { return '>'; }
"("                 { return '('; }
")"                 { return ')'; }
"{"                 { return '{'; }
"}"                 { return '}'; }
";"                 { return ';'; }

.                   { fprintf(stderr, "Lexical Error at line %d: Unexpected character '%s'\n", yylineno, yytext); }

%%