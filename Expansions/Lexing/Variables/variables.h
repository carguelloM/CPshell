#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h> 
#include <regex.h> 
#include <pwd.h>

#include "../../../global.h"

char* expandVar(char* name);

bool ifVariable(char* name);

bool expandVars(char* word, char* newWord);