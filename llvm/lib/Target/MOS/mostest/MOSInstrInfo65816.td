//===-- MOSInstrInfo65816.td - MOS 65816 Instructions --------*- tablegen -*-===//
//
// Part of LLVM-MOS, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file describes the instructions and addressing modes specific to the
// WDC 65816.
//
//===----------------------------------------------------------------------===//

let Predicates = [HasW65816] in {

  //===--------------------------------------------------------------------===//
  // 16-bit Accumulator/Memory Operations
  //===--------------------------------------------------------------------===//

  // Use a separate DecoderNamespace to avoid conflicts with 8-bit instructions
  // in the main Disassembler table. These instructions are identical in encoding
  // to the 8-bit ones, so the 8-bit definitions suffice for disassembly.
  let DecoderNamespace = "MOS65816Alt" in {
    // ADC
    def ADC16_Immediate : Inst24<"adc", Opcode<0x69>, Immediate16> {
        let Uses = [A16, C];
        let Defs = [A16, N, Z, C, V];
    }
    def ADC16_ZeroPage : Inst16<"adc", Opcode<0x65>, ZeroPage> {
        let Uses = [A16, C];
        let Defs = [A16, N, Z, C, V];
    }
    def ADC16_Absolute : Inst24<"adc", Opcode<0x6D>, Absolute> {
        let Uses = [A16, C];
        let Defs = [A16, N, Z, C, V];
    }

    // AND
    def AND16_Immediate : Inst24<"and", Opcode<0x29>, Immediate16> {
        let Uses = [A16];
        let Defs = [A16, N, Z];
    }
    def AND16_ZeroPage : Inst16<"and", Opcode<0x25>, ZeroPage> {
        let Uses = [A16];
        let Defs = [A16, N, Z];
    }
    def AND16_Absolute : Inst24<"and", Opcode<0x2D>, Absolute> {
        let Uses = [A16];
        let Defs = [A16, N, Z];
    }

    // EOR
    def EOR16_Immediate : Inst24<"eor", Opcode<0x49>, Immediate16> {
        let Uses = [A16];
        let Defs = [A16, N, Z];
    }
    def EOR16_ZeroPage : Inst16<"eor", Opcode<0x45>, ZeroPage> {
        let Uses = [A16];
        let Defs = [A16, N, Z];
    }
    def EOR16_Absolute : Inst24<"eor", Opcode<0x4D>, Absolute> {
        let Uses = [A16];
        let Defs = [A16, N, Z];
    }

    // ORA
    def ORA16_Immediate : Inst24<"ora", Opcode<0x09>, Immediate16> {
        let Uses = [A16];
        let Defs = [A16, N, Z];
    }
    def ORA16_ZeroPage : Inst16<"ora", Opcode<0x05>, ZeroPage> {
        let Uses = [A16];
        let Defs = [A16, N, Z];
    }
    def ORA16_Absolute : Inst24<"ora", Opcode<0x0D>, Absolute> {
        let Uses = [A16];
        let Defs = [A16, N, Z];
    }

    // SBC
    def SBC16_Immediate : Inst24<"sbc", Opcode<0xE9>, Immediate16> {
        let Uses = [A16, C];
        let Defs = [A16, N, Z, C, V];
    }
    def SBC16_ZeroPage : Inst16<"sbc", Opcode<0xE5>, ZeroPage> {
        let Uses = [A16, C];
        let Defs = [A16, N, Z, C, V];
    }
    def SBC16_Absolute : Inst24<"sbc", Opcode<0xED>, Absolute> {
        let Uses = [A16, C];
        let Defs = [A16, N, Z, C, V];
    }

    // LDA
    def LDA16_Immediate : Inst24<"lda", Opcode<0xA9>, Immediate16> {
        let Defs = [A16, N, Z];
    }
    def LDA16_ZeroPage : Inst16<"lda", Opcode<0xA5>, ZeroPage> {
        let Defs = [A16, N, Z];
    }
    def LDA16_Absolute : Inst24<"lda", Opcode<0xAD>, Absolute> {
        let Defs = [A16, N, Z];
    }

    // STA
    def STA16_ZeroPage : Inst16<"sta", Opcode<0x85>, ZeroPage> {
        let Uses = [A16];
    }
    def STA16_Absolute : Inst24<"sta", Opcode<0x8D>, Absolute> {
        let Uses = [A16];
    }

    // CMP
    def CMP16_Immediate : Inst24<"cmp", Opcode<0xC9>, Immediate16> {
        let Uses = [A16];
        let Defs = [N, Z, C];
    }
    def CMP16_ZeroPage : Inst16<"cmp", Opcode<0xC5>, ZeroPage> {
        let Uses = [A16];
        let Defs = [N, Z, C];
    }
    def CMP16_Absolute : Inst24<"cmp", Opcode<0xCD>, Absolute> {
        let Uses = [A16];
        let Defs = [N, Z, C];
    }

    // LDX
    def LDX16_Immediate : Inst24<"ldx", Opcode<0xA2>, Immediate16> {
        let Defs = [X16, N, Z];
    }
    def LDX16_ZeroPage : Inst16<"ldx", Opcode<0xA6>, ZeroPage> {
        let Defs = [X16, N, Z];
    }
    def LDX16_Absolute : Inst24<"ldx", Opcode<0xAE>, Absolute> {
        let Defs = [X16, N, Z];
    }

    // LDY
    def LDY16_Immediate : Inst24<"ldy", Opcode<0xA0>, Immediate16> {
        let Defs = [Y16, N, Z];
    }
    def LDY16_ZeroPage : Inst16<"ldy", Opcode<0xA4>, ZeroPage> {
        let Defs = [Y16, N, Z];
    }
    def LDY16_Absolute : Inst24<"ldy", Opcode<0xAC>, Absolute> {
        let Defs = [Y16, N, Z];
    }

    // STX
    def STX16_ZeroPage : Inst16<"stx", Opcode<0x86>, ZeroPage> {
        let Uses = [X16];
    }
    def STX16_Absolute : Inst24<"stx", Opcode<0x8E>, Absolute> {
        let Uses = [X16];
    }

    // STY
    def STY16_ZeroPage : Inst16<"sty", Opcode<0x84>, ZeroPage> {
        let Uses = [Y16];
    }
    def STY16_Absolute : Inst24<"sty", Opcode<0x8C>, Absolute> {
        let Uses = [Y16];
    }

    // CPX
    def CPX16_Immediate : Inst24<"cpx", Opcode<0xE0>, Immediate16> {
        let Uses = [X16];
        let Defs = [N, Z, C];
    }
    def CPX16_ZeroPage : Inst16<"cpx", Opcode<0xE4>, ZeroPage> {
        let Uses = [X16];
        let Defs = [N, Z, C];
    }

    // CPY
    def CPY16_Immediate : Inst24<"cpy", Opcode<0xC0>, Immediate16> {
        let Uses = [Y16];
        let Defs = [N, Z, C];
    }
    def CPY16_ZeroPage : Inst16<"cpy", Opcode<0xC4>, ZeroPage> {
        let Uses = [Y16];
        let Defs = [N, Z, C];
    }
  }

  // Non-conflicting (Long addressing or new opcodes)
  def ADC16_AbsoluteLong : Inst32<"adc", Opcode<0x6F>, AbsoluteLong> {
    let Uses = [A16, C];
    let Defs = [A16, N, Z, C, V];
  }
  def AND16_AbsoluteLong : Inst32<"and", Opcode<0x2F>, AbsoluteLong> {
    let Uses = [A16];
    let Defs = [A16, N, Z];
  }
  def EOR16_AbsoluteLong : Inst32<"eor", Opcode<0x4F>, AbsoluteLong> {
    let Uses = [A16];
    let Defs = [A16, N, Z];
  }
  def ORA16_AbsoluteLong : Inst32<"ora", Opcode<0x0F>, AbsoluteLong> {
    let Uses = [A16];
    let Defs = [A16, N, Z];
  }
  def SBC16_AbsoluteLong : Inst32<"sbc", Opcode<0xEF>, AbsoluteLong> {
    let Uses = [A16, C];
    let Defs = [A16, N, Z, C, V];
  }
  def LDA16_AbsoluteLong : Inst32<"lda", Opcode<0xAF>, AbsoluteLong> {
    let Defs = [A16, N, Z];
  }
  def STA16_AbsoluteLong : Inst32<"sta", Opcode<0x8F>, AbsoluteLong> {
    let Uses = [A16];
  }
  def CMP16_AbsoluteLong : Inst32<"cmp", Opcode<0xCF>, AbsoluteLong> {
    let Uses = [A16];
    let Defs = [N, Z, C];
  }

  //===----------------------------------------------------------------------===//
  // Logical Instructions
  //===----------------------------------------------------------------------===//

  class MOSAddSub16 : MOSLogicalInstr {
    dag OutOperandList = (outs Ac16:$dst, Cc:$carryout, Vc:$vout);
    let Constraints = "$dst = $l, $carryout = $carryin";
  }
  class MOSAddSubOp16<Operand op> : MOSAddSub16 {
    dag InOperandList = (ins Ac16:$l, op:$r, Cc:$carryin);
  }
  class MOSAddSubRC16<RegisterClass rc> : MOSAddSub16 {
    dag InOperandList = (ins Ac16:$l, rc:$r, Cc:$carryin);
  }

  def ADC16Imm : MOSAddSubOp16<imm16>, PseudoInstExpansion<(ADC16_Immediate imm16:$r)>;
  def ADC16Zp : MOSAddSubOp16<addr8>, PseudoInstExpansion<(ADC16_ZeroPage addr8:$r)>;
  def ADC16Abs : MOSAddSubOp16<addr16>, PseudoInstExpansion<(ADC16_Absolute addr16:$r)>;
  def ADC16AbsLong : MOSAddSubOp16<addr24>, PseudoInstExpansion<(ADC16_AbsoluteLong addr24:$r)>;
  
  def ADC16Imag8 : MOSAddSubRC16<Imag8>, PseudoInstExpansion<(ADC16_ZeroPage addr8:$r)> {
    let Constraints = "$dst = $l";
    let isCommutable = true;
  }

  def SBC16Imm : MOSAddSubOp16<imm16>, PseudoInstExpansion<(SBC16_Immediate imm16:$r)>;
  def SBC16Zp : MOSAddSubOp16<addr8>, PseudoInstExpansion<(SBC16_ZeroPage addr8:$r)>;
  def SBC16Abs : MOSAddSubOp16<addr16>, PseudoInstExpansion<(SBC16_Absolute addr16:$r)>;
  def SBC16AbsLong : MOSAddSubOp16<addr24>, PseudoInstExpansion<(SBC16_AbsoluteLong addr24:$r)>;
  
  def SBC16Imag8 : MOSAddSubRC16<Imag8>, PseudoInstExpansion<(SBC16_ZeroPage addr8:$r)> {
    let Constraints = "$dst = $l";
  }

  class MOSLogical16 : MOSLogicalInstr {
    dag OutOperandList = (outs Ac16:$dst);
    let Constraints = "$dst = $l";
  }
  class MOSLogicalOp16<Operand op> : MOSLogical16 {
    dag InOperandList = (ins Ac16:$l, op:$r);
  }
  class MOSLogicalRC16<RegisterClass rc> : MOSLogical16 {
    dag InOperandList = (ins Ac16:$l, rc:$r);
  }

  def AND16Imm : MOSLogicalOp16<imm16>, PseudoInstExpansion<(AND16_Immediate imm16:$r)>;
  def AND16Zp : MOSLogicalOp16<addr8>, PseudoInstExpansion<(AND16_ZeroPage addr8:$r)>;
  def AND16Abs : MOSLogicalOp16<addr16>, PseudoInstExpansion<(AND16_Absolute addr16:$r)>;
  def AND16AbsLong : MOSLogicalOp16<addr24>, PseudoInstExpansion<(AND16_AbsoluteLong addr24:$r)>;
  def AND16Imag8 : MOSLogicalRC16<Imag8>, PseudoInstExpansion<(AND16_ZeroPage addr8:$r)>;

  def ORA16Imm : MOSLogicalOp16<imm16>, PseudoInstExpansion<(ORA16_Immediate imm16:$r)>;
  def ORA16Zp : MOSLogicalOp16<addr8>, PseudoInstExpansion<(ORA16_ZeroPage addr8:$r)>;
  def ORA16Abs : MOSLogicalOp16<addr16>, PseudoInstExpansion<(ORA16_Absolute addr16:$r)>;
  def ORA16AbsLong : MOSLogicalOp16<addr24>, PseudoInstExpansion<(ORA16_AbsoluteLong addr24:$r)>;
  def ORA16Imag8 : MOSLogicalRC16<Imag8>, PseudoInstExpansion<(ORA16_ZeroPage addr8:$r)>;

  def EOR16Imm : MOSLogicalOp16<imm16>, PseudoInstExpansion<(EOR16_Immediate imm16:$r)>;
  def EOR16Zp : MOSLogicalOp16<addr8>, PseudoInstExpansion<(EOR16_ZeroPage addr8:$r)>;
  def EOR16Abs : MOSLogicalOp16<addr16>, PseudoInstExpansion<(EOR16_Absolute addr16:$r)>;
  def EOR16AbsLong : MOSLogicalOp16<addr24>, PseudoInstExpansion<(EOR16_AbsoluteLong addr24:$r)>;
  def EOR16Imag8 : MOSLogicalRC16<Imag8>, PseudoInstExpansion<(EOR16_ZeroPage addr8:$r)>;

  // Logical Stores
  class MOSStore16 : MOSLogicalInstr {
     dag OutOperandList = (outs);
     let mayStore = true;
  }
  class MOSStoreOp16<Operand op> : MOSStore16 {
     dag InOperandList = (ins Ac16:$val, op:$addr);
  }
  def STA16Abs : MOSStoreOp16<addr16>, PseudoInstExpansion<(STA16_Absolute addr16:$addr)>;
  def STA16AbsLong : MOSStoreOp16<addr24>, PseudoInstExpansion<(STA16_AbsoluteLong addr24:$addr)>;
  def STA16Zp : MOSStoreOp16<addr8>, PseudoInstExpansion<(STA16_ZeroPage addr8:$addr)>;

  // Logical Loads
  class MOSLoad16 : MOSLogicalInstr {
     dag OutOperandList = (outs Ac16:$dst);
     let mayLoad = true;
  }
  class MOSLoadOp16<Operand op> : MOSLoad16 {
     dag InOperandList = (ins op:$addr);
  }
  def LD16Imm : MOSLoadOp16<imm16>, PseudoInstExpansion<(LDA16_Immediate imm16:$addr)>;
  def LD16Abs : MOSLoadOp16<addr16>, PseudoInstExpansion<(LDA16_Absolute addr16:$addr)>;
  def LD16AbsLong : MOSLoadOp16<addr24>, PseudoInstExpansion<(LDA16_AbsoluteLong addr24:$addr)>;
  def LD16Zp : MOSLoadOp16<addr8>, PseudoInstExpansion<(LDA16_ZeroPage addr8:$addr)>;
}
