#include "directories.h"

int runCDHome(void) 
{
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


int runCD(char* arg) 
{
	if (strcmp(arg, ".") == 0) { // special case - cd .
		return 1;
	}
	if (strcmp(arg, "..") == 0) { // special case - cd ..
		int slashPos = findLastSlash(varTable.word[0]);
		if (slashPos < 1) { //if the last '/' is on position 0, then we are in root
			chdir("/");
			strcpy(varTable.word[0], "/");
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
		char destination[100];
		
		if(arg[0] == '.' && arg[1] != '.') 
		{
			chopN(arg, 2);
			strcpy(destination, varTable.word[0]);
			strcat(destination, "/");
			strcat(destination, arg);
		}

		else if(arg[0] == '.' && arg[1] == '.')
		{	
			chopN(arg, 3);
			int slashPos = findLastSlash(varTable.word[0]);
			if (slashPos < 1) { //if the last '/' is on position 0, then we are in root
			chdir("/");
			strcpy(varTable.word[0], "/");
			return 1;
			}
			else {
				char *start = &varTable.word[0][0];
				char *end = &varTable.word[0][slashPos];
				char *substr = (char *)calloc(1, end - start + 1);
				memcpy(substr, start, end - start);
				strcpy(destination, substr);
				strcat(destination, "/");
				strcat(destination, arg);
			}
		}
		else{
				strcpy(destination, varTable.word[0]);
				strcat(destination, "/");
				strcat(destination, arg);
		}

		char COPY_ARG[100];
		strcpy(COPY_ARG, destination);
		strcpy(destination, "");
		char* disect = strtok(COPY_ARG, "/");

		while(disect != NULL)
		{
			//printf("DISET = %s\n", disect);
			if(strcmp(disect, ".") == 0)
			{
				// Just ignore it should be current working directory
			}
			else if(strcmp(disect, "..") == 0)
				{
					int slashPos = findLastSlash(destination);
					if (slashPos < 1) { //if the last '/' is on position 0, then we are in root
					chdir("/");
					strcpy(varTable.word[0], "/");
					return 1;
					}

					else {
					char *start = &destination[0];
					char *end = &destination[slashPos];
					char *substr = (char *)calloc(1, end - start + 1);
					memcpy(substr, start, end - start);
					strcat(destination, "/");
					strcpy(destination, substr);
				}
			}
			else
			{	
				strcat(destination, "/");
				strcat(destination, disect);
			}
		disect = strtok(NULL, "/");	
		}
		
		strcpy(varTable.word[0], destination);

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
		
		char destination[200];
		strcpy(destination, "");
		chopN(arg, 1); // Take out first slash

		char COPY_ARG[100];
		strcpy(COPY_ARG, arg);
		char* disect = strtok(COPY_ARG, "/");

		while(disect != NULL)
		{
			if(strcmp(disect, ".") == 0)
			{
				// Just ignore it should be current working directory
			}
			else if(strcmp(disect, "..") == 0)
				{
					int slashPos = findLastSlash(destination);
					if (slashPos < 1) { //if the last '/' is on position 0, then we are in root
					chdir("/");
					strcpy(varTable.word[0], "/");
					return 1;
					}

					else {
					char *start = &destination[0];
					char *end = &destination[slashPos];
					char *substr = (char *)calloc(1, end - start + 1);
					memcpy(substr, start, end - start);
					strcat(destination, "/");
					strcpy(destination, substr);
				}
			}
			else
			{	
				strcat(destination, "/");
				strcat(destination, disect);
			}
		disect = strtok(NULL, "/");	
		}
		
		if(chdir(destination) == 0){
			strcpy(varTable.word[0], destination);
			return 1;
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
}
