`include "timescale.vh"

module spi (
    input wire         clk,
    input wire         resn,
    input wire         trig,
    output reg [15:0]  rdData,
    input wire [15:0]  wrData,

    // SPI interface
    output  reg  SCLK,
    output  reg  SS,
    output  reg  MOSI,
    input   wire MISO
);
    reg [3:0]  state;
    reg [15:0] bitCount;
    reg [15:0] clkCounter;

    // Generate SPI clock
    // ADC operates from 0.8 to 3.2 MHz
    always @ (posedge clk) begin
        clkCounter = clkCounter + 1;
        if (clkCounter == 33) begin
            SCLK <= !SCLK;
        end
    end

    always @ (SCLK) begin
        if (!resn) begin
            SS <= 1;
            MOSI <= 0;
            state <= 0;
            bitCount <= 0;
        end else begin
            case (state)
                0: begin
                    // Idle
                    if (trig) begin
                        if (SCLK == 0) begin
                            // SS should be lowered on the first falling edge of SCLK
                            SS <= 0;
                            state <= 1;
                            bitCount <= 15;
                        end
                    end
                end

                1: begin
                    if (SCLK == 0) begin
                        // In order to avoid potential race conditions, the
                        // user should generate MOSI on the negative edges of SCLK.
                        MOSI <= wrData[bitCount];
                        bitCount <= bitCount - 1;
                        if (bitCount == 0) begin
                            state <= 2;
                        end
                    end else begin
                        // Capture data bits on the rising edge of SCLK.
                        rdData[bitCount] <= MISO;
                    end
                end

                2: begin
                    if (SCLK == 1) begin
                        // SS should be raised on the last rising edge of an operational frame.
                        SS <= 1;
                        MOSI <= 0;
                        state <= 0;
                        bitCount <= 0;
                    end
                end

                default: ;
            endcase
        end
    end
endmodule
