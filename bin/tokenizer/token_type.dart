 enum TokenType {
//    关键字
    FN_KW,
//    -> 'fn'
    LET_KW,
//    -> 'let'
    CONST_KW,
//    -> 'const'
    AS_KW,
//    -> 'as'
    WHILE_KW,
//    -> 'while'
    IF_KW,
//    -> 'if'
    ELSE_KW,
//    -> 'else'
    RETURN_KW,
//    -> 'return'

// 这两个是扩展 c0 的
    BREAK_KW,
//             -> 'break'
    CONTINUE_KW,
//            -> 'continue'

//    字面量
    UINT_LITERAL,
//    -> digit 无符号整数
    STRING_LITERAL,
//    -> '"' (string_regular_char | escape_sequence)* '"' 字符串常量

// 扩展 c0
    DOUBLE_LITERAL,
//    -> digit+ '.' digit+ ([eE] [+-]? digit+)? 无符号整数
    CHAR_LITERAL,
//    -> '\'' (char_regular_char | escape_sequence) '\'' 字符常量

//    标识符
    IDENT,

//    运算符
    PLUS,
//    -> '+'
    MINUS,
//    -> '-'
    MUL,
//    -> '*'
    DIV,
//    -> '/'
    ASSIGN,
//    -> '='
    EQ,
//    -> '=='
    NEQ,
//    -> '!='
    LT,
//    -> '<'
    GT,
//    -> '>'
    LE,
//    -> '<='
    GE,
//    -> '>='
    L_PAREN,
//    -> '('
    R_PAREN,
//    -> ')'
    L_BRACE,
//    -> '{'
    R_BRACE,
//    -> '}'
    ARROW,
//    -> '->'
    COMMA,
//    -> ','
    COLON,
//    -> ':'
    SEMICOLON,
//    -> ';'


//    类型
    INT,
//    64 位有符号整数 int
    VOID,
//    空类型 void
    DOUBLE,
//    64 位 IEEE-754 浮点数 double
    BOOLEAN,

//    注释
    COMMENT,
//    -> '//'

    EOF,
//    文件尾

}
extension TokenTypeString on TokenType{
  String toTypeString() {
        switch (this) {
            case TokenType.FN_KW:
                return "FN_KW";
            case TokenType.LET_KW:
                return "LET_KW";
            case TokenType.CONST_KW:
                return "CONST_KW";
            case TokenType.AS_KW:
                return "AS_KW";
            case TokenType.WHILE_KW:
                return "WHILE_KW";
            case TokenType.IF_KW:
                return "IF_KW";
            case TokenType.ELSE_KW:
                return "ELSE_KW";
            case TokenType.RETURN_KW:
                return "RETURN_KW";
            case TokenType.BREAK_KW:
                return "BREAK_KW";
            case TokenType.CONTINUE_KW:
                return "CONTINUE_KW";
            case TokenType.UINT_LITERAL:
                return "UINT_LITERAL";
            case TokenType.STRING_LITERAL:
                return "STRING_LITERAL";
            case TokenType.DOUBLE_LITERAL:
                return "DOUBLE_LITERAL";
            case TokenType.CHAR_LITERAL:
                return "CHAR_LITERAL";
            case TokenType.IDENT:
                return "IDENT";
            case TokenType.PLUS:
                return "PLUS";
            case TokenType.MINUS:
                return "MINUS";
            case TokenType.MUL:
                return "MUL";
            case TokenType.DIV:
                return "DIV";
            case TokenType.ASSIGN:
                return "ASSIGN";
            case TokenType.EQ:
                return "EQ";
            case TokenType.NEQ:
                return "NEQ";
            case TokenType.LT:
                return "LT";
            case TokenType.GT:
                return "GT";
            case TokenType.LE:
                return "LE";
            case TokenType.GE:
                return "GE";
            case TokenType.L_PAREN:
                return "L_PAREN";
            case TokenType.R_PAREN:
                return "R_PAREN";
            case TokenType.L_BRACE:
                return "L_BRACE";
            case TokenType.R_BRACE:
                return "R_BRACE";
            case TokenType.ARROW:
                return "ARROW";
            case TokenType.COMMA:
                return "COMMA";
            case TokenType.COLON:
                return "COLON";
            case TokenType.SEMICOLON:
                return "SEMICOLON";
            case TokenType.INT:
                return "INT";
            case TokenType.VOID:
                return "VOID";
            case TokenType.DOUBLE:
                return "DOUBLE";
            case TokenType.BOOLEAN:
                return "BOOLEAN";
            case TokenType.COMMENT:
                return "COMMENT";
            case TokenType.EOF:
                return "EOF";
            default:
                return "InvalidToken";
        }
    }
}