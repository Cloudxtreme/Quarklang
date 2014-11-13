{ open Parser }

let digit = ['0'-'9']
let letter = ['a'-'z' 'A'-'Z' '_']
let sign = ['+' '-']
let floating =
    digit+ '.' digit* | '.' digit+
  | digit+ ('.' digit*)? 'e' '-'? digit+
  | '.' digit+ 'e' '-'? digit+
        
rule token = parse
  (* whitespace *)
  | [' ' '\t' '\r' '\n'] { token lexbuf }

  (* meaningful character sequences *)
  | ';' { SEMICOLON }
  | ':' { COLON }
  | ',' { COMMA }
  | '$' { DOLLAR }
  | '(' { LPAREN }  | ')' { RPAREN }
  | '{' { LCURLY }  | '}' { RCURLY }
  | '[' { LSQUARE } | ']' { RSQUARE }
  | '=' { ASSIGN }
  | ''' { PRIME }
  | '?' { QUERY }
  | 'i' { COMPLEX }
  | "<#" { LQREG }
  | "#>" { RQREG }
  | "def" { DEF }


  (* arithmetic *)
  | '+' { PLUS }
  | '-' { MINUS }
  | '*' { TIMES }
  | '/' { DIVIDE }
  | "mod" { MODULO }

  (* logical *)
  | '<'     { LT }
  | "<="    { LTE }
  | '>'     { GT }
  | ">="    { GTE }
  | "=="    { EQUALS }
  | "!="    { NOT_EQUALS }
  | "and"   { AND }
  | "or"    { OR }
  | '!'     { NOT }
  | "**"    { POWER }

  (* unary *)
  | '~'     { BITNOT }
  | '&'     { BITAND }
  | '^'     { BITXOR }
  | '|'     { BITOR }
  | "<<"    { LSHIFT }
  | ">>"    { RSHIFT }

  (* special assignment *)
  | "+=" { PLUS_EQUALS }
  | "-=" { MINUS_EQUALS }
  | "*=" { TIMES_EQUALS }
  | "/-" { DIVIDE_EQUALS }
  | "++" { INCREMENT }
  | "--" { DECREMENT }

  (* literals *) 
  | sign? digit+ as lit { INT(int_of_string lit) } 
  | floating as lit { FLOAT(float_of_string lit) }
  | "true" as lit { BOOL(bool_of_string lit) }
  | "false" as lit { BOOL(bool_of_string lit) }
  | '"' (('\\' _ | [^ '"'])* as str) '"' { STRING(str) }

  (* datatypes *)
  | "bool" 
  | "int" 
  | "float" 
  | "complex" 
  | "void" 
  | "string" 
  | "array"
      as primitive { TYPE(primitive) }

  (* keywords *)
  | "return" { RETURN }
  | "if" { IF }
  | "else" { ELSE }
  | "for" { FOR }
  | "while" { WHILE }
  | "in" { IN }

  (* ID *)
  | letter (letter | digit)* as lit { ID(lit) }

  (* comments *)
  | "%{" { comments lexbuf }
  | "%" {inline_comments lexbuf}

  (* end of file *)
  | eof { EOF }

and comments = parse
  | "}%" { token lexbuf}
  | _ { comments lexbuf}

and inline_comments = parse
  | "\n" {token lexbuf}
  | _ {inline_comments lexbuf}

