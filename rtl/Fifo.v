// Generator : SpinalHDL v1.1.5    git head : 0310b2489a097f2b9de5535e02192d9ddd2764ae
// Date      : 12/11/2018, 20:09:50
// Component : Fifo


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
  reg [5:0] head;
  reg [5:0] tail;
  reg  full;
  reg  empty;
  wire [5:0] headNext;
  wire [5:0] tailNext;
  wire  writing;
  wire  reading;
  wire  readingWriting;
  reg [7:0] mem [0:63];
  assign _zz_2 = io_dataIn;
  assign _zz_3 = ((! full) && io_write);
  always @ (posedge clk) begin
    if(_zz_3) begin
      mem[head] <= _zz_2;
    end
  end

  assign _zz_1 = mem[tail];
  assign headNext = (head + (6'b000001));
  assign tailNext = (tail + (6'b000001));
  assign writing = (io_write && (! io_read));
  assign reading = ((! io_write) && io_read);
  assign readingWriting = (io_write && io_read);
  assign io_dataOut = _zz_1;
  assign io_empty = empty;
  assign io_full = full;
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      head <= (6'b000000);
      tail <= (6'b000000);
      full <= 1'b0;
      empty <= 1'b1;
    end else begin
      if(writing)begin
        if((! full))begin
          head <= headNext;
          full <= (headNext == tail);
          empty <= 1'b0;
        end
      end
      if(reading)begin
        if((! empty))begin
          tail <= tailNext;
          empty <= (tailNext == head);
          full <= 1'b0;
        end
      end
      if(readingWriting)begin
        if(full)begin
          tail <= tailNext;
          full <= 1'b0;
        end
        if(empty)begin
          head <= headNext;
          empty <= 1'b0;
        end
        if(((! full) && (! empty)))begin
          tail <= tailNext;
          head <= headNext;
        end
      end
    end
  end

endmodule

