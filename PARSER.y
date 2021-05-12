%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include "global.h"

#include "Parsing/Aliases/aliasesParse.h"
#include "Parsing/Variables/variablesParse.h"
#include "Parsing/Directories/Directories.h"


int ersex(void);
int yylex(void);
int yyerror(char *s);


%}

%union {char *string;}

%start cmd_line
%type<string> nonBuilt redirection err pipes back
%token <string> BYE CD STRING ALIAS END SETENV PRINTENV UNSETENV UNALIAS IOIN IOUT BACKGRND STDERR PIPE

%%
cmd_line    :
	BYE END 		                {if(!reparsing){exit(1);} return 1; }
    | SETENV STRING STRING END      {if(!reparsing){setEnv($2, $3);}  return 1;}
    | PRINTENV END                  {if(!reparsing){printEnv();}  return 1;}
	| PRINTENV IOUT	STRING END		{if(!reparsing){printEnvFile($3, 0);} return 1;}
	| PRINTENV IOUT IOUT STRING END	{if(!reparsing){printEnvFile($4, 1);} return 1;}					
    | UNSETENV STRING END           {if(!reparsing){unsetEnv($2);}  return 1;}
    | UNALIAS STRING END            {if(!reparsing){unsetAlias($2);}  return 1;}
	| CD STRING END        			{if(!reparsing){runCD($2);}  return 1;}
	| CD END						{ if(!reparsing){runCDHome();}  return 1;}
	| ALIAS STRING STRING END		{if(!reparsing){runSetAlias($2, $3);}  return 1;}
    | ALIAS END                     { if(!reparsing){listAlias();} return 1;}
	| ALIAS IOUT STRING END			{if(!reparsing){printAliasFile($3,0);} return 1;}
	| ALIAS IOUT IOUT STRING END	{if(!reparsing){printAliasFile($4,1);} return 1;}
	| nonBuilt redirection  back END		{return 1;}
	| nonBuilt err back END			{
									strcpy(cmdTable.inputFile,"");
									strcpy(cmdTable.outputFile,"");
									cmdTable.append = false;
									 return 1;}	
	|	pipes err back END				{
									strcpy(cmdTable.inputFile,"");
									strcpy(cmdTable.outputFile,"");
									cmdTable.append = false;
									pipePresent = true; return 1;}
	| 	pipes redirection back END		{ pipePresent = true; return 1;
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
												int currArguNum = cmdTable.arguments[cmdTableIndex-1].argumentNum;
												strcpy(cmdTable.arguments[cmdTableIndex-1].argu[currArguNum], $2);
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
;
back:
													{}											
	| BACKGRND										{backgroundProc = true;}
	
%%

int yyerror(char *s) {
	if(reparsing == true)
	{
		return 1;
	}
	else{
		printf("%s\n",s);
		termianlErr = true;
		return 0;
	}
  }

