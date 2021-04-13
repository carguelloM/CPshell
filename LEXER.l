%{
#include "PARSER.tab.h"
#include <string.h>
#include <dirent.h> 
#include <regex.h> 
#include <pwd.h>

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


void expandVars(char* word, char* newWord){
    //char *newWord = (char *)calloc(1, 40000);
    char* curr = &word[0];
    char* start = NULL;
    char* end = NULL;
    int pos = 0;
    int length = 0;
    bool varMatch = false;
    bool betweenBraces = false;
    while (*curr != '\0')
    {
        if (*curr == '$') 
        {
            start = curr + 2;
            betweenBraces = true;
        }
        else if (*curr == '}')
        {
            end = curr;
            char *varName = (char *)calloc(1, end - start + 1);
  			memcpy(varName, start, end - start);
            
            //Scanning varTable
            for (int i = 0; i < varIndex; i++) 
            {
                if(strcmp(varTable.var[i], varName) == 0) 
                {
                    newWord = strcat(newWord, varTable.word[i]);
                    varMatch = true;
                    break;
                }
            }
            if (!varMatch) 
            {
                newWord = strcat(newWord, varName);
            }
            varMatch = false;
            pos = strlen(newWord);
            betweenBraces = false;
        }
        else if (*curr != '{')
        {
            if (!betweenBraces)
            {
                newWord[pos] = *curr;
            }
            pos++;
        }

        curr++;
    }
}

bool regexMatch(int returnValue){
  if (returnValue == 0){
    return true;
  }
  else if (returnValue == REG_NOMATCH){
    return false;
  }
  else{
    printf("An error occured.\n");
    return false;
  }
}

void expandTilde(char* word, char* newWord)
{
    
    int totLength = strlen(word);

    bool slashPresent = false;
    int length = 0;

    char* start = NULL;
    char* end = NULL;
    char* substr = NULL;

    char* pwDir = (char *)calloc(1, 4000);

    char* curr = &word[1];
    while (*curr != '/' && *curr != '\0')
    {
        curr++;
        length++;
    }

    if (*curr == '/')
    {
        slashPresent = true;
        //slashPos = curr;
    }

    if (length == 0)
    {
        //use HOME
        strcpy(pwDir, varTable.word[1]);
    }
    else 
    {
        start = &word[1];
        end = &word[length];
        substr = (char *)calloc(1, end - start + 2);
        memcpy(substr, start, end - start + 1);

        //printf("  %s  ", substr);
        if (getpwnam(substr) == NULL)
        {
            printf("Error: no such file or directory ");
        }
        else 
        {
            strcpy(pwDir, getpwnam(substr)->pw_dir);
        }

    }


    strcpy(newWord, pwDir);

    if (slashPresent)
    {
        start = &word[length+1];
    }
    else 
    {
        start = &word[length+1];
    }
    end = &word[totLength];

    substr = (char *)calloc(1, end - start + 2);
    memcpy(substr, start, end - start + 1);

    strcat(newWord, substr);

}



void expandWildcards(char* word, char* newWord) 
{
    if(strchr(word, '*') == NULL && strchr(word, '?') == NULL)
    {
        strcpy(newWord, word);
        return;
    }
    else 
    {
        ///// CONSTRUCT REGEX /////
        char *regexStr = (char *)calloc(1, 4000);
        char* curr = &word[0];
        int pos = 0;


        regexStr[0] = '^';
        while (*curr != '\0')
        {
            if (*curr == '*') 
            {
                regexStr = strcat(regexStr, "[.:~A-Za-z0-9!\/_-]*"); //RESTRICT
                pos = strlen(regexStr);
            }
            else if (*curr == '?')
            {
                regexStr = strcat(regexStr, "[.:~A-Za-z0-9!\/_-]"); //RESTRICT
                pos = strlen(regexStr);
            }
            else
            {
                regexStr[pos] = *curr;
                pos++;
            }

            curr++;
        }

        regexStr = strcat(regexStr, "$");

        printf("--  %s  -- ", regexStr);
        
        //// COMPILING REGEX //////
        regex_t regex;
        int returnValue = regcomp(&regex,regexStr,0);

        ///////////////////////////
        int numFiles = 0;
        int maxLength = 0;


        // Copying to the table
        int fileIndex = 0;

        DIR *d;
        struct dirent *dir;
        d = opendir(".");
        if (d) {
            while ((dir = readdir(d)) != NULL) {
                returnValue = regexec(&regex, dir->d_name, 0, NULL, 0);
                if (regexMatch(returnValue)) 
                {
                    strcpy(filesTable[fileIndex], dir->d_name);
                    fileIndex++;

                    if (strlen(dir->d_name) > maxLength)
                    {
                        maxLength = strlen(dir->d_name);
                    }
                }
            }
        closedir(d);
        }

        // Sorting 
        qsort(filesTable, fileIndex, maxLength+1, strcmp);

        
        for (int i = 0; i < fileIndex; i++)
        {
            printf("%s ", filesTable[i]);
            newWord = strcat(newWord, " ");
            newWord = strcat(newWord, filesTable[i]);
        }

        // Cleaning the table
        for (int i = 0; i < fileIndex; i++)
        {
            strcpy(filesTable[i], "");
        }
    }
}

%}
%array
%option noyywrap
%x string_condition
%x variable_expansion

CHAR            [.:~A-Za-z0-9!\/_/*/?-][.:~A-Za-z0-9!\/_/*/?-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*


%%

<string_condition>(($\{{ANYCHAR}+\})|{ANYCHAR}+)+   { 
                                    wordCounter++;


                                    char *newWord = (char *)calloc(1, 40000);
                                    expandVars(yytext, newWord);

                                    if(ifAlias(newWord) && (wordCounter == 1)) {
                                        printf("yytext: %s\n", yytext);
                                        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                                        char *yycopy = strdup( subAliases(newWord) );
                                        for ( int i = strlen(subAliases(newWord)) - 1; i >= 0; --i )
                                            unput( yycopy[i] );
                                        free( yycopy );
                                    } else {
                                        printf("yytext: %s\n", yytext);
                                        yylval.string = strdup(newWord);
                                        return STRING;
                                    };
                                }
<string_condition>[\"]          {BEGIN(INITIAL);}




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
                        expandVars(newWordTilde, middleWord);
                        //expandVars(yytext, middleWord);

                        //WILDCARD
                        char *newWord = (char *)calloc(1, 4000);
                        expandWildcards(middleWord, newWord);


                        if(ifAlias(newWord) && (wordCounter ==1)) {
                        printf("yytext: %s\n", yytext);
                        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                           char *yycopy = strdup( subAliases(newWord) );
                           for ( int i = strlen(subAliases(newWord)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );

                        


                    } else {
                        //WILDCARD


                        printf("yytext: %s\n", yytext);
                        yylval.string = strdup(newWord);
                        return STRING;
                    };
                     }


                    
%%