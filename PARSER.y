%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"

int yylex(void);
int yyerror(char *s);
int runCD(char* arg);
int runSetAlias(char *name, char *word);
int setEnv(char* variable, char* word);
int printEnv(void);
int unsetEnv(char* variable);
int listAlias(void);
int unsetAlias(char* name);
%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD STRING ALIAS END SETENV PRINTENV UNSETENV UNALIAS

%%
cmd_line    :
	BYE END 		                {exit(1); return 1; }
    | SETENV STRING STRING END      {setEnv($2, $3); return 1;}
    | PRINTENV END                  {printEnv(); return 1;}
    | UNSETENV STRING END           {unsetEnv($2); return 1;}
    | UNALIAS STRING END            {unsetAlias($2); return 1;}
	| CD STRING END        			{runCD($2); return 1;}
	| ALIAS STRING STRING END		{runSetAlias($2, $3); return 1;}
    | ALIAS END                     { listAlias(); return 1;}

%%

int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
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
int runCD(char* arg) {
	if (arg[0] != '/') { // arg is relative path
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

int runSetAlias(char *name, char *word) {
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
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
            disableAliases = false;
            return 1;
        }
    }
    disableAliases = false;
    return 0;
}