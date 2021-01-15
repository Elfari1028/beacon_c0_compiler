class InstructionEntry {
  String ins;
  int op = -10010;

  InstructionEntry(this.ins, {this.op}) {
    this.ins = ins;
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
