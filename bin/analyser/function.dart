
  import '../instruction/instruction_entry.dart';

class Func {
       int nameLoc;
       int ret_slots;
       int param_slots;
       int loc_slots;
       int body_count;
      List<InstructionEntry> instructions;
      Func(this.nameLoc, this.ret_slots, this.param_slots, this.loc_slots, this.body_count, this.instructions){
        this.nameLoc = nameLoc;
        this.ret_slots = ret_slots;
        this.param_slots = param_slots;
        this.loc_slots = loc_slots;
        this.body_count = body_count;
        this.instructions = instructions;
    }

      int getNameLoc() {
        return nameLoc;
    }

      void setNameLoc(int nameLoc) {
        this.nameLoc = nameLoc;
    }

      int getRet_slots() {
        return ret_slots;
    }

      void setRet_slots(int ret_slots) {
        this.ret_slots = ret_slots;
    }

      int getParam_slots() {
        return param_slots;
    }

      void setParam_slots(int param_slots) {
        this.param_slots = param_slots;
    }

      int getLoc_slots() {
        return loc_slots;
    }

      void setLoc_slots(int loc_slots) {
        this.loc_slots = loc_slots;
    }

      int getBody_count() {
        return body_count;
    }

      void setBody_count(int body_count) {
        this.body_count = body_count;
    }

      List<InstructionEntry> getInstructions() {
        return instructions;
    }

      void setInstructions(List<InstructionEntry> instructions) {
        this.instructions = instructions;
    }
}