`include "timescale.vh"

module xoroshiro128plus_tb;

    /* Make a reset that pulses low once. */
    reg reset = 1;

    initial begin
    /* verilator lint_off STMTDLY */
        # 1 reset = 0;
        # 1 reset = 1;
    /* verilator lint_on STMTDLY */
    end

    /* Make a regular pulsing clock. */
    reg clk = 0;
    /* verilator lint_off STMTDLY */
    always #5
    /* verilator lint_on STMTDLY */
    begin
        clk = !clk;
    end

    wire [62:0]          x;
    wire [32*16 - 1 : 0] y;

    always @ (posedge clk)
    begin
        $write ("%h\n%h\n", y[31:0], y[63:32]);
    end

    rnd r1 (.resn(reset), .clk(clk), .out(x));

    shuff s1 (.x(x), .out(y));

endmodule
