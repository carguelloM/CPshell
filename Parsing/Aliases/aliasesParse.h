#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include <dirent.h> 
#include <regex.h> 
#include <pwd.h>

#include "../../global.h"


bool checkLoops(char* word, char* name);

int runSetAlias(char *name, char *word);

int listAlias(void);

int unsetAlias(char* name);

int printAliasFile(char *filename, int append);