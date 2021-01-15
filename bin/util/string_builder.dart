import '../tokenizer/character.dart';

class StringBuilder {
  String val;
  StringBuilder() {
    val = "";
  }
  void append(String data) {
    val += data;
  }

  void appendChar(Char data) {
    val += String.fromCharCode(data.value);
  }

  void clear() {
    val = "";
  }

  int length() {
    return val.length;
  }

  @override
  String toString() {
    return val;
  }
}
