%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"

int ersex(void);
int yyerror(char *s);
int runCD(char* arg);
int runCDHome(void);
int findLastSlash(char *arg);
int runSetAlias(char *name, char *word);
int setEnv(char* variable, char* word);
int printEnv(void);
int printEnvFile(char *filename, int append);
int printAliasFile(char *filename, int append);
int unsetEnv(char* variable);
int listAlias(void);
int unsetAlias(char* name);

%}

%union {char *string;}

%start cmd_line
%type<string> nonBuilt redirection err pipes
%token <string> BYE CD STRING ALIAS END SETENV PRINTENV UNSETENV UNALIAS IOIN IOUT BACKGRND STDERR PIPE

%%
cmd_line    :
	BYE END 		                {exit(1); return 1; }
    | SETENV STRING STRING END      {setEnv($2, $3);  return 1;}
    | PRINTENV END                  {printEnv();  return 1;}
	| PRINTENV IOUT	STRING END		{printEnvFile($3, 0); return 1;}
	| PRINTENV IOUT IOUT STRING END	{printEnvFile($4, 1); return 1;}					
    | UNSETENV STRING END           {unsetEnv($2);  return 1;}
    | UNALIAS STRING END            {unsetAlias($2);  return 1;}
	| CD STRING END        			{runCD($2);  return 1;}
	| CD END						{ runCDHome();  return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3);  return 1;}
    | ALIAS END                     { listAlias(); return 1;}
	| ALIAS IOUT STRING END			{printAliasFile($3,0); return 1;}
	| ALIAS IOUT IOUT STRING END		{printAliasFile($4,1); return 1;}
	| nonBuilt redirection  END		{return 1;}
	| nonBuilt err END				{
									strcpy(cmdTable.inputFile,"");
									strcpy(cmdTable.outputFile,"");
									cmdTable.append = false;
									 return 1;}	
	|	pipes err END					{
									strcpy(cmdTable.inputFile,"");
									strcpy(cmdTable.outputFile,"");
									cmdTable.append = false;
									pipePresent = true; return 1;}
	| 	pipes redirection END		{ pipePresent = true; return 1;
										return 1;}
;
redirection:
	IOIN STRING err								{strcpy(cmdTable.inputFile,$2);
												strcpy(cmdTable.outputFile,"");
												cmdTable.append = false;
												}
	| IOUT STRING err							{strcpy(cmdTable.inputFile,"");
												strcpy(cmdTable.outputFile,$2);
												cmdTable.append = false;
												}
	| IOUT IOUT STRING	err						{
												strcpy(cmdTable.inputFile,"");
												strcpy(cmdTable.outputFile,$3);
												cmdTable.append = true;
												}						
	| IOIN STRING IOUT STRING	err			{strcpy(cmdTable.inputFile,$2);
												strcpy(cmdTable.outputFile,$4);
												cmdTable.append = false;
												}
	| IOIN STRING IOUT IOUT STRING	err			{strcpy(cmdTable.inputFile,$2);
												strcpy(cmdTable.outputFile,$5);
												cmdTable.append = true;
												}										
;

nonBuilt:
	STRING										{
												strcpy(cmdTable.cmd[cmdTableIndex],$1);
												cmdTable.arguments[cmdTableIndex].argumentNum = 0;
												cmdTable.pipeIN[cmdTableIndex] = false;
												cmdTable.pipeOUT[cmdTableIndex] = false;
												cmdTableIndex++;
												}
	| nonBuilt STRING							{
												strcpy(cmdTable.arguments[cmdTableIndex-1].argu[argumentCounter], $2);
												cmdTable.arguments[cmdTableIndex-1].argumentNum++;
												}	

err:		
													{
														strcpy(cmdTable.errRedirectFile, "");
													}
	| STDERR STRING									{strcpy(cmdTable.errRedirectFile, $2);}
	| STDERR BACKGRND STRING						{	
													if(strcmp($3,"1") == 0){
														strcpy(cmdTable.errRedirectFile, "STDOUT_FILENO");
														}
													else{
														printf("Invalid I/O Redirection\n");
														termianlErr = true;
														}
													}
;

pipes:
	nonBuilt PIPE nonBuilt							{numPipes++;}
	| pipes PIPE nonBuilt							{numPipes++;}
	
%%

int yyerror(char *s) {
  printf("%s\n",s);
  termianlErr = true;
  return 0;
  }


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

int setEnv(char* variable, char* word){
	
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
int printEnvFile(char* filename , int append){
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

int printAliasFile(char *filename, int append){
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

int printEnv(void){
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

int findLastSlash(char* arg) {
	if (sizeof(arg) == 0) {
		return -1;
	}
	int argLen = (int) strlen(arg);
	int slashPos = -1;
	for (int i = 0; i < argLen; i++) {
		if (arg[i] == '/') {
			slashPos = i;
		}
	}
	return slashPos;
}

int runCDHome(void) {
	strcpy(varTable.word[0], varTable.word[1]); //set PWD to HOME
	if(chdir(varTable.word[0]) == 0) {
		return 1;
	}
	else {
		getcwd(cwd, sizeof(cwd));
		strcpy(varTable.word[0], cwd);
		return 0; //error
	}
}

int runCD(char* arg) {
	if (strcmp(arg, ".") == 0) { // special case - cd .
		return 1;
	}
	if (strcmp(arg, "..") == 0) { // special case - cd ..
		int slashPos = findLastSlash(varTable.word[0]);
		if (slashPos < 1) { //if the last '/' is on position 0, then we are in root
			return 1;
		}
		else {
			char *start = &varTable.word[0][0];
  			char *end = &varTable.word[0][slashPos];
			char *substr = (char *)calloc(1, end - start + 1);
  			memcpy(substr, start, end - start);
			strcpy(varTable.word[0], substr);
			if (chdir(varTable.word[0]) == 0) {
				return 1;
			}
			else {
				return 0; // error
			}
		}
	}
	else if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			return 1;
		}
		else {
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
}

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
            //disableAliases = false;
            return 1;
        }
    }
    //disableAliases = false;
    return 0;
}