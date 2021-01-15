import 'dart:convert';
import 'dart:io';

class Scanner {
  File file;
  List<String> lines = [];
  int ptr = 0;
  Scanner(this.file) {
    final fin = this.file;
    Stream<List<int>> inputStream = fin.openRead();

    inputStream
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(new LineSplitter()) // Convert stream to individual lines.
        .listen((String line) {
      lines.add(line);
    });
  }
  bool hasNext() {
    if (ptr <= lines.length)
      return true;
    else
      return false;
  }

  String nextLine() {
    return lines[ptr++];
  }
}
