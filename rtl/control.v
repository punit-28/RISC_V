// Single combined control unit (original had Main_Decoder + ALU_Decoder)
module control (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input        funct7_5,
    output reg   reg_write,
    output reg   mem_write,
    output reg   alu_src_b,      // 0: rs2, 1: imm
    output reg [1:0] alu_src_a,  // 0: rs1, 1: pc, 2: zero
    output reg [1:0] wb_sel,     // 0: alu, 1: mem, 2: pc+4
    output reg [2:0] imm_sel,
    output reg   branch,
    output reg   jal,
    output reg   jalr,
    output reg [3:0] alu_op
);
    localparam OP_R=7'b0110011, OP_I=7'b0010011, OP_LOAD=7'b0000011,
               OP_STORE=7'b0100011, OP_BRANCH=7'b1100011, OP_JAL=7'b1101111,
               OP_JALR=7'b1100111, OP_LUI=7'b0110111, OP_AUIPC=7'b0010111;

    // ALU op decode from funct3/funct7 (used by R and I types)
    reg [3:0] f_op;
    always @(*) begin
        case (funct3)
            3'b000: f_op = (opcode == OP_R && funct7_5) ? 4'd1 : 4'd0; // SUB/ADD
            3'b001: f_op = 4'd5;                                       // SLL
            3'b010: f_op = 4'd8;                                       // SLT
            3'b011: f_op = 4'd9;                                       // SLTU
            3'b100: f_op = 4'd4;                                       // XOR
            3'b101: f_op = funct7_5 ? 4'd7 : 4'd6;                     // SRA/SRL
            3'b110: f_op = 4'd3;                                       // OR
            3'b111: f_op = 4'd2;                                       // AND
        endcase
    end

    always @(*) begin
        // defaults
        reg_write = 0; mem_write = 0; alu_src_b = 0; alu_src_a = 2'd0;
        wb_sel = 2'd0; imm_sel = 3'd0; branch = 0; jal = 0; jalr = 0;
        alu_op = 4'd0;

        case (opcode)
            OP_R:     begin reg_write = 1; alu_op = f_op; end
            OP_I:     begin reg_write = 1; alu_src_b = 1; alu_op = f_op; end
            OP_LOAD:  begin reg_write = 1; alu_src_b = 1; wb_sel = 2'd1; end
            OP_STORE: begin mem_write = 1; alu_src_b = 1; imm_sel = 3'd1; end
            OP_BRANCH:begin branch = 1; imm_sel = 3'd2; end
            OP_JAL:   begin reg_write = 1; jal = 1; wb_sel = 2'd2; imm_sel = 3'd4; end
            OP_JALR:  begin reg_write = 1; jalr = 1; wb_sel = 2'd2; alu_src_b = 1; end
            OP_LUI:   begin reg_write = 1; alu_src_a = 2'd2; alu_src_b = 1; imm_sel = 3'd3; end
            OP_AUIPC: begin reg_write = 1; alu_src_a = 2'd1; alu_src_b = 1; imm_sel = 3'd3; end
            default: ;
        endcase
    end
endmodule
