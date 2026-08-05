%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol_table.h"

int yylex(void);
extern int yylineno;
void yyerror(const char *s);
%}

%code requires {
    typedef enum {
        OP_EQ = 258,
        OP_NEQ,
        OP_LEQ,
        OP_GEQ
    } OpType;

    typedef enum {
        NODE_NUM,
        NODE_STR,
        NODE_VAR,
        NODE_LET,
        NODE_ASSIGN,
        NODE_BINOP,
        NODE_IF,
        NODE_WHILE,
        NODE_PRINT,
        NODE_INPUT,
        NODE_SEQ
    } NodeType;

    typedef struct ASTNode {
        NodeType type;
        double num_val;
        char *str_val;
        int op;
        struct ASTNode *left;
        struct ASTNode *right;
        struct ASTNode *third;
    } ASTNode;

    extern ASTNode *root_ast;
    ASTNode *create_node_num(double val);
    ASTNode *create_node_str(char *val);
    ASTNode *create_node_var(char *name);
    ASTNode *create_node_let(char *name, ASTNode *expr);
    ASTNode *create_node_assign(char *name, ASTNode *expr);
    ASTNode *create_node_binop(int op, ASTNode *left, ASTNode *right);
    ASTNode *create_node_if(ASTNode *cond, ASTNode *then_b, ASTNode *else_b);
    ASTNode *create_node_while(ASTNode *cond, ASTNode *body);
    ASTNode *create_node_print(ASTNode *expr);
    ASTNode *create_node_input(void);
    ASTNode *create_node_seq(ASTNode *left, ASTNode *right);

    double eval_ast(ASTNode *node);
    void free_ast(ASTNode *node);
}

%union {
    double num;
    char *str;
    ASTNode *node;
}

%token <num> NUMBER
%token <str> STRING IDENTIFIER
%token LET IF ELSE WHILE PRINT INPUT
%token EQ NEQ LEQ GEQ

%type <node> program stmt_list stmt block expr

%right '='
%left EQ NEQ
%left '<' '>' LEQ GEQ
%left '+' '-'
%left '*' '/'
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

program:
    stmt_list { root_ast = $1; }
;

stmt_list:
    /* empty */ { $$ = NULL; }
  | stmt_list stmt { $$ = create_node_seq($1, $2); }
;

stmt:
    LET IDENTIFIER '=' expr ';' { $$ = create_node_let($2, $4); }
  | IDENTIFIER '=' expr ';' { $$ = create_node_assign($1, $3); }
  | IF '(' expr ')' block %prec LOWER_THAN_ELSE { $$ = create_node_if($3, $5, NULL); }
  | IF '(' expr ')' block ELSE block { $$ = create_node_if($3, $5, $7); }
  | WHILE '(' expr ')' block { $$ = create_node_while($3, $5); }
  | PRINT '(' expr ')' ';' { $$ = create_node_print($3); }
  | ';' { $$ = NULL; }
;

block:
    '{' stmt_list '}' { $$ = $2; }
  | stmt { $$ = $1; }
;

expr:
    NUMBER { $$ = create_node_num($1); }
  | STRING { $$ = create_node_str($1); }
  | IDENTIFIER { $$ = create_node_var($1); }
  | INPUT '(' ')' { $$ = create_node_input(); }
  | expr '+' expr { $$ = create_node_binop('+', $1, $3); }
  | expr '-' expr { $$ = create_node_binop('-', $1, $3); }
  | expr '*' expr { $$ = create_node_binop('*', $1, $3); }
  | expr '/' expr { $$ = create_node_binop('/', $1, $3); }
  | expr '<' expr { $$ = create_node_binop('<', $1, $3); }
  | expr '>' expr { $$ = create_node_binop('>', $1, $3); }
  | expr EQ expr  { $$ = create_node_binop(OP_EQ, $1, $3); }
  | expr NEQ expr { $$ = create_node_binop(OP_NEQ, $1, $3); }
  | expr LEQ expr { $$ = create_node_binop(OP_LEQ, $1, $3); }
  | expr GEQ expr { $$ = create_node_binop(OP_GEQ, $1, $3); }
  | '(' expr ')' { $$ = $2; }
;

%%

ASTNode *root_ast = NULL;

ASTNode *create_node(NodeType type) {
    ASTNode *n = (ASTNode *)malloc(sizeof(ASTNode));
    if (!n) {
        fprintf(stderr, "Memory allocation error\n");
        exit(1);
    }
    n->type = type;
    n->num_val = 0.0;
    n->str_val = NULL;
    n->op = 0;
    n->left = NULL;
    n->right = NULL;
    n->third = NULL;
    return n;
}

ASTNode *create_node_num(double val) {
    ASTNode *n = create_node(NODE_NUM);
    n->num_val = val;
    return n;
}

ASTNode *create_node_str(char *val) {
    ASTNode *n = create_node(NODE_STR);
    n->str_val = val;
    return n;
}

ASTNode *create_node_var(char *name) {
    ASTNode *n = create_node(NODE_VAR);
    n->str_val = name;
    return n;
}

ASTNode *create_node_let(char *name, ASTNode *expr) {
    ASTNode *n = create_node(NODE_LET);
    n->str_val = name;
    n->left = expr;
    return n;
}

ASTNode *create_node_assign(char *name, ASTNode *expr) {
    ASTNode *n = create_node(NODE_ASSIGN);
    n->str_val = name;
    n->left = expr;
    return n;
}

ASTNode *create_node_binop(int op, ASTNode *left, ASTNode *right) {
    ASTNode *n = create_node(NODE_BINOP);
    n->op = op;
    n->left = left;
    n->right = right;
    return n;
}

ASTNode *create_node_if(ASTNode *cond, ASTNode *then_b, ASTNode *else_b) {
    ASTNode *n = create_node(NODE_IF);
    n->left = cond;
    n->right = then_b;
    n->third = else_b;
    return n;
}

ASTNode *create_node_while(ASTNode *cond, ASTNode *body) {
    ASTNode *n = create_node(NODE_WHILE);
    n->left = cond;
    n->right = body;
    return n;
}

ASTNode *create_node_print(ASTNode *expr) {
    ASTNode *n = create_node(NODE_PRINT);
    n->left = expr;
    return n;
}

ASTNode *create_node_input(void) {
    return create_node(NODE_INPUT);
}

ASTNode *create_node_seq(ASTNode *left, ASTNode *right) {
    if (!left) return right;
    if (!right) return left;
    ASTNode *n = create_node(NODE_SEQ);
    n->left = left;
    n->right = right;
    return n;
}

double eval_ast(ASTNode *node) {
    if (!node) return 0.0;

    switch (node->type) {
        case NODE_NUM:
            return node->num_val;

        case NODE_STR:
            return 0.0;

        case NODE_VAR:
            return get_symbol(node->str_val);

        case NODE_LET: {
            double val = eval_ast(node->left);
            set_symbol(node->str_val, val);
            return val;
        }

        case NODE_ASSIGN: {
            if (!has_symbol(node->str_val)) {
                fprintf(stderr, "Runtime Warning: Variable '%s' assigned before declaration.\n", node->str_val);
            }
            double val = eval_ast(node->left);
            set_symbol(node->str_val, val);
            return val;
        }

        case NODE_BINOP: {
            double l = eval_ast(node->left);
            double r = eval_ast(node->right);
            switch (node->op) {
                case '+': return l + r;
                case '-': return l - r;
                case '*': return l * r;
                case '/':
                    if (r == 0) {
                        fprintf(stderr, "Runtime Error: Division by zero.\n");
                        return 0.0;
                    }
                    return l / r;
                case '<': return l < r;
                case '>': return l > r;
                case OP_EQ: return l == r;
                case OP_NEQ: return l != r;
                case OP_LEQ: return l <= r;
                case OP_GEQ: return l >= r;
                default: return 0.0;
            }
        }

        case NODE_IF: {
            double cond = eval_ast(node->left);
            if (cond != 0.0) {
                eval_ast(node->right);
            } else if (node->third) {
                eval_ast(node->third);
            }
            return 0.0;
        }

        case NODE_WHILE: {
            while (eval_ast(node->left) != 0.0) {
                eval_ast(node->right);
            }
            return 0.0;
        }

        case NODE_PRINT: {
            if (node->left && node->left->type == NODE_STR) {
                printf("%s\n", node->left->str_val);
            } else {
                double val = eval_ast(node->left);
                if (val == (long long)val) {
                    printf("%lld\n", (long long)val);
                } else {
                    printf("%g\n", val);
                }
            }
            return 0.0;
        }

        case NODE_INPUT: {
            double val = 0.0;
            if (scanf("%lf", &val) != 1) {
                val = 0.0;
            }
            return val;
        }

        case NODE_SEQ: {
            eval_ast(node->left);
            eval_ast(node->right);
            return 0.0;
        }
    }
    return 0.0;
}

void free_ast(ASTNode *node) {
    if (!node) return;
    free_ast(node->left);
    free_ast(node->right);
    free_ast(node->third);
    if (node->str_val) free(node->str_val);
    free(node);
}

void yyerror(const char *s) {
    fprintf(stderr, "Parse Error at line %d: %s\n", yylineno, s);
}