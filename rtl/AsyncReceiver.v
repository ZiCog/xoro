// Generator : SpinalHDL v1.1.5    git head : 0310b2489a097f2b9de5535e02192d9ddd2764ae
// Date      : 01/12/2018, 09:11:40
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
  wire [7:0] _zz_5;
  wire [4:0] _zz_6;
  wire [4:0] _zz_7;
  wire [7:0] _zz_8;
  wire  _zz_9;
  reg [4:0] head;
  reg [4:0] tail;
  reg  full;
  reg  empty;
  reg  _zz_1;
  reg  _zz_2;
  reg  _zz_3;
  reg  _zz_4;
  reg [7:0] mem [0:31];
  assign _zz_6 = (head + (5'b00001));
  assign _zz_7 = (tail + (5'b00001));
  assign _zz_8 = io_dataIn;
  assign _zz_9 = ((! full) && io_write);
  always @ (posedge clk) begin
    if(_zz_9) begin
      mem[head] <= _zz_8;
    end
  end

  assign _zz_5 = mem[tail];
  assign io_dataOut = _zz_5;
  assign io_empty = empty;
  assign io_full = full;
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      head <= (5'b00000);
      tail <= (5'b00000);
      full <= 1'b0;
      empty <= 1'b1;
    end else begin
      if(((io_write && (! _zz_1)) && (! io_read)))begin
        if((! full))begin
          head <= (head + (5'b00001));
          full <= (_zz_6 == tail);
          empty <= 1'b0;
        end
      end
      if(((! io_write) && (io_read && (! _zz_2))))begin
        if((! empty))begin
          tail <= (tail + (5'b00001));
          empty <= (_zz_7 == head);
          full <= 1'b0;
        end
      end
      if(((io_write && (! _zz_3)) && (io_read && (! _zz_4))))begin
        if(full)begin
          tail <= (tail + (5'b00001));
          full <= 1'b0;
        end
        if(empty)begin
          head <= (head + (5'b00001));
          empty <= 1'b0;
        end
        if(((! full) && (! empty)))begin
          tail <= (tail + (5'b00001));
          head <= (head + (5'b00001));
        end
      end
    end
  end

  always @ (posedge clk) begin
    _zz_1 <= io_write;
    _zz_2 <= io_read;
    _zz_3 <= io_write;
    _zz_4 <= io_read;
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
      input   clk,
      input   reset);
  reg  _zz_8;
  reg  _zz_9;
  wire [7:0] _zz_10;
  wire  _zz_11;
  wire  _zz_12;
  wire  _zz_13;
  wire  _zz_14;
  wire [31:0] _zz_15;
  wire [0:0] _zz_16;
  reg [2:0] state;
  wire [2:0] next_1;
  reg [5:0] bitTimer;
  reg [2:0] bitCount;
  reg [7:0] shifter;
  reg  baudClockX64Sync1;
  reg  baudClockX64Sync2;
  reg  _zz_1;
  reg  _zz_2;
  reg  _zz_3;
  reg  _zz_4;
  reg  _zz_5;
  reg  _zz_6;
  reg [7:0] rdata;
  reg  ready;
  wire  busCycle;
  reg  _zz_7;
  assign _zz_13 = (baudClockX64Sync2 && (! _zz_6));
  assign _zz_14 = (busCycle && (! _zz_7));
  assign _zz_15 = {24'd0, rdata};
  assign _zz_16 = (! _zz_12);
  Fifo fifo_1 ( 
    .io_dataIn(shifter),
    .io_dataOut(_zz_10),
    .io_read(_zz_8),
    .io_write(_zz_9),
    .io_full(_zz_11),
    .io_empty(_zz_12),
    .clk(clk),
    .reset(reset) 
  );
  assign next_1 = (3'b000);
  always @ (*) begin
    _zz_8 = 1'b0;
    if(_zz_14)begin
      case(io_mem_addr)
        4'b0000 : begin
          _zz_8 = 1'b1;
        end
        4'b0100 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @ (*) begin
    _zz_9 = 1'b0;
    case(state)
      3'b000 : begin
      end
      3'b001 : begin
      end
      3'b010 : begin
      end
      3'b011 : begin
      end
      3'b100 : begin
        if(_zz_13)begin
          if((! _zz_11))begin
            _zz_9 = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  assign busCycle = (io_mem_valid && io_enable);
  assign io_mem_rdata = (busCycle ? _zz_15 : (32'b00000000000000000000000000000000));
  assign io_mem_ready = (busCycle ? ready : 1'b0);
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      state <= (3'b000);
      bitTimer <= (6'b000000);
      bitCount <= (3'b000);
      shifter <= (8'b00000000);
      baudClockX64Sync1 <= 1'b0;
      baudClockX64Sync2 <= 1'b0;
      rdata <= (8'b00000000);
      ready <= 1'b0;
    end else begin
      baudClockX64Sync1 <= io_baudClockX64;
      baudClockX64Sync2 <= baudClockX64Sync1;
      if((baudClockX64Sync2 && (! _zz_1)))begin
        bitTimer <= (bitTimer - (6'b000001));
      end
      case(state)
        3'b000 : begin
          state <= (3'b000);
          if((baudClockX64Sync2 && (! _zz_2)))begin
            if((io_rx == 1'b0))begin
              state <= (3'b001);
              bitTimer <= (6'b011111);
            end
          end
        end
        3'b001 : begin
          state <= (3'b001);
          if((baudClockX64Sync2 && (! _zz_3)))begin
            if((bitTimer == (6'b000000)))begin
              if((io_rx == 1'b0))begin
                bitTimer <= (6'b111111);
                state <= (3'b010);
              end else begin
                state <= (3'b000);
              end
            end
          end
        end
        3'b010 : begin
          state <= (3'b010);
          if((baudClockX64Sync2 && (! _zz_4)))begin
            if((bitTimer == (6'b000000)))begin
              shifter[bitCount] <= io_rx;
              bitCount <= (bitCount + (3'b001));
              if((bitCount == (3'b111)))begin
                state <= (3'b011);
              end
            end
          end
        end
        3'b011 : begin
          state <= (3'b011);
          if((baudClockX64Sync2 && (! _zz_5)))begin
            if((bitTimer == (6'b000000)))begin
              if((io_rx == 1'b1))begin
                state <= (3'b100);
              end else begin
                state <= (3'b000);
              end
            end
          end
        end
        3'b100 : begin
          state <= (3'b100);
          if(_zz_13)begin
            state <= (3'b000);
          end
        end
        default : begin
          state <= (3'b000);
        end
      endcase
      ready <= busCycle;
      if(_zz_14)begin
        case(io_mem_addr)
          4'b0000 : begin
            rdata <= _zz_10;
          end
          4'b0100 : begin
            rdata <= {7'd0, _zz_16};
          end
          default : begin
          end
        endcase
      end
    end
  end

  always @ (posedge clk) begin
    _zz_1 <= baudClockX64Sync2;
    _zz_7 <= busCycle;
  end

  always @ (posedge clk) begin
    _zz_2 <= baudClockX64Sync2;
  end

  always @ (posedge clk) begin
    _zz_3 <= baudClockX64Sync2;
  end

  always @ (posedge clk) begin
    _zz_4 <= baudClockX64Sync2;
  end

  always @ (posedge clk) begin
    _zz_5 <= baudClockX64Sync2;
  end

  always @ (posedge clk) begin
    _zz_6 <= baudClockX64Sync2;
  end

endmodule

