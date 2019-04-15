// Generator : SpinalHDL v1.1.5    git head : 0310b2489a097f2b9de5535e02192d9ddd2764ae
// Date      : 15/04/2019, 21:20:08
// Component : Memory


module Memory (
      input   io_enable,
      input   io_mem_valid,
      input   io_mem_instr,
      input  [3:0] io_mem_wstrb,
      input  [31:0] io_mem_wdata,
      input  [15:0] io_mem_addr,
      output [31:0] io_mem_rdata,
      output  io_mem_ready,
      input   clk,
      input   reset);
  wire [31:0] _zz_1;
  wire [31:0] _zz_2;
  wire [3:0] _zz_3;
  wire  _zz_4;
  reg [31:0] rdata;
  reg  ready;
  wire [13:0] addr;
  reg [7:0] memory_1_symbol0 [0:1024*10];
  reg [7:0] memory_1_symbol1 [0:1024*10];
  reg [7:0] memory_1_symbol2 [0:1024*10];
  reg [7:0] memory_1_symbol3 [0:1024*10];
  assign _zz_2 = io_mem_wdata;
  assign _zz_3 = io_mem_wstrb;
  assign _zz_4 = (io_enable && io_mem_valid);
  initial begin
    $readmemb("Memory.v_toplevel_memory_1_symbol0.bin",memory_1_symbol0);
    $readmemb("Memory.v_toplevel_memory_1_symbol1.bin",memory_1_symbol1);
    $readmemb("Memory.v_toplevel_memory_1_symbol2.bin",memory_1_symbol2);
    $readmemb("Memory.v_toplevel_memory_1_symbol3.bin",memory_1_symbol3);
  end
  always @ (posedge clk) begin
    if(_zz_3[0] && _zz_4) begin
      memory_1_symbol0[addr] <= _zz_2[7 : 0];
    end
    if(_zz_3[1] && _zz_4) begin
      memory_1_symbol1[addr] <= _zz_2[15 : 8];
    end
    if(_zz_3[2] && _zz_4) begin
      memory_1_symbol2[addr] <= _zz_2[23 : 16];
    end
    if(_zz_3[3] && _zz_4) begin
      memory_1_symbol3[addr] <= _zz_2[31 : 24];
    end
  end

  assign _zz_1[7 : 0] = memory_1_symbol0[addr];
  assign _zz_1[15 : 8] = memory_1_symbol1[addr];
  assign _zz_1[23 : 16] = memory_1_symbol2[addr];
  assign _zz_1[31 : 24] = memory_1_symbol3[addr];
  assign addr = (io_mem_addr >>> 2);
  always @ (*) begin
    if((io_enable && io_mem_valid))begin
      rdata = _zz_1;
      ready = 1'b1;
    end else begin
      rdata = (32'b00000000000000000000000000000000);
      ready = 1'b0;
    end
  end

  assign io_mem_ready = ready;
  assign io_mem_rdata = rdata;
endmodule

