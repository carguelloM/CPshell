#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h> 
#include <regex.h> 
#include <pwd.h>

#include "../../global.h"

int compare (const void * a, const void * b);

bool expandWildcards(char* word, char* newWord);

bool regexMatch(int returnValue);