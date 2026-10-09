// Immediate generator: I, S, B, U, J formats
module imm_gen (
    input  [31:0] instr,
    input  [2:0]  sel,
    output reg [31:0] imm
);
    localparam I_T=3'd0, S_T=3'd1, B_T=3'd2, U_T=3'd3, J_T=3'd4;

    always @(*) begin
        case (sel)
            I_T: imm = {{20{instr[31]}}, instr[31:20]};
            S_T: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            B_T: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            U_T: imm = {instr[31:12], 12'b0};
            J_T: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            default: imm = 32'b0;
        endcase
    end
endmodule
