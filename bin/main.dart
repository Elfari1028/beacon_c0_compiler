import 'instruction/output.dart';

int main(List<String> args) {
  try {
    var outPut = OutPut(args[0], args[1]);
    outPut.start();
    return 0;
  } catch (e) {
    print(e);
    return 1;
  }
}
