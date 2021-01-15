class Global {
  int isConst;
  int valueCount;
  String valueItem;
  Global(this.isConst, this.valueCount, this.valueItem);

  int getIsConst() {
    return isConst;
  }

  void setIsConst(int isConst) {
    this.isConst = isConst;
  }

  int getValueCount() {
    return valueCount;
  }

  void setValueCount(int valueCount) {
    this.valueCount = valueCount;
  }

  String getValueItem() {
    return valueItem;
  }

  void setValueItem(String valueItem) {
    this.valueItem = valueItem;
  }
}
