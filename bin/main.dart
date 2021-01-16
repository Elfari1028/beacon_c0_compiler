import 'instruction/output.dart';

void main(List<String> args) {
  try {
    var outPut = OutPut(args[0], args[1]);

    outPut.start();
  } catch (e) {
    print(e);
  }
}
