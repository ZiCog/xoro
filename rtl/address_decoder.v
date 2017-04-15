//
// address_decoder
//
// Here is where we decide what devices on what addresses get enabled.
//
`include "inc/timescale.vh"

module address_decoder (input [31:0] address, output reg [7:0] enables);
    always @(address) begin
        enables = 0;
        case (address[31:4])
            28'hffff000: enables[0] = 1;
            28'hffff001: enables[1] = 1;
            28'hffff002: enables[2] = 1;
            28'hffff003: enables[3] = 1;
            28'hffff004: enables[4] = 1;
            28'hffff005: enables[5] = 1;
            28'hffff006: enables[6] = 1;
            default: enables[7] = 1;
        endcase
    end
endmodule
