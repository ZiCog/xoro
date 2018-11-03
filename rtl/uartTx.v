//
// Design Name : uartTx
// File Name   : uartTx.v
// Function    : Simple UART transmiter.
//               115200 baud when driven from 100Mhz clock.
//               Single byte buffer for concurrent loading while tramitting.
// Coder       : Heater.
//
`include "inc/timescale.vh"


module EdgeDetect (
      input   io_in,
      output  io_q,
      input   clk,
      input   resetn);
  reg  old_in;
  assign io_q = (io_in && (! old_in));
  always @ (posedge clk or negedge resetn) begin
    if (!resetn) begin
      old_in <= 1'b0;
    end else begin
      old_in <= io_in;
    end
  end

endmodule


module BaudRateGenerator (
		input  wire clk,
		input  wire resetn,
		input  wire baudClock,
		output wire bitStart,
		output wire probe
	);

	wire baudClockEdge;
   reg [3:0] baudClockcount;
	
	EdgeDetect  baudClockEdgeDetect(
		.clk(clk),
		.resetn(resetn),
		.io_in(baudClock),
		.io_q(baudClockEdge)
	);			 

	EdgeDetect  bitClockEdgeDetect(
		.clk(clk),
		.resetn(resetn),
		.io_in(baudRateClock),
		.io_q(bitStart)
	);			 
	
	assign baudRateClock = baudClockcount[3];
	assign probe = baudRateClock;
	
	always @ (posedge clk or negedge resetn) begin
		if (!resetn) begin
			baudClockcount <= 7;
		end else begin
			if (baudClockEdge) begin
			  baudClockcount <= baudClockcount - 1;
			end
		end
	end
endmodule


module uartTx  (
	// Bus interface
	input wire 	       clk,
	input wire 	       resetn,
	input wire 	       enable,
	input wire 	       mem_valid,
	output wire        mem_ready,
	input wire 	       mem_instr,
	input wire [3:0]   mem_wstrb,
	input wire [31:0]  mem_wdata,
	input wire [31:0]  mem_addr,
	output wire [31:0] mem_rdata,

	input wire         baudClock,
	output wire        probe,

	// Serial interface
	output reg 	       serialOut     // The serial outout.
);
			 
   // Internal Variables
   reg [7:0] 			       shifter;
   reg [7:0] 			       buffer;
   reg [7:0] 			       state;
   reg [3:0] 			       bitCount;
   reg 				       bufferEmpty;          // TRUE when ready to accept next character.
   reg 				       rdy;
	
	wire                    baudRateClock;

	BaudRateGenerator baudRateGenerator(
		.clk(clk),
		.resetn(resetn),
		.baudClock(baudClock),
		.bitStart(bitStart),
		.probe(probe)
	);			 

	
   // UART TX Logic
   always @ (posedge clk or negedge resetn) begin
      if (!resetn) begin
         state          <= 0;
         buffer         <= 0;
         bufferEmpty    <= 1;
         shifter        <= 0;
         serialOut      <= 1;
         bitCount       <= 0;
         rdy            <= 0;
      end else begin
         if (mem_valid & enable) begin
            if  ((mem_wstrb[0] == 1) && (bufferEmpty == 1)) begin
               buffer <= mem_wdata[7:0];
               bufferEmpty <= 0;
            end
            rdy <= 1;
         end else begin
            rdy <= 0;
         end

         if (bitStart) begin
            case (state)
              // Idle
              0 : begin
                 if (bufferEmpty == 0) begin
                    shifter <= buffer;
                    bufferEmpty <= 1;
                    bitCount <= 8;

                    // Start bit
                    serialOut <= 0;
                    state <= 1;
                 end
              end

              // Transmitting
              1 : begin
                 if (bitCount > 0) begin
                    // Data bits
                    serialOut <= shifter[0];
                    bitCount <= bitCount - 4'd1;
                    shifter <= shifter >> 1;
                 end else begin
                    // Stop bit
                    serialOut <= 1;
                    state <= 2;
                 end
              end

              // Second stop bit
              2 : begin
                 serialOut <= 1;
                 state <= 0;
              end

              default : ;
            endcase
         end
      end
   end
   
   // Wire-OR'ed bus outputs.
   assign mem_rdata = enable ? bufferEmpty : 1'b0;
   assign mem_ready = enable ? rdy : 1'b0;
endmodule


