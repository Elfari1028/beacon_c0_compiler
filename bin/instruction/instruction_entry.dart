class InstructionEntry {
  String ins;
  int op;

  InstructionEntry(this.ins, {this.op = -10010}) {
  }
  //   InstructionEntry(String ins, int op){
  //     this.ins = ins;
  //     this.op = op;
  // }

  String getIns() {
    return ins;
  }

  void setIns(String ins) {
    this.ins = ins;
  }

  int getOp() {
    return op;
  }

  void setOp(int op) {
    this.op = op;
  }
}
