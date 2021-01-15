import 'dart:ffi';
import 'dart:typed_data';

import 'package:binary_codec/binary_codec.dart';
import 'package:sprintf/sprintf.dart';

class Instruction {
  static String nop() {
    return convertToBinary("00");
  }

  static String push(int i) {
    return "push(" + i.toString() + ")";
  }

  // static String push(int i) {
  //   return "push(" + i.toString() + ")";
  // }

  static Uint8List pushB(int i) {
    Uint8List bytes = Uint8List(9);
    bytes[0] = 0x01;
    return addBytes(bytes, longToBytes(i, 8), 1);
  }

  // static Uint8List pushB(int i) {
  //   Uint8List bytes = Uint8List(9);
  //   bytes[0] = 0x01;
  //   return addBytes(bytes, intToBytes(i, 8), 1);
  // }
//TODO checksqe
  static String pushd(double d) {
    
    return "push(" + doubleToBinary(d) + ")";
  }

  static Uint8List pushdB(double d) {
    Uint8List bytes = Uint8List(9);
    bytes[0] = 0x01;
    return addBytes(bytes, doubleToBytes(d), 1);
  }

  static String pop() {
    return convertToBinary("02");
  }

  static String popn(int i) {
    return "popn(" + i.toString() + ")";
  }

  static Uint8List popnB(int i) {
    Uint8List bytes = Uint8List(5);
    bytes[0] = 0x03;
    return addBytes(bytes, intToBytes(i, 4), 1);
  }

  static String dup() {
    return convertToBinary("04");
  }

  static String loca(int off) {
    return "loca(" + off.toString() + ")";
  }

  static Uint8List locaB(int off) {
    Uint8List bytes = Uint8List(5);
    bytes[0] = 0x0a;
    return addBytes(bytes, intToBytes(off, 4), 1);
  }

  static String arga(int off) {
    return "arga(" + off.toString() + ")";
  }

  static Uint8List argaB(int off) {
    Uint8List bytes = Uint8List(5);
    bytes[0] = 0x0b;
    return addBytes(bytes, intToBytes(off, 4), 1);
  }

  static String globa(int n) {
    return "globa(" + n.toString() + ")";
  }

  static Uint8List globaB(int n) {
    Uint8List bytes = Uint8List(5);
    bytes[0] = 0x0c;
    return addBytes(bytes, intToBytes(n, 4), 1);
  }

  static String load(int n) {
    if (n == 8) return convertToBinary("10");
    if (n == 16) return convertToBinary("11");
    if (n == 32) return convertToBinary("12");
    if (n == 64) return "load64";
    return "";
  }

  static Uint8List load64() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x13;
    return bytes;
  }

  static String store(int n) {
    if (n == 8) return convertToBinary("14");
    if (n == 16) return convertToBinary("15");
    if (n == 32) return convertToBinary("16");
    if (n == 64) return "store64";
    return "";
  }

  static Uint8List store64() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x17;
    return bytes;
  }

  static String alloc() {
    return convertToBinary("18");
  }

  static String free() {
    return convertToBinary("19");
  }

  static String stackalloc(int size) {
    return "stackalloc(" + size.toString() + ")";
  }

  static Uint8List stackallocB(int size) {
    Uint8List bytes = Uint8List(5);
    bytes[0] = 0x1a;
    return addBytes(bytes, intToBytes(size, 4), 1);
  }

  static String addi() {
    return "addi";
  }

  static Uint8List addiB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x20;
    return bytes;
  }

  static String subi() {
    return "subi";
  }

  static Uint8List subiB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x21;
    return bytes;
  }

  static String muli() {
    return "muli";
  }

  static Uint8List muliB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x22;
    return bytes;
  }

  static String divi() {
    return "divi";
  }

  static Uint8List diviB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x23;
    return bytes;
  }

  static String addf() {
    return "addf";
  }

  static Uint8List addfB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x24;
    return bytes;
  }

  static String subf() {
    return "subf";
  }

  static Uint8List subfB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x25;
    return bytes;
  }

  static String mulf() {
    return "mulf";
  }

  static Uint8List mulfB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x26;
    return bytes;
  }

  static String divf() {
    return "divf";
  }

  static Uint8List divfB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x27;
    return bytes;
  }

  static String divu() {
    return "divu";
  }

  static Uint8List divuB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x28;
    return bytes;
  }

  static String shl() {
    return convertToBinary("29");
  }

  static String shr() {
    return convertToBinary("2a");
  }

  static String and() {
    return convertToBinary("2b");
  }

  static String or() {
    return convertToBinary("2c");
  }

  static String xor() {
    return convertToBinary("2d");
  }

  static String not() {
    return "not";
  }

  static Uint8List notB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x2e;
    return bytes;
  }

  static String cmpi() {
    return "cmpi";
  }

  static Uint8List cmpiB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x30;
    return bytes;
  }

  static String cmpu() {
    return convertToBinary("31");
  }

  static String cmpf() {
    return "cmpf";
  }

  static Uint8List cmpfB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x32;
    return bytes;
  }

  static String negi() {
    return "negi";
  }

  static Uint8List negiB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x34;
    return bytes;
  }

  static String negf() {
    return "negf";
  }

  static Uint8List negfB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x35;
    return bytes;
  }

  static String itof() {
    return "itof";
  }

  static Uint8List itofB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x36;
    return bytes;
  }

  static String ftoi() {
    return "ftoi";
  }

  static Uint8List ftoiB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x37;
    return bytes;
  }

  static String shrl() {
    return convertToBinary("38");
  }

  static String setlt() {
    return "setlt";
  }

  static Uint8List setltB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x39;
    return bytes;
  }

  static String setgt() {
    return "setgt";
  }

  static Uint8List setgtB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x3a;
    return bytes;
  }

  static String br(int off) {
    return "br(" + off.toString() + ")";
  }

  static Uint8List brB(int off) {
    Uint8List bytes = Uint8List(5);
    bytes[0] = 0x41;
    return addBytes(bytes, intToBytes(off, 4), 1);
  }

  static String brfalse(int off) {
    return convertToBinary("42") + toBinary(off, 32);
  }

  static String brtrue(int off) {
    return "brtrue(" + off.toString() + ")";
  }

  static Uint8List brtrueB(int off) {
    Uint8List bytes = Uint8List(5);
    bytes[0] = 0x43;
    return addBytes(bytes, intToBytes(off, 4), 1);
  }

  static String call(int id) {
    return "call(" + id.toString() + ")";
  }

  static Uint8List callB(int id) {
    Uint8List bytes = Uint8List(5);
    bytes[0] = 0x48;
    return addBytes(bytes, intToBytes(id, 4), 1);
  }

  static String ret() {
    return "ret";
  }

  static Uint8List retB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x49;
    return bytes;
  }

  static String callname(int id) {
    return "callname(" + id.toString() + ")";
  }

  static Uint8List callnameB(int id) {
    Uint8List bytes = Uint8List(5);
    bytes[0] = 0x4a;
    return addBytes(bytes, intToBytes(id, 4), 1);
  }

  static String scani() {
    return convertToBinary("50");
  }

  static String scanc() {
    return convertToBinary("51");
  }

  static String scanf() {
    return convertToBinary("52");
  }

  static String printi() {
    return convertToBinary("54");
  }

  static String printc() {
    return "printc";
  }

  static Uint8List printcB() {
    Uint8List bytes = Uint8List(1);
    bytes[0] = 0x55;
    return bytes;
  }

  static String printf() {
    return convertToBinary("56");
  }

  static String prints() {
    return convertToBinary("57");
  }

  static String println() {
    return convertToBinary("58");
  }

  static String panic() {
    return convertToBinary("fe");
  }

  static String toBinary(int i, int bytes) {
    return sprintf("%" + bytes.toString() + "s", i.toRadixString(2))
        .replaceAll(" ", "0");
  }
  //  static String toBinary(int i, int bytes) {
  //     return String.format("%"+bytes+"s",i.toRadixString(2)).replaceAll(" ", "0");
  // }


//TODO:: check seq
  static String doubleToBinary(double d) {
    Uint8List data = binaryCodec.encode(d);
    String str = "";
    data.forEach((element) {
      str += element.toRadixString(2);
    });
    return sprintf("%64s", str).replaceAll(" ", "0");
  }

  static String convertToBinary(String cmd) {
    return toBinary(int.parse(cmd, radix: 16), 8);
  }

  static Uint8List cmdToBytes(String cmd) {
    int i = int.parse(cmd);
    return intToBytes(i, 1);
  }

  static Uint8List intToBytes(int value, int len) {
    int l_value = value;
    Uint8List b = Uint8List(len);
    for (int i = 0; i < len; i++) {
      b[len - i - 1] = ((l_value >> (8 * i)) & 0xff);
    }
    return b;
  }

  static Uint8List longToBytes(int value, int len) {
    Uint8List b = Uint8List(len);
    for (int i = 0; i < len; i++) {
      b[len - i - 1] = ((value >> (8 * i)) & 0xff);
    }
    return b;
  }
//TODO:: check seq
  static Uint8List doubleToBytes(double d) {
    Uint8List byteRet = new Uint8List(8);
    Uint8List raw = binaryCodec.encode(d);
    for (int i = 0; i < 8; i++) {
      byteRet[8 - i - 1] = raw[i];
    }
    return byteRet;
  }

  static Uint8List addBytes(Uint8List b1, Uint8List b2, int off) {
    for (int i = off; i < off + b2.length; i++) {
      b1[i] = b2[i - off];
    }
    return b1;
  }
}
