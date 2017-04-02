//
// blinky
//

// DE0-Nano pin outs.
// Signal Name FPGA Pin No. Description
// CLOCK_50    R8           50MHz Clock input

// Signal Name FPGA Pin No. Description
// KEY[0]      PIN_J15      Push-button[0] 3.3V
// KEY[1]      PIN_E1       Push-button[1] 3.3V

// Signal Name FPGA Pin No. Description
// LED[0]      PIN_A15      LED Green[0] 3.3V
// LED[1]      PIN_A13      LED Green[1] 3.3V
// LED[2]      PIN_B13      LED Green[2] 3.3V
// LED[3]      PIN_A11      LED Green[3] 3.3V
// LED[4]      PIN_D1       LED Green[4] 3.3V
// LED[5]      PIN_F3       LED Green[5] 3.3V
// LED[6]      PIN_B1       LED Green[6] 3.3V
// LED[7]      PIN_L3       LED Green[7] 3.3V

// Signal Name FPGA Pin No. Description
// GPIO_10     PIN_F13      GPIO JP2, 2
// GPIO_11     PIN_T15      GPIO JP2, 4
// GPIO_13     PIN_T13      GPIO JP2, 6
// GPIO_15     PIN_T12      GPIO JP2, 8

// Signal Name FPGA Pin No. Description
// GPIO_17     PIN_T11      GPIO JP2, 10


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

    always @(posedge CLOCK_50)
    begin
        resetCount <= resetCount + 1;
        if (resetCount == 100) resetn <= 1;
    end

    gpio gpio (
        .clk(CLOCK_50),
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

    memory mem (
        .clk(CLOCK_50),
        .enable(enables[7]),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_instr(mem_instr),
        .mem_wstrb(mem_wstrb),
        .mem_wdata(mem_wdata),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata)
    );

    address_decoder ad (
        .address(mem_addr),
        .enables(enables)
    );

    defparam cpu.BARREL_SHIFTER = 0;
    defparam cpu.TWO_CYCLE_COMPARE = 0;
    defparam cpu.TWO_CYCLE_ALU = 0;
    defparam cpu.ENABLE_TRACE = 0;
    defparam cpu.LATCHED_MEM_RDATA = 0;
    defparam cpu.ENABLE_PCPI = 0;        //
    defparam cpu.ENABLE_FAST_MUL = 0;    // MUL and DIV cost 564 LE and !
    defparam cpu.ENABLE_DIV = 0;         //

    picorv32 cpu (
        .clk(CLOCK_50),
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

    assign RND_OUT = {mem_ready, mem_instr, mem_valid};

endmodule
