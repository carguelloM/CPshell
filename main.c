#include "main.h"
#include <stdio.h>

int main(){
	shell_init();
	
	while(1){
		printPrompt();
		char *CMD = getCommand();
		printf("Command is: %s", CMD);

	}
}

void shell_init(){
	
}

void printPrompt(){
	printf("nutshell-CP $");
}

char* getCommand(){
	char * CMD;
	scanf("%s",CMD);
	return CMD;
}

