//
// Pseudo Random Number Generator interface.
// Uses the xoroshiro128+ PRNG.
//

module prng (
    // Bus interface
    input  wire        clk,
    input  wire        resetn,
    input  wire        enable,
    input  wire        mem_valid,
    output wire        mem_ready,
    input  wire        mem_instr,
    input  wire [3:0]  mem_wstrb,
    input  wire [31:0] mem_wdata,
    input  wire [31:0] mem_addr,
    output wire [31:0] mem_rdata
);

    wire [63:0] prng_out;
    reg  prng_clk;
    reg  rdy;
    reg  q;

    xoroshiro128plus prng(
        .resn(resetn),
        .clk(prng_clk),
        .out(prng_out)
    );

    always @(negedge clk) begin
        if (!resetn) begin
            rdy <= 0;
            prng_clk <= 0;
        end else if (mem_valid & enable) begin
            prng_clk <= 1;
            rdy <= 1;
        end else begin
            prng_clk <= 0;
            rdy <= 0;
        end
        q <= prng_out;
    end

    // Tri-state the bus outputs.
    assign mem_rdata = enable ? q : 'bz;
    assign mem_ready = enable ? rdy : 1'bz;

endmodule
