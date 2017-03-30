//
// memory_decoder
//
// Here is where we diced what devices on what addresses get enabled.
//

module memory_decoder (input [31:0] address, output [7:0] enables);
    assign enables[0] = 'b1;
    assign enables[1] = 'b0;
    assign enables[2] = 'b0;
    assign enables[3] = 'b0;
    assign enables[4] = 'b0;
    assign enables[5] = 'b0;
    assign enables[6] = 'b0;
    assign enables[7] = 'b0;
endmodule
