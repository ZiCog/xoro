//
// Design Name : uartTx 
// File Name   : uartTx.v
// Function    : Simple UART transmiter.
//               115200 baud when driven from 50Mhz clock.
//               Single byte buffer for concurrent loading while tramitting.                
// Coder       : Heater.
//

module uartTx (
    input       resn,          // Reset, active low.
    input       clk,           // Clock, (Use 50Mhz for 115200 baud).
    input       wr,            // Writes data to holding register on rising clock
    input [7:0] data,          // Data to be transmitted.
    output reg  serialOut,     // The serial outout.
    output reg  empty          // TRUE when ready to accept next character.
);
    // Internal Variables 
    reg [7:0]  shifter;
    reg [7:0]  buffer;
    reg [7:0]  state;
    reg [3:0]  bitCount;
    reg [19:0] bitTimer; 

    // UART TX Logic
    always @ (posedge clk or negedge resn) begin
        if (!resn) begin
            state     <= 0;
            buffer    <= 0;
            empty     <= 1;
            shifter   <= 0;
            serialOut <= 1;
            bitCount  <= 0;
            bitTimer  <= 0;
        end else begin
            if ((wr == 1) && (empty == 1)) begin
                buffer <= data;
                empty <= 0;
            end

            // Generate bit clock timer for 115200 baud from 50MHz clock
            bitTimer <= bitTimer + 1;
            if (bitTimer == 1302) begin
                bitTimer <= 0;
            end

            if (bitTimer == 0) begin
                case (state)
                    // Idle
                    0 : begin
                        if (!empty) begin
                            shifter <= buffer;
                            empty <= 1;
                            bitCount <= 8;
                            serialOut <= 0;
                            state <= 1;
                        end
                    end

                    // Transmitting
                    1 : begin
                        // Data bits
                        if (bitCount > 0) begin
                            bitCount <= bitCount - 1;
                            serialOut <= shifter[0];
                            shifter <= shifter >> 1;
                        end else begin
                            // Stop bit
                            serialOut <= 1;
                            state <= 0;
                        end
                    end

                    default : ;
                endcase
            end
        end
    end
endmodule
