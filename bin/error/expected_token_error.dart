
 import '../tokenizer/token.dart';
import '../tokenizer/token_type.dart';
import '../util/pos.dart';
import 'compile_error.dart';
import 'error_code.dart';

class ExpectedTokenError extends CompileError {
   
    List<TokenType> expecTokenType;
    Token token;

     ErrorCode getErr() {
        return ErrorCode.ExpectedToken;
    }

     Pos getPos() {
        return token.getStartPos();
    }

    /**
     * @param expectedTokenType
     * @param token
     * @param code
     * @param pos
     */
     ExpectedTokenError(TokenType expectedTokenType, Token token) {
        this.expecTokenType =[];
        this.expecTokenType.add(expectedTokenType);
        this.token = token;
    }

    /**
     * @param expectedTokenType
     * @param token
     * @param code
     * @param pos
     */
     ExpectedTokenError.withList(List<TokenType> expectedTokenType, Token token) {
        this.expecTokenType = expectedTokenType;
        this.token = token;
    }

     String toString() {
        return "Analyse error. Expected "+expecTokenType.toString()+" at "+
                token.getStartPos().toString()+"got: "+token.toStringAlt();
    }
}
