import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../analyser/analyser.dart';
import '../analyser/function.dart';
import '../analyser/global.dart';
import '../analyser/symbol_entry.dart';
import '../tokenizer/character.dart';
import '../tokenizer/string_iter.dart';
import '../tokenizer/token_type.dart';
import '../tokenizer/tokenizer.dart';
import '../util/hex_list.dart';
import '../util/scanner.dart';
import 'instruction_entry.dart';

class OutPut {
  String inPath;
  String outPath;
  OutPut(this.inPath, this.outPath) {}
  String getInPath() {
    return inPath;
  }

  void setInPath(String inPath) {
    this.inPath = inPath;
  }

  String getOutPath() {
    return outPath;
  }

  void setOutPath(String outPath) {
    this.outPath = outPath;
  }

  void start() {
    File fin = new File(inPath); //转入的文件对象
    Stream<List<int>> inputStream = fin.openRead();
    List<String> lines = [];
    inputStream
        .transform(utf8.decoder) // Decode bytes to UTF-8.
        .transform(new LineSplitter()) // Convert stream to individual lines.
        .listen((String line) {
      // Process results.
      // line = line.replaceAll("\r", "");
      lines.add(line);
      print(line);
    }, onDone: () {
      output(lines);
    });
  }

  void output(List lines) {
    Scanner sc = new Scanner(lines);
    StringIter it = new StringIter(sc);
    Tokenizer tn = new Tokenizer(it);
    Analyser an = new Analyser(tn);
    an.analyse();
    Map<String, SymbolEntry> symbolTable = an.getSymbolTable();

    int top = 0;
    int trueGlobalVarsCount = 0;
    List<Global> globals = [];
    int globalCount = 0;
    List<Func> functions = [];
    int functionCount = 0;

    // print(symbolTable);
    symbolTable.forEach((key, symbolEntry) {
      if (!(symbolEntry.getKind() == ("func"))) {
        trueGlobalVarsCount++;
        globals.add(null);
        if (symbolEntry.getKind() == ("string")) {
          String name = key;
          print(name);
          globals[top++] = new Global(
              symbolEntry.getIsConstant() ? 1 : 0, name.length, name);
        } else {
          globals[top++] =
              new Global(symbolEntry.getIsConstant() ? 1 : 0, 8, "0");
        }
      }
    });

    int globalVarsEnd = top;
    // print(symbolTable);
    symbolTable.forEach((name, symbolEntry) {
      if (symbolEntry.getKind() == ("func")) {
        int funcIndex = an.getFuncIndex(name);
        // print("never here right?" +
        //     funcIndex.toString() +
        //     " " +
        //     globalVarsEnd.toString());
        // print(globals[funcIndex + globalVarsEnd]);
        while (globals.length <= funcIndex + globalVarsEnd) globals.add(null);
        globals[funcIndex + globalVarsEnd] = new Global(1, name.length, name);
        top++;
      }
    });

    globalCount = top;
    print("全局变量表：");
    for (int i = 0; i < top; i++) {
      print(globals[i].getIsConst().toString() +
          " " +
          globals[i].getValueCount().toString() +
          " " +
          globals[i].getValueItem());
    }
    int funcTableTop = 0;
    for (int i = globalVarsEnd + 8; i < globalCount; i++) {
      String funcName = globals[i].getValueItem();
      SymbolEntry funcEntry = symbolTable[funcName];
      int ret_slots = 0;
      if (funcEntry.getType() == TokenType.INT) {
        ret_slots = 1;
      }
      int param_slots = funcEntry.getParamVars().length;
      int loc_slots = funcEntry.getLocVars().length;
      List<InstructionEntry> instructionEntries = funcEntry.getInstructions();
      int body_count = instructionEntries.length;
      while (functions.length <= funcTableTop) functions.add(null);
      if (funcName == ("_start")) {
        functions[funcTableTop++] =
            new Func(i, 0, 0, 0, body_count, instructionEntries);
      } else {
        functions[funcTableTop++] = new Func(i, ret_slots, param_slots,
            loc_slots, body_count, instructionEntries);
      }
    }
    functionCount = funcTableTop;
    print("函数表：");
    for (int i = 0; i < funcTableTop; i++) {
      print(functions[i].getNameLoc().toString() +
          " " +
          functions[i].getRet_slots().toString() +
          " " +
          functions[i].getParam_slots().toString() +
          " " +
          functions[i].getLoc_slots().toString() +
          " " +
          functions[i].getBody_count().toString());
      for (int j = 0; j < functions[i].getBody_count(); j++) {
        print(functions[i].getInstructions()[j].getIns() +
            "(" +
            functions[i].getInstructions()[j].getOp().toString() +
            ")");
      }
    }
    print(globalCount);
    print(functionCount);
    HexList output = HexList();

    File file = new File(outPath);
    var sink = file.openWrite();
    //magic
    HexList magic = int2bytes(4, 0x72303b3e);
    // output.addAll(magic);
    sink.writeln(magic);
    //version
    HexList version = int2bytes(4, 0x00000001);
    // output.addAll(version);
    sink.writeln(version);
    //globals.count
    HexList globalCountByte = int2bytes(4, globalCount);
    // output.addAll(globalCountByte);
    sink.writeln(globalCountByte);
    for (int i = 0; i < globalCount; i++) {
      //isConst
      HexList isConst = int2bytes(1, globals[i].getIsConst());
      // output.addAll(isConst);
      sink.writeln(isConst);
      // value count
      HexList globalValueCountByte;
      //value items
      HexList globalValueItemByte;
      if (globals[i].getValueItem() == ("0")) {
        globalValueCountByte = int2bytes(4, 8);
        globalValueItemByte = long2bytes(8, 0);
      } else {
        globalValueItemByte = String2bytes(globals[i].getValueItem());
        globalValueCountByte = int2bytes(4, globals[i].getValueCount());
      }
      sink.writeln(globalValueCountByte);
      sink.writeln(globalValueItemByte);
      // output.addAll(globalValueCountByte);
      // output.addAll(globalValueItemByte);
    }
    //functions.count
    HexList functionCountByte = int2bytes(4, functionCount);
    // output.addAll(functionCountByte);
    sink.writeln(functionCountByte);
    //functions
    for (int i = 0; i < functionCount; i++) {
      //name
      HexList name = int2bytes(4, functions[i].getNameLoc());
      sink.writeln(name);
      //retSlots
      HexList retSlots = int2bytes(4, functions[i].getRet_slots());
      sink.writeln(retSlots);
      //paramsSlots;
      HexList paramsSlots = int2bytes(4, functions[i].getParam_slots());
      sink.writeln(paramsSlots);
      //locSlots;
      HexList locSlots = int2bytes(4, functions[i].getLoc_slots());
      sink.writeln(locSlots);
      //bodyCount
      HexList bodyCount = int2bytes(4, functions[i].getBody_count());
      sink.writeln(bodyCount);
      //instructions
      for (int j = 0; j < functions[i].getBody_count(); j++) {
        InstructionEntry instructionEntry = functions[i].getInstructions()[j];
        int intInstru = instruToInt(instructionEntry.getIns());
        HexList instruByte = int2bytes(1, intInstru);
        sink.writeln(instruByte);
        print((instructionEntry.ins) + instructionEntry.getOp().toString());
        if (instructionEntry.getOp() != -10010) {
          int opera = instructionEntry.getOp();
          if (intInstru == 0x4a) {
            //print(trueGlobalVarsCount);
            opera = opera + trueGlobalVarsCount;
            print("");
            print(opera);
          }
          bool is64OrNot = is64(instructionEntry.getIns());
          if (is64OrNot) {
            HexList operaByte = long2bytes(8, opera);
            sink.writeln(operaByte);
          } else {
            HexList operaByte = int2bytes(4, opera);
            sink.writeln(operaByte);
          }
        }
      }
    }
    sink.close();
  }

  static HexList Char2bytes(Char value) {
    HexList AB = new HexList();
    AB.add((value.value & 0xff));
    return AB;
  }

  static HexList String2bytes(String valueString) {
    HexList AB = new HexList();
    for (int i = 0; i < valueString.length; i++) {
      Char ch = Char(valueString.codeUnitAt(i));
      AB.add((ch.value & 0xff));
    }
    return AB;
  }

  static HexList long2bytes(int length, int target) {
    HexList bytes = new HexList();
    int start = 8 * (length - 1);
    for (int i = 0; i < length; i++) {
      bytes.add(((target >> (start - i * 8)) & 0xFF));
    }
    return bytes;
  }

  static HexList int2bytes(int length, int target) {
    HexList bytes = new HexList();
    int start = 8 * (length - 1);
    for (int i = 0; i < length; i++) {
      bytes.add(((target >> (start - i * 8)) & 0xFF));
    }
    return bytes;
  }

  static int instruToInt(String name) {
    switch (name) {
      case "stackalloc":
        return 0x1a;
      case "call":
        return 0x48;
      case "callname":
        return 0x4a;
      case "loca":
        return 0x0a;
      case "store64":
        return 0x17;
      case "arga":
        return 0x0b;
      case "load64":
        return 0x13;
      case "push":
        return 0x01;
      case "ret":
        return 0x49;
      case "br":
        return 0x41;
      case "globa":
        return 0x0c;
      case "cmpi":
        return 0x30;
      case "brfalse":
        return 0x42;
      case "brtrue":
        return 0x43;
      case "setlt":
        return 0x39;
      case "setgt":
        return 0x3a;
      case "addi":
        return 0x20;
      case "subi":
        return 0x21;
      case "multi":
        return 0x22;
      case "divi":
        return 0x23;
      case "negi":
        return 0x34;
      case "itof":
        return 0x36;
      case "ftoi":
        return 0x37;
    }
    return 0;
  }

  static bool is64(String name) {
    switch (name) {
      case "stackalloc":
        return false;
      case "call":
        return false;
      case "callname":
        return false;
      case "loca":
        return false;
      case "arga":
        return false;
      case "push":
        return true;
      case "br":
        return false;
      case "globa":
        return false;
      case "brfalse":
        return false;
      case "brtrue":
        return false;
    }
    return false;
  }
}
