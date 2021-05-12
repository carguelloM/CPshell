#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <string.h>
#include <dirent.h> 
#include <regex.h> 
#include <pwd.h>

#include "../../global.h"

int findLastSlash(char* arg);

void chopN(char *str, size_t n);