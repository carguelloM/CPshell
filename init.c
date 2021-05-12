#include "init.h"

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
    backgroundProc = false;
    reparsing = false;
    newLineReached = false;

    getcwd(cwd, sizeof(cwd));

    strcpy(varTable.var[varIndex], "PWD");
    strcpy(varTable.word[varIndex], cwd);
    varIndex++;

    struct passwd *pw = getpwuid(getuid());
    const char *homedir = pw->pw_dir;

    strcpy(varTable.var[varIndex], "HOME");
    strcpy(varTable.word[varIndex], homedir);
    varIndex++;
    strcpy(varTable.var[varIndex], "PROMPT");
    strcpy(varTable.word[varIndex], "nutshell-CP");
    varIndex++;
    strcpy(varTable.var[varIndex], "PATH");
    strcpy(varTable.word[varIndex], ".:/bin");
    varIndex++;

    strcpy(reparseFiledir, varTable.word[1]);
    strcat(reparseFiledir, "/reparser.txt");

    return 1;
}

int shellRefresh(void)
{
    currentCommand = 0;
    cmdTableIndex = 0;
    numPipes = 0;
    pipePresent = false;
    IOPresent =  false;
    backgroundProc = false;
    reparsing = false;
    strcpy(currLine,"");
    newLineReached = false;

    return 1;
}