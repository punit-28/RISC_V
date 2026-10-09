// ALU: 10 operations (original had only ADD/SUB/AND/OR/SLT)
module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  op,
    output reg [31:0] y
);
    localparam ADD=4'd0, SUB=4'd1, AND=4'd2, OR=4'd3, XOR=4'd4,
               SLL=4'd5, SRL=4'd6, SRA=4'd7, SLT=4'd8, SLTU=4'd9;

    always @(*) begin
        case (op)
            ADD:  y = a + b;
            SUB:  y = a - b;
            AND:  y = a & b;
            OR:   y = a | b;
            XOR:  y = a ^ b;
            SLL:  y = a << b[4:0];
            SRL:  y = a >> b[4:0];
            SRA:  y = $signed(a) >>> b[4:0];
            SLT:  y = {31'b0, $signed(a) < $signed(b)};
            SLTU: y = {31'b0, a < b};
            default: y = 32'b0;
        endcase
    end
endmodule
