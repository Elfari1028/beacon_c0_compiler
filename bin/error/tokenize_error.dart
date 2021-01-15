

 import '../util/pos.dart';
import 'compile_error.dart';
import 'error_code.dart';
import 'error_code.dart';

class TokenizeError extends CompileError {
    // auto-generated

    ErrorCode err;
    Pos pos;

     TokenizeError(ErrorCode err, Pos pos) {
   
        this.err = err;
        this.pos = pos;
    }

     TokenizeError.from(ErrorCode err,int row, int col) {
     
        this.err = err;
        this.pos = new Pos(row, col);
    }

     ErrorCode getErr() {
        return err;
    }

     Pos getPos() {
        return pos;
    }

     String toString() {
        return"Tokenize Error: "+err.toString()+", at: "+pos.toString();
    }
}
