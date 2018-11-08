// Generator : SpinalHDL v1.1.5    git head : 0310b2489a097f2b9de5535e02192d9ddd2764ae
// Date      : 09/11/2018, 00:30:38
// Component : AsyncReceiver


module EdgeDetect_ (
      input   io_trigger,
      output  io_Q,
      input   clk,
      input   reset);
  reg  oldTrigger;
  assign io_Q = (io_trigger && (! oldTrigger));
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      oldTrigger <= 1'b0;
    end else begin
      oldTrigger <= io_trigger;
    end
  end

endmodule

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
  wire [4:0] _zz_2;
  wire [4:0] _zz_3;
  wire [7:0] _zz_4;
  wire  _zz_5;
  reg [4:0] head;
  reg [4:0] tail;
  reg  full;
  reg  empty;
  reg [7:0] mem [0:31];
  assign _zz_2 = (head + (5'b00001));
  assign _zz_3 = (tail + (5'b00001));
  assign _zz_4 = io_dataIn;
  assign _zz_5 = ((! full) && io_write);
  always @ (posedge clk) begin
    if(_zz_5) begin
      mem[head] <= _zz_4;
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
      full <= 1'b0;
      empty <= 1'b1;
    end else begin
      if((io_write && (! io_read)))begin
        if((! full))begin
          head <= (head + (5'b00001));
          full <= (_zz_2 == tail);
          empty <= 1'b0;
        end
      end
      if(((! io_write) && io_read))begin
        if((! empty))begin
          tail <= (tail + (5'b00001));
          empty <= (_zz_3 == head);
          full <= 1'b0;
        end
      end
      if((io_write && io_read))begin
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

endmodule

module AsyncReceiver (
      input   io_enable,
      input   io_mem_valid,
      output reg  io_mem_ready,
      input  [3:0] io_mem_addr,
      output reg [31:0] io_mem_rdata,
      input   io_baudClockX64,
      input   io_rx,
      input   clk,
      input   reset);
  reg  _zz_1;
  reg  _zz_2;
  wire  _zz_3;
  wire [7:0] _zz_4;
  wire  _zz_5;
  wire  _zz_6;
  wire  _zz_7;
  wire  _zz_8;
  wire [0:0] _zz_9;
  reg [1:0] state;
  reg [5:0] bitTimer;
  reg [2:0] bitCount;
  reg [7:0] shifter;
  reg [7:0] buffer_1;
  wire  baudClockEdge;
  assign _zz_7 = (bitTimer == (6'b000000));
  assign _zz_8 = (io_rx == 1'b1);
  assign _zz_9 = (! _zz_6);
  EdgeDetect_ baudClockX64Edge ( 
    .io_trigger(io_baudClockX64),
    .io_Q(_zz_3),
    .clk(clk),
    .reset(reset) 
  );
  Fifo fifo_1 ( 
    .io_dataIn(buffer_1),
    .io_dataOut(_zz_4),
    .io_read(_zz_1),
    .io_write(_zz_2),
    .io_full(_zz_5),
    .io_empty(_zz_6),
    .clk(clk),
    .reset(reset) 
  );
  assign baudClockEdge = _zz_3;
  always @ (*) begin
    _zz_2 = 1'b0;
    if(baudClockEdge)begin
      case(state)
        2'b00 : begin
        end
        2'b01 : begin
        end
        2'b10 : begin
        end
        default : begin
          if(_zz_7)begin
            if(_zz_8)begin
              _zz_2 = 1'b1;
            end
          end
        end
      endcase
    end
  end

  always @ (*) begin
    _zz_1 = 1'b0;
    io_mem_rdata = (32'b00000000000000000000000000000000);
    io_mem_ready = 1'b0;
    if((io_mem_valid && io_enable))begin
      io_mem_ready = 1'b1;
      case(io_mem_addr)
        4'b0000 : begin
          io_mem_rdata = {24'd0, buffer_1};
          _zz_1 = 1'b1;
        end
        4'b0100 : begin
          io_mem_rdata = {31'd0, _zz_9};
        end
        default : begin
        end
      endcase
    end
  end

  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      state <= (2'b00);
      bitTimer <= (6'b000000);
      bitCount <= (3'b000);
      shifter <= (8'b00000000);
      buffer_1 <= (8'b00000000);
    end else begin
      if(baudClockEdge)begin
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
            if(_zz_7)begin
              if(_zz_8)begin
                buffer_1 <= shifter;
              end
              state <= (2'b00);
            end
          end
        endcase
      end
    end
  end

endmodule

