#include "helper.h"

int findLastSlash(char* arg) 
{
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



// Source for chopN: https://stackoverflow.com/questions/4761764/how-to-remove-first-three-characters-from-string-with-c
void chopN(char *str, size_t n)
{
    assert(n != 0 && str != 0);
    size_t len = strlen(str);
    if (n > len)
        return;  // Or: n = len;
    memmove(str, str+n, len - n + 1);
}
