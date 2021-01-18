import error.*;
import instruction.Assembler;

import java.io.*;

public class App {
    public static void main(String[] args) throws IOException, CompileError {
        Assembler outPut = new Assembler(args[0],args[1]);
        outPut.output();
    }
}
