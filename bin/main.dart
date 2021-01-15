import 'instruction/output.dart';

void main(List<String> args) {
        var outPut = OutPut();
        outPut.setInPath(args[0]);
        outPut.setOutPath(args[1]);
        outPut.output();
}
