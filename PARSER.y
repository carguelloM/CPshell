%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"

int yylex(void);
int yyerror(char *s);
int runCD(char* arg);
int runCDHome(void);
int findLastSlash(char *arg);
int runSetAlias(char *name, char *word);
int setEnv(char* variable, char* word);
int printEnv(void);
int unsetEnv(char* variable);
int listAlias(void);
int unsetAlias(char* name);
int runNonBuiltIn(char* commandName);
%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD STRING ALIAS END SETENV PRINTENV UNSETENV UNALIAS

%%
cmd_line    :
	BYE END 		                {exit(1); return 1; }
    | SETENV STRING STRING END      {setEnv($2, $3);  return 1;}
    | PRINTENV END                  {printEnv();  return 1;}
    | UNSETENV STRING END           {unsetEnv($2);  return 1;}
    | UNALIAS STRING END            {unsetAlias($2);  return 1;}
	| CD STRING END        			{runCD($2);  return 1;}
	| CD END						{ runCDHome();  return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3);  return 1;}
    | ALIAS END                     { listAlias(); return 1;}
	| STRING END					{runNonBuiltIn($1); return 1;}

%%

int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
  }


int runNonBuiltIn(char* commandName) {
	char binaryPath[40000 + 1];
	char pathString[40000 + 1];
	binaryPath[0] = '\0';
	pathString[0] = '\0';

	//strcpy(pathString, )

	// DELETE THE .: from PATH WHEN USING IT!!!!!!

	strcat(binaryPath, varTable.word[3]);
	strcat(binaryPath, "/");
	strcat(binaryPath, commandName);
	printf("%s", binaryPath);
	strcpy(binaryPath, "/bin/ls");

	pid_t p = fork();

	if (p <= 0) { //child process

		int value = execl(binaryPath, binaryPath, NULL);
		printf("%d", value);
		exit(1);
	}
	else { 
		waitpid(); 
		return 1;
	}

}

int setEnv(char* variable, char* word){
    for (int i = 0; i < varIndex; i++){

       if(strcmp(varTable.var[i], variable) == 0) {
			strcpy(varTable.word[i], word);
			return 1;
		} 

        else 
        {
            strcpy(varTable.var[varIndex], variable);
	        strcpy(varTable.word[varIndex], word);
	        varIndex++;
            return 1;
        }   
    }
    return 0;
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