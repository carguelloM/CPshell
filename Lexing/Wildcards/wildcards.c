#include "wildcards.h"


bool regexMatch(int returnValue)
{
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
                strcat(regexStr, "[.:~A-Za-z0-9!\\/_-]*"); 
                pos = strlen(regexStr);
            }
            else if (*curr == '?')
            {
                strcat(regexStr, "[.:~A-Za-z0-9!\\/_-]"); 
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