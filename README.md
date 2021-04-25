# CP(Cesar&Piotr) - Unix Shell 
#### Cesar Arguello and Piotr Suder

The features implemented for this shell include: 

* Built-in commands (setenv variable word, printenv, unsetenv variable, cd, alias name word, unalias name, alias, bye, infinite loop alias-expansion detection).
* Non-built-in commands (such as ls, pwd, wc, sort, page, nm, cat, cp, mv, ping, echo, etc., with and without arguments).
* Redirecting I/O with non-built-in commands.
* Using pipes with non-built-in commands.
* Running non-built-in commands in background
* Using both pipes and I/O rdirection, combined, with non-built-in commands.
* Environment variable expansion.
* Alias expansion.
* Wildcard matching*.
* Tilde expansion.

The feature which is not implemented is file name completion.

#### *Remark
Wildcard expansion works well with manually inputting the commands through the command line but it causes the shell to go into an infinite loop when invoked from an input file with commands. The reason for that is the retokenizing procedure that is invoked in order to allow expansion of a single word containing the wildcard (for instance \*.c) into possibly multiple words in case more than one file name is matched with the wildcard. Normally, the lexer would return all the file names as one word causing incorrect execution of the commands which take them as an input. That is why we have added one more stage to the parsing procedure. After the wildcard in expanded by the lexer, rather than being parsed and executed, the contents of the command together with the expanded wildcards are saved into a *.txt* file. Then the lexer is invoked again, but this time it takes the contents of the *.txt* file as the input rather than the contents of the *stdin* buffer. This allows us to tokenize the command again, this time with the file names expanded from the wildcard being treated as separate words by the lexer. After that, the parsing and execution is carried out as they normally would. Unfortunately, the effect of changing the input of the lexer from the *stdin* buffer to the *.txt* file and then changing it back to the *stdin* buffer is that all the contents of the *stdin* buffer get flushed and as a result the shell starts getting incorrect inputs which make it go into an infinite loop of printing "Syntax error". 

Given more time, this problem could be possibly resolved by using a *.txt* file where the contents of the *stdin* buffer would be stored before the retokenizing is invoked. Then the commands would be read in from that file rather than from the *stdin* buffer which would prevent the loss of data after the retokenizing procedure would be invoked due to a wildcard being detected. An alternative approach would be to not perform the retokenizing at all and rather pass all of the file names into the parser as one word and make the parser break them up into individual file names before providing them as input to built-in and non-built-in commands.

**When testing the shell, if there are no wildcards in the commands being passed, the shell can be safely tested by using a file with commands as an input. However, if there are wildcards present in the commands, then the commands need to be put in manually through the keyboard.**

## Distribution of Work

Impementing the following features was done collectively by both Cesar and Piotr:

* Built-in commands.
* Non-built-in commands.

Implementing the following features was done exclusively by Cesar:

* Redirecting I/O with non-built-in commands.
* Using pipes with non-built-in commands.
* Running non-built-in commands in background.
* Using both pipes and I/O redirection, combined, with non-built-in commands.

Implementing the following features was done exclusively by Piotr:

* Environment variable expansion
* Alias expansion.
* Wildcard matching.
* Tilde expansion.

