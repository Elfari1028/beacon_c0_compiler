
import '../util/pos.dart';
import 'compile_error.dart';
import 'error_code.dart';

class AnalyzeError extends CompileError {
    ErrorCode code;
    Pos pos;

    ErrorCode getErr() {
        return code;
    }

    Pos getPos() {
        return pos;
    }

    /**
     * @param code
     * @param pos
     */
     AnalyzeError(ErrorCode code, Pos pos) {
        this.code = code;
        this.pos = pos;
    }

     String toString() {
        return"Analyze Error: "+code.toString()+", at: "+pos.toString();
    }
}
