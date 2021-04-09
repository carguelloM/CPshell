
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

char *getcwd(char *buf, size_t size);
int yyparse();

bool checkExeStatus (char* commandName){
	char binaryPath[100];
	binaryPath[0] = '/0';
	struct stat sb;
	bool abletoExe = false;
	char  PATH_COPY[100];
	strcpy(PATH_COPY, varTable.word[3]);
	char * currpath = strtok(PATH_COPY, ":");

	while(currpath != NULL)
	{	
		searchPath[0] = '\0';
		strcat(searchPath, currpath);
		strcat(searchPath, "/");
		strcat(searchPath, commandName);

		if (stat(searchPath, &sb) == 0 && sb.st_mode & S_IXUSR) 
		{
			abletoExe = true;
			break;
		}
		// set currpath to next value in PATH env variable
		currpath = strtok(NULL, ":");
	}

	return abletoExe;
}


int runNonBuiltIn(char* commandName, int totalArgs) {
	pid_t child0 = fork();

	if (child0 > 0) { //PARENT 
		waitpid(child0, NULL,0); 
		return 1;
		
	}
	else { 
		if(checkExeStatus(commandName))
		{
        char *argtoPass[totalArgs + 2];
        argtoPass[0] = searchPath;
        argtoPass[totalArgs+1] = NULL;
        for (int i=1; i <= totalArgs; i++)
            {
                argtoPass[i] = cmdTable.arguments[cmdTableIndex-1].argu[i-1];
            }
       
        int value = execv(searchPath, argtoPass);
        
		}
		else{
		printf("Command not found\n");
		exit(1);
		}
        return 1;
	}

}

int main()
{
    aliasIndex = 0;
    varIndex = 0;
    wordCounter = 0;
    cmdTableIndex = 0;
    argumentCounter = 0;
	
    getcwd(cwd, sizeof(cwd));

    strcpy(varTable.var[varIndex], "PWD");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "HOME");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;
    strcpy(varTable.var[varIndex], "PROMPT");
    strcpy(varTable.word[varIndex], "nutshell-CP");
    varIndex++;
    strcpy(varTable.var[varIndex], "PATH");
    strcpy(varTable.word[varIndex], ".:/bin");
    varIndex++;

    system("clear");
    while(1)
    {
       
		printf("[%s]$ ", varTable.word[2]);
        yyparse();
        printf("Current Index %d\n", cmdTableIndex);
        if(cmdTableIndex != 0)
        {
            char* runCMD = cmdTable.cmd[cmdTableIndex-1];
            int numargs = cmdTable.arguments[cmdTableIndex-1].argumentNum;
            runNonBuiltIn(runCMD, numargs);
            cmdTableIndex--;
        }
    }

   return 0;
}