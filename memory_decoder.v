//
// memory_decoder
//
// Here is where we decide what devices on what addresses get enabled.
//

module memory_decoder (input [31:0] address, output [7:0] enables);
    integer memoryEnable;
    always @(address) begin
        memoryEnable = 0;
        if (address[31]) begin
            // A peripheral device access.
        end else begin
            // A memory access.
            memoryEnable = 1;
        end
    end
    assign enables[0] = memoryEnable;
/*
    assign enables[0] = !(address & 'h80000000);
    assign enables[1] = 'b0;
    assign enables[2] = 'b0;
    assign enables[3] = 'b0;
    assign enables[4] = 'b0;
    assign enables[5] = 'b0;
    assign enables[6] = 'b0;
    assign enables[7] = 'b0;
*/
endmodule
