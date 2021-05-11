#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h> 
#include <regex.h> 
#include <pwd.h>

#include "../../../global.h"

bool ifAlias(char* name);

char* subAliases(char* name);