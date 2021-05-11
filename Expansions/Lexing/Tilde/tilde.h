#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h> 
#include <regex.h> 
#include <pwd.h>

#include "../../../global.h"

void expandTilde(char* word, char* newWord);