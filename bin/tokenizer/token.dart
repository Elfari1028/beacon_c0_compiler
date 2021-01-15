

import 'dart:ffi';

import '../util/pos.dart';
import 'token_type.dart';

class Token {
     TokenType tokenType;
     Object value;
     Pos startPos;
     Pos endPos;

     Token(TokenType tokenType, Object value, Pos startPos, Pos endPos) {
        this.tokenType = tokenType;
        this.value = value;
        this.startPos = startPos;
        this.endPos = endPos;
    }

     Token.fromToken(Token token) {
        this.tokenType = token.tokenType;
        this.value = token.value;
        this.startPos = token.startPos;
        this.endPos = token.endPos;
    }


    // bool equals(Object o) {
    //     if (this == o)
    //         return true;
    //     if (o == null || getClass() != o.getClass())
    //         return false;
    //     Token token = (Token) o;
    //     return tokenType == token.tokenType && Objects.equals(value, token.value)
    //             && Objects.equals(startPos, token.startPos) && Objects.equals(endPos, token.endPos);
    // }

    // @override
    //  int get hashCode {
    //     return Objects.hash(tokenType, value, startPos, endPos);
    // }

     String getValueString() {
        if (value is int || value is String || value is Uint8 || value is double || value is Double) {
            return value.toString();
        }
        throw TokenError("No suitable cast for token value.");
    }

     TokenType getTokenType() {
        return tokenType;
    }

     void setTokenType(TokenType tokenType) {
        this.tokenType = tokenType;
    }

     Object getValue() {
        return value;
    }

     void setValue(Object value) {
        this.value = value;
    }

     Pos getStartPos() {
        return startPos;
    }

     void setStartPos(Pos startPos) {
        this.startPos = startPos;
    }

     Pos getEndPos() {
        return endPos;
    }

     void setEndPos(Pos endPos) {
        this.endPos = endPos;
    }

    @override
     String toString() {
        var sb = "";
        sb+="Line: "+this.startPos.row.toString()+' ';
        sb+="Column: "+this.startPos.col.toString()+' ';
        sb+="Type: "+this.tokenType.toTypeString()+' ';
        sb+="Value: "+this.value.toString();
        return sb.toString();
    }

     String toStringAlt() {
        return ""+"Token("+this.tokenType.toTypeString()+", value: "+value.toString()
                +"at: "+this.startPos.toString();
    }
}

class TokenError extends Error {
  final String message;
  TokenError(this.message);
  @override
  String toString() => "$message";
}