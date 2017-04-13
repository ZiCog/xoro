`include "timescale.vh"

module hello (
    input  resn,      // Reset, active low.
    input  clk,
    output serialOut  // The serial output.
);
    // UART TX testing "Hello World!"
    reg wr;
    wire [7:0] char;
    reg  [3:0] state;

    wire empty;

    reg [3:0] messageIdx;

    rom message (
	     .addr(messageIdx),
	     .clk(clk),
		  .q(char)
    );

    uartTx t1 (
        .resn(resn),         		// Reset, active low.
        .clk(clk),           		// Clock, (Use 50Mhz for 115200 baud).
        .wr(wr),                	// Writes data to holding register on rising clock
        .data(char),           	// Data to be transmitted.
        .serialOut(serialOut),	// The serial outout.
        .empty(empty)            // TRUE when ready to accept next character.
     );

     always @(posedge clk or negedge resn)
     begin
        if (!resn) begin
            state <= 0;
            wr <= 0;
            messageIdx <= 0;
        end else begin
            case (state)
                0 : begin
                    messageIdx <= messageIdx + 1;
                    wr <= 1;
                    state <= 1;
                end

                1: begin
                    wr <= 0;
                    state <= 2;
                end

                2: begin
                    if (empty == 1) begin
                        state <= 0;
                    end
                end

                default : ;
            endcase
        end
    end
endmodule
