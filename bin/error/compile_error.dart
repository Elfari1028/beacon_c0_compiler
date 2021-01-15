import '../util/pos.dart';
import 'error_code.dart';

abstract class CompileError extends Error {

  ErrorCode getErr();

  Pos getPos();
}
