/* Bus Interface.

   Use like so

	 wire [31:0] mem_rdata_memory;
	 wire [31:0] mem_rdata_timer;
	 wire [31:0] mem_rdata_uart;
	 wire [31:0] mem_rdata_prng;
	 wire [31:0] mem_rdata_gpio;

	 wire [31:0] mem_ready_memory;
	 wire [31:0] mem_ready_timer;
	 wire [31:0] mem_ready_uart;
	 wire [31:0] mem_ready_prng;
	 wire [31:0] mem_ready_gpio;
	 
	 
	 
    busInterface busInterface (
        .clk(CLOCK),
        .resetn(resetn),
	 
		  .mem_addr(mem_addr),

		  .mem_rdata_gpio(mem_rdata_gpio),
		  .mem_rdata_uart(mem_rdata_uart),
		  .mem_rdata_timer(mem_rdata_timer),
		  .mem_rdata_prng(mem_rdata_prng),
		  .mem_rdata_memory(mem_rdata_memory),

		  .mem_ready_gpio(mem_ready_gpio),
		  .mem_ready_uart(mem_ready_uart),
		  .mem_ready_timer(mem_ready_timer),
		  .mem_ready_prng(mem_ready_prng),
		  .mem_ready_memory(mem_ready_memory),
			 
		  .mem_ready(mem_ready),
		  .mem_rdata(mem_rdata),
		  .enables(enables) 
	 );

*/



module busInterface (
    input  wire        clk,
    input  wire        resetn,
	 
	 
	 input  wire [31:0] mem_addr,

    input  wire [31:0] mem_rdata_gpio,
    input  wire [31:0] mem_rdata_uart,
    input  wire [31:0] mem_rdata_timer,
    input  wire [31:0] mem_rdata_prng,
    input  wire [31:0] mem_rdata_memory,

    input  wire        mem_ready_gpio,
    input  wire        mem_ready_uart,
    input  wire        mem_ready_timer,
    input  wire        mem_ready_prng,
    input  wire        mem_ready_memory,
	 	 
    output reg         mem_ready,
    output reg  [31:0] mem_rdata,
	 output reg  [7:0]  enables 

);

    always @(posedge clk) begin
	     if (!resetn) begin
		      enables <= 8'd0;
				mem_ready <= 1'd0;
				mem_rdata <= 32'd0;
		  end else begin
			  enables = 0;
			  case (mem_addr[31:4])
					28'hffff000: enables[0] <= 1'd1;
					28'hffff001: enables[1] <= 1'd1;
					28'hffff002: enables[2] <= 1'd1;
					28'hffff003: enables[3] <= 1'd1;
					28'hffff004: enables[4] <= 1'd1;
					28'hffff005: enables[5] <= 1'd1;
					28'hffff006: enables[6] <= 1'd1;
					default: enables[7] <= 1'd1;
			  endcase
		
			  case (mem_addr[31:4])
					28'hffff000: mem_ready <= mem_ready_memory;
					28'hffff001: mem_ready <= mem_ready_memory;
					28'hffff002: mem_ready <= mem_ready_memory;
					28'hffff003: mem_ready <= mem_ready_timer;
					28'hffff004: mem_ready <= mem_ready_uart;
					28'hffff005: mem_ready <= mem_ready_prng;
					28'hffff006: mem_ready <= mem_ready_gpio;
					default: mem_ready <= mem_ready_memory;
			  endcase
		 
			  case (mem_addr[31:4])
					28'hffff000: mem_rdata <= mem_rdata_memory;
					28'hffff001: mem_rdata <= mem_rdata_memory;
					28'hffff002: mem_rdata <= mem_rdata_memory;
					28'hffff003: mem_rdata <= mem_rdata_timer;
					28'hffff004: mem_rdata <= mem_rdata_uart;
					28'hffff005: mem_rdata <= mem_rdata_prng;
					28'hffff006: mem_rdata <= mem_rdata_gpio;
					default: mem_rdata = mem_rdata_memory;
			  endcase
		 end
    end
endmodule


