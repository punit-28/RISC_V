// 32 x 32-bit register file. x0 is hard-wired to zero.
// Active-high synchronous reset clears all registers.
module regfile (
    input         clk,
    input         rst,
    input         we,
    input  [4:0]  ra1, ra2, wa,
    input  [31:0] wd,
    output [31:0] rd1, rd2
);
    reg [31:0] regs [0:31];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) regs[i] <= 32'b0;
        end else if (we && wa != 5'd0) begin
            regs[wa] <= wd;
        end
    end

    assign rd1 = (ra1 == 5'd0) ? 32'b0 : regs[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'b0 : regs[ra2];
endmodule
