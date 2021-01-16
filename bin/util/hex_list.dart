class HexList {
  List<int> list;

  @override
  String toString() {
    String ret = "";
    list.forEach((element) {
      ret += String.fromCharCode(element);
      // element.toRadixString(16).padLeft(2,'0') + " ";
    });
    return ret;
  }

  HexList() {
    list = [];
  }
  HexList.fromList(List<int> tmp) {
    list = tmp;
  }
  void add(int i) {
    list.add(i);
  }

  void addAll(List<int> li) {
    list.addAll(li);
  }
}
