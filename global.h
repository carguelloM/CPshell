#include "stdbool.h"
#include <limits.h>
#include <pwd.h>
#include <sys/types.h>

#define MAX_FILES 400
#define MAX_FILE_NAME 100

struct evTable {
   char var[128][100];
   char word[128][100];
};

struct aTable {
	char name[128][100];
	char word[128][100];
};

struct argsTable{
   char argu[128][100];
   int argumentNum;
};

struct commandTable {
   char cmd[128][100];
   struct argsTable arguments[128];
   char inputFile[100];
   char outputFile[100];
   bool pipeIN[128];
   bool pipeOUT[128];
   char errRedirectFile[128];
   bool append;
   
};

char cwd[PATH_MAX];

struct evTable varTable;
struct aTable aliasTable;
struct commandTable cmdTable;

int aliasIndex, varIndex, cmdTableIndex;

char filesTable[MAX_FILES][MAX_FILE_NAME]; 

//State Variables
char searchPath[100];
int wordCounter;
int argumentCounter;
bool termianlErr;
int currentCommand;
int numPipes;
bool pipePresent;
bool IOPresent;
int pipeLead[2];
int pipeSec[2];
char* subAliases(char* name);

