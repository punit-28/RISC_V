// Byte-addressable data memory (1 KB). Supports LB/LH/LW/LBU/LHU and SB/SH/SW.
// (original used word index = full address and only supported LW/SW)
module dmem (
    input         clk,
    input         we,
    input  [2:0]  funct3,
    input  [31:0] addr,
    input  [31:0] wdata,
    output reg [31:0] rdata
);
    reg [7:0] mem [0:1023];
    integer i;
    initial for (i = 0; i < 1024; i = i + 1) mem[i] = 8'h00;

    wire [9:0] a = addr[9:0];

    // store
    always @(posedge clk) begin
        if (we) begin
            mem[a] <= wdata[7:0];
            if (funct3[1:0] != 2'b00) mem[a+1] <= wdata[15:8];
            if (funct3[1:0] == 2'b10) begin
                mem[a+2] <= wdata[23:16];
                mem[a+3] <= wdata[31:24];
            end
        end
    end

    // load
    wire [7:0]  b0 = mem[a];
    wire [15:0] h0 = {mem[a+1], mem[a]};
    wire [31:0] w0 = {mem[a+3], mem[a+2], mem[a+1], mem[a]};

    always @(*) begin
        case (funct3)
            3'b000:  rdata = {{24{b0[7]}},  b0};   // LB
            3'b001:  rdata = {{16{h0[15]}}, h0};   // LH
            3'b010:  rdata = w0;                   // LW
            3'b100:  rdata = {24'b0, b0};          // LBU
            3'b101:  rdata = {16'b0, h0};          // LHU
            default: rdata = 32'b0;
        endcase
    end
endmodule
