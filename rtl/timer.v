//
// Timer for for picorv32
//
`include "inc/timescale.vh"

module timer (
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
    reg [31:0] count;
    reg rdy;

    always @(negedge clk) begin
        if (!resetn) begin
            rdy <= 0;
            count <= 0;
        end else begin
            count <= count + 1;
            if (mem_valid & enable) begin
                rdy <= 1;
            end else begin
                rdy <= 0;
            end
        end
    end

    // Wire-OR'ed bus outputs.
    assign mem_rdata = enable ? count : 32'b0;
    assign mem_ready = enable ? rdy : 1'b0;

endmodule
