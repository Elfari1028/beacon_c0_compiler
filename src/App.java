import error.*;
import instruction.Assembler;

import java.io.*;

public class App {
    public static void main(String[] args) {
        try {
            Assembler outPut = new Assembler(args[0], args[1]);
            outPut.output();
        } catch (Exception e) {
            System.exit(-1);
        }
    }
}
