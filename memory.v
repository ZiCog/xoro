//
// Memory controller for picorv32
//
// Little endian.
// Increasing numeric significance with increasing memory addresses known as "little-endian".
//

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

    reg [7:0] mem0 [0 : 1024 * 12 - 1];
    reg [7:0] mem1 [0 : 1024 * 12 - 1];
    reg [7:0] mem2 [0 : 1024 * 12 - 1];
    reg [7:0] mem3 [0 : 1024 * 12 - 1];

    reg [31:0] q;
    reg rdy;

    initial
    begin
        $readmemh("firmware/firmware0.hex", mem0);
        $readmemh("firmware/firmware1.hex", mem1);
        $readmemh("firmware/firmware2.hex", mem2);
        $readmemh("firmware/firmware3.hex", mem3);
    end

    always @(negedge clk) begin
        if (mem_valid) begin
            if (mem_wstrb[0])
                mem0[mem_addr >> 2] <= mem_wdata[7:0];
            if (mem_wstrb[1])
                mem1[mem_addr >> 2] <= mem_wdata[15:8];
            if (mem_wstrb[2])
                mem2[mem_addr >> 2] <= mem_wdata[23:16];
            if (mem_wstrb[3])
                mem3[mem_addr >> 2] <= mem_wdata[31:24];
            rdy <= 1;
        end else begin
            rdy <= 0;
        end
        q <= {mem3[mem_addr >> 2], mem2[mem_addr >> 2], mem1[mem_addr >> 2], mem0[mem_addr >> 2]};
    end

    // Tri-state the outputs.
    assign mem_rdata = enable ? q : 'bz;
    assign mem_ready = enable ? rdy : 1'bz;

endmodule
