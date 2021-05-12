#include "variables.h"

char* expandVar(char* name)
{
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], name) == 0) {
            wordCounter = 0;
            return varTable.word[i];
        }
    }
    return name;
}

bool ifVariable(char* name)
{
    for (int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], name) == 0) {
            return true;
        }
    }
    return false;
}

bool expandVars(char* word, char* newWord)
{
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
