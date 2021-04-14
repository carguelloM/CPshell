
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
    struct stat sb0;
    struct stat sb1;
    bool abletoExe = false;

    // check if absolute path is given
    printf("NAME : %s\n", commandName);
    if (stat(commandName, &sb0) == 0 && sb0.st_mode & S_IXUSR) 
		{
            strcpy(searchPath, commandName);
			abletoExe = true;
			return abletoExe;
		}

	char binaryPath[100];
	strcpy(binaryPath,"");
	char  PATH_COPY[100];
	strcpy(PATH_COPY, varTable.word[3]);
	char * currpath = strtok(PATH_COPY, ":");

	while(currpath != NULL)
	{	
		strcpy(searchPath,"");
		strcat(searchPath, currpath);
		strcat(searchPath, "/");
		strcat(searchPath, commandName);

		if (stat(searchPath, &sb1) == 0 && sb1.st_mode & S_IXUSR) 
		{
			abletoExe = true;
			return abletoExe;
		}
		// set currpath to next value in PATH env variable
		currpath = strtok(NULL, ":");
	}

	return abletoExe;
}

bool checkFileReadStatus(void)
{   
    if(strcmp(cmdTable.inputFile, "") == 0){
        return false;
    }
    
    char * filename = cmdTable.inputFile;

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
		strcat(searchPath, cmdTable.inputFile);

		if (access(searchPath, F_OK) == 0)
		{   
            if (access(searchPath, R_OK) == 0){
                strcpy(cmdTable.inputFile, searchPath);
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

  printf("File %s does not exist\n", cmdTable.inputFile);
  exit(1);
}


bool checkFileWriteStatus(int errorOutput)
{
    char * filename;
    if(errorOutput == 1){
        filename = cmdTable.errRedirectFile;
    }
    else{
        filename = cmdTable.outputFile;
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
    printf("File %s does not exist \n", cmdTable.inputFile);
    exit(1);
}

int runNonBuiltIn(char* commandName, int totalArgs, int currCMD) {    
    if(pipePresent)
    {
       if(currCMD % 2 == 0)
       {
           pipe(pipeLead);
       }
       else
       {
           pipe(pipeSec);
       }
    }
    
    pid_t child0 = fork();

    if (child0 > 0) { //PARENT 
		waitpid(child0, NULL,0); 
        if(pipePresent){
            if(currCMD == 0)
            {
               close(pipeLead[1]);
               return 1; 
            }
            if(currCMD == cmdTableIndex -1)
            {
                if(currCMD  % 2 == 0)
                {
                    //printf("HERE");
                    close(pipeSec[0]);
                    close(pipeLead[0]);
                    close(pipeLead[1]);
                }
                else
                {
                    close(pipeLead[0]);
                    close(pipeSec[0]);
                    close(pipeSec[1]);

                }
                return 1;
            }

           else
            {
                if(currCMD %2 == 0)
                {
                    close(pipeSec[0]);
                    close(pipeLead[1]);
                }
                else
                {
                    close(pipeSec[1]);
                    close(pipeLead[0]);
                }
            }
             
        }
		return 1;
	}

	else { 
		if(checkExeStatus(commandName))
		{
        int fd0;
        int fd1;

        bool in = false;
        bool out = false;
        bool errRed = false;

        // Check for Input Redirected from File
        //printf("Current CMMD = %d\n", currCMD);
        //printf("Cuuremt CMMD NAME= %s\n", commandName);
        if(IOPresent && (strcmp(cmdTable.inputFile,"") != 0) && (currCMD == 0))
        {   
            //printf("CHANGING INPUT TO FILE\n");
            in = checkFileReadStatus();
            fd0 = open(cmdTable.inputFile, O_RDONLY);
        }

        // Check for Output Redirection to File
        if (IOPresent && (strcmp(cmdTable.outputFile, "") != 0) && (currCMD == cmdTableIndex - 1) && checkFileWriteStatus(0))
        {
             //printf("CHANGING OUTPUT TO FILE\n");
            out = true;
            if(!cmdTable.append){
                fd1 = creat(cmdTable.outputFile, 0644);
            }
            else{
                fd1 = open(cmdTable.outputFile, O_WRONLY|O_APPEND);
            }
        }
            // Check for Standard Error Redirection 
           if(strcmp(cmdTable.errRedirectFile, "") != 0 && (currCMD == cmdTableIndex -1)){
            
            errRed = true;
        }
        
        // Check for Redirection From Pipe
        if(cmdTable.pipeIN[currCMD])
        {
            //printf("CHANGING INPUT TO PIPE\n");
            in = true;
            if(currCMD % 2 == 0)
            {
               fd0 = pipeSec[0]; 
            }
            else{
                fd0 = pipeLead[0];
            }
        }

        // Check for Redirection to Pipe
        if(cmdTable.pipeOUT[currCMD])
        {
            //printf("CHANGING OUTPUT TO PIPE\n");
            out = true;
            if(currCMD % 2 == 0)
            {
                fd1 = pipeLead[1];
            }
            else
            {
                fd1 = pipeSec[1];
            }
        }
        
       if(in){
           if(fd0 != STDIN_FILENO)
           {
             dup2(fd0, STDIN_FILENO);
           }
           close(fd0);
        }

        if(out){   
            if(fd1 != STDOUT_FILENO)
            {
                dup2(fd1, STDOUT_FILENO);
                }
            close(fd1);
        }

        if(errRed)
        {   
            if(strcmp(cmdTable.errRedirectFile, "STDOUT_FILENO") == 0)
            {
                dup2(STDOUT_FILENO, STDERR_FILENO);
            }
            else{
                bool tryFile = checkFileWriteStatus(1);
                int fd2 = creat(cmdTable.errRedirectFile, 0644);
                 if(fd2 != STDERR_FILENO)
                {
                    dup2(fd2, STDERR_FILENO);
                }
                close(fd2);
            }
        }

         // fetch arguments 
        char *argtoPass[totalArgs + 2];
        argtoPass[0] = searchPath;
        argtoPass[totalArgs+1] = NULL;
        for (int i=1; i <= totalArgs; i++)
            {
                argtoPass[i] = cmdTable.arguments[currCMD].argu[i-1];
            }
        // RUN the command
        int value = execv(searchPath, argtoPass);
        
		}
		else{
		printf("Command %s not found\n", commandName);
		exit(1);
		}
        exit(1);
	}

}

int shellInit(void)
{
    aliasIndex = 0;
    varIndex = 0;
    wordCounter = 0;
    cmdTableIndex = 0;
    argumentCounter = 0;
	termianlErr = false;
    currentCommand = 0;
    pipePresent = false;
    IOPresent =  false;

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

    return 1;
}

int shellRefresh(void)
{
    currentCommand = 0;
    cmdTableIndex = 0;
    numPipes = 0;
    pipePresent = false;
    IOPresent =  false;

    return 1;
}

int main()
{   int init = shellInit();
    int refresh;

    system("clear");
    while(1)
    {
        refresh = shellRefresh();
		printf("[%s]$ ", varTable.word[2]);
        yyparse();
       
        if(termianlErr)
        {
            termianlErr = false;
            continue;
        }

        if((strcmp(cmdTable.inputFile,"") != 0) || (strcmp(cmdTable.outputFile, "") != 0) || (strcmp(cmdTable.errRedirectFile, "") != 0))
        {
            IOPresent = true;
        }
    
        while(currentCommand != cmdTableIndex)
        {   
            if(pipePresent){
                if(currentCommand == 0)
                {
                    cmdTable.pipeIN[currentCommand] = false;
                    cmdTable.pipeOUT[currentCommand] = true;
                    cmdTable.pipeIN[currentCommand + 1] = true;
                    
                }
                
                if(currentCommand == cmdTableIndex-1)
                {   
                    cmdTable.pipeOUT[currentCommand] = false;
                }
                else
                {
                    cmdTable.pipeOUT[currentCommand] = true;
                    cmdTable.pipeIN[currentCommand +1] = true;
                  
                }
             }
            char* runCMD = cmdTable.cmd[currentCommand];
            int numargs = cmdTable.arguments[currentCommand].argumentNum;
            runNonBuiltIn(runCMD, numargs, currentCommand);
            currentCommand++;
        }

         
    }

   return 0;
}