import 'dart:convert';
import 'dart:io';

class Scanner {
  List<String> lines = [];
  int ptr = 0;
  Scanner(List lines) {
    this.lines = lines;
  }
  bool hasNext() {
    if (ptr < lines.length)
      return true;
    else
      return false;
  }

  String nextLine() {
    return lines[ptr++];
  }
}
