//
// Design Name : uartTx
// File Name   : uartTx.v
// Function    : Simple UART transmiter.
//               115200 baud when driven from 100Mhz clock.
//               Single byte buffer for concurrent loading while tramitting.
// Coder       : Heater.
//
`include "inc/timescale.vh"

module uartTx  #(
		 // parameter [31:0] BAUD_DIVIDER = 868   // 115200 baud from 100MHz clock
		 parameter [31:0] BAUD_DIVIDER = 694   // 115200 baud from 100MHz clock
		 //    parameter [31:0] BAUD_DIVIDER = 434   // 115200 baud from 50MHz clock
		 ) (
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
			 
		    // Serial interface
		    output reg 	       serialOut     // The serial outout.
		    );
   // Internal Variables
   reg [7:0] 			       shifter;
   reg [7:0] 			       buffer;
   reg [7:0] 			       state;
   reg [3:0] 			       bitCount;
   reg [19:0] 			       bitTimer;
   reg 				       bufferEmpty;          // TRUE when ready to accept next character.
   reg 				       rdy;

   // UART TX Logic
   always @ (posedge clk or negedge resetn) begin
      if (!resetn) begin
         state       <= 0;
         buffer      <= 0;
         bufferEmpty <= 1;
         shifter     <= 0;
         serialOut   <= 1;
         bitCount    <= 0;
         bitTimer    <= 0;
         rdy         <= 0;
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

         // Generate bit clock timer for 115200 baud from 50MHz clock
         bitTimer <= bitTimer + 20'd1;
         if (bitTimer == BAUD_DIVIDER) begin
            bitTimer <= 0;
         end

         if (bitTimer == 0) begin
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
