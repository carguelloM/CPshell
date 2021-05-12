#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <dirent.h> 
#include <regex.h> 
#include <pwd.h>

#include "../../global.h"

int setPATH(char* word);

int setEnv(char* variable, char* word);

int printEnv(void);

int printEnvFile(char* filename , int append);

int unsetEnv(char*  variable);


