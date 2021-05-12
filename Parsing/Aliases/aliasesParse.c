#include "aliasesParse.h"

bool checkLoops(char* word, char* name) {
	char currword[100];
	strcpy(currword, word);
	int position = 0;
	bool brokenChain = false;

	while(true) {
		position = 0;
		if (brokenChain) {
			return false;
		}
		while(true) {
			if (position >= aliasIndex) {
				brokenChain = true;
				break;			
			}
			else if (strcmp(aliasTable.word[position], "") == 0) {
				brokenChain = true;
				break;
			}

			if (strcmp(aliasTable.name[position], currword) == 0) {
				strcpy(currword, aliasTable.word[position]);
				if (strcmp(currword, name) == 0) {
					return true;
				}
				break;	
			}
			position++;
		}
	}
}

int runSetAlias(char *name, char *word) {
	if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}

	if (checkLoops(word, name)) {
		printf("Error, expansion of \"%s\" would create a loop.\n", name);
		return 1;
	}
	
	for (int i = 0; i < aliasIndex; i++) {
		
		if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}

int listAlias(void) {
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.word[i], "") != 0){
            printf("%s=%s\n", aliasTable.name[i], aliasTable.word[i]);
        }
    }

    return 1;
}

int unsetAlias(char* name)
{
    for (int i = 0; i < aliasIndex; i++)
    {
        if(strcmp(aliasTable.name[i], name) == 0){
            strcpy(aliasTable.word[i], "");
            return 1;
        }
    }
    return 0;
}


int printAliasFile(char *filename, int append)
{
	//Check for absolute path
	char nameToWrite[100];
	if(access(filename, F_OK) == 0)
    {
        if(access(filename, W_OK) == 0)
        {
           strcpy(nameToWrite,filename);
        }

        else{
            printf("No write permission for: %s", filename);
            return 1;
        }
    }
	else{
		strcat("/",nameToWrite);
		
		if(access(nameToWrite, W_OK) != 0)
		{
			printf("No write permission for: %s", filename);
				return 1;
		} 
	}

	FILE * fp;
	if(append != 1)
	{
	fp = fopen(nameToWrite,"w+");
	}
	else
	{
	fp = fopen(nameToWrite,"a");
	}
	for (int i=0; i < varIndex; i++)
	{	if(strcmp(aliasTable.word[i], "") != 0){
			fprintf(fp, "%s=%s\n", aliasTable.name[i], aliasTable.word[i]);
			}
	}
	fclose(fp);
	return 1;
}