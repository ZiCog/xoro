//
// Test bench for memory.v
//
// Inspired by tutorial here: http://www.asic-world.com/verilog/art_testbench_writing.html
//

module memory_tb;

    // Define the inputs
    reg resn;
    reg clk;

    //------------------------------------------------------
    // Use the picorv32 CPU to drive the memory in this test.

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

    defparam cpu.BARREL_SHIFTER = 1;
    defparam cpu.TWO_CYCLE_COMPARE = 1;
    defparam cpu.TWO_CYCLE_ALU = 1;
    defparam cpu.ENABLE_TRACE = 1;

    picorv32 cpu (
        .clk(clk),
        .resetn(resn),
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
//------------------------------------------------------

    // Instantiate DUT.
    memory mc (
        .resn(resn),
        .clk(clk),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_instr(mem_instr),
        .mem_wstrb(mem_wstrb),
        .mem_wdata(mem_wdata),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata)
    );

    // Initialize all inputs
    initial
    begin
        resn = 0;
        clk = 0;
    end

    // Generate a clock tick
    always begin
        #5 clk = !clk;
    end

    // Specify file for waveform dump
    initial  begin
        $dumpfile ("memory.vcd");
        $dumpvars;
    end

    // Monitor all signals
    initial  begin
        $display("\tclk,\tresn,\tmem_valid,\tmem_ready,\tmem_instr,\tmem_addr,\tmem_wstrb,\tmem_wdata,\tmem_rdata");

        $monitor("\t%b,\t%b,\t%b,\t\t%b,\t\t%b,\t\t%h,\t%b\t\t%h\t%h", clk, resn, mem_valid, mem_ready, mem_instr, mem_addr, mem_wstrb, mem_wdata, mem_rdata);
    end

    event reset_trigger;
    event reset_done_trigger;

    initial begin
        forever begin
            @ (reset_trigger);
            @ (negedge clk);
            resn = 0;
            @ (negedge clk);
            resn = 1;
            -> reset_done_trigger;
        end
    end

    initial
    begin: TEST_CASE
        #10 -> reset_trigger;
        @ (reset_done_trigger);
        $write("reset done\n");


        #100000 $finish();
    end
endmodule
