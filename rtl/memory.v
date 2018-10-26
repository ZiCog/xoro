//
// Memory controller for picorv32
//
// Little endian.
// Increasing numeric significance with increasing memory addresses known as "little-endian".
//
`include "inc/timescale.vh"

module memory (
	       input wire 	  clk,
	       input wire 	  enable,
	       input wire 	  mem_valid,
	       output wire 	  mem_ready,
	       input wire 	  mem_instr,
	       input wire [3:0]   mem_wstrb,
	       input wire [31:0]  mem_wdata,
	       input wire [31:0]  mem_addr,
	       output wire [31:0] mem_rdata
	       );

   qram32  mem (
		.address(mem_addr >> 2),
		.byteena(mem_wstrb),
		.clock(~clk),
		.data(mem_wdata),
		.wren(wren),
		.q(q)
		);

   reg 				  rdy;
   wire [31:0] 			  q;
   wire 			  wren;

   assign wren = (enable & mem_valid & |mem_wstrb);

   always @(posedge clk) begin
      if (mem_valid & enable) begin
         rdy <= 1;
      end else begin
         rdy <= 0;
      end
   end

   // Wire-OR'ed bus outputs.
   assign mem_rdata = enable ? q : 32'b0;
   assign mem_ready = enable ? rdy : 1'b0;

endmodule
