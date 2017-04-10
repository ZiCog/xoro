//
// Test bench for xoro_top.v
//


module xoro_top_tb;

    // Define all inputs
    reg clk;
    reg resn;

    // Define all outputs
    wire [3:0] leds;
    wire [3:0] rnd;
    wire       serialOut;

    // Instantiate DUT.
    xoro_top xoro_top (
        .CLOCK_50(clk),
        .reset_btn(resn),
        .LED(leds),
        .RND_OUT(rnd),
        .UART_TX(serialOut)
    );

    // Initialize all inputs
    initial
    begin
        clk = 0;
        resn = 0;
    end

    // Specify file for waveform dump
    initial  begin
        $dumpfile ("xoro_top_tb.vcd");
        $dumpvars;
    end

    // Monitor all signals
    initial  begin
        $display("\tclk,\tresn,\tleds,\trnd,\tserialOut,\tmem_addr, \txoro_to.mem_rdata,\txoro_top.resetn");
        $monitor("\t%b,\t%b,\t%b,\t%b,\t%b,\t\t%h,\t%h,\t%b", clk,  resn, leds, rnd, serialOut, xoro_top.mem_addr, xoro_top.mem_rdata, xoro_top.resetn);
    end

    // Generate a clock tick
    always
        #5clk = !clk;

    // Generate a reset on start up
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
endmodule
