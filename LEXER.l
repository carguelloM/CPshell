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
    char NAME_COPY [100];
    strcpy(NAME_COPY, name);

    char * temp = strtok(NAME_COPY, " ");

    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], temp) == 0) {
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
    
    char NAME_COPY [100];
    strcpy(NAME_COPY, name);
    char * temp = strtok(NAME_COPY, " ");
      for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], temp) == 0) {
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


bool expandVars(char* word, char* newWord){

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

            free(varName);
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
    
    if (strchr(word, '$') == NULL)
    {
        return false;
    }

    return true;
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
    //char* substr = NULL;

    char* pwDir = (char *)calloc(1, 4000);

    char* curr = &word[1];
    while (*curr != '/' && *curr != '\0')
    {
        curr++;
        length++;
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
        char* substr1 = (char *)calloc(1, end - start + 2);
        memcpy(substr1, start, end - start + 1);

        if (getpwnam(substr1) == NULL)
        {
            printf("Error: no such file or directory ");
        }
        else 
        {
            strcpy(pwDir, getpwnam(substr1)->pw_dir);
        }

        free(substr1);

    }

    strcpy(newWord, pwDir);

    start = &word[length+1];
    end = &word[totLength];

    char* substr2 = (char *)calloc(1, end - start + 2);
    memcpy(substr2, start, end - start + 1);

    strcat(newWord, substr2);

    free(substr2);
    free(pwDir);

}

int compare (const void * a, const void * b)
{
  return strcmp((char*)a, (char*)b );
}

bool expandWildcards(char* word, char* newWord) 
{
    if (strcmp(word, "*") == 0)
    {
        strcpy(newWord, "");
        return true;
    } 
    if (strcmp(word, "*.") == 0)
    {
        strcpy(newWord, ".");
        return true;
    } 
    if (strcmp(word, ".*") == 0)
    {
        strcpy(newWord, ".");
        return true;
    } 
    if (strcmp(word, "..*") == 0)
    {
        strcpy(newWord, "..");
        return true;
    } 
    if (strcmp(word, "*..") == 0)
    {
        strcpy(newWord, "..");
        return true;
    }

    if(strchr(word, '*') == NULL && strchr(word, '?') == NULL)
    {
        strcpy(newWord, word);
        return false;
    }
    else 
    {
        ///// CONSTRUCT REGEX /////
        char *regexStr = (char *)calloc(1, 4000);
        char* curr = &word[0];
        int pos = 1;

        strcat(regexStr, "^");

        while (*curr != '\0')
        {
            if (*curr == '*') 
            {
                strcat(regexStr, "[.:~A-Za-z0-9!\\/_-]*"); //RESTRICT
                pos = strlen(regexStr);
            }
            else if (*curr == '?')
            {
                strcat(regexStr, "[.:~A-Za-z0-9!\\/_-]"); //RESTRICT
                pos = strlen(regexStr);
            }
            else
            {
                regexStr[pos] = *curr;
                pos++;
            }

            curr++;
        }

        strcat(regexStr, "$");

        //printf("--  %s  -- ", regexStr);
        
        //// COMPILING REGEX //////
        regex_t regex;
        int returnValue = regcomp(&regex,regexStr,0);

        free(regexStr);

        ///////////////////////////
        int numFiles = 0;
        //int maxLength = 0;


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
                    //printf("file: %s", dir->d_name);
                    strcpy(filesTable[fileIndex], dir->d_name);
                    fileIndex++;

                    //if (strlen(dir->d_name) > maxLength)
                    //{
                    //    maxLength = strlen(dir->d_name);
                    //}
                }

            }
        closedir(d);
        }


        // Sorting 
        qsort(filesTable, fileIndex, sizeof(*filesTable), compare);

        if (fileIndex == 0)
        {
            strcpy(newWord, "");
            char WORD_COPY[100];
            strcpy(WORD_COPY, word);
            char * currToken = strtok(WORD_COPY, "*?");

            while(currToken != NULL)
            {
                strcat(newWord,currToken);
                currToken = strtok(NULL,"*?");
            }

            //newWord = strcat(newWord, " ");
        }
        
        for (int i = 0; i < fileIndex; i++)
        {
            //printf("%s ", filesTable[i]);
            newWord = strcat(newWord, filesTable[i]);
            newWord = strcat(newWord, " ");
        }

        // Cleaning the table
        for (int i = 0; i < fileIndex; i++)
        {
            strcpy(filesTable[i], "");
        }

        return true;

    }
}

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