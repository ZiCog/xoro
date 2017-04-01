//
// Test bench for blinky.v
//
module blinky_tb;

    // Define inputs
    reg CLOCK_50;
    reg reset_btn;

    // Define outputs
    wire [7:0] LED;
    wire [3:0] RND_OUT;
    wire UART_TX;

    // Instantiate DUT
    blinky b (
        .CLOCK_50(CLOCK_50),
        .reset_btn(reset_btn),
        .LED(LED),
        .RND_OUT(RND_OUT),
        .UART_TX(UART_TX)
    );

    // Initialize all inputs
    initial
    begin
        reset_btn = 0;
        CLOCK_50 = 0;
    end

    // Generate a clock tick
    always begin
        #5 CLOCK_50 = !CLOCK_50;
    end

    // Specify file for waveform dump
    initial  begin
        $dumpfile ("blinky.vcd");
        $dumpvars;
    end

    // Monitor all signals
    initial  begin
        $display("\tCLOCK_50,\treset_btn,\tLED,\t\tRND_OUT,\tUART_TX,");
        $monitor("\t%b,\t\t%b,\t\t%b,\t%b,\t\t%b,", CLOCK_50, reset_btn, LED, RND_OUT, UART_TX);
    end

    event reset_trigger;
    event reset_done_trigger;

    initial begin
        forever begin
            @ (reset_trigger);
            @ (negedge CLOCK_50);
            reset_btn = 0;
            @ (negedge CLOCK_50);
            reset_btn = 1;
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
