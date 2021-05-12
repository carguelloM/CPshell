#include "variablesParse.h"

int setPATH(char* word)
{	char *ptr1, *ptr2;
	char WORD_COPY[100];
	strcpy(WORD_COPY, word);
	char* currword = strtok_r(WORD_COPY, ":", &ptr1);
	char  PATH_COPY[100];
	bool addToPATH;
	while(currword != NULL)
	{	
		strcpy(PATH_COPY, varTable.word[3]);
		char * currpath = strtok_r(PATH_COPY, ":", &ptr2);
		addToPATH = true;
		while(currpath != NULL)
		{	
			if(strcmp(currword, currpath) == 0)
			{
				printf("\"%s\" Already in PATH environment variable\n", currword);
				addToPATH = false;
				break;
			}
			// set currpath to next value in PATH env variable
			currpath = strtok_r(NULL, ":", &ptr2);
		}
		if(addToPATH)
		{
		strcat(varTable.word[3], ":");
		strcat(varTable.word[3], currword);
		}
		currword = strtok_r(NULL, ":", &ptr1);
	}
	return 1;
}

int setEnv(char* variable, char* word)
{
	
    if(strcmp(varTable.var[3],variable) == 0)
	{
		setPATH(word);
		return 1;
	}
	for (int i = 0; i < varIndex; i++){
       if(strcmp(varTable.var[i], variable) == 0) {
		   
			strcpy(varTable.word[i], word);
			return 1;
		} 
	}
    strcpy(varTable.var[varIndex], variable);
	strcpy(varTable.word[varIndex], word);
	varIndex++;
    return 1;
}

int printEnvFile(char* filename , int append)
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
	{	if(strcmp(varTable.word[i], "") != 0){
			fprintf(fp, "%s=%s\n", varTable.var[i], varTable.word[i]);
			}
	}
	fclose(fp);
	return 1;
}


int printEnv(void)
{
    for (int i = 0; i < varIndex; i++)
    {
        if(strcmp(varTable.word[i], "") != 0){
        printf("%s=%s\n", varTable.var[i], varTable.word[i]);
        }
    }

    return 1;
}

int unsetEnv(char*  variable)
{	
	if (strcmp(variable, "PATH") == 0)
	{
		printf("Variable PATH cannot be unset\n");
		return 1;
	}
	if(strcmp(variable, "HOME") == 0)
	{
		printf("Variable HOME cannot be unset\n");
		return 1;
	}
    for (int i = 0; i < varIndex; i++)
    {
        if(strcmp(varTable.var[i], variable) == 0){
            strcpy(varTable.word[i], "");
            return 1;
        }
    }

    return 1;
}
