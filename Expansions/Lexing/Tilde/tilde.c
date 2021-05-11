#include "tilde.h"

void expandTilde(char* word, char* newWord)
{
    int totLength = strlen(word);
    bool slashPresent = false;
    int length = 0;

    char* start = NULL;
    char* end = NULL;

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
