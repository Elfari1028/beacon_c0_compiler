
 class Pos {
     Pos(int row, int col) {
        this.row = row;
        this.col = col;
    }

     int row;
     int col;

     Pos nextCol() {
        return new Pos(row, col + 1);
    }

     Pos nextRow() {
        return new Pos(row + 1, 0);
    }

     @override
  String toString() {
        return "Pos(row: "+ row.toString()+", col: "+col.toString()+")";
    }
}
