import '../instruction/instruction_entry.dart';
import '../tokenizer/token_type.dart';

class SymbolEntry {
  // 种类：简单变量var，函数func，参数param等
  String kind;
  // 类型：int，double，string,void,如果是函数则存其返回类型
  TokenType type;
  // 值,如果是函数，则存其返回值
  Object value;
  // 如果是函数，则是参数类型
  List<TokenType> paramsType = [];

  // 如果是函数
  int level;
  // 指令集
  List<InstructionEntry> instructions = [];
  // 本地变量集
  List<String> locVars = [];
  // 函数参数集
  List<String> paramVars = [];

  // 是否常量
  bool _isConstant;
  // 是否有值
  bool _isInitialized;

  bool _isGlobal = false;

  int stackOffset;

  SymbolEntry(this.kind, this.type, this.level, this._isConstant,
      this._isInitialized, this.stackOffset) {}

  String getKind() {
    return kind;
  }

  void setKind(String kind) {
    this.kind = kind;
  }

  TokenType getType() {
    return type;
  }

  void setType(TokenType type) {
    this.type = type;
  }

  Object getValue() {
    return value;
  }

  void setValue(Object value) {
    this.value = value;
  }

  int getLevel() {
    return level;
  }

  void setLevel(int level) {
    this.level = level;
  }

  List<InstructionEntry> getInstructions() {
    return instructions;
  }

  void setInstructions(List<InstructionEntry> instructions) {
    this.instructions = instructions;
  }

  List<String> getLocVars() {
    return locVars;
  }

  void setLocVars(List<String> locVars) {
    this.locVars = locVars;
  }

  List<String> getParamVars() {
    return paramVars;
  }

  void setParamVars(List<String> paramVars) {
    this.paramVars = paramVars;
  }

  bool getIsConstant() {
    return _isConstant;
  }

  void setConstant(bool constant) {
    _isConstant = constant;
  }

  bool isInitialized() {
    return _isInitialized;
  }

  void setInitialized(bool initialized) {
    _isInitialized = initialized;
  }

  bool isGlobal() {
    return _isGlobal;
  }

  void setGlobal(bool global) {
    _isGlobal = global;
  }

  int getStackOffset() {
    return stackOffset;
  }

  void setStackOffset(int stackOffset) {
    this.stackOffset = stackOffset;
  }

  @override
  String toString() {
    return "{ kind: " + kind + "--- type:" + type.toString() + "}";
  }
}
