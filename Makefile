# Simple Makefile



all:  bison-config flex-config nutshell

bison-config:
	bison -d PARSER.y

flex-config:
	flex LEXER.l

nutshell: 
	 nutshell.c nutshparser.tab.c lex.yy.c -o nutshell.o

clean:
	rm nutshparser.tab.c nutshparser.tab.h lex.yy.c