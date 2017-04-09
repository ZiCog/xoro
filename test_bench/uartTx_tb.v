//
// Test bench for uartTx.v
//
// Inspired by tutorial here: http://www.asic-world.com/verilog/art_testbench_writing.html
//

module uart_tb;

    // Define input signals (reg)
    reg        clk;
    reg        resetn;
    reg        enable;
    reg        mem_valid;
    reg        mem_instr;
    reg [3:0]  mem_wstrb;
    reg [31:0] mem_wdata;
    reg [31:0] mem_addr;

    // Define output signals (wire)
    wire        mem_ready;
    wire [31:0] mem_rdata;
    wire        serialOut;    // The serial outout.

    // UART TX empty status
    reg notEmpty = 1;

    // Instantiate DUT.
    defparam uartTx.BAUD_DIVIDER = 10;
    uartTx uartTx (
        .clk(clk),
        .resetn(resetn),
        .enable(enable),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_wstrb(mem_wstrb),
        .mem_wdata(mem_wdata),
        .mem_addr(mem_addr),
        .mem_ready(mem_ready),
        .mem_rdata(mem_rdata),
        .serialOut(serialOut)
    );

    // Initialize all inputs
    initial
    begin
        clk = 0;
        resetn = 0;
        enable = 0;
        mem_valid = 0;
        mem_instr = 0;
        mem_wstrb = 0;
        mem_wdata = 0;
        mem_addr = 0;
    end

    // Generate a clock tick
    always
        #5clk = !clk;

    // Specify file for waveform dump
    initial  begin
        $dumpfile ("uartTx.vcd");
        $dumpvars;
    end

    // Monitor all signals
    initial  begin
        $display("\tclk,\tresetn,\tenable,\tmem_valid,\tmem_ready,\tmem_instr,\tmem_addr,\tmem_wstrb,\tmem_wdata,\tmem_rdata,\tserialOut");
        $monitor("\t%b, \t%b, \t%b, \t%b, \t\t%b, \t\t%b, \t\t%h, \t%b\t\t%h\t%h\t%b", clk,  resetn,  enable,  mem_valid,  mem_ready,  mem_instr,  mem_addr,  mem_wstrb,  mem_wdata,  mem_rdata, serialOut);
    end

    event reset_trigger;
    event reset_done_trigger;

    initial begin
        forever begin
            @ (reset_trigger);
            @ (negedge clk);
            resetn = 0;
            @ (negedge clk);
            resetn = 1;
            -> reset_done_trigger;
        end
    end

    task writeBus32;
        input [31:0] address;
        input [31:0] data;

        begin
            @(posedge clk);
//            $display("writeBus32:");
            enable = 1;
            mem_valid = 1;
            mem_instr = 0;
            mem_wstrb = 4'b1111;
            mem_wdata = data;
            mem_addr = address;
            @(posedge clk);
//            $display("writeBus32: Got mem_ready.");
            enable = 0;
            mem_valid = 0;
            mem_instr = 0;
            mem_wstrb = 0;
            mem_wdata = 0;
            mem_addr = 0;
//            $display("writeBus32: done.");
        end
    endtask

    task readBus32;
        input  [31:0] address;
        output [31:0] data;
        begin
            @(posedge clk);
//            $display("readBus32:");
            enable = 1;
            mem_valid = 1;
            mem_instr = 0;
            mem_wstrb = 4'b000;
            mem_addr = address;
            @(posedge clk);
//            $display("readBus32: Got mem_ready.");
            enable = 0;
            mem_valid = 0;
            mem_instr = 0;
            mem_wstrb = 0;
            mem_wdata = 0;
            mem_addr = 0;
            data = mem_rdata;
//            $display("readBus32: done. returning: %b", data);
        end
    endtask

    reg bufferEmpty = 0;

    initial
    begin: TEST_CASE
        #10 -> reset_trigger;
        @ (reset_done_trigger);
        $write("reset done\n");

        $write("Transmit firts char.\n");
        writeBus32(32'hffff0040, 8'haa);

        while (1) begin
            readBus32(32'hffff0040, bufferEmpty);
            while (bufferEmpty != 1) begin
                readBus32(32'hffff0040, bufferEmpty);
            end
            $write("Transmit following char.\n");
            writeBus32(32'hffff0040, 8'h55);
        end
    end
endmodule
