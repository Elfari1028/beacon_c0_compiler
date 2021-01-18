package tokenizer;

import util.Pos;

import java.util.ArrayList;
import java.util.Optional;
import java.util.Scanner;

/**
 * 这是一个从 C++ 版本抄过来的字符迭代器
 */
public class StringIter {
    // 以行为基础的缓冲区
    ArrayList<String> linesBuffer = new ArrayList<>();

    Scanner scanner;
    // 指向下一个要读取的字符
    Pos ptrNext = new Pos(0, 0);

    Pos ptr = new Pos(0, 0);

    boolean initialized = false;

    Optional<Character> peeked = Optional.empty();

    public StringIter(Scanner scanner) {
        this.scanner = scanner;
    }

    public void readAll() {
        if (initialized) {
            return;
        }
        while (scanner.hasNext()) {
            linesBuffer.add(scanner.nextLine() + '\n');
        }
        // todo:check read \n?
        initialized = true;
    }

    public Pos nextPos() {
        if (ptr.row >= linesBuffer.size()) {
            throw new Error("advance after EOF");
        }
        if (ptr.col == linesBuffer.get(ptr.row).length() - 1) {
            return new Pos(ptr.row + 1, 0);
        }
        return new Pos(ptr.row, ptr.col + 1);
    }

    /**
     * 获取当前字符的位置
     */
    public Pos currentPos() {
        return ptr;
    }

    /**
     * 获取上一个字符的位置
     */
    public Pos previousPos() {
        if (ptr.row == 0 && ptr.col == 0) {
            throw new Error("previous position from beginning");
        }
        if (ptr.col == 0) {
            return new Pos(ptr.row - 1, linesBuffer.get(ptr.row - 1).length() - 1);
        }
        return new Pos(ptr.row, ptr.col - 1);
    }

    /**
     * 将指针指向下一个字符，并返回当前字符
     */
    public char nextChar() {
        if (this.peeked.isPresent()) {
            char ch = this.peeked.get();
            this.peeked = Optional.empty();
            this.ptr = ptrNext;
            return ch;
        } else {
            char ch = this.getNextChar();
            this.ptr = ptrNext;
            return ch;
        }
    }

    private char getNextChar() {
        if (isEOF()) {
            return 0;
        }
        char result = linesBuffer.get(ptrNext.row).charAt(ptrNext.col);
        ptrNext = nextPos();
        return result;
    }

    /**
     * 查看下一个字符，但不移动指针
     */
    public char peekChar() {
        if (peeked.isPresent()) {
            return peeked.get();
        } else {
            char ch = getNextChar();
            this.peeked = Optional.of(ch);
            return ch;
        }
    }

    public Boolean isEOF() {
        return ptr.row >= linesBuffer.size();
    }

    // Note: Is it evil to unread a buffer?
    public void unreadLast() {
        ptr = previousPos();
    }

}
