// Generator : SpinalHDL v1.1.5    git head : 0310b2489a097f2b9de5535e02192d9ddd2764ae
// Date      : 13/11/2018, 18:51:12
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
  wire  _zz_1;
  wire  _zz_2;
  wire [0:0] _zz_3;
  reg [1:0] state;
  reg [5:0] bitTimer;
  reg [2:0] bitCount;
  reg [7:0] shifter;
  reg [7:0] buffer_1;
  reg  bufferFull;
  wire  baudClockEdge;
  assign _zz_2 = (io_mem_valid && io_enable);
  assign _zz_3 = bufferFull;
  EdgeDetect_ baudClockX64Edge ( 
    .io_trigger(io_baudClockX64),
    .io_Q(_zz_1),
    .clk(clk),
    .reset(reset) 
  );
  assign baudClockEdge = _zz_1;
  always @ (*) begin
    io_mem_rdata = (32'b00000000000000000000000000000000);
    io_mem_ready = 1'b0;
    if(_zz_2)begin
      io_mem_ready = 1'b1;
      case(io_mem_addr)
        4'b0000 : begin
          io_mem_rdata = {24'd0, buffer_1};
        end
        4'b0100 : begin
          io_mem_rdata = {31'd0, _zz_3};
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
      bufferFull <= 1'b0;
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
            if((bitTimer == (6'b000000)))begin
              if((io_rx == 1'b1))begin
                buffer_1 <= shifter;
                bufferFull <= 1'b1;
              end
              state <= (2'b00);
            end
          end
        endcase
      end
      if(_zz_2)begin
        case(io_mem_addr)
          4'b0000 : begin
            bufferFull <= 1'b0;
          end
          4'b0100 : begin
          end
          default : begin
          end
        endcase
      end
    end
  end

endmodule

