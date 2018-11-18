//
// xoro_top.v
//
// For all DE0-Nano pin outs the file DE0_NANO.qsf
//
`include "inc/timescale.vh"



// Generate a 1 clock wide "tick" pulse every 100ms.
module hundredMsTick (
		      input wire  clk,
		      input wire  resetn,
		      output wire tick
		      );
   reg [31:0] 			  timer;
   
   always @(posedge clk) begin
      if (!resetn) begin
         timer <= 5000000;
      end else begin
         if (timer == 0) begin
            timer <= 5000000;
         end else begin
            timer <= timer - 1;
         end
      end
   end

   assign tick = (timer == 0);
endmodule


module gpio_test (
		  // Bus interface
		  input wire 	     clk,
		  input wire 	     resetn,

		  output wire 	     mem_valid,
		  input wire 	     mem_ready,
		  output wire 	     mem_instr,

		  output wire [31:0] mem_addr,
		  output wire [3:0]  mem_wstrb,
		  output wire [31:0] mem_wdata,
		  input wire [31:0]  mem_rdata,

		  input wire 	     tick
		  );
   
   reg [3:0] 			     counter;
   
   
   always @(posedge clk) begin
      if (!resetn) begin
         counter <= 0;
      end else begin
         if (tick) begin
            counter <= counter + 4'd1;
         end
      end
   end
   
   
   assign mem_valid = tick;
   assign mem_instr = 1'b0;
   
   assign mem_addr =  tick ? 32'hffff0060 : 32'b0;
   assign mem_wstrb = tick ? 4'b1 : 4'b0;
   assign mem_wdata = tick ? counter : 32'b0;

endmodule



module uart_test (
		  input wire 	     clk,
		  input wire 	     resetn,

		  // Bus interface
		  output wire 	     mem_valid,
		  input wire 	     mem_ready,
		  output wire 	     mem_instr,

		  output wire [31:0] mem_addr,
		  output wire [3:0]  mem_wstrb,
		  output wire [31:0] mem_wdata,
		  input wire [31:0]  mem_rdata,

		  input wire 	     tick
		  );
   wire [7:0] 			     msg [0:15];
   assign msg[0]  = "H";
   assign msg[1]  = "e";
   assign msg[2]  = "l";
   assign msg[3]  = "l";
   assign msg[4]  = "o";
   assign msg[5]  = " ";
   assign msg[6]  = "W";
   assign msg[7]  = "o";
   assign msg[8]  = "r";
   assign msg[9]  = "l";
   assign msg[10] = "d";
   assign msg[11] = "!";
   assign msg[12] = 8'h0a;
   assign msg[13] = 8'h0d;
   assign msg[14] = 8'h00;
   assign msg[15] = 8'h00;
   
   reg [3:0] 			     index;
   
   
   always @(posedge clk) begin
      if (!resetn) begin
         index <= 0;
      end else begin
         if (tick) begin
            index <= index + 4'd1;
         end
      end
   end
   
   
   assign mem_valid = tick;
   assign mem_instr = 1'b0;
   
   assign mem_addr =  tick ? 32'hffff0040 : 32'b0;
   assign mem_wstrb = tick ? 4'b1 : 4'b0;
   assign mem_wdata = tick ? msg[index] : 32'b0;

endmodule



module xoro_top (input CLOCK_50,
                 input reset_btn,
					  output[7:0] LED,
					  output UART_TX,
					  input UART_RX,
					  output GPIO_1_D[33:0]
		 );

   wire        trap;

   wire        mem_valid;
   wire        mem_instr;
   wire        mem_ready;

   wire [31:0] mem_addr;
   wire [31:0] mem_wdata;
   wire [3:0]  mem_wstrb;
   wire [31:0] mem_rdata;

   // Look-Ahead Interface
   wire        mem_la_read;
   wire        mem_la_write;
   wire [31:0] mem_la_addr;
   wire [31:0] mem_la_wdata;
   wire [3:0]  mem_la_wstrb;

   wire        pcpi_valid;
   wire [31:0] pcpi_insn;
   wire [31:0] pcpi_rs1;
   wire [31:0] pcpi_rs2;
   reg         pcpi_wr;
   reg [31:0]  pcpi_rd;
   reg         pcpi_wait;
   reg         pcpi_ready;

   // IRQ Interface
   reg [31:0]  irq;
   wire [31:0] eoi;

   // Trace Interface
   wire        trace_valid;
   wire [35:0] trace_data;

   // Peripheral enables
   wire [7:0]  enables;

   reg 	       resetn = 0;
   reg [7:0]   resetCount = 0;

   wire        CLOCK;
   wire        CLOCK_100;
   wire        CLOCK_7372800;         // 64 times 115200 baud.
   wire        CLOCK_BAUD_18432000;   // 16 times 115200 baud.
   wire        CLOCK_LOCKED;

   
   always @(posedge CLOCK)
     begin
        resetCount <= resetCount + 8'd1;
        if (resetCount == 100) resetn <= 1;
     end

`ifndef SIMULATION
   // Generate 100MHz and 10MHz clocks
   // See Quartus PLL tutorial here: http://www.emb4fun.de/fpga/nutos1/
   pll_sys pll_sys_inst (
			 .inclk0 (CLOCK_50),      // The input clok
			 .c0 (CLOCK_100),         // 100MHz clock
			 .c1 (CLOCK_7372800),     // 64 times 115200 baud.
			 .c2 (CLOCK_1843200),     // 16 times 115200 baud.
			 .locked (CLOCK_LOCKED)   // PLL is locked signal
			 );
   assign CLOCK = CLOCK_100;
`else
   assign CLOCK = CLOCK_50;
`endif

   wire probe;
   assign GPIO_1_D[33] = probe;
   assign GPIO_1_D[31] = UART_RX;



   gpio gpio (
              .clk(CLOCK),
              .resetn(resetn),

              .enable(enables[6]),
              .mem_valid(mem_valid),
              .mem_ready(mem_ready_gpio),
              .mem_instr(mem_instr),

              .mem_addr(mem_addr),
              .mem_wstrb(mem_wstrb),
              .mem_wdata(mem_wdata),
              .mem_rdata(mem_rdata_gpio),

              //.gpio(LED)
	      );

   uartTx uartTx (
		  .clk(CLOCK),
		  .resetn(resetn),
      
		  .enable(enables[4]),
		  .mem_valid(mem_valid),
		  .mem_ready(mem_ready_uart),
		  .mem_instr(mem_instr),
      
		  .mem_addr(mem_addr),
		  .mem_wstrb(mem_wstrb),
		  .mem_wdata(mem_wdata),
		  .mem_rdata(mem_rdata_uart),

		  
		  .baudClock(CLOCK_1843200),
		  .probe(probe),
		  
		  .serialOut(UART_TX)
		  );
   
	AsyncReceiver uartRx (
      .clk(CLOCK),
		.reset(!resetn),

	   .io_enable(enables[2]),
      .io_mem_valid(mem_valid),
      .io_mem_ready(mem_ready_uartRx),
      .io_mem_addr(mem_addr),
      .io_mem_rdata(mem_rdata_uartRx),
      .io_baudClockX64(CLOCK_7372800),
      .io_rx(UART_RX),
		.io_leds(LED)
   );
	
	wire testTick;
   wire uartTestTick;
   wire gpioTestTick;

   hundredMsTick hundredMsTick (
				.clk(CLOCK),
				.resetn(resetn),

				.tick(testTick)
				);

   
   /*
    gpio_test gpio_test (
    .clk(CLOCK),
    .resetn(resetn),
    
    .mem_valid(mem_valid),
    .mem_ready(mem_ready),
    .mem_instr(mem_instr),

    .mem_addr(mem_addr),
    .mem_wstrb(mem_wstrb),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    
    .tick(testTick)
    );    

    uart_test uart_test (
    .clk(CLOCK),
    .resetn(resetn),
    
    .mem_valid(mem_valid),
    .mem_ready(mem_ready),
    .mem_instr(mem_instr),

    .mem_addr(mem_addr),
    .mem_wstrb(mem_wstrb),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata),
    
    .tick(testTick)
    );    
    */
   

   memory mem (
               .clk(CLOCK),
               .enable(enables[7]),
               .mem_valid(mem_valid),
               .mem_ready(mem_ready_memory),
               .mem_instr(mem_instr),
               .mem_wstrb(mem_wstrb),
               .mem_wdata(mem_wdata),
               .mem_addr(mem_addr),
               .mem_rdata(mem_rdata_memory)
	       );


   prng prng (
              .clk(CLOCK),
              .resetn(resetn),
              .enable(enables[5]),
              .mem_valid(mem_valid),
              .mem_ready(mem_ready_prng),
              .mem_instr(mem_instr),
              .mem_wstrb(mem_wstrb),
              .mem_wdata(mem_wdata),
              .mem_addr(mem_addr),
              .mem_rdata(mem_rdata_prng)
	      );


   timer timer (
		.clk(CLOCK),
		.resetn(resetn),
		.enable(enables[3]),
		.mem_valid(mem_valid),
		.mem_ready(mem_ready_timer),
		.mem_instr(mem_instr),
		.mem_wstrb(mem_wstrb),
		.mem_wdata(mem_wdata),
		.mem_addr(mem_addr),
		.mem_rdata(mem_rdata_timer)
		);

   
   // Peripheral's mem_ready amd mem_data.  
   wire mem_ready_uartRx;
   wire mem_ready_uart;
   wire mem_ready_gpio;
   wire mem_ready_prng;
   wire mem_ready_timer;
   wire mem_ready_memory;
   wire [31:0] mem_rdata_uartRx;
   wire [31:0] mem_rdata_uart;
   wire [31:0] mem_rdata_gpio;
   wire [31:0] mem_rdata_prng;
   wire [31:0] mem_rdata_timer;
   wire [31:0] mem_rdata_memory;
   
   busInterface busInterface (
			      //        .clk(CLOCK),
			      //        .resetn(resetn),
      
			      .mem_addr(mem_addr),

			      .mem_rdata_gpio(mem_rdata_gpio),
			      .mem_rdata_uart(mem_rdata_uart),
			      .mem_rdata_uartRx(mem_rdata_uartRx),
			      .mem_rdata_timer(mem_rdata_timer),
			      .mem_rdata_prng(mem_rdata_prng),
			      .mem_rdata_memory(mem_rdata_memory),

			      .mem_ready_gpio(mem_ready_gpio),
			      .mem_ready_uart(mem_ready_uart),
			      .mem_ready_uartRx(mem_ready_uartRx),
			      .mem_ready_timer(mem_ready_timer),
			      .mem_ready_prng(mem_ready_prng),
			      .mem_ready_memory(mem_ready_memory),
      
			      .mem_ready(mem_ready),
			      .mem_rdata(mem_rdata),
			      .enables(enables) 
			      );

   
   defparam cpu.ENABLE_COUNTERS = 0;
   defparam cpu.ENABLE_COUNTERS64 = 0;
   defparam cpu.BARREL_SHIFTER = 1;
   defparam cpu.TWO_CYCLE_COMPARE = 0;
   defparam cpu.TWO_CYCLE_ALU = 0;
   defparam cpu.ENABLE_PCPI = 0;        //
   defparam cpu.ENABLE_FAST_MUL = 1;    // MUL and DIV cost 564 LE and !
   defparam cpu.ENABLE_DIV = 1;         //

   picorv32 cpu (
		 .clk(CLOCK),
		 .resetn(resetn),
		 .trap(trap),

		 .mem_valid(mem_valid),
		 .mem_instr(mem_instr),
		 .mem_ready(mem_ready),

		 .mem_addr(mem_addr),
		 .mem_wdata(mem_wdata),
		 .mem_wstrb(mem_wstrb),
		 .mem_rdata(mem_rdata),

		 // Look-Ahead Interface
		 .mem_la_read(mem_la_read),
		 .mem_la_write(mem_la_write),
		 .mem_la_addr(mem_la_addr),
		 .mem_la_wdata(mem_la_wdata),
		 .mem_la_wstrb(mem_la_wstrb),

		 // Pico Co-Processor Interface (PCPI)
		 .pcpi_valid(pcpi_valid),
		 .pcpi_insn(pcpi_insn),
		 .pcpi_rs1(pcpi_rs1),
		 .pcpi_rs2(pcpi_rs2),
		 .pcpi_wr(pcpi_wr),
		 .pcpi_rd(pcpi_rd),
		 .pcpi_wait(pcpi_wait),
		 .pcpi_ready(pcpi_ready),

		 // IRQ Interface
		 .irq(irq),
		 .eoi(eoi),

		 // Trace Interface
		 .trace_valid(trace_valid),
		 .trace_data(trace_data)
		 );


endmodule
