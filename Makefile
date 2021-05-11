# Simple Makefile



all:  bison-config flex-config nutshell

bison-config:
	bison -d PARSER.y

flex-config:
	flex LEXER.l

nutshell: 
	gcc main.c Expansions/Lexing/Wildcards/wildcards.c Expansions/Lexing/Variables/variables.c \
	Expansions/Lexing/Aliases/aliases.c Expansions/Lexing/Tilde/tilde.c \
	PARSER.tab.c lex.yy.c -o nutshell.o -ll

clean:
	rm PARSER.tab.c PARSER.tab.h lex.yy.c
