#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

bool checkExeStatus (char* commandName);

bool checkFileReadStatus(void);

bool checkFileWriteStatus(int errorOutput);

int runNonBuiltIn(char* commandName, int totalArgs, int currCMD) ;

int proccessLine(void);

void printPrompt(void);