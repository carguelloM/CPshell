#include "aliases.h"

char* subAliases(char* name)
{
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            wordCounter = 0;
            return aliasTable.word[i];
        }
    }
    char NAME_COPY [100];
    strcpy(NAME_COPY, name);

    char * temp = strtok(NAME_COPY, " ");

    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], temp) == 0) {
            wordCounter = 0;
            return aliasTable.word[i];
        }
    } 

    return name;
}


bool ifAlias(char* name)
{
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    
    char NAME_COPY [100];
    strcpy(NAME_COPY, name);
    char * temp = strtok(NAME_COPY, " ");
      for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], temp) == 0) {
            return true;
        }
    }
    
    return false;
}


