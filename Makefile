CC = gcc
CFLAGS = -Wall -Wextra -std=c99
LEX = flex
YACC = bison -d

TARGET = catc
OBJS = parser.tab.o lex.yy.o symbol_table.o main.o

all: $(TARGET)

$(TARGET):$(OBJS)
	$(CC)$(CFLAGS) -o $(TARGET)$(OBJS)

parser.tab.c parser.tab.h: parser.y
	$(YACC) -o parser.tab.c parser.y

lex.yy.c: lexer.l parser.tab.h
	$(LEX) -o lex.yy.c lexer.l

%.o: %.c
	$(CC)$(CFLAGS) -c $< -o$@

clean:
	rm -f $(TARGET) *.o parser.tab.c parser.tab.h lex.yy.c

.PHONY: all clean