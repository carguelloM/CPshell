%{
#include "PARSER.tab.h"
#include <string.h>
#include <dirent.h> 
#include <regex.h> 
#include <pwd.h>

#include "Expansions/Lexing/Wildcards/wildcards.h"
#include "Expansions/Lexing/Aliases/aliases.h"
#include "Expansions/Lexing/Variables/variables.h"
#include "Expansions/Lexing/Tilde/tilde.h"


%}
%array
%option noyywrap
%x string_condition
%x variable_expansion

CHAR            [.:~A-Za-z0-9!\\/_/*/?-][.:~A-Za-z0-9!\\/_/*/?-]*
ANYCHAR            [)(*&%$#@!+`;,\.a-zA-Z0-9'\\/*_=~ -][)(*&%$#@!+`;,\.a-zA-Z0-9'\\/*_=~ -]*


%%

<string_condition>(($\{{ANYCHAR}+\})|{ANYCHAR}+)+   { 
                                    wordCounter++;


                                    char *middleWord = (char *)calloc(1, 40000);
                                    bool varFound = expandVars(yytext, middleWord);

                                    //WILDCARD
                                    char *newWord = (char *)calloc(1, 4000);
                                    bool wildcardFound = expandWildcards(middleWord, newWord);
                                    //strcpy(middleWord, newWord);

                                    if (wildcardFound)
                                    {
                                        //reparsing = true;
                                        char *yycopy = strdup(newWord);
                                        for ( int i = strlen(newWord) - 1; i >= 0; --i )
                                            unput( yycopy[i] );
                                        free( yycopy );
                                    }

                                    else {


                                        if(ifAlias(newWord) && (wordCounter == 1)) {


                                            //printf("yytext: %s\n", yytext);
                                            //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                                            char *yycopy = strdup( subAliases(newWord) );
                                            for ( int i = strlen(subAliases(newWord)) - 1; i >= 0; --i )
                                                unput( yycopy[i] );
                                            free( yycopy );

                                        } else {
                                            //printf("yytext: %s\n", yytext);
                                            yylval.string = strdup(newWord);

                                            
                                            if (!varFound && !wildcardFound)
                                            {
                                                strcat(currLine, "\"");
                                            }
                                            
                                            strcat(currLine, yylval.string);

                                            if (!varFound && !wildcardFound)
                                            {
                                                strcat(currLine, "\"");
                                            }
                                            strcat(currLine, " ");

                                            free(middleWord);
                                            free(newWord);

                                            return STRING;
                                        }
                                    };
                                }
<string_condition>[\"]          {BEGIN(INITIAL);}



[ ]		            { }
bye                 { wordCounter++;  strcat(currLine, "bye"); strcat(currLine, " "); return BYE; }
setenv              { wordCounter++; strcat(currLine, "setenv"); strcat(currLine, " "); return SETENV;}
printenv            { wordCounter++; strcat(currLine, "printenv"); strcat(currLine, " "); return PRINTENV;}
unsetenv            { wordCounter++; strcat(currLine, "unsetenv"); strcat(currLine, " "); return UNSETENV;}
unalias             { wordCounter++; strcat(currLine, "unalias"); strcat(currLine, " "); return UNALIAS;}
cd		            { wordCounter++; strcat(currLine, "cd"); strcat(currLine, " "); return CD;}
alias		        { wordCounter++; strcat(currLine, "alias"); strcat(currLine, " ");return ALIAS; }
"\|"                {wordCounter++; strcat(currLine, "|"); strcat(currLine, " ");return PIPE;}
2"\>"               {wordCounter++;  strcat(currLine, "2>"); strcat(currLine, " ");return STDERR;}
"\<"                 {wordCounter++; strcat(currLine, "<"); strcat(currLine, " "); return IOIN;}
"\>"                {wordCounter++; strcat(currLine, ">"); strcat(currLine, " ");return IOUT;}
"\n"		        { newLineReached = true; wordCounter = 0; strcat(currLine, "\n"); strcat(currLine, " "); return END; }
&                   {wordCounter++; strcat(currLine, "&"); strcat(currLine, " ");return BACKGRND;}
[\"]                 { BEGIN(string_condition); }



(($\{{CHAR}+\})|{CHAR}+)+              {
                        wordCounter++;

                        //TILDE EXPANSION
                        char *newWordTilde = (char *)calloc(1, 4000);

                        if (yytext[0] == '~')
                        {
                            expandTilde(yytext, newWordTilde);
                            //strcpy(newWordTilde, yytext);
                        }
                        else 
                        {
                            strcpy(newWordTilde, yytext);
                        }

                        char *middleWord = (char *)calloc(1, 4000);
                        bool varFound = expandVars(newWordTilde, middleWord);
                        //expandVars(yytext, middleWord);

                        //WILDCARD
                        char *newWord = (char *)calloc(1, 4000);
                        bool wildcardFound = expandWildcards(middleWord, newWord);
                        strcpy(middleWord, newWord);


                        if (wildcardFound)
                        {

                            //reparsing = true;
                            char *yycopy = strdup(newWord);
                            for ( int i = strlen(newWord) - 1; i >= 0; --i )
                                unput( yycopy[i] );
                            free( yycopy );

                        }
                        else 
                        {

                            if(ifAlias(newWord) && (wordCounter ==1)) {


                            //printf("yytext: %s\n", yytext);
                            //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                            char *yycopy = strdup( subAliases(newWord) );

                            //printf("This is the expanded alias: %s ----", yycopy);
                            for ( int i = strlen(subAliases(newWord)) - 1; i >= 0; --i )
                                unput( yycopy[i] );
                            free( yycopy );

                        } else {

                            //printf("yytext: %s\n", yytext);
                            yylval.string = strdup(newWord);

                            //printf("Command: %s", yylval.string);
                            strcat(currLine, yylval.string);
                            strcat(currLine, " ");

                            free(newWord);
                            free(newWordTilde);
                            free(middleWord);

                            return STRING;
                        }
                    };
                    }

                    
%%