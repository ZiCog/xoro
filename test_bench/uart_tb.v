//
// Test bench for uartTx.v
//
// Inspired by tutorial here: http://www.asic-world.com/verilog/art_testbench_writing.html
//

module uart_tb;

    // Define input signals (reg)
    reg       resn;
    reg       clk;
    reg       wr; 
    reg [7:0] data; 

    // Define output signals (wire)
    wire serialOut;
    wire empty; 
        
    // Instantiate DUT.    
    tx t1 ( 
        .resn(resn),
        .clk(clk),
        .wr(wr),
        .data(data),
        .serialOut(serialOut),
        .empty(empty)
    ); 

    // Initialize all inputs
    initial 
    begin 
        resn = 0; 
        clk = 0; 
        wr = 0;
        data = 0;
    end 
    
    // Generate a clock tick
    always 
        #5clk = !clk; 

    // Specify file for waveform dump
    initial  begin
        $dumpfile ("counter.vcd"); 
        $dumpvars; 
    end 

    // Monitor all signals
    initial  begin
        $display("\tclk,\tresn,\twr,\tdata,\tserialOut,\tempty"); 
        $monitor("\t%b,\t%b,\t%b,\t%h,\t%b,\t\t%b", clk, resn, wr, data, serialOut, empty); 
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

        @ (negedge clk); 
        $write("loading first char.\n");
        data = 8'h00;
        wr = 1;
        @ (negedge clk) wr = 0;

       repeat (10) begin 
            @ (posedge empty); 
            $write("empty: reloading\n");
            @ (negedge clk)
            data = data + 1;
            wr = 1; 
            @ (negedge clk) wr = 0;
       end 
       @ (posedge empty) $finish;
    end   
endmodule 
