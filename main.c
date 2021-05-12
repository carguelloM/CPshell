#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "global.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "init.h"
#include "execution.h"

char *getcwd(char *buf, size_t size);
int yyparse();
void yyrestart  (FILE * input_file);

int main()
{ 
    int init = shellInit();
    int refresh;

    system("clear");
    while(1)
    {
        
        refresh = shellRefresh();
        printPrompt();
       
        yyparse();
       
        if(termianlErr)
        {
            termianlErr = false;
            yyrestart(stdin);
            continue;
        }
       
        if(backgroundProc)
        {
            pid_t child = fork();
            
            if(child > 0)
            { //PARENT SHELL
               usleep(5000);
            }
            else // CHILD SHOULD CARRY ON WITH THE TASK
            {
            int line = proccessLine();
            exit(1); 
            }    
            
        }
        else{
            int line = proccessLine();
        }
     
    }

   return 0;
}