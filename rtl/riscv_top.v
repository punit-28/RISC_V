// RV32I single-cycle core (variant)
// Reset is ACTIVE-HIGH synchronous.
module riscv_top #(parameter PROG = "program.hex") (
    input clk,
    input rst
);
    // ---------------- Fetch ----------------
    reg  [31:0] pc;
    wire [31:0] instr, pc_plus4, pc_target, pc_next;

    imem #(.FILE(PROG)) u_imem (.addr(pc), .instr(instr));
    assign pc_plus4 = pc + 32'd4;

    // ---------------- Decode ----------------
    wire [6:0] opcode   = instr[6:0];
    wire [2:0] funct3   = instr[14:12];
    wire       funct7_5 = instr[30];

    wire reg_write, mem_write, alu_src_b, branch, jal, jalr;
    wire [1:0] alu_src_a, wb_sel;
    wire [2:0] imm_sel;
    wire [3:0] alu_op;

    control u_ctrl (
        .opcode(opcode), .funct3(funct3), .funct7_5(funct7_5),
        .reg_write(reg_write), .mem_write(mem_write),
        .alu_src_b(alu_src_b), .alu_src_a(alu_src_a),
        .wb_sel(wb_sel), .imm_sel(imm_sel),
        .branch(branch), .jal(jal), .jalr(jalr), .alu_op(alu_op)
    );

    wire [31:0] rs1_val, rs2_val, imm, wb_data;

    regfile u_rf (
        .clk(clk), .rst(rst), .we(reg_write),
        .ra1(instr[19:15]), .ra2(instr[24:20]), .wa(instr[11:7]),
        .wd(wb_data), .rd1(rs1_val), .rd2(rs2_val)
    );

    imm_gen u_imm (.instr(instr), .sel(imm_sel), .imm(imm));

    // ---------------- Execute ----------------
    reg  [31:0] op_a;
    always @(*) begin
        case (alu_src_a)
            2'd0:    op_a = rs1_val;
            2'd1:    op_a = pc;
            default: op_a = 32'b0;
        endcase
    end
    wire [31:0] op_b = alu_src_b ? imm : rs2_val;
    wire [31:0] alu_y;

    alu u_alu (.a(op_a), .b(op_b), .op(alu_op), .y(alu_y));

    wire br_taken;
    branch_unit u_br (.a(rs1_val), .b(rs2_val), .funct3(funct3), .taken(br_taken));

    // ---------------- Memory ----------------
    wire [31:0] mem_rdata;
    dmem u_dmem (
        .clk(clk), .we(mem_write), .funct3(funct3),
        .addr(alu_y), .wdata(rs2_val), .rdata(mem_rdata)
    );

    // ---------------- Write back ----------------
    assign wb_data = (wb_sel == 2'd1) ? mem_rdata :
                     (wb_sel == 2'd2) ? pc_plus4  : alu_y;

    // ---------------- Next PC ----------------
    assign pc_target = pc + imm;
    assign pc_next = jalr                       ? (alu_y & 32'hFFFF_FFFE) :
                     (jal | (branch & br_taken)) ? pc_target : pc_plus4;

    always @(posedge clk) begin
        if (rst) pc <= 32'b0;
        else     pc <= pc_next;
    end
endmodule
