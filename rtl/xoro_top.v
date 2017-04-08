//
// xoro_top.v
//
// For all DE0-Nano pin outs the file DE0_NANO.qsf
//
module xoro_top (input CLOCK_50, input reset_btn, output[7:0] LED, output[3:0] RND_OUT, output UART_TX);

    wire        trap;

    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;

    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;

    // Look-Ahead Interface
    wire        mem_la_read;
    wire        mem_la_write;
    wire [31:0] mem_la_addr;
    wire [31:0] mem_la_wdata;
    wire [3:0]  mem_la_wstrb;

    wire        pcpi_valid;
    wire [31:0] pcpi_insn;
    wire [31:0] pcpi_rs1;
    wire [31:0] pcpi_rs2;
    reg         pcpi_wr;
    reg  [31:0] pcpi_rd;
    reg         pcpi_wait;
    reg         pcpi_ready;

    // IRQ Interface
    reg  [31:0] irq;
    wire [31:0] eoi;

    // Trace Interface
    wire        trace_valid;
    wire [35:0] trace_data;

    // Peripheral enables
    wire [7:0] enables;

    reg resetn = 0;
    reg [7:0] resetCount = 0;

    wire CLOCK_100;
    wire CLOCK_100_SHIFTED;
    wire CLOCK_10;
    wire CLOCK_LOCKED;

    always @(posedge CLOCK_100)
    begin
        resetCount <= resetCount + 1;
        if (resetCount == 100) resetn <= 1;
    end

    // Generate 100MHz and 10MHz clocks
    // See Quartus PLL tutorial here: http://www.emb4fun.de/fpga/nutos1/
    pll_sys pll_sys_inst (
        .inclk0 (CLOCK_50),      // The input clok
        .c0 (CLOCK_100),         // 100MHz clock
        .c1 (CLOCK_100_SHIFTED), // 100MHz clock with phase shift of -54 degrees
        .c2 (CLOCK_10),          // 10MHz clock
        .locked (CLOCK_LOCKED)   // PLL is locked signal
    );

    memory mem (
        .clk(CLOCK_100),
        .enable(enables[7]),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_instr(mem_instr),
        .mem_wstrb(mem_wstrb),
        .mem_wdata(mem_wdata),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata)
    );

    gpio gpio (
        .clk(CLOCK_100),
        .resetn(resetn),
        .enable(enables[6]),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_instr(mem_instr),
        .mem_wstrb(mem_wstrb),
        .mem_wdata(mem_wdata),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata),
        .gpio(LED)
    );

    prng rand (
        .clk(CLOCK_100),
        .resetn(resetn),
        .enable(enables[5]),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_instr(mem_instr),
        .mem_wstrb(mem_wstrb),
        .mem_wdata(mem_wdata),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata)
    );

    uartTx uartTx (
        .clk(CLOCK_100),
        .resetn(resetn),
        .enable(enables[4]),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_instr(mem_instr),
        .mem_wstrb(mem_wstrb),
        .mem_wdata(mem_wdata),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata),
        .serialOut(UART_TX)
    );

    address_decoder ad (
        .address(mem_addr),
        .enables(enables)
    );

    defparam cpu.BARREL_SHIFTER = 1;
    defparam cpu.TWO_CYCLE_COMPARE = 1;
    defparam cpu.TWO_CYCLE_ALU = 1;
    defparam cpu.ENABLE_PCPI = 1;        //
    defparam cpu.ENABLE_FAST_MUL = 1;    // MUL and DIV cost 564 LE and !
    defparam cpu.ENABLE_DIV = 1;         //

    picorv32 cpu (
        .clk(CLOCK_100),
        .resetn(resetn),
        .trap(trap),

        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),

        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),

        // Look-Ahead Interface
        .mem_la_read(mem_la_read),
        .mem_la_write(mem_la_write),
        .mem_la_addr(mem_la_addr),
        .mem_la_wdata(mem_la_wdata),
        .mem_la_wstrb(mem_la_wstrb),

        // Pico Co-Processor Interface (PCPI)
        .pcpi_valid(pcpi_valid),
        .pcpi_insn(pcpi_insn),
        .pcpi_rs1(pcpi_rs1),
        .pcpi_rs2(pcpi_rs2),
        .pcpi_wr(pcpi_wr),
        .pcpi_rd(pcpi_rd),
        .pcpi_wait(pcpi_wait),
        .pcpi_ready(pcpi_ready),

        // IRQ Interface
        .irq(irq),
        .eoi(eoi),

        // Trace Interface
        .trace_valid(trace_valid),
        .trace_data(trace_data)
    );

    // Put the clocks out on some pins so we can see them working.
    assign RND_OUT = {CLOCK_100, CLOCK_100_SHIFTED, CLOCK_10, CLOCK_LOCKED};

endmodule
