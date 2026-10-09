        addi x1, x0, 10        # x1 = 10
        addi x2, x0, 3         # x2 = 3
        add  x3, x1, x2        # 13
        sub  x4, x1, x2        # 7
        and  x5, x1, x2        # 2
        or   x6, x1, x2        # 11
        xor  x7, x1, x2        # 9
        sll  x8, x1, x2        # 80
        srl  x9, x1, x2        # 1
        addi x10, x0, -16      # -16
        sra  x11, x10, x2      # -2
        slt  x12, x10, x1      # 1  (signed)
        sltu x13, x10, x1      # 0  (unsigned)
        lui  x14, 0x12345      # 0x12345000
        auipc x15, 0           # = pc of this instr = 0x38
        sw   x3, 0(x0)         # mem[0] = 13
        lw   x16, 0(x0)        # 13
        sb   x10, 5(x0)        # mem[5] = 0xF0
        lbu  x17, 5(x0)        # 0xF0 = 240
        lb   x18, 5(x0)        # sign-ext = -16
        addi x19, x0, 0
        addi x20, x0, 5
loop:   addi x19, x19, 1
        bne  x19, x20, loop    # x19 = 5
        jal  x21, fn           # x21 = return addr
        addi x22, x0, 99       # skipped
fn:     addi x23, x0, 7        # x23 = 7
        auipc x24, 0
        addi x24, x24, 16
        jalr x25, 0(x24)       # jump to done, x25 = pc+4
        addi x26, x0, 99       # skipped
done:   addi x27, x0, 1        # x27 = 1
end:    jal  x0, end           # halt
