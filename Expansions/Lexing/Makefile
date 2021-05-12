# Simple Makefile



all:  bison-config flex-config nutshell

bison-config:
	bison -d PARSER.y

flex-config:
	flex LEXER.l

nutshell: 
	gcc main.c Lexing/Wildcards/wildcards.c Lexing/Variables/variables.c \
	Lexing/Aliases/aliases.c Lexing/Tilde/tilde.c Parsing/Aliases/aliasesParse.c \
	Parsing/Directories/directories.c Parsing/Directories/helper.c Parsing/Variables/variablesParse.c \
	PARSER.tab.c lex.yy.c -o nutshell.o -ll

clean:
	rm PARSER.tab.c PARSER.tab.h lex.yy.c
