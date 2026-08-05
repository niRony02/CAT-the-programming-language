#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"
#include "symbol_table.h"

extern FILE *yyin;
extern ASTNode *root_ast;

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <source_file.cat>\n", argv[0]);
        return 1;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file) {
        perror("Error opening file");
        return 1;
    }

    yyin = file;
    int parse_result = yyparse();
    fclose(file);

    if (parse_result == 0 && root_ast != NULL) {
        eval_ast(root_ast);
        free_ast(root_ast);
    } else {
        fprintf(stderr, "Compilation or parsing failed.\n");
        free_symbol_table();
        return 1;
    }

    free_symbol_table();
    return 0;
}