//
// Memory controller for picorv32
//
// Little endian.
// Increasing numeric significance with increasing memory addresses known as "little-endian".
//
`include "inc/timescale.vh"

module memory (
    input  wire        clk,
    input  wire        enable,
    input  wire        mem_valid,
    output wire        mem_ready,
    input  wire        mem_instr,
    input  wire [3:0]  mem_wstrb,
    input  wire [31:0] mem_wdata,
    input  wire [31:0] mem_addr,
    output wire [31:0] mem_rdata
);

    reg [31:0] mem [0 : 1024 * 16 - 1];

    reg [31:0] q;
    reg rdy;

    initial
    begin
        $readmemh("firmware/firmware.hex", mem);
    end

    always @(negedge clk) begin
        if (mem_valid & enable) begin
            case (mem_wstrb)
                4'b0001 : begin
                    mem[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
                end
                4'b0010 : begin
                    mem[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
                end
                4'b0100 : begin
                    mem[mem_addr >> 2][23:16] <= mem_wdata[23:16];
                end
                4'b1000 : begin
                    mem[mem_addr >> 2][31:24] <= mem_wdata[31:24];
                end
                4'b0011 : begin
                    mem[mem_addr >> 2][15: 0] <= mem_wdata[15: 0];
                end
                4'b1100 : begin
                    mem[mem_addr >> 2][31:16] <= mem_wdata[31:16];
                end
                4'b1111 : begin
                    mem[mem_addr >> 2] <= mem_wdata[31: 0];
                end
                default : ;
            endcase
            rdy <= 1;
        end else begin
            rdy <= 0;
        end
        q <= mem[mem_addr >> 2];
    end

    // Tri-state the outputs.
    assign mem_rdata = enable ? q : 'bz;
    assign mem_ready = enable ? rdy : 1'bz;

endmodule
