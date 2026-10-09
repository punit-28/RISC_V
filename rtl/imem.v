// Instruction memory: 256 words, loaded from program.hex
module imem #(parameter FILE = "program.hex") (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] rom [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) rom[i] = 32'h00000013; // NOP (addi x0,x0,0)
        $readmemh(FILE, rom);
    end
    assign instr = rom[addr[9:2]];
endmodule
