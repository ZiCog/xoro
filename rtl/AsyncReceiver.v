// Generator : SpinalHDL v1.1.5    git head : 0310b2489a097f2b9de5535e02192d9ddd2764ae
// Date      : 18/11/2018, 16:11:21
// Component : AsyncReceiver


module Fifo (
      input  [7:0] io_dataIn,
      output [7:0] io_dataOut,
      input   io_read,
      input   io_write,
      output  io_full,
      output  io_empty,
      input   clk,
      input   reset);
  wire [7:0] _zz_1;
  wire [7:0] _zz_2;
  wire  _zz_3;
  reg [4:0] head;
  reg [4:0] tail;
  reg [5:0] count;
  reg  full;
  reg  empty;
  reg [7:0] mem [0:31];
  assign _zz_2 = io_dataIn;
  assign _zz_3 = ((! full) && io_write);
  always @ (posedge clk) begin
    if(_zz_3) begin
      mem[head] <= _zz_2;
    end
  end

  assign _zz_1 = mem[tail];
  assign io_dataOut = _zz_1;
  assign io_empty = empty;
  assign io_full = full;
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      head <= (5'b00000);
      tail <= (5'b00000);
      count <= (6'b000000);
      full <= 1'b0;
      empty <= 1'b1;
    end else begin
      if((io_write && (! io_read)))begin
        if((count != (6'b100000)))begin
          head <= (head + (5'b00001));
          count <= (count + (6'b000001));
          full <= (count == (6'b011111));
          empty <= 1'b0;
        end
      end
      if(((! io_write) && io_read))begin
        if((count != (6'b000000)))begin
          tail <= (tail + (5'b00001));
          count <= (count - (6'b000001));
          empty <= (count == (6'b000001));
          full <= 1'b0;
        end
      end
      if((io_write && io_read))begin
        if(full)begin
          tail <= (tail + (5'b00001));
          count <= (count - (6'b000001));
          full <= 1'b0;
        end
        if(empty)begin
          head <= (head + (5'b00001));
          count <= (count + (6'b000001));
          empty <= 1'b0;
        end
        if(((! full) && (! empty)))begin
          tail <= (tail + (5'b00001));
          head <= (head + (5'b00001));
        end
      end
    end
  end

endmodule

module AsyncReceiver (
      input   io_enable,
      input   io_mem_valid,
      output  io_mem_ready,
      input  [3:0] io_mem_addr,
      output [31:0] io_mem_rdata,
      input   io_baudClockX64,
      input   io_rx,
      output [7:0] io_leds,
      input   clk,
      input   reset);
  reg [7:0] _zz_3;
  reg  _zz_4;
  reg  _zz_5;
  wire [7:0] _zz_6;
  wire  _zz_7;
  wire  _zz_8;
  wire  _zz_9;
  wire  _zz_10;
  wire  _zz_11;
  wire [31:0] _zz_12;
  wire [0:0] _zz_13;
  reg [1:0] state;
  reg [5:0] bitTimer;
  reg [2:0] bitCount;
  reg [7:0] shifter;
  reg [7:0] leds;
  reg  baudClockX64Sync1;
  reg  baudClockX64Sync2;
  reg [31:0] cunt;
  reg  _zz_1;
  reg [7:0] rdata;
  reg  ready;
  wire  busCycle;
  reg  _zz_2;
  assign _zz_9 = (baudClockX64Sync2 && (! _zz_1));
  assign _zz_10 = (busCycle && (! _zz_2));
  assign _zz_11 = (bitTimer == (6'b000000));
  assign _zz_12 = {24'd0, rdata};
  assign _zz_13 = (! _zz_8);
  Fifo fifo_1 ( 
    .io_dataIn(_zz_3),
    .io_dataOut(_zz_6),
    .io_read(_zz_4),
    .io_write(_zz_5),
    .io_full(_zz_7),
    .io_empty(_zz_8),
    .clk(clk),
    .reset(reset) 
  );
  always @ (*) begin
    _zz_4 = 1'b0;
    if(_zz_10)begin
      case(io_mem_addr)
        4'b0000 : begin
          _zz_4 = 1'b1;
        end
        4'b0100 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @ (*) begin
    _zz_5 = 1'b0;
    _zz_3 = (8'b00000000);
    if(_zz_9)begin
      case(state)
        2'b00 : begin
        end
        2'b01 : begin
        end
        2'b10 : begin
        end
        default : begin
          if(_zz_11)begin
            if((io_rx == 1'b1))begin
              if((! _zz_7))begin
                _zz_3 = shifter;
                _zz_5 = 1'b1;
              end
            end
          end
        end
      endcase
    end
  end

  assign io_leds = leds;
  assign busCycle = (io_mem_valid && io_enable);
  assign io_mem_rdata = (busCycle ? _zz_12 : (32'b00000000000000000000000000000000));
  assign io_mem_ready = (busCycle ? ready : 1'b0);
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      state <= (2'b00);
      bitTimer <= (6'b000000);
      bitCount <= (3'b000);
      shifter <= (8'b00000000);
      leds <= (8'b00000000);
      baudClockX64Sync1 <= 1'b0;
      baudClockX64Sync2 <= 1'b0;
      cunt <= (32'b00000000000000000000000000000000);
      rdata <= (8'b00000000);
      ready <= 1'b0;
    end else begin
      baudClockX64Sync1 <= io_baudClockX64;
      baudClockX64Sync2 <= baudClockX64Sync1;
      if(_zz_9)begin
        cunt <= (cunt + (32'b00000000000000000000000000000001));
        bitTimer <= (bitTimer - (6'b000001));
        case(state)
          2'b00 : begin
            if((io_rx == 1'b0))begin
              state <= (2'b01);
              bitTimer <= (6'b011111);
            end
          end
          2'b01 : begin
            if((bitTimer == (6'b000000)))begin
              if((io_rx == 1'b0))begin
                bitTimer <= (6'b111111);
                state <= (2'b10);
              end else begin
                state <= (2'b00);
              end
            end
          end
          2'b10 : begin
            if((bitTimer == (6'b000000)))begin
              shifter[bitCount] <= io_rx;
              bitCount <= (bitCount + (3'b001));
              if((bitCount == (3'b111)))begin
                state <= (2'b11);
              end
            end
          end
          default : begin
            if(_zz_11)begin
              state <= (2'b00);
            end
          end
        endcase
      end
      leds <= {6'd0, state};
      ready <= busCycle;
      if(_zz_10)begin
        case(io_mem_addr)
          4'b0000 : begin
            rdata <= _zz_6;
          end
          4'b0100 : begin
            rdata <= {7'd0, _zz_13};
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @ (posedge clk) begin
    _zz_1 <= baudClockX64Sync2;
    _zz_2 <= busCycle;
  end

endmodule

