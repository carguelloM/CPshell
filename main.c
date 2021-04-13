
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
 #include <fcntl.h>

char *getcwd(char *buf, size_t size);
int yyparse();

bool checkExeStatus (char* commandName){
	char binaryPath[100];
	strcpy(binaryPath,"");
	struct stat sb;
	bool abletoExe = false;
	char  PATH_COPY[100];
	strcpy(PATH_COPY, varTable.word[3]);
	char * currpath = strtok(PATH_COPY, ":");

	while(currpath != NULL)
	{	
		strcpy(searchPath,"");
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

bool checkFileReadStatus(int currCMD)
{   
    if(strcmp(cmdTable.inputFile[currCMD], "") == 0){
        return false;
    }
    
    char * filename = cmdTable.inputFile[currCMD];

    if(access(filename, F_OK) == 0)
    {
        if(access(filename, R_OK) == 0)
        {
            return true;
        }

        else{
            printf("No read permission for: %s", filename);
            exit(1);
        }
    }

    char binaryPath[100];
	strcpy(binaryPath, "");
	bool abletoRead = false;
	char  PATH_COPY[100];
	strcpy(PATH_COPY, varTable.word[3]);
	char * currpath = strtok(PATH_COPY, ":");

    while(currpath != NULL)
	{	
		searchPath[0] = '\0';
		strcat(searchPath, currpath);
		strcat(searchPath, "/");
		strcat(searchPath, cmdTable.inputFile[currCMD]);

		if (access(searchPath, F_OK) == 0)
		{   
            if (access(searchPath, R_OK) == 0){
                strcpy(cmdTable.inputFile[currCMD], searchPath);
                return true;
            }

            else
            {
               printf("No read permission for: %s", searchPath);
                exit(1);
            }
			
		}
		// set currpath to next value in PATH env variable
		currpath = strtok(NULL, ":");
	}

  printf("File %s does not exist\n", cmdTable.inputFile[currCMD]);
  exit(1);
}


bool checkFileWriteStatus(int currCMD, int errorOutput)
{
    char * filename;
    if(errorOutput == 1){
        filename = cmdTable.errRedirectFile[currCMD];
    }
    else{
        filename = cmdTable.outputFile[currCMD];
    }

    if(access(filename, F_OK) == 0)
    {
        if(access(filename, W_OK) == 0)
        {
            return true;
        }

        else{
            printf("No write permission for: %s", filename);
            exit(1);
        }
    }
    printf("File %s does not exist \n", cmdTable.inputFile[currCMD]);
    exit(1);
}

int runNonBuiltIn(char* commandName, int totalArgs, int currCMD) {
	pid_t child0 = fork();

    if (child0 > 0) { //PARENT 
		waitpid(child0, NULL,0); 
		return 1;
	}

	else { 
		if(checkExeStatus(commandName))
		{
        bool in = checkFileReadStatus(currCMD);
        bool out = false;
        bool errRed = false;
        if((strcmp(cmdTable.outputFile[currCMD], "") != 0) && checkFileWriteStatus(currCMD,0))
        {
            out = true;
        }

        if(strcmp(cmdTable.errRedirectFile[currCMD], "") != 0){
            printf("HERE");
            errRed = true;
        }
        
        char *argtoPass[totalArgs + 2];
        argtoPass[0] = searchPath;
        argtoPass[totalArgs+1] = NULL;
        for (int i=1; i <= totalArgs; i++)
            {
                argtoPass[i] = cmdTable.arguments[currCMD].argu[i-1];
            }
 
       if(in){
           int fd0 = open(cmdTable.inputFile[currCMD], O_RDONLY);
           if(fd0 != STDIN_FILENO)
           {
             dup2(fd0, STDIN_FILENO);
           }
           close(fd0);
        }

        if(out){   
            if(!cmdTable.append[currCMD]){
            int fd1 = creat(cmdTable.outputFile[currCMD], 0644);
             if(fd1 != STDOUT_FILENO)
                {
                dup2(fd1, STDOUT_FILENO);
                }
            close(fd1);
            }
            else{
                int fd1 = open(cmdTable.outputFile[currCMD], O_WRONLY|O_APPEND);
                if(fd1 != STDOUT_FILENO)
                {
                dup2(fd1, STDOUT_FILENO);
                }
                close(fd1);
            }
        }

        if(errRed)
        {   
            if(strcmp(cmdTable.errRedirectFile[currCMD], "STDOUT_FILENO") == 0)
            {
                dup2(STDOUT_FILENO, STDERR_FILENO);
            }
            else{
                bool tryFile = checkFileWriteStatus(currCMD,1);
                int fd2 = creat(cmdTable.errRedirectFile[currCMD], 0644);
                 if(fd2 != STDERR_FILENO)
                {
                    dup2(fd2, STDERR_FILENO);
                }
                close(fd2);
            }
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
	termianlErr = false;
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
       
		printf("%s [%s]$ ", varTable.word[0], varTable.word[2]);
        yyparse();
        //printf("LOOK: %s\n", cmdTable.errRedirectFile[cmdTableIndex-1]);
        if(termianlErr)
        {
            termianlErr = false;
            continue;
        }
        if(cmdTableIndex != 0)
        {   
            char* runCMD = cmdTable.cmd[cmdTableIndex-1];
            int numargs = cmdTable.arguments[cmdTableIndex-1].argumentNum;
            runNonBuiltIn(runCMD, numargs, cmdTableIndex-1);
            cmdTableIndex--;
        }
    }

   return 0;
}