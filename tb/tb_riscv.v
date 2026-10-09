`timescale 1ns/1ps
module tb_riscv;
    reg clk = 0, rst = 1;
    riscv_top #(.PROG("sw/program.hex")) dut (.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    integer errors = 0;
    task check(input [4:0] r, input [31:0] exp);
        begin
            if (dut.u_rf.regs[r] !== exp) begin
                $display("FAIL x%0d = %h, expected %h", r, dut.u_rf.regs[r], exp);
                errors = errors + 1;
            end else
                $display("ok   x%0d = %h", r, exp);
        end
    endtask

    initial begin
        $dumpfile("riscv.vcd"); $dumpvars(0, tb_riscv);
        repeat (3) @(posedge clk);
        rst = 0;
        repeat (80) @(posedge clk);

        check(1,  10);          check(2,  3);
        check(3,  13);          check(4,  7);
        check(5,  2);           check(6,  11);
        check(7,  9);           check(8,  80);
        check(9,  1);           check(10, 32'hFFFFFFF0);
        check(11, 32'hFFFFFFFE);check(12, 1);
        check(13, 0);           check(14, 32'h12345000);
        check(15, 32'h00000038);check(16, 13);
        check(17, 32'hF0);      check(18, 32'hFFFFFFF0);
        check(19, 5);           check(21, 32'h00000064);
        check(22, 0);           check(23, 7);
        check(25, 32'h00000078);check(26, 0);
        check(27, 1);

        if (errors == 0) $display("\nALL TESTS PASSED");
        else             $display("\n%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
