%{
#include "PARSER.tab.h"
#include <string.h>
#include "global.h"

char* subAliases(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            wordCounter = 0;
            return aliasTable.word[i];
        }
    }
    return name;
}
bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}



char* expandVar(char* name){
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], name) == 0) {
            wordCounter = 0;
            return varTable.word[i];
        }
    }
    return name;
}


bool ifVariable(char* name){
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], name) == 0) {
            return true;
        }
    }
    return false;
}




%}
%array
%option noyywrap
%x string_condition
%x variable_expansion

CHAR            [.:~A-Za-z0-9!\/_-][.:~A-Za-z0-9!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*


%%

<string_condition>{ANYCHAR}+     { wordCounter++;
                            if(ifAlias(yytext) && (wordCounter == 1)) {
                        printf("yytext: %s\n", yytext);
                        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );
                    } else {
                        printf("yytext: %s\n", yytext);
                        yylval.string = strdup(yytext);
                        return STRING;
                    };

    
                                     }
<string_condition>[\"]          {BEGIN(INITIAL);}


<variable_expansion>{CHAR}+   { 
                        printf("Got here!");
                        wordCounter++;
                        if(ifVariable(yytext)) 
                        {
                            printf("yytext: %s\n", yytext);
                            //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                            char *yycopy = strdup( expandVar(yytext) );
                            for ( int i = strlen(expandVar(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                            free( yycopy );
                        } else {
                            printf("yytext: %s\n", yytext);
                            yylval.string = strdup(yytext);
                            return STRING;
                        };

                    }

<variable_expansion>[}]         {BEGIN(INITIAL);}

[ ]		            { }
bye                 { wordCounter++;  return BYE; }
setenv              { wordCounter++; return SETENV;}
printenv            { wordCounter++; return PRINTENV;}
unsetenv            { wordCounter++; return UNSETENV;}
unalias             { wordCounter++; return UNALIAS;}
cd		            { wordCounter++; return CD;}
alias		        { wordCounter++; return ALIAS; }
2"\>"               {wordCounter++;  return STDERR;}
"\<"                 {wordCounter++; return IOIN;}
"\>"                {wordCounter++; return IOUT;}
"\n"		        { wordCounter = 0; return END; }
&                   {wordCounter++; return BACKGRND;}
[\"]                 { BEGIN(string_condition); }
[${]                {BEGIN(variable_expansion); }




{CHAR}+              {
                        wordCounter++;
                        if(ifAlias(yytext) && (wordCounter ==1)) {
                        printf("yytext: %s\n", yytext);
                        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );
                    } else {
                        printf("yytext: %s\n", yytext);
                        yylval.string = strdup(yytext);
                        return STRING;
                    };
                     }


                    
%%