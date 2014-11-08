%{ open Ast %}

%token LPAREN RPAREN LCURLY RCURLY LSQUARE RSQUARE
%token LQREG RQREG
%token COMMA SEMICOLON COLON
%token EQUAL_TO
%token PLUS_EQUALS MINUS_EQUALS TIMES_EQUALS DIVIDE_EQUALS MODULO_EQUALS
%token LSHIFT_EQUALS RSHIFT_EQUALS BITOR_EQUALS BITAND_EQUALS BITXOR_EQUALS *)
%token LSHIFT RSHIFT BITAND BITOR BITXOR AND OR
%token LT LTE GT GTE EQ NOT_EQ
%token PLUS MINUS TIMES DIVIDE MODULO
%token NOT BITNOT DECREMENT INCREMENT
%token DOLLAR PRIME QUERY POWER
%token IF ELSE WHILE FOR IN
%token COMPLEX FRACTION
%token RETURN
%token EOF
%token <int> INT
%token <float> FLOAT
%token <string> ID TYPE STRING

%right EQUAL_TO PLUS_EQUALS MINUS_EQUALS TIMES_EQUALS DIVIDE_EQUALS MODULO_EQUALS

%left DOLLAR
%left OR
%left AND
%left BITOR
%left BITXOR
%left BITAND
%left EQUALS NOT_EQUALS
%left LT LTE GT GTE
%left LSHIFT RSHIFT
%left PLUS MINUS
%left TIMES DIVIDE MODULO

%right NOT BITNOT POWER

%nonassoc IF
%nonassoc ELSE

%start top_level
%type <Ast.statement list> top_level

%%

ident:
    ID { Ident($1) }

datatype:
  /* TODO 
   * I don't like how this type_of_string func is implemented in AST.
   * We should be doing pattern matching ... I think. */
    TYPE { type_of_string $1 }
  | TYPE LSQUARE RSQUARE { ArrayType(type_of_string $1) }

expr:
  | num_expr
  | bool_expr

(* resolves to boolean *)
bool_expr:
  (* logical *)
  | expr LT expr        { Binop($1, Less, $3) }
  | expr LTE expr       { Binop($1, LessEq, $3) }
  | expr GT expr        { Binop($1, Greater, $3) }
  | expr GTE expr       { Binop($1, GreaterEq, $3) }
  | expr EQ expr        { Binop($1, Eq, $3) }
  | expr NOT_EQ expr    { Binop($1, NotEq, $3) }
  | expr AND expr       { Binop($1, And, $3) }
  | expr OR expr        { Binop($1, Or, $3) }
  /* TODO add later
  | MINUS num_expr %prec UMINUS { Unop(Neg, $2) }
  | NOT num_expr                { Unop(Not, $2) }
  */

/* resolves to a number */
num_expr:
  /* arithmetic */
  | num_expr PLUS num_expr   { Binop($1, Add, $3) }
  | num_expr MINUS num_expr  { Binop($1, Sub, $3) }
  | expr TIMES expr  { Binop($1, Mul, $3) }
  | expr DIVIDE expr  { Binop($1, Div, $3) }
  | expr MODULO expr { Binop($1, Mod, $3) }

  /* unary */
  | BITNOT expr             { Unop(BitNot, $2) }
  | expr BITAND expr        { Binop($1, BitAnd, $3) }
  | expr BITXOR expr        { Binop($1, BitXor, $3) }
  | expr BITOR expr         { Binop($1, BitOr, $3) }
  | expr LSHIFT expr        { Binop($1, Lshift, $3) }
  | expr RSHIFT expr        { Binop($1, Rshift, $3) }

  /* TODO does this work? */
  | LPAREN expr RPAREN { $2 }

  /* literals */
  | INT                         { Int($1) }
  | FLOAT                       { Float($1) }
  | expr DOLLAR expr            { Fraction($1, $3) }
  | STRING                      { String($1) }
  | LCURLY expr_list RCURLY     { Array($2) }
  | LQREG num_expr COMMA num_expr RQREG { QReg($2, $4) }
  | num_expr (PLUS | MINUS) num_expr COMPLEX { Complex($1, $3) }

  /* functions */
  | ident LPAREN RPAREN               { FunctionCall($1, []) }
  | ident LPAREN expr_list RPAREN { FunctionCall ($1, $3) }

expr_list:
  | expr COMMA expr_list { $1 :: $3 }
  | expr                 { [$1] }

decl:
  | ident DECL_EQUAL expr SC               { AssigningDecl($1, $3) }
  | datatype ident SC                      { PrimitiveDecl($1, $2) }
  | datatype ident LSQUARE RSQUARE SC      { ArrayDecl($1, $2, []) }
  | datatype ident LSQUARE expr_list RSQUARE SC { ArrayDecl($1, $2, $4) }

statement:
  | IF LPAREN expr RPAREN statement ELSE statement
      { IfStatement($3, $5, $7) }
  | IF LPAREN expr RPAREN statement %prec IFX
      { IfStatement($3, $5, EmptyStatement) }

  | WHILE LPAREN expr RPAREN statement { WhileStatement($3, $5) }
  | FOR LPAREN iterator_list RPAREN statement { ForStatement($3, $5) }

  | LCURLY statement_seq RCURLY { CompoundStatement($2) }

  | expr SC { Expression($1) }
  | SC { EmptyStatement }
  | decl { Declaration($1) }

  | RETURN expr SC { ReturnStatement($2) }
  | RETURN SC { VoidReturnStatement }


iterator_list:
  | iterator COMMA iterator_list { $1 :: $3 }
  | iterator { [$1] }

iterator:
  | ident IN range { RangeIterator($1, $3) }
  | ident IN expr { ArrayIterator($1, $3) }

range:
  | expr COLON expr COLON expr { Range($1, $3, $5) }
  | expr COLON expr { Range($1, $3, Int(1l)) }
  | COLON expr COLON expr { Range(Int(0l), $2, $4) }
  | COLON expr { Range(Int(0l), $2, Int(1l)) }

top_level_statement:
  | datatype ident LPAREN param_list RPAREN LCURLY statement_seq RCURLY
      { FunctionDecl(false, $1, $2, $4, $7) }
  | DEVICE datatype ident LPAREN param_list RPAREN LCURLY statement_seq RCURLY
      { FunctionDecl(true, $2, $3, $5, $8) }
  | datatype ident LPAREN param_list RPAREN SC
      { ForwardDecl(false, $1, $2, $4) }
  | DEVICE datatype ident LPAREN param_list RPAREN SC
      { ForwardDecl(true, $2, $3, $5) }
  | decl { Declaration($1) }

param:
  | datatype ident { PrimitiveDecl($1, $2) }
  | datatype ident LSQUARE RSQUARE
      { ArrayDecl($1, $2, []) }

non_empty_param_list:
  | param COMMA non_empty_param_list { $1 :: $3 }
  | param { [$1] }

param_list:
  | non_empty_param_list { $1 }
  | { [] }

top_level:
  | top_level_statement top_level {$1 :: $2}
  | top_level_statement { [$1] }

statement_seq:
  | statement statement_seq {$1 :: $2 }
  | { [] }

%%

