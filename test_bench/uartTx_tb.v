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

    // Instantiate DUT.
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

    initial
    begin: TEST_CASE
        #10 -> reset_trigger;
        @ (reset_done_trigger);
        $write("reset done\n");


        // FIXME: This is dumb, we should loop for ever reading the empty state, then sending a char 
        @ (negedge clk);
        $write("loading first char.\n");

        mem_wdata = 8'haa;
        mem_addr = 32'hffff0040;
        mem_wstrb = 4'b1111;
        mem_valid = 1;
        enable = 1;

        @(posedge mem_ready)
        $display("mem ready !!!!");
        mem_wdata = 8'h00;
        mem_addr = 32'h00000000;
        mem_wstrb = 4'b1111;
        mem_valid = 0;
        enable = 0;

       repeat (1000) begin
            #2000;
            $write("loading next char.\n");
            mem_wdata = 8'haa;
            mem_addr = 32'hffff0040;
            mem_wstrb = 4'b1111;
            mem_valid = 1;
            enable = 1;
            @(posedge mem_ready)
            $display("mem ready !!!!");
            mem_wdata = 8'h00;
            mem_addr = 32'h00000000;
            mem_wstrb = 4'b1111;
            mem_valid = 0;
            enable = 0;
       end
       $finish;

    end
endmodule
