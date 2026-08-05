#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

static Symbol *head = NULL;

static char *duplicate_string(const char *s) {
    size_t len = strlen(s);
    char *buf = (char *)malloc(len + 1);
    if (buf) strcpy(buf, s);
    return buf;
}

void set_symbol(const char *name, double val) {
    Symbol *curr = head;
    while (curr != NULL) {
        if (strcmp(curr->name, name) == 0) {
            curr->value = val;
            return;
        }
        curr = curr->next;
    }
    Symbol *new_sym = (Symbol *)malloc(sizeof(Symbol));
    if (!new_sym) {
        fprintf(stderr, "Memory allocation error for symbol table\n");
        exit(1);
    }
    new_sym->name = duplicate_string(name);
    new_sym->value = val;
    new_sym->next = head;
    head = new_sym;
}

double get_symbol(const char *name) {
    Symbol *curr = head;
    while (curr != NULL) {
        if (strcmp(curr->name, name) == 0) {
            return curr->value;
        }
        curr = curr->next;
    }
    fprintf(stderr, "Runtime Error: Variable '%s' is not defined.\n", name);
    return 0.0;
}

int has_symbol(const char *name) {
    Symbol *curr = head;
    while (curr != NULL) {
        if (strcmp(curr->name, name) == 0) {
            return 1;
        }
        curr = curr->next;
    }
    return 0;
}

void free_symbol_table(void) {
    Symbol *curr = head;
    while (curr != NULL) {
        Symbol *tmp = curr;
        curr = curr->next;
        free(tmp->name);
        free(tmp);
    }
    head = NULL;
}