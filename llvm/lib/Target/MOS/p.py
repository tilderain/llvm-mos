import os
import re

def apply_patch(filepath, search_pattern, replace_pattern, flags=0):
    if not os.path.exists(filepath):
        print(f"Skipping {filepath}: File not found")
        return False
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    new_content = re.sub(search_pattern, replace_pattern, content, flags=flags)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Patched {filepath}")
        return True
    else:
        print(f"No changes needed for {filepath} (pattern not found or already applied)")
        return False

def append_to_file(filepath, content):
    if not os.path.exists(filepath):
        print(f"Skipping {filepath}: File not found")
        return False
    
    with open(filepath, 'r') as f:
        current_content = f.read()
        
    if content.strip() in current_content:
        print(f"Content already present in {filepath}")
        return False
        
    with open(filepath, 'a') as f:
        f.write("\n" + content + "\n")
    print(f"Appended to {filepath}")
    return True

# 1. MOSInstrGISel.td: Add generic instructions for Long addressing
instr_gisel_content = """
// Generalized 8-bit load using the absolute long addressing mode (24-bit address).
def G_LOAD_ABS_LONG : MOSGenericInstruction {
  let OutOperandList = (outs type0:$dst);
  let InOperandList = (ins unknown:$addr);
  let mayLoad = true;
}

// Generalized 8-bit store using the absolute long addressing mode (24-bit address).
def G_STORE_ABS_LONG : MOSGenericInstruction {
  let OutOperandList = (outs);
  let InOperandList = (ins type0:$src, unknown:$addr);
  let mayStore = true;
}

// Generalized 8-bit load using the absolute long indexed addressing mode.
def G_LOAD_ABS_X_LONG : MOSGenericInstruction {
  let OutOperandList = (outs type0:$dst);
  let InOperandList = (ins unknown:$base, type1:$index);
  let mayLoad = true;
}

// Generalized 8-bit store using the absolute long indexed addressing mode.
def G_STORE_ABS_X_LONG : MOSGenericInstruction {
  let OutOperandList = (outs);
  let InOperandList = (ins type0:$src, unknown:$base, type1:$index);
  let mayStore = true;
}
"""
append_to_file("MOSInstrGISel.td", instr_gisel_content)

# 2. MOSCallingConv.td: Add support for 32-bit pointers (i32) in registers
cc_pattern = r"(CCIfPtr<CCAssignToReg<\[RS1, RS2, RS3, RS4, RS5, RS6, RS7\]>>,\s*)"
cc_replace = r"""\1
  // 32-bit pointers (65816 far pointers) are assigned to RL registers.
  CCIf<"State.getMachineFunction().getSubtarget<MOSSubtarget>().hasW65816()",
       CCIfType<[i32], CCAssignToReg<[
    RL0, RL1, RL2, RL3, RL4, RL5, RL6, RL7
  ]>>>,
"""
apply_patch("MOSCallingConv.td", cc_pattern, cc_replace)

# 3. MOSLegalizerInfo.cpp: Set pointer size to 32 for W65816 and update legalization rules
legalizer_ctor_pattern = r"(LLT P = LLT::pointer\(0, 16\);)"
legalizer_ctor_replace = r"LLT P = STI.hasW65816() ? LLT::pointer(0, 32) : LLT::pointer(0, 16);"
apply_patch("MOSLegalizerInfo.cpp", legalizer_ctor_pattern, legalizer_ctor_replace)

# Add static helper functions for Long addressing
legalizer_helpers = """
static std::optional<MachineOperand>
matchAbsoluteLongAddressing(MachineRegisterInfo &MRI, Register Addr) {
  int64_t Offset = 0;
  while (true) {
    if (auto ConstAddr = getIConstantVRegValWithLookThrough(Addr, MRI)) {
      return MachineOperand::CreateImm(Offset + ConstAddr->Value.getSExtValue());
    }
    if (const MachineInstr *GVAddr = getOpcodeDef(G_GLOBAL_VALUE, Addr, MRI)) {
      const MachineOperand &GV = GVAddr->getOperand(1);
      return MachineOperand::CreateGA(GV.getGlobal(), GV.getOffset() + Offset);
    }
    if (const auto *PtrAddAddr =
            cast_if_present<GPtrAdd>(getOpcodeDef(G_PTR_ADD, Addr, MRI))) {
      auto ConstOffset =
          getIConstantVRegValWithLookThrough(PtrAddAddr->getOffsetReg(), MRI);
      if (!ConstOffset)
        return std::nullopt;
      Offset += ConstOffset->Value.getSExtValue();
      Addr = PtrAddAddr->getBaseReg();
      continue;
    }
    return std::nullopt;
  }
}

static bool tryAbsoluteLongAddressing(LegalizerHelper &Helper,
                                      MachineRegisterInfo &MRI,
                                      GLoadStore &MI) {
  MachineIRBuilder &Builder = Helper.MIRBuilder;
  unsigned Opcode = isa<GLoad>(MI) ? MOS::G_LOAD_ABS_LONG : MOS::G_STORE_ABS_LONG;
  auto Operand = matchAbsoluteLongAddressing(MRI, MI.getPointerReg());

  if (Operand.has_value()) {
    Helper.Observer.changingInstr(MI);
    MI.setDesc(Builder.getTII().get(Opcode));
    MI.removeOperand(1);
    MI.addOperand(*Operand);
    Helper.Observer.changedInstr(MI);
    return true;
  }
  return false;
}

static bool tryAbsoluteLongIndexedAddressing(LegalizerHelper &Helper,
                                             MachineRegisterInfo &MRI,
                                             GLoadStore &MI) {
  LLT S8 = LLT::scalar(8);
  MachineIRBuilder &Builder = Helper.MIRBuilder;
  
  Register Addr = MI.getPointerReg();
  int64_t Offset = 0;
  Register Index = 0;

  unsigned Opcode = isa<GLoad>(MI) ? MOS::G_LOAD_ABS_X_LONG : MOS::G_STORE_ABS_X_LONG;

  while (true) {
    if (auto ConstAddr = getIConstantVRegValWithLookThrough(Addr, MRI)) {
      assert(Index);
      Offset = ConstAddr->Value.getSExtValue() + Offset;
      auto Inst = Builder.buildInstr(Opcode)
                      .add(MI.getOperand(0))
                      .addImm(Offset)
                      .addUse(Index)
                      .addMemOperand(*MI.memoperands_begin());
      MI.eraseFromParent();
      return true;
    }
    if (const MachineInstr *GVAddr = getOpcodeDef(G_GLOBAL_VALUE, Addr, MRI)) {
      assert(Index);
      const MachineOperand &GV = GVAddr->getOperand(1);
      auto Inst = Builder.buildInstr(Opcode)
                      .add(MI.getOperand(0))
                      .addGlobalAddress(GV.getGlobal(), GV.getOffset() + Offset)
                      .addUse(Index)
                      .addMemOperand(*MI.memoperands_begin());
      MI.eraseFromParent();
      return true;
    }
    if (const auto *PtrAddAddr =
            cast_if_present<GPtrAdd>(getOpcodeDef(G_PTR_ADD, Addr, MRI))) {
      Addr = PtrAddAddr->getBaseReg();
      Register NewOffset = PtrAddAddr->getOffsetReg();
      if (auto ConstOffset = getIConstantVRegValWithLookThrough(NewOffset, MRI)) {
        Offset += ConstOffset->Value.getSExtValue();
        continue;
      }
      if (MachineInstr *ZExtOffset = getOpcodeDef(G_ZEXT, NewOffset, MRI)) {
        if (Index) return false;
        Register Src = ZExtOffset->getOperand(1).getReg();
        if (MRI.getType(Src).getSizeInBits() > 8) return false;
        if (MRI.getType(Src).getSizeInBits() < 8)
          Src = Builder.buildZExt(S8, Src).getReg(0);
        Index = Src;
        continue;
      }
    }
    return false;
  }
}
"""

# Insert helpers before selectAddressingMode
apply_patch("MOSLegalizerInfo.cpp", 
            r"(bool MOSLegalizerInfo::selectAddressingMode)", 
            legalizer_helpers + "\n" + r"\1")

# Update selectAddressingMode to handle 32-bit pointers
select_addr_pattern = r"(case 16: \{\n\s+if \(tryAbsoluteAddressing\(Helper, MRI, MI, false\)\)\n\s+return true;\n\s+if \(tryAbsoluteIndexedAddressing\(Helper, MRI, MI, false\)\)\n\s+return true;\n\s+return selectIndirectAddressing\(Helper, MRI, MI\);\n\s+\})"
select_addr_replace = r"""\1
  case 32: {
    if (tryAbsoluteLongAddressing(Helper, MRI, MI))
      return true;
    if (tryAbsoluteLongIndexedAddressing(Helper, MRI, MI))
      return true;
    // Fallback to Indirect Long if implemented, or fail
    return false;
  }"""
apply_patch("MOSLegalizerInfo.cpp", select_addr_pattern, select_addr_replace)


# 4. MOSInstructionSelector.cpp: Map generic long instructions to real MOS instructions
selector_pattern = r"(case MOS::G_STORE_INDIR_IDX:\n\s+Opcode = MOS::STIndirIdx;\n\s+break;)"
selector_replace = r"""\1
  case MOS::G_LOAD_ABS_LONG:
    Opcode = MOS::LDA_AbsoluteLong;
    break;
  case MOS::G_STORE_ABS_LONG:
    Opcode = MOS::STA_AbsoluteLong;
    break;
  case MOS::G_LOAD_ABS_X_LONG:
    Opcode = MOS::LDA_AbsoluteXLong;
    break;
  case MOS::G_STORE_ABS_X_LONG:
    Opcode = MOS::STA_AbsoluteXLong;
    break;"""
apply_patch("MOSInstructionSelector.cpp", selector_pattern, selector_replace)


# 5. MOSMCInstLower.cpp: Handle 32-bit imaginary registers (Imag32RegClass)
mc_lower_pattern = r"(if \(MOS::Imag16RegClass.contains\(Reg\) \|\| MOS::Imag8RegClass.contains\(Reg\)\))"
mc_lower_replace = r"if (MOS::Imag32RegClass.contains(Reg) || MOS::Imag16RegClass.contains(Reg) || MOS::Imag8RegClass.contains(Reg))"
apply_patch("MOSMCInstLower.cpp", mc_lower_pattern, mc_lower_replace)

print("Patching complete.")
