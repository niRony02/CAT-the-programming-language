#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

typedef struct Symbol {
    char *name;
    double value;
    struct Symbol *next;
} Symbol;

void set_symbol(const char *name, double val);
double get_symbol(const char *name);
int has_symbol(const char *name);
void free_symbol_table(void);

#endif