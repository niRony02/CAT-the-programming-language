# CAT ? Custom Programming Language Interpreter

CAT is a lightweight, custom interpreted programming language built from scratch using **Flex (Lexer)**, **Bison (Parser)**, and **C** for an academic Compiler Design project.

## Features
- **Data Types & Variables**: Variable declaration (let) and dynamic symbol table assignment.
- **Arithmetic & Logic**: Operations (+, -, *, /) and comparisons (>, <, ==, !=).
- **Control Flow**: if/else conditional logic and while loop iterations.
- **I/O Operations**: Built-in print() statement and dynamic console input().

## Architecture & How It Was Built
1. **Lexical Analysis (lexer.l)**: Scans input source files, handles comments/whitespace, and converts text into tokens.
2. **Syntax Analysis (parser.y)**: Uses Context-Free Grammar (CFG) rules in Bison to parse tokens and construct an **Abstract Syntax Tree (AST)**.
3. **Symbol Table (symbol_table.c/h)**: Implemented as a dynamic linked-list structure storing variable states during execution.
4. **Execution Engine (main.c)**: Recursively evaluates AST nodes to execute logic at runtime.

## Challenges Faced & Solved
- **Windows File Encoding**: Resolved UTF-16 LE BOM parsing errors caused by standard PowerShell redirection by switching output encoding to ASCII/UTF-8.
- **Compiler Warnings**: Addressed implicit POSIX function declaration warnings (ileno) during GCC compilation on Windows MinGW.
- **Parser Grammar Conflicts**: Cleaned stray backslashes and duplicate header guard definitions in Bison declarations.
