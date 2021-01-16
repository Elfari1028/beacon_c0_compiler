import 'dart:ffi';
import 'dart:typed_data';

import '../../lib/binary_codec/binary_codec.dart';

import '../util/optional.dart';
import '../util/pos.dart';
import '../util/scanner.dart';
import 'character.dart';
import 'token.dart';

/**
 * 这是一个从 C++ 版本抄过来的字符迭代器
 */
class StringIter {
  // 以行为基础的缓冲区
  List<String> linesBuffer = [];

  Scanner scanner;
  // 指向下一个要读取的字符
  Pos ptrNext = new Pos(0, 0);

  Pos ptr = new Pos(0, 0);

  bool initialized = false;

  Optional<Char> peeked = Optional.empty();

  StringIter(Scanner scanner) {
    this.scanner = scanner;
  }

  // 从这里开始其实是一个基于行号的缓冲区的实现
  // 为了简单起见，我们没有单独拿出一个类实现
  // 核心思想和 C 的文件输入输出类似，就是一个 buffer 加一个指针，有三个细节
  // 1.缓冲区包括 \n
  // 2.指针始终指向下一个要读取的 Char
  // 3.行号和列号从 0 开始

  // 一次读入全部内容，并且替换所有换行为 \n
  // 这样其实是不合理的，这里只是简单起见这么实现
  void readAll() {
    if (initialized) {
      return;
    }
    while (scanner.hasNext()) {
      linesBuffer.add(scanner.nextLine() + '\n');
    }
    // todo:check read \n?
    initialized = true;
  }

  // 一个简单的总结
  // | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 偏移
  // | = | = | = | = | = | = | = | = | = | = |
  // | h | a | 1 | 9 | 2 | 6 | 0 | 8 | 1 | \n |（缓冲区第0行）
  // | 7 | 1 | 1 | 4 | 5 | 1 | 4 | （缓冲区第1行）
  // 这里假设指针指向第一行的 \n，那么有
  // nextPos() = (1, 0)
  // currentPos() = (0, 9)
  // previousPos() = (0, 8)
  // nextChar() = '\n' 并且指针移动到 (1, 0)
  // peekChar() = '\n' 并且指针不移动
  /**
     * 获取下一个字符的位置
     */
  Pos nextPos() {
    if (ptr.row >= linesBuffer.length) {
      throw new TokenError("advance after EOF");
    }
    if (ptr.col == linesBuffer[ptr.row].length - 1 ||
        linesBuffer[ptr.row][ptr.col + 1] == '\n') {
      return new Pos(ptr.row + 1, 0);
    }
    // print(linesBuffer[ptr.row][ptr.col + 1]);
    return new Pos(ptr.row, ptr.col + 1);
  }

  /**
     * 获取当前字符的位置
     */
  Pos currentPos() {
    return ptr;
  }

  /**
     * 获取上一个字符的位置
     */
  Pos previousPos() {
    if (ptr.row == 0 && ptr.col == 0) {
      throw new TokenError("previous position from beginning");
    }
    if (ptr.col == 0) {
      return new Pos(ptr.row - 1, linesBuffer[ptr.row - 1].length - 1);
    }
    return new Pos(ptr.row, ptr.col - 1);
  }

  /**
     * 将指针指向下一个字符，并返回当前字符
     */
  Char nextChar() {
    if (this.peeked.isPresent()) {
      Char ch = this.peeked.obt();
      this.peeked = Optional.empty();
      this.ptr = ptrNext;
      return ch;
    } else {
      Char ch = this.getNextChar();
      this.ptr = ptrNext;
      return ch;
    }
  }

  Char getNextChar() {
    int result;
    if (isEOF()) {
      result = 0;
    } else {
      result = linesBuffer[ptr.row].codeUnitAt(ptrNext.col);
      ptrNext = nextPos();
      // print(ptrNext);
    }
    //TODO : test this;
    Uint8List list = binaryCodec.encode(result);
    Char ret = Char(list[0]);
    // print(String.fromCharCode(result));
    return ret;
  }

  /**
     * 查看下一个字符，但不移动指针
     */
  Char peekChar() {
    if (peeked.isPresent()) {
      // print("present");
      return peeked.obt();
    } else {
      // print("not present");
      Char ch = getNextChar();
      peeked = Optional.of(ch);
      // print("not present, then: " + String.fromCharCode(peeked.data.value));
      return ch;
    }
  }

  bool isEOF() {
    return ptr.row >= linesBuffer.length;
  }

  // Note: Is it evil to unread a buffer?
  void unreadLast() {
    ptr = previousPos();
  }
}
