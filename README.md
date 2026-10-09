# RV32I Single-Cycle Core (variant)

Based on the structure of `amanky01/RISCV`, but extended and cleaned up.

## What's different from the original
| Area | Original | This variant |
|---|---|---|
| ALU ops | ADD, SUB, AND, OR, SLT | + XOR, SLL, SRL, SRA, SLTU (4-bit op) |
| Instructions | R-type, LW, SW | + I-type ALU (ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI), LUI, AUIPC, JAL, JALR, BEQ/BNE/BLT/BGE/BLTU/BGEU |
| Data memory | word index = full address, LW/SW only | byte-addressable, LB/LH/LW/LBU/LHU, SB/SH/SW |
| Branch/jump | `Branch` signal unused | working PC mux (branch unit + JAL/JALR) |
| Immediates | I and S only | I, S, B, U, J |
| Control | Main_Decoder + ALU_Decoder | single `control.v` |
| Register file | hard-coded initial values | clean, x0 hard-wired to 0 |
| Reset | active-low | active-high, synchronous |

## Run
```
iverilog -g2012 -o sim.vvp rtl/*.v tb/tb_riscv.v && vvp sim.vvp
python3 sw/asm.py sw/test.s sw/program.hex     # re-assemble your own program
```
Waveform: `riscv.vcd` (GTKWave).
