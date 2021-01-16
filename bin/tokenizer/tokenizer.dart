import '../error/error_code.dart';
import '../error/tokenize_error.dart';
import '../util/pos.dart';
import '../util/string_builder.dart';
import 'character.dart';
import 'string_iter.dart';
import 'token.dart';
import 'token_type.dart';

class Tokenizer {
  StringIter it;
  StringBuilder token = new StringBuilder();

  Tokenizer(StringIter it) {
    this.it = it;
  }

  // 这里本来是想实现 Iterator<Token> 的，但是 Iterator 不允许抛异常，于是就这样了

  /**
     * 获取下一个 Token
     *
     * @return
     * @throws TokenizeError 如果解析有异常则抛出
     */
  Token nextToken() {
    it.readAll();

    // 跳过之前的所有空白字符
    skipSpaceCharacters();

    if (it.isEOF()) {
      return new Token(TokenType.EOF, "", it.currentPos(), it.currentPos());
    }

    Char peek = it.peekChar();
    // print(String.fromCharCode(peek.value));
    if (Character.isDigit(peek)) {
      return lexUIntOrDouble();
    } else if (String.fromCharCode(it.peekChar().value) == '"') {
      return lexString();
    } else if (String.fromCharCode(it.peekChar().value) == '\'') {
      return lexChar();
    } else if (Character.isAlphabetic(peek) ||
        String.fromCharCode(it.peekChar().value) == '_') {
      return lexIdentOrKeyword();
    } else if (String.fromCharCode(it.peekChar().value) == '/') {
      return lexComment();
    } else {
      return lexOperatorOrUnknown();
    }
  }

  Token lexComment() {
    Pos start = it.currentPos();
    Char now = it.nextChar();
    if (String.fromCharCode(it.peekChar().value) != '/') {
      return new Token(TokenType.DIV, '/', it.previousPos(), it.currentPos());
    }
    while (true) {
      token.appendChar(now);
      now = it.nextChar();
      String nowStr = String.fromCharCode(now.value);
      if (nowStr == '\n' || nowStr == '\t' || nowStr == '\r') {
        break;
      }
    }
    Token t =
        new Token(TokenType.COMMENT, token.toString(), start, it.currentPos());
    token.clear();
    return t;
  }

  Token lexUIntOrDouble() {
    token.clear();
    Pos start = it.currentPos();
    while (true) {
      // 直到查看下一个字符不是数字为止:
      Char peek = it.peekChar();
      if (!Character.isDigit(peek)) {
        break;
      }
      Char now = it.nextChar();
      token.appendChar(now);
    }
    if (String.fromCharCode(it.peekChar().value) != '.') {
      Pos tokenPos =
          new Pos(it.currentPos().row, it.currentPos().col - token.length());
      return new Token(TokenType.UINT_LITERAL, int.parse(token.toString()),
          tokenPos, it.currentPos());
    }
    token.appendChar(it.nextChar());
    int i = 0;
    while (Character.isDigit(it.peekChar())) {
      token.appendChar(it.nextChar());
      i++;
    }
    if (i == 0) {
      Pos tokenPos =
          new Pos(it.currentPos().row, it.currentPos().col - token.length());
      return null;
    }
    if (String.fromCharCode(it.peekChar().value) == 'e' ||
        String.fromCharCode(it.peekChar().value) == 'E') {
      token.appendChar(it.nextChar());
      if (String.fromCharCode(it.peekChar().value) == '+' ||
          String.fromCharCode(it.peekChar().value) == '-')
        token.appendChar(it.nextChar());
      int j = 0;
      while (Character.isDigit(it.peekChar())) {
        token.appendChar(it.nextChar());
        j++;
      }
      Pos tokenPos =
          new Pos(it.currentPos().row, it.currentPos().col - token.length());
      if (j == 0) {
        return null;
      }
      return new Token(TokenType.DOUBLE_LITERAL, double.parse(token.toString()),
          tokenPos, it.currentPos());
    }
    Pos tokenPos =
        new Pos(it.currentPos().row, it.currentPos().col - token.length());
    return new Token(TokenType.DOUBLE_LITERAL, double.parse(token.toString()),
        tokenPos, it.currentPos());
  }

  Token lexString() {
    Pos start = it.currentPos();
    Char peek;
    Char now;
    it.nextChar();
    while (true) {
      peek = it.peekChar();
      if (peek == '\n' || peek == '\t' || peek == '\r') {
        it.nextChar();
        break;
      } else if (peek == '"') {
        it.nextChar();
        break;
      } else if (peek == '\\') {
        it.nextChar();
        peek = it.peekChar();
//                if (peek == '\\' || peek == '"' || peek == '\'' || peek == 'n' || peek == 'r' || peek == 't') {
//                    token.appendChar(now);
//                }
//                else {
//                    it.nextChar();
//                    break;
//                }
        if (peek == '\\' || peek == '"' || peek == '\'') {
          token.appendChar(peek);
        } else if (peek == 'r') {
          token.append('\r');
        } else if (peek == 'n') {
          token.append('\n');
        } else if (peek == 't') {
          token.append('\t');
        } else {
          it.nextChar();
          break;
        }
        it.nextChar();
      } else {
        now = it.nextChar();
        token.appendChar(now);
      }
    }
    if (token.length() != 0) {
      Token t = new Token(
          TokenType.STRING_LITERAL, token.toString(), start, it.currentPos());
      token.clear();
      return t;
    }
    return null;
  }

  Token lexChar() {
    Pos start = it.currentPos();
    String peek;
    Char now;
    it.nextChar();
    while (true) {
      peek = String.fromCharCode(it.peekChar().value);
      if (peek == '\'') {
        it.nextChar();
        break;
      } else if (peek == '\n' || peek == '\t' || peek == '\r') {
        it.nextChar();
        break;
      } else if (peek == '\\') {
        it.nextChar();
        peek = String.fromCharCode(it.peekChar().value);
//                if (peek == '\\' || peek == '"' || peek == '\'' || peek == 'n' || peek == 'r' || peek == 't') {
//                    token.appendChar(now);
//                }
//                else {
//                    it.nextChar();
//                    break;
//                }
        if (peek == '\\' || peek == '"' || peek == '\'') {
          token.appendChar(it.peekChar());
        } else if (peek == 'r') {
          token.append('\r');
        } else if (peek == 'n') {
          token.append('\n');
        } else if (peek == 't') {
          token.append('\t');
        } else {
          it.nextChar();
          break;
        }
        it.nextChar();
      } else {
        now = it.nextChar();
        token.appendChar(now);
      }
    }
    if (token.length() != 0) {
      Token t = new Token(
          TokenType.CHAR_LITERAL, token.toString(), start, it.currentPos());
      token.clear();
      return t;
    }
    return null;
  }

  Token lexIdentOrKeyword() {
    // print(token);
    token.clear();

    Pos start = it.currentPos();
    // print(start);
    while (true) {
      Char peek = it.peekChar();
      // print(String.fromCharCode(peek.value));
      if (!Character.isLetterOrDigit(peek) &&
          String.fromCharCode(it.peekChar().value) != '_') {
        break;
      }
      Char now = it.nextChar();
      token.appendChar(now);
    }
    if (token.length() != 0) {
      String str = token.toString();
      Token t;
      switch (str) {
        case "fn":
          t = new Token(TokenType.FN_KW, str, start, it.currentPos());
          token.clear();
          return t;
        case "let":
          t = new Token(TokenType.LET_KW, str, start, it.currentPos());
          token.clear();
          return t;
        case "const":
          t = new Token(TokenType.CONST_KW, str, start, it.currentPos());
          token.clear();
          return t;
        case "as":
          t = new Token(TokenType.AS_KW, str, start, it.currentPos());
          token.clear();
          return t;
        case "while":
          t = new Token(TokenType.WHILE_KW, str, start, it.currentPos());
          token.clear();
          return t;
        case "if":
          t = new Token(TokenType.IF_KW, str, start, it.currentPos());
          token.clear();
          return t;
        case "else":
          t = new Token(TokenType.ELSE_KW, str, start, it.currentPos());
          token.clear();
          return t;
        case "return":
          t = new Token(TokenType.RETURN_KW, str, start, it.currentPos());
          token.clear();
          return t;
        case "break":
          t = new Token(TokenType.BREAK_KW, str, start, it.currentPos());
          token.clear();
          return t;
        case "continue":
          t = new Token(TokenType.CONTINUE_KW, str, start, it.currentPos());
          token.clear();
          return t;

        case "int":
          t = new Token(TokenType.INT, str, start, it.currentPos());
          token.clear();
          return t;
        case "void":
          t = new Token(TokenType.VOID, str, start, it.currentPos());
          token.clear();
          return t;
        case "double":
          t = new Token(TokenType.DOUBLE, str, start, it.currentPos());
          token.clear();
          return t;
        case "boolean":
          t = new Token(TokenType.BOOLEAN, str, start, it.currentPos());
          token.clear();
          return t;

        default:
          t = new Token(TokenType.IDENT, str, start, it.currentPos());
          token.clear();
          return t;
      }
    }
    return null;
  }

  Token lexOperatorOrUnknown() {
    String sw = String.fromCharCode(it.nextChar().value);
    switch (sw) {
      case '+':
        return new Token(TokenType.PLUS, '+', it.previousPos(),
            it.currentPos()); //区别 MINUS 和 ARROW
      case '-':
        if (String.fromCharCode(it.peekChar().value) == '>') {
          it.nextChar();
          return new Token(
              TokenType.ARROW, "->", it.previousPos(), it.currentPos());
        } else {
          return new Token(
              TokenType.MINUS, '-', it.previousPos(), it.currentPos());
        }
        break;
      case '*':
        return new Token(TokenType.MUL, '*', it.previousPos(), it.currentPos());
      case '(':
        return new Token(
            TokenType.L_PAREN, '(', it.previousPos(), it.currentPos());
      case ')':
        return new Token(
            TokenType.R_PAREN, ')', it.previousPos(), it.currentPos());
      case '{':
        return new Token(
            TokenType.L_BRACE, '{', it.previousPos(), it.currentPos());
      case '}':
        return new Token(
            TokenType.R_BRACE, '}', it.previousPos(), it.currentPos());
      case ',':
        return new Token(
            TokenType.COMMA, ',', it.previousPos(), it.currentPos());
      case ':':
        return new Token(
            TokenType.COLON, ':', it.previousPos(), it.currentPos());
      case ';':
        return new Token(
            TokenType.SEMICOLON, ';', it.previousPos(), it.currentPos());
      case '=':
        if (String.fromCharCode(it.peekChar().value) == '=') {
          it.nextChar();
          return new Token(
              TokenType.EQ, "==", it.previousPos(), it.currentPos());
        } else {
          return new Token(
              TokenType.ASSIGN, '=', it.previousPos(), it.currentPos());
        }
        break;
      //判断 NEQ
      case '!':
        if (String.fromCharCode(it.peekChar().value) == '=') {
          it.nextChar();
          return new Token(
              TokenType.NEQ, "!=", it.previousPos(), it.currentPos());
        } else {
          throw new TokenizeError(ErrorCode.InvalidInput, it.previousPos());
        }

        break;
      //判断 LT 和 LE
      case '<':
        if (String.fromCharCode(it.peekChar().value) == '=') {
          it.nextChar();
          return new Token(
              TokenType.LE, "<=", it.previousPos(), it.currentPos());
        } else {
          return new Token(
              TokenType.LT, '<', it.previousPos(), it.currentPos());
        }

        break;
      //判断 GT 和 GE
      case '>':
        if (String.fromCharCode(it.peekChar().value) == '=') {
          it.nextChar();
          return new Token(
              TokenType.GE, ">=", it.previousPos(), it.currentPos());
        } else {
          return new Token(
              TokenType.GT, '>', it.previousPos(), it.currentPos());
        }

        break;

      default:
        // print("its +\""+ sw+"\"");
        throw new TokenizeError(ErrorCode.InvalidInput, it.previousPos());
    }
  }

  void skipSpaceCharacters() {
    while ((!it.isEOF()) && Character.isWhitespace(it.peekChar())) {
      // print(String.fromCharCode(it.peekChar().value));
      it.nextChar();
    }
  }
}
