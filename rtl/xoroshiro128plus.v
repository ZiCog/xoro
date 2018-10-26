//
// The xoroshiro128+ PRNG
//
// From the C source found here : http://xoroshiro.di.unimi.it/
//
`include "inc/timescale.vh"

module xoroshiro128plus (input resn, input clk, output [63:0] out);
   reg  [63:0] s0, s1, ss;
   wire [63:0] sx = s0 ^ s1;

   always @(posedge clk or negedge resn) begin
      if (!resn) begin
         s0 <= 64'b1;    // seed s0
         s1 <= 64'b0;
         ss <= 64'b0;
      end else begin
         s0 <= {s0[08:00], s0[63:09]} ^ sx ^ {sx[49:00], 14'b0};
         s1 <= {sx[27:00], sx[63:28]};
         ss <= s0 + s1;
      end
   end
   assign out = ss[63:0];
endmodule
