#!/usr/bin/env python3
"""Tiny RV32I assembler -> program.hex  (usage: python3 asm.py prog.s program.hex)"""
import sys, re

R = {f"x{i}": i for i in range(32)}
RTYPE = {"add":(0,0),"sub":(0,0x20),"sll":(1,0),"slt":(2,0),"sltu":(3,0),
         "xor":(4,0),"srl":(5,0),"sra":(5,0x20),"or":(6,0),"and":(7,0)}
ITYPE = {"addi":0,"slti":2,"sltiu":3,"xori":4,"ori":6,"andi":7}
SHIFTI = {"slli":(1,0),"srli":(5,0),"srai":(5,0x20)}
LOAD = {"lb":0,"lh":1,"lw":2,"lbu":4,"lhu":5}
STORE = {"sb":0,"sh":1,"sw":2}
BR = {"beq":0,"bne":1,"blt":4,"bge":5,"bltu":6,"bgeu":7}

def reg(s): return R[s.strip()]
def num(s): return int(s.strip(), 0)

def enc_r(f7,rs2,rs1,f3,rd,op): return (f7<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|op
def enc_i(imm,rs1,f3,rd,op): return ((imm&0xFFF)<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|op
def enc_s(imm,rs2,rs1,f3,op):
    imm &= 0xFFF
    return ((imm>>5)<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|((imm&0x1F)<<7)|op
def enc_b(imm,rs2,rs1,f3,op):
    imm &= 0x1FFF
    return (((imm>>12)&1)<<31)|(((imm>>5)&0x3F)<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(((imm>>1)&0xF)<<8)|(((imm>>11)&1)<<7)|op
def enc_u(imm,rd,op): return ((imm&0xFFFFF)<<12)|(rd<<7)|op
def enc_j(imm,rd,op):
    imm &= 0x1FFFFF
    return (((imm>>20)&1)<<31)|(((imm>>1)&0x3FF)<<21)|(((imm>>11)&1)<<20)|(((imm>>12)&0xFF)<<12)|(rd<<7)|op

def assemble(lines):
    labels, items, pc = {}, [], 0
    for ln in lines:
        t = ln.split("#")[0].strip()
        if not t: continue
        while ":" in t:
            lab, t = t.split(":",1); labels[lab.strip()] = pc; t = t.strip()
        if t: items.append((pc,t,ln.strip())); pc += 4
    out = []
    for pc,t,raw in items:
        m, _, a = t.partition(" ")
        args = [x.strip() for x in a.split(",")] if a else []
        def tgt(x): return (labels[x]-pc) if x in labels else num(x)
        if m in RTYPE:
            f3,f7 = RTYPE[m]; w = enc_r(f7,reg(args[2]),reg(args[1]),f3,reg(args[0]),0x33)
        elif m in ITYPE:
            w = enc_i(num(args[2]),reg(args[1]),ITYPE[m],reg(args[0]),0x13)
        elif m in SHIFTI:
            f3,f7 = SHIFTI[m]; w = enc_i((f7<<5)|num(args[2]),reg(args[1]),f3,reg(args[0]),0x13)
        elif m in LOAD:
            o,b = re.match(r"(.+)\((.+)\)",args[1]).groups()
            w = enc_i(num(o),reg(b),LOAD[m],reg(args[0]),0x03)
        elif m in STORE:
            o,b = re.match(r"(.+)\((.+)\)",args[1]).groups()
            w = enc_s(num(o),reg(args[0]),reg(b),STORE[m],0x23)
        elif m in BR:
            w = enc_b(tgt(args[2]),reg(args[1]),reg(args[0]),BR[m],0x63)
        elif m == "jal":  w = enc_j(tgt(args[1]),reg(args[0]),0x6F)
        elif m == "jalr":
            o,b = re.match(r"(.+)\((.+)\)",args[1]).groups()
            w = enc_i(num(o),reg(b),0,reg(args[0]),0x67)
        elif m == "lui":   w = enc_u(num(args[1]),reg(args[0]),0x37)
        elif m == "auipc": w = enc_u(num(args[1]),reg(args[0]),0x17)
        elif m == "nop":   w = 0x00000013
        else: raise SystemExit(f"unknown instruction: {t}")
        out.append((w, raw))
    return out

if __name__ == "__main__":
    src, dst = sys.argv[1], sys.argv[2]
    prog = assemble(open(src).read().splitlines())
    with open(dst,"w") as f:
        for w,raw in prog: f.write(f"{w:08x} // {raw}\n")
    print(f"{len(prog)} instructions -> {dst}")
