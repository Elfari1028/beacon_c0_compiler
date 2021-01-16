import 'dart:math';

class Char {
  int value;
  Char(this.value);
}

class Character {
  static bool isDigit(Char ch) {
    if (ch.value >= 48 && ch.value <= 57) {
      return true;
    } else {
      return false;
    }
  }

  static bool isAlphabetic(Char ch) {
    String str = String.fromCharCode(ch.value);
    final validCharacters = RegExp(r'^[a-zA-Z]+$');
    if (validCharacters.hasMatch(str)) {
      return true;
    } else {
      return false;
    }
  }

  static bool isLetterOrDigit(Char ch) {
    String str = String.fromCharCode(ch.value);

    final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');

    if (validCharacters.hasMatch(str)) {
      return true;
    } else {
      return false;
    }
  }

  static bool isWhitespace(Char ch) {
    if (String.fromCharCode(ch.value) == ' ' ||
        String.fromCharCode(ch.value) == "\n")
      return true;
    else
      return false;
  }
}
