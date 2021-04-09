#include "stdbool.h"
#include <limits.h>

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
};

char cwd[PATH_MAX];

struct evTable varTable;
struct aTable aliasTable;
struct commandTable cmdTable;

int aliasIndex, varIndex, cmdTableIndex;

//State Variables
char searchPath[100];
int wordCounter;
int argumentCounter;

char* subAliases(char* name);

