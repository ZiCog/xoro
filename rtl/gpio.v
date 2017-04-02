//
// GPIO controller for picorv32
//
// Little endian.
// Increasing numeric significance with increasing memory addresses known as "little-endian".
//

module gpio (
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
    output wire [31:0] mem_rdata,

    // gpio interface
    output reg [31:0]  gpio
);

    reg [7:0] q;
    reg rdy;

    always @(negedge clk) begin
        if (!resetn) begin
            rdy <= 0;
            q <= 0;
            gpio <= 0;
        end else if (mem_valid & enable) begin
            if (mem_wstrb[0])
                gpio[7:0] <= mem_wdata[7:0];
            if (mem_wstrb[1])
                gpio[15:8] <= mem_wdata[15:8];
            if (mem_wstrb[2])
                gpio[23:16] <= mem_wdata[23:16];
            if (mem_wstrb[3])
                gpio[31:24] <= mem_wdata[31:24];
            rdy <= 1;
        end else begin
            rdy <= 0;
        end
        q <= gpio;
    end

    // Tri-state the bus outputs.
    assign mem_rdata = enable ? q : 'bz;
    assign mem_ready = enable ? rdy : 1'bz;

endmodule
