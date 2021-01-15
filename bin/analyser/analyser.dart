

import '../error/analyze_error.dart';
import '../error/error_code.dart';
import '../error/expected_token_error.dart';
import '../instruction/instruction.dart';
import '../instruction/instruction_entry.dart';
import '../tokenizer/character.dart';
import '../tokenizer/token.dart';
import '../tokenizer/token_type.dart';
import '../tokenizer/tokenizer.dart';
import '../util/pos.dart';
import 'symbol_entry.dart';

class Analyser {

    Tokenizer tokenizer;
    List<Instruction> instructions;

    //    全局变量表
    List<String> globalVarList =[];
    //    全局函数表
    List<String> funcList =[];

    /**
     * 符号表
     */
    Map<String, SymbolEntry> symbolTable = {};


    int level = 0;

    //    判断是否有一个名为 main 的函数作为程序入口
     bool hasMainFuc = false;
    //    判断是否全部返回
    bool allReturn = false;

      List<List<int>> SymbolMatrix = [
            //  *   /  +  -  >  <  >= <= == != as
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],// *
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],// /
            [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0],// +
            [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0],// -
            [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0],// >
            [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0],// <
            [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0],// >=
            [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0],// <=
            [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0],// ==
            [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0],// !=
            [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],// as
    ];


    /**
     * 当前偷看的 token
     */
    Token peekedToken = null;
    //    当前读到的token
    Token currentToken = null;


    /**
     * 下一个变量的栈偏移
     */
    int nextOffset = 0;

     Analyser(Tokenizer tokenizer) {
        this.tokenizer = tokenizer;
        this.instructions =[];
    }

     List<Instruction> analyse(){
        analyseProgram();
        return instructions;
    }


    /**
     * 查看下一个 Token
     *
     * @return
     * @throws TokenizeError
     */
     Token peek()  {
        if (peekedToken == null) {
            do {
                peekedToken = tokenizer.nextToken();
            } while (peekedToken.getTokenType()==(TokenType.COMMENT));
        }
        return peekedToken;
    }

    /**
     * 获取下一个 Token
     *
     * @return
     * @throws TokenizeError
     */
     Token next() {
        if (peekedToken != null) {
            Token token = peekedToken;
            peekedToken = null;
            currentToken = token;
            return token;
        } else {
            currentToken = tokenizer.nextToken();
            return currentToken;
        }
    }

    /**
     * 如果下一个 token 的类型是 tt，则返回 true
     *
     * @param tt
     * @return
     * @throws TokenizeError
     */
     bool check(TokenType tt){
        Token token = peek();
        while (token.getTokenType() == TokenType.COMMENT) {
            next();
            token = peek();
        }
        return token.getTokenType() == tt;
    }

    /**
     * 如果下一个 token 的类型是 tt，则前进一个 token 并返回这个 token
     *
     * @param tt 类型
     * @return 如果匹配则返回这个 token，否则返回 null
     * @throws TokenizeError
     */
     Token nextIf(TokenType tt){
        Token token = peek();
        while (token.getTokenType() == TokenType.COMMENT) {
            next();
            token = peek();
        }
        if (token.getTokenType() == tt) {
            return next();
        } else {
            return null;
        }
    }

    /**
     * 如果下一个 token 的类型是 tt，则前进一个 token 并返回，否则抛出异常
     *
     * @param tt 类型
     * @return 这个 token
     * @throws CompileError 如果类型不匹配
     */
     Token expect(TokenType tt) {
        Token token = peek();
        while (token.getTokenType() == TokenType.COMMENT) {
            next();
            token = peek();
        }
        if (token.getTokenType() == tt) {
            return next();
        } else {
            throw new ExpectedTokenError(tt, token);
        }
    }

    /**
     * 获取下一个变量的栈偏移
     *
     * @return
     */
     int getNextVariableOffset() {
        return this.nextOffset++;
    }

    /**
     * 添加一个符号
     *
     * @param name          名字
     * @param kind
     * @param type
     * @param level
     * @param isInitialized 是否已赋值
     * @param isConstant    是否是常量
     * @param curPos        当前 token 的位置（报错用）
     * @throws AnalyzeError 如果重复定义了则抛异常
     */
     void addSymbol(String name, String kind, TokenType type, int level, bool isConstant, bool isInitialized, Pos curPos){
        // Iterator iter = symbolTable.entrySet().iterator();
        symbolTable.forEach((key, value) {
          String name1 = key;
          SymbolEntry entry1 = value;
          if(name1 == name && entry1.getLevel() == level){
                throw new AnalyzeError(ErrorCode.DuplicateDeclaration, curPos);
          }
        });
        symbolTable[name] =  new SymbolEntry(kind, type, level, isConstant, isInitialized, getNextVariableOffset());
    }

    /**
     * 设置符号为已赋值
     *
     * @param name   符号名称
     * @param curPos 当前位置（报错用）
     * @throws AnalyzeError 如果未定义则抛异常
     */
     void initializeSymbol(String name, Pos curPos) {
        var entry = this.symbolTable[name];
        if (entry == null) {
            throw new AnalyzeError(ErrorCode.NotDeclared, curPos);
        } else {
            entry.setInitialized(true);
        }
    }

    /**
     * 获取变量在栈上的偏移
     *
     * @param name   符号名
     * @param curPos 当前位置（报错用）
     * @return 栈偏移
     * @throws AnalyzeError
     */
     int getOffset(String name, Pos curPos)  {
        var entry = this.symbolTable[name];
        if (entry == null) {
            throw new AnalyzeError(ErrorCode.NotDeclared, curPos);
        } else {
            return entry.getStackOffset();
        }
    }

    /**
     * 获取变量是否是常量
     *
     * @param name   符号名
     * @param curPos 当前位置（报错用）
     * @return 是否为常量
     * @throws AnalyzeError
     */
     bool isConstant(String name, Pos curPos){
        var entry = this.symbolTable[name];
        if (entry == null) {
            throw new AnalyzeError(ErrorCode.NotDeclared, curPos);
        } else {
            return entry.getIsConstant();
        }
    }


     int getGlobalIndex(String name) {
        for (int i = 0; i < globalVarList.length; i++) {
            if (globalVarList[i]==(name))
                return i;
        }
        return -1;
    }

     int getFuncIndex(String name) {
        for (int i = 0; i < funcList.length; i++) {
            if (funcList[i]==(name)) {
                return i;
            }
        }
        return -1;
    }


    //    program -> (decl_stmt| function)*
     void analyseProgram(){
        init();
        while (check(TokenType.FN_KW) || check(TokenType.LET_KW) || check(TokenType.CONST_KW)) {
            if (check(TokenType.FN_KW)) {
                analyseFunction();
            } else {
                analyseDeclStmt("_start");
            }
        }
        expect(TokenType.EOF);
        if(!hasMainFuc){
            throw new AnalyzeError(ErrorCode.NoMainFunc,peekedToken.getStartPos());
        }
        SymbolEntry startSymbol = symbolTable["_start"];
        List<InstructionEntry> instructionEntries = startSymbol.getInstructions();
        InstructionEntry instructionEntry = new InstructionEntry("stackalloc",op: 0);
        instructionEntries.add(instructionEntry);
        InstructionEntry instructionEntry1 = new InstructionEntry("call",op: getFuncIndex("main") - 8);
        instructionEntries.add(instructionEntry1);
        startSymbol.setInstructions(instructionEntries);
        print("分析完成");
    }

     void init(){
//        先将start函数加入符号表
//        addSymbol("_start", "func", TokenType.VOID, 0, true, true, peek().getStartPos());
        Pos pos = new Pos(0, 0);
        addSymbol("getint", "func", TokenType.INT, level, true, true, pos);
        funcList.add("getint");
        addSymbol("getdouble", "func", TokenType.DOUBLE, level, true, true, pos);
        funcList.add("getdouble");
        addSymbol("getchar", "func", TokenType.INT, level, true, true, pos);
        funcList.add("getchar");
        addSymbol("putint", "func", TokenType.VOID, level, true, true, pos);
        funcList.add("putint");
        addSymbol("putdouble", "func", TokenType.VOID, level, true, true, pos);
        funcList.add("putdouble");
        addSymbol("putchar", "func", TokenType.VOID, level, true, true, pos);
        funcList.add("putchar");
        addSymbol("putstr", "func", TokenType.VOID, level, true, true, pos);
        funcList.add("putstr");
        addSymbol("putln", "func", TokenType.VOID, level, true, true, pos);
        funcList.add("putln");
        addSymbol("_start", "func", TokenType.VOID, level, true, true, pos);
        funcList.add("_start");
    }


    //    function -> 'fn' IDENT '(' function_param_list? ')' '->' ty block_stmt
     void analyseFunction() {
        expect(TokenType.FN_KW);
        Token identToken = expect(TokenType.IDENT);
        String funcName = identToken.getValueString();
        addSymbol(funcName, "func", null, level++, true, true, identToken.getStartPos());
        funcList.add(funcName);
        SymbolEntry funcSymbol = symbolTable[funcName];
        funcSymbol.setGlobal(true);
        expect(TokenType.L_PAREN);
        if (!check(TokenType.R_PAREN)) {
            analyseFunctionParamList(funcName);
        }
        expect(TokenType.R_PAREN);
        expect(TokenType.ARROW);
        TokenType type = analyseTy();
        funcSymbol.setType(type);

        if (funcName=="main") {
            hasMainFuc = true;
        }


        analyseBlockStmt(funcName, false, 0, 0, 0);

        if (type == TokenType.VOID) {
            allReturn = true;

            InstructionEntry instructionEntry = new InstructionEntry(("ret"));
            List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
            instructionEntries.add(instructionEntry);
            funcSymbol.setInstructions(instructionEntries);
        }

//        将当前函数中的变量弹出符号表
        int currentLevel = level;

        symbolTable.forEach((key, entry) {
             if (entry.getLevel() == currentLevel&&currentLevel!=0) {
                if (getGlobalIndex(key)!=-1) {
                    entry.setLevel(0);
                    entry.setGlobal(true);
                    entry.setKind("var");
                } else {
                    symbolTable.remove(key);
                }
            }         
        });
        level = currentLevel - 1;
    }


    //    function_param_list -> function_param (',' function_param)*
     void  analyseFunctionParamList(String funcName) {
        if (check(TokenType.CONST_KW) || check(TokenType.IDENT)) {
            analyseFunctionParam(funcName);
        }
        while (check(TokenType.COMMA)) {
            expect(TokenType.COMMA);
            analyseFunctionParam(funcName);
        }
    }

    //    function_param -> 'const'? IDENT ':' ty
     void analyseFunctionParam(String funcName) {
        bool isConst = false;
        if (check(TokenType.CONST_KW)) {
            expect(TokenType.CONST_KW);
            isConst = true;
        }
        Token identToken = expect(TokenType.IDENT);
        expect(TokenType.COLON);
        TokenType type = analyseTy();
        addSymbol(identToken.getValueString(), "param", type, level, isConst, false, identToken.getStartPos());
        SymbolEntry funcSymbol = symbolTable[funcName];
        List<String> paramList = funcSymbol.getParamVars();
        paramList.add(identToken.getValueString());
        funcSymbol.setParamVars(paramList);

    }

    //    block_stmt -> '{' stmt* '}'
     void analyseBlockStmt(String funcName, bool isInLoop, int startLoc, int endLoc, int ifLayer) {
        expect(TokenType.L_BRACE);
        while (!check(TokenType.R_BRACE)) {
            analyseStmt(funcName, isInLoop, startLoc, endLoc, ifLayer);
        }
        expect(TokenType.R_BRACE);
    }


    //    stmt ->
//    expr_stmt
//    | decl_stmt
//    | if_stmt
//    | while_stmt
//    | return_stmt
//    | block_stmt
//    | empty_stmt
     void analyseStmt(String funcName, bool isInLoop, int startLoc, int endLoc, int ifLayer) {
//    empty_stmt -> ';'
        if (check(TokenType.SEMICOLON)) {
            expect(TokenType.SEMICOLON);
        }
        //    let_decl_stmt -> 'let' IDENT ':' ty ('=' expr)? ';'
        else if (check(TokenType.LET_KW)) {
            analyseLetDeclStmt(funcName);
//    const_decl_stmt -> 'const' IDENT ':' ty '=' expr ';'
        } else if (check(TokenType.CONST_KW)) {
            analyseConstDeclStmt(funcName);
        }
//    if_stmt -> 'if' expr block_stmt ('else' (block_stmt | if_stmt))?
        else if (check(TokenType.IF_KW)) {
            analyseIfStmt(funcName, isInLoop, startLoc, endLoc, ifLayer);
        }
//    while_stmt -> 'while' expr block_stmt
        else if (check(TokenType.WHILE_KW)) {
            analyseWhileStmt(funcName);
        }
//    return_stmt -> 'return' expr? ';'
        else if (check(TokenType.RETURN_KW)) {
            analyseReturnStmt(funcName);
        }
//    block_stmt -> '{' stmt* '}'
        else if (check(TokenType.L_BRACE)) {
            analyseBlockStmt(funcName, isInLoop, startLoc, endLoc, ifLayer);
        } else if (check(TokenType.BREAK_KW)) {
            if (!isInLoop) {
                throw new AnalyzeError(ErrorCode.NoEnd, new Pos(0, 0));
            }
            analyseBreakStmt(funcName, endLoc, ifLayer);
        } else if (check(TokenType.CONTINUE_KW)) {
            if (!isInLoop) {
                throw new AnalyzeError(ErrorCode.NoEnd, new Pos(0, 0));
            }
            analyseContinueStmt(funcName, startLoc, ifLayer);
        }
//    expr_stmt -> expr ';'
        else {
            analyseExprStmt(funcName);
        }
    }

     void analyseExprStmt(String funcName){
        analyseExpr(funcName);
        expect(TokenType.SEMICOLON);
    }

     void analyseContinueStmt(String funcName, int startLoc, int ifLayer) {
        expect(TokenType.CONTINUE_KW);
        SymbolEntry funcSymbol = symbolTable[funcName];
        List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
        int currentLoc = instructionEntries.length;
        InstructionEntry instructionEntry = new InstructionEntry("br", op:startLoc - currentLoc - 3 - ifLayer);
        instructionEntries.add(instructionEntry);
        funcSymbol.setInstructions(instructionEntries);
        expect(TokenType.SEMICOLON);
    }

     void analyseBreakStmt(String funcName, int endLoc, int ifLayer)  {
        expect(TokenType.BREAK_KW);
        SymbolEntry funcSymbol = symbolTable[funcName];
        List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
        int currentLoc = instructionEntries.length;
        InstructionEntry instructionEntry = new InstructionEntry("br", op:endLoc - currentLoc - 3 - ifLayer);
        instructionEntries.add(instructionEntry);
        funcSymbol.setInstructions(instructionEntries);
        expect(TokenType.SEMICOLON);
    }

    //    if_stmt -> 'if' expr block_stmt ('else' (block_stmt | if_stmt))?
     void analyseIfStmt(String funcName, bool isInLoop, int startLoc, int endLoc, int ifLayer) {
        expect(TokenType.IF_KW);
        SymbolEntry funcSymbol = symbolTable[funcName];
        analyseExpr(funcName);
        List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
        int loc1 = instructionEntries.length;
        InstructionEntry endIns = instructionEntries[loc1 - 1];
        if (!(endIns.getIns()=="brtrue") && !(endIns.getIns()=="brfalse")) {
            InstructionEntry instructionEntry = new InstructionEntry("brture",op: 1);
            instructionEntries.add(instructionEntry);
            loc1++;
        }
        analyseBlockStmt(funcName, isInLoop, startLoc, endLoc, ifLayer);
        int loc2 = instructionEntries.length;
        InstructionEntry instructionEntry = new InstructionEntry("br", op:loc2 - loc1 + 1);
        instructionEntries.insert(loc1,instructionEntry);
        bool hasElse = false;
        if (check(TokenType.ELSE_KW)) {
            expect(TokenType.ELSE_KW);
            hasElse = true;
            if (check(TokenType.L_BRACE)) {
                analyseBlockStmt(funcName, isInLoop, startLoc, endLoc, ifLayer);
            } else if (check(TokenType.IF_KW)) {
                ifLayer++;
                analyseIfStmt(funcName, isInLoop, startLoc, endLoc, ifLayer);
            } else {
                throw new AnalyzeError(ErrorCode.NoEnd, peek().getStartPos());
            }
        }
        int loc3 = instructionEntries.length;
        if (hasElse) {
            instructionEntry = new InstructionEntry("br",op: loc3 - loc2);
            instructionEntries.insert(loc2 + 1, instructionEntry);
        }
        instructionEntry = new InstructionEntry("br",op: 0);
        instructionEntries.add(instructionEntry);
        funcSymbol.setInstructions(instructionEntries);
    }

    //    while_stmt -> 'while' expr block_stmt
     void analyseWhileStmt(String funcName) {
        expect(TokenType.WHILE_KW);
        SymbolEntry funcSymbol = symbolTable[funcName];
        List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
        InstructionEntry instructionEntry = new InstructionEntry("br", op:0);
        instructionEntries.add(instructionEntry);
        int loc1 = instructionEntries.length;
        print("loc1:" + loc1.toString());
        funcSymbol.setInstructions(instructionEntries);
        analyseExpr(funcName);
        instructionEntries = funcSymbol.getInstructions();
        InstructionEntry endIns = instructionEntries[instructionEntries.length - 1];
        if (!(endIns.getIns()=="brtrue") && !(endIns.getIns()=="brfalse")) {
            instructionEntry = new InstructionEntry("brture", op:1);
            instructionEntries.add(instructionEntry);
        }
        int loc2 = instructionEntries.length;
        print("loc2:" + loc2.toString());
        funcSymbol.setInstructions(instructionEntries);
        analyseBlockStmt(funcName, true, loc1, loc2, 0);
        instructionEntries = funcSymbol.getInstructions();
        int loc3 = instructionEntries.length;
        instructionEntry = new InstructionEntry("br", op:loc3 - loc2 + 1);
        instructionEntries.insert(loc2, instructionEntry);
        instructionEntry = new InstructionEntry("br", op:loc1 - loc3 - 2);
        instructionEntries.add(instructionEntry);
        funcSymbol.setInstructions(instructionEntries);
    }

    //    return_stmt -> 'return' expr? ';'
     void analyseReturnStmt(String funcName){
        SymbolEntry funcSymbol = symbolTable[funcName];
        InstructionEntry instructionEntry;
        Token token = expect(TokenType.RETURN_KW);
        TokenType retType = TokenType.VOID;
        List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
//        有返回值
        if (!check(TokenType.SEMICOLON)) {
            instructionEntry = new InstructionEntry("arga", op:0);
            instructionEntries.add(instructionEntry);
            funcSymbol.setInstructions(instructionEntries);
            retType = analyseExpr(funcName);
            instructionEntries = funcSymbol.getInstructions();
            instructionEntry = new InstructionEntry("store64");
            instructionEntries.add(instructionEntry);
            funcSymbol.setInstructions(instructionEntries);
        }
//        print(funcSymbol.getType().toString()+' ' +retType.toString());
        if (funcSymbol.getType() != retType) {
            throw new AnalyzeError(ErrorCode.NotDeclared, token.getStartPos());
        }
        instructionEntries = funcSymbol.getInstructions();
        instructionEntry = new InstructionEntry("ret");
        instructionEntries.add(instructionEntry);
        funcSymbol.setInstructions(instructionEntries);
        expect(TokenType.SEMICOLON);
    }

    //    decl_stmt -> let_decl_stmt | const_decl_stmt
     void analyseDeclStmt(String funcName)  {
        if (check(TokenType.LET_KW)) {
            analyseLetDeclStmt(funcName);
        } else {
            analyseConstDeclStmt(funcName);
        }
    }

    //    let_decl_stmt -> 'let' IDENT ':' ty ('=' expr)? ';'
     void analyseLetDeclStmt(String funcName)  {
        expect(TokenType.LET_KW);
        SymbolEntry funcSymbol = symbolTable[funcName];
        Token identToken = expect(TokenType.IDENT);
        expect(TokenType.COLON);
        TokenType type = analyseTy();
        if (type == TokenType.VOID) {
            throw new AnalyzeError(ErrorCode.InvalidAssignment, identToken.getStartPos());
        }

//        加入符号表
        addSymbol(identToken.getValueString(), "var", type, level, false, false, identToken.getStartPos());
        SymbolEntry varSymbol = symbolTable[identToken.getValueString()];
        List<String> localVars = funcSymbol.getLocVars();
        List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
        InstructionEntry instructionEntry;
        bool isGlobal = false;
        if(level == 0){
            isGlobal = true;
            globalVarList.add(identToken.getValueString());
        }
        if (check(TokenType.ASSIGN)) {
            expect(TokenType.ASSIGN);
            varSymbol.setInitialized(true);
            if (isGlobal) {
                instructionEntry = new InstructionEntry("globa", op:localVars.length);
            } else {
                instructionEntry = new InstructionEntry("loca", op:localVars.length);
            }
            instructionEntries.add(instructionEntry);
            funcSymbol.setInstructions(instructionEntries);
            analyseExpr(funcName);
            instructionEntries = funcSymbol.getInstructions();
            instructionEntry = new InstructionEntry("store64");
            instructionEntries.add(instructionEntry);
            funcSymbol.setInstructions(instructionEntries);
        }
        varSymbol.setGlobal(isGlobal);
        localVars.add(identToken.getValueString());
        funcSymbol.setLocVars(localVars);
        expect(TokenType.SEMICOLON);
    }


    //    const_decl_stmt -> 'const' IDENT ':' ty '=' expr ';'
     void analyseConstDeclStmt(String funcName){
        expect(TokenType.CONST_KW);
        SymbolEntry funcSymbol = symbolTable[funcName];
        Token identToken = expect(TokenType.IDENT);
        expect(TokenType.COLON);
        TokenType type = analyseTy();
        if (type == TokenType.VOID) {
            throw new AnalyzeError(ErrorCode.InvalidAssignment, identToken.getStartPos());
        }
//        加入符号表
        addSymbol(identToken.getValueString(), "var", type, level, true, true, identToken.getStartPos());
        SymbolEntry varSymbol = symbolTable[identToken.getValueString()];
        List<String> localVars = funcSymbol.getLocVars();
        List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
        InstructionEntry instructionEntry;
        expect(TokenType.ASSIGN);
        varSymbol.setInitialized(true);
        if (level == 0) {
            varSymbol.setGlobal(true);
            globalVarList.add(identToken.getValueString());
            instructionEntry = new InstructionEntry("globa",op: localVars.length);
        } else {
            instructionEntry = new InstructionEntry("loca",op: localVars.length);
        }
        instructionEntries.add(instructionEntry);
        funcSymbol.setInstructions(instructionEntries);
        analyseExpr(funcName);
        instructionEntries = funcSymbol.getInstructions();
        instructionEntry = new InstructionEntry("store64");
        instructionEntries.add(instructionEntry);
        funcSymbol.setInstructions(instructionEntries);
        localVars.add(identToken.getValueString());
        funcSymbol.setLocVars(localVars);
        expect(TokenType.SEMICOLON);
    }


     TokenType analyseTy() {
        if (check(TokenType.INT)) {
            return expect(TokenType.INT).getTokenType();
        } else if (check(TokenType.VOID)) {
            return expect(TokenType.VOID).getTokenType();
        } else {
            return expect(TokenType.DOUBLE).getTokenType();
        }
    }


    /*
     * 改写表达式相关的产生式：
     * E -> C ( == | != | < | > | <= | >= C )
     * C -> T { + | - T}
     * T -> F { * | / F}
     * F -> A ( as int_ty | double_ty )
     * A -> ( - ) I
     * I -> IDENT | UNIT | DOUBLE | func_call | '(' E ')' | IDENT = E
     *  */
     TokenType analyseExpr(String funcName) {
        TokenType type = analyseC(funcName);
        while (true) {
            // 预读可能是运算符的 token
            Token op = peek();
            if (op.getTokenType() != TokenType.EQ &&
                    op.getTokenType() != TokenType.NEQ &&
                    op.getTokenType() != TokenType.LT &&
                    op.getTokenType() != TokenType.GT &&
                    op.getTokenType() != TokenType.LE &&
                    op.getTokenType() != TokenType.GE) {
                break;
            }
            // 运算符
            next();
            analyseC(funcName);

            SymbolEntry funcSymbol = symbolTable[funcName];
            List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
            InstructionEntry instructionEntry1;
            InstructionEntry instructionEntry2;
            // 生成代码
            if (op.getTokenType() == TokenType.EQ) {
                instructionEntry1 = new InstructionEntry("cmpi");
                instructionEntry2 = new InstructionEntry("brfalse", op:1);
                instructionEntries.add(instructionEntry1);
                instructionEntries.add(instructionEntry2);
            } else if (op.getTokenType() == TokenType.NEQ) {
                instructionEntry1 = new InstructionEntry("cmpi");
                instructionEntry2 = new InstructionEntry("brtrue", op:1);
                instructionEntries.add(instructionEntry1);
                instructionEntries.add(instructionEntry2);
            } else if (op.getTokenType() == TokenType.LT) {
                instructionEntry1 = new InstructionEntry("cmpi");
                instructionEntry2 = new InstructionEntry("setlt");
                InstructionEntry instructionEntry3 = new InstructionEntry("brtrue", op:1);
                instructionEntries.add(instructionEntry1);
                instructionEntries.add(instructionEntry2);
                instructionEntries.add(instructionEntry3);
            } else if (op.getTokenType() == TokenType.GT) {
                instructionEntry1 = new InstructionEntry("cmpi");
                instructionEntry2 = new InstructionEntry("setgt");
                InstructionEntry instructionEntry3 = new InstructionEntry("brtrue", op:1);
                instructionEntries.add(instructionEntry1);
                instructionEntries.add(instructionEntry2);
                instructionEntries.add(instructionEntry3);
            } else if (op.getTokenType() == TokenType.LE) {
                instructionEntry1 = new InstructionEntry("cmpi");
                instructionEntry2 = new InstructionEntry("setgt");
                InstructionEntry instructionEntry3 = new InstructionEntry("brfalse", op:1);
                instructionEntries.add(instructionEntry1);
                instructionEntries.add(instructionEntry2);
                instructionEntries.add(instructionEntry3);
            } else {
                instructionEntry1 = new InstructionEntry("cmpi");
                instructionEntry2 = new InstructionEntry("setlt");
                InstructionEntry instructionEntry3 = new InstructionEntry("brfalse",op: 1);
                instructionEntries.add(instructionEntry1);
                instructionEntries.add(instructionEntry2);
                instructionEntries.add(instructionEntry3);
            }
            funcSymbol.setInstructions(instructionEntries);
        }
        return type;
    }

     TokenType analyseC(String funcName)  {
        TokenType type = analyseT(funcName);
        while (true) {
            // 预读可能是运算符的 token
            Token op = peek();
            if (op.getTokenType() != TokenType.PLUS &&
                    op.getTokenType() != TokenType.MINUS) {
                break;
            }
            // 运算符
            next();
            analyseT(funcName);
            SymbolEntry funcSymbol = symbolTable[funcName];
            List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
            InstructionEntry instructionEntry;
            // 生成代码
            if (op.getTokenType() == TokenType.PLUS) {
                instructionEntry = new InstructionEntry("addi");
            } else {
                instructionEntry = new InstructionEntry("subi");
            }
            instructionEntries.add(instructionEntry);
            funcSymbol.setInstructions(instructionEntries);
        }
        return type;
    }

     TokenType analyseT(String funcName){
        TokenType type = analyseF(funcName);
        while (true) {
            // 预读可能是运算符的 token
            Token op = peek();
            if (op.getTokenType() != TokenType.MUL &&
                    op.getTokenType() != TokenType.DIV) {
                break;
            }
            // 运算符
            next();
            analyseF(funcName);
            SymbolEntry funcSymbol = symbolTable[funcName];
            List<InstructionEntry> instructionEntries =[];
            instructionEntries = funcSymbol.getInstructions();
            // 生成代码
            if (op.getTokenType() == TokenType.MUL) {
                InstructionEntry instructionEntry1 = new InstructionEntry("multi");
                instructionEntries.add(instructionEntry1);
            } else if (op.getTokenType() == TokenType.DIV)
            {
                InstructionEntry instructionEntry1 = new InstructionEntry("divi");
                instructionEntries.add(instructionEntry1);
            }
            funcSymbol.setInstructions(instructionEntries);
        }
        return type;
    }

    //   F -> A ( as int_ty | double_ty )
     TokenType analyseF(String funcName){
        TokenType type = analyseA(funcName);

        if (check(TokenType.AS_KW)) {
            expect(TokenType.AS_KW);
            SymbolEntry funcSymbol = symbolTable[funcName];
            List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
            InstructionEntry instructionEntry;
            if (check(TokenType.INT)) {
                expect(TokenType.INT);
                instructionEntry = new InstructionEntry("ftoi");
                instructionEntries.add(instructionEntry);
                funcSymbol.setInstructions(instructionEntries);
                return TokenType.INT;
            } else if (check(TokenType.DOUBLE)) {
                expect(TokenType.DOUBLE);
                instructionEntry = new InstructionEntry("itof");
                instructionEntries.add(instructionEntry);
                funcSymbol.setInstructions(instructionEntries);
                return TokenType.DOUBLE;
            } else {
                throw new AnalyzeError(ErrorCode.NotDeclared, peekedToken.getStartPos());
            }
        }
        return type;
    }

     TokenType analyseA(String funcName)  {
        TokenType type;
        int minusCount = 0;
        while (check(TokenType.MINUS)) {
            minusCount++;
            expect(TokenType.MINUS);
        }
        type = analyseI(funcName);
        for (int i = 0; i < minusCount; i++) {
            SymbolEntry funcSymbol = symbolTable[funcName];
            List<InstructionEntry> instructionEntries =[];
            instructionEntries = funcSymbol.getInstructions();
            // 生成代码
            InstructionEntry instructionEntry1 = new InstructionEntry("negi");
            instructionEntries.add(instructionEntry1);
            funcSymbol.setInstructions(instructionEntries);
        }
        return type;
    }

    //    I -> IDENT | UNIT | DOUBLE | func_call | '(' E ')' | IDENT = E
     TokenType analyseI(String funcName){
        SymbolEntry funcSymbol = symbolTable[funcName];
        List<InstructionEntry> instructionEntries = funcSymbol.getInstructions();
        if (check(TokenType.IDENT)) {
            Token nameToken = expect(TokenType.IDENT);
            String name = nameToken.getValueString();
            SymbolEntry entry = this.symbolTable[name];
            if (entry == null) {
                throw new AnalyzeError(ErrorCode.NotDeclared, nameToken.getStartPos());
            }
            //调用函数（解决一下标准库的问题）
            if (check(TokenType.L_PAREN)) {
                if (!(entry.getKind()=="func")) {
                    throw new AnalyzeError(ErrorCode.NotDeclared, nameToken.getStartPos());
                }
                String callOrcallname = "call";
                bool isLib = false;
                if (name=="getint" || name==("getdouble") || name==("getchar") || name==("putint") || name==("putchar") || name==("putdouble") || name==("putstr") || name==("putln")) {
                    callOrcallname = "callname";
                    isLib = true;
                }
                expect(TokenType.L_PAREN);
                bool hasParam = false;
                //有参数
                if (!check(TokenType.R_PAREN)) {
                    hasParam = true;
                    InstructionEntry instructionEntry1;
                    if (entry.getType() == TokenType.VOID) {
                        instructionEntry1 = new InstructionEntry("stackalloc",op: 0);
                    } else {
                        instructionEntry1 = new InstructionEntry("stackalloc", op:1);
                    }
                    instructionEntries.add(instructionEntry1);
                    funcSymbol.setInstructions(instructionEntries);
                    analyseCallParamList(funcName);
                }
                expect(TokenType.R_PAREN);
                TokenType returnType = entry.getType();
                if (returnType == TokenType.INT && !hasParam) {
                    // 生成代码
                    InstructionEntry instructionEntry1 = new InstructionEntry("stackalloc", op:1);
                    instructionEntries.add(instructionEntry1);
                    InstructionEntry instructionEntry2;
                    if (isLib) {
                        instructionEntry2 = new InstructionEntry(callOrcallname,op: getFuncIndex(name));
                    } else {
                        instructionEntry2 = new InstructionEntry(callOrcallname, op:getFuncIndex(name) - 8);
                    }
                    instructionEntries.add(instructionEntry2);
                    funcSymbol.setInstructions(instructionEntries);
                } else if (returnType == TokenType.VOID && !hasParam) {
                    // 生成代码
                    InstructionEntry instructionEntry1 = new InstructionEntry("stackalloc", op:0);
                    instructionEntries.add(instructionEntry1);
                    InstructionEntry instructionEntry2;
                    if (isLib) {
                        instructionEntry2 = new InstructionEntry(callOrcallname, op:getFuncIndex(name));
                    } else {
                        instructionEntry2 = new InstructionEntry(callOrcallname, op:getFuncIndex(name) - 8);
                    }
                    instructionEntries.add(instructionEntry2);
                    funcSymbol.setInstructions(instructionEntries);
                } else {
                    // 生成代码
                    InstructionEntry instructionEntry2;
                    if (isLib) {
                        instructionEntry2 = new InstructionEntry(callOrcallname,op: getFuncIndex(name));
                    } else {
                        instructionEntry2 = new InstructionEntry(callOrcallname, op:getFuncIndex(name) - 8);
                    }
                    instructionEntries.add(instructionEntry2);
                    funcSymbol.setInstructions(instructionEntries);
                }
                return returnType;
            }
            //赋值
            else if (check(TokenType.ASSIGN)) {
                if (entry.getKind()==("func")) {
                    throw new AnalyzeError(ErrorCode.NotDeclared, nameToken.getStartPos());
                }
                if (entry.getIsConstant()) {
                    throw new AnalyzeError(ErrorCode.AssignToConstant, nameToken.getStartPos());
                }
                expect(TokenType.ASSIGN);
                // 生成代码
                List<String> localVars = funcSymbol.getLocVars();
                List<String> paramVars = funcSymbol.getParamVars();
                if (entry.getKind()==("param")) {
                    int index = -1;
                    for (int i = 0; i < paramVars.length; i++) {
                        if (paramVars[i]==(name)) {
                            index = i;
                        }
                    }
                    if (index == -1) {
                        throw new AnalyzeError(ErrorCode.NotDeclared, peek().getStartPos());
                    }
                    if (funcSymbol.getType()== TokenType.VOID) {
                        InstructionEntry instructionEntry1 = new InstructionEntry("arga", op:index);
                        instructionEntries.add(instructionEntry1);
                    } else {
                        InstructionEntry instructionEntry1 = new InstructionEntry("arga", op:index+1);
                        instructionEntries.add(instructionEntry1);
                    }
                } else {
                    int index = -1;
                    for (int i = 0; i < localVars.length; i++) {
                        if (localVars[i]==(name)) {
                            index = i;
                        }
                    }
                    InstructionEntry instructionEntry1;
                    if (index == -1) {
                        index = getGlobalIndex(name);
                        instructionEntry1 = new InstructionEntry("globa", op:index);
                    } else {
                        instructionEntry1 = new InstructionEntry("loca", op:index);
                    }
                    instructionEntries.add(instructionEntry1);
                }
                funcSymbol.setInstructions(instructionEntries);
                TokenType type = analyseExpr(funcName);
                if (type== TokenType.VOID) {
                    throw new AnalyzeError(ErrorCode.InvalidAssignment, nameToken.getStartPos());
                }
                // 生成代码
                InstructionEntry instructionEntry2 = new InstructionEntry("store64");
                instructionEntries.add(instructionEntry2);
                funcSymbol.setInstructions(instructionEntries);
                return TokenType.VOID;
            }
            //变量名
            else {
                // 生成代码
                List<String> localVars = funcSymbol.getLocVars();
                List<String> paramVars = funcSymbol.getParamVars();
                if (entry.getKind()==("param")) {
                    int index = -1;
                    for (int i = 0; i < paramVars.length; i++) {
                        if (paramVars[i]==(name)) {
                            index = i;
                        }
                    }
                    if (index == -1) {
                        throw new AnalyzeError(ErrorCode.NotDeclared, peek().getStartPos());
                    }
                    if (funcSymbol.getType()== TokenType.VOID) {
                        InstructionEntry instructionEntry1 = new InstructionEntry("arga", op:index);
                        instructionEntries.add(instructionEntry1);
                    } else {
                        InstructionEntry instructionEntry1 = new InstructionEntry("arga", op:index+1);
                        instructionEntries.add(instructionEntry1);
                    }
                } else {
                    int index = -1;
                    for (int i = 0; i < localVars.length; i++) {
                        if (localVars[i]==(name)) {
                            index = i;
                        }
                    }
                    InstructionEntry instructionEntry1;
                    if (index == -1) {
                        index = getGlobalIndex(name);
                        instructionEntry1 = new InstructionEntry("globa", op:index);
                    } else {
                        instructionEntry1 = new InstructionEntry("loca",op: index);
                    }
                    instructionEntries.add(instructionEntry1);
                }
                InstructionEntry instructionEntry2 = new InstructionEntry("load64");
                instructionEntries.add(instructionEntry2);
                funcSymbol.setInstructions(instructionEntries);
                return entry.getType();
            }
        } else if (check(TokenType.UINT_LITERAL)) {
            Token token = expect(TokenType.UINT_LITERAL);
            // 生成代码
            int longValue = token.getValue() as int;
            int value = longValue;
            InstructionEntry instructionEntry1 = new InstructionEntry("push", op:value);
            instructionEntries.add(instructionEntry1);
            funcSymbol.setInstructions(instructionEntries);
            return TokenType.INT;
        } else if (check(TokenType.STRING_LITERAL)) {
            Token token = expect(TokenType.STRING_LITERAL);
            String value = token.getValueString();
            //计算全局变量数
            int globalVarsNum = calcGlobalVars();
            // 生成代码
            InstructionEntry instructionEntry1 = new InstructionEntry("push", op:globalVarsNum);
            instructionEntries.add(instructionEntry1);
            funcSymbol.setInstructions(instructionEntries);
            //加入符号表
            addSymbol(value, "string", TokenType.UINT_LITERAL, 0, true, true, token.getStartPos());
            return TokenType.INT;
        } else if (check(TokenType.CHAR_LITERAL)) {
            Token token = expect(TokenType.CHAR_LITERAL);
            // 生成代码
            String charStr = token.getValue() as String;
            Char charCh = Char(0);
            for (int i = 0; i < charStr.length; i++) {
                charCh = Char(charStr.codeUnitAt(i));
            }
            InstructionEntry instructionEntry1 = new InstructionEntry("push", op:charCh.value);
            instructionEntries.add(instructionEntry1);
            funcSymbol.setInstructions(instructionEntries);
            return TokenType.INT;
        } else if (check(TokenType.DOUBLE_LITERAL)) {
            expect(TokenType.DOUBLE_LITERAL);
            return TokenType.DOUBLE;
        } else if (check(TokenType.L_PAREN)) {
            expect(TokenType.L_PAREN);
            TokenType type = analyseExpr(funcName);
            expect(TokenType.R_PAREN);
            return type;
        }
        return null;
    }

     int calcGlobalVars() {
        int globalVars = 0;
        symbolTable.forEach((key, symbolEntry) {
          if (!(symbolEntry.getKind()==("func")) && symbolEntry.getLevel() == 0) {
                globalVars++;
            }
        });
        return globalVars;
    }

     void analyseCallParamList(String funcName) {
        analyseExpr(funcName);
        while (check(TokenType.COMMA)) {
            expect(TokenType.COMMA);
            analyseExpr(funcName);
        }
    }

     Map<String, SymbolEntry> getSymbolTable() {
        return this.symbolTable;
    }
}
