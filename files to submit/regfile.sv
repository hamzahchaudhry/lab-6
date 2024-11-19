/*
The datapath consists of one register file 1 containing 8 registers, each holding 16-bits;
three multiplexers 6 shifter unit 7 9 ;
three 16-bit registers with load enable 8 ;
and an arithmetic logic unit (ALU) 3 4 5 ;
a 1-bit register with load enable 2
*/

/*
ensure your regfile module contain internal signals R0,
R1, ... R7 are connected as shown in Figure 4 (do NOT use R0, R1, ... R7 as module instance names).
*/

module regfile(data_in,writenum,write,readnum,clk,data_out);
  input [15:0] data_in;
  input [2:0] writenum, readnum;
  input write, clk;
  output reg [15:0] data_out;

  reg [7:0] decoderOUT; //decoder output
  reg [7:0] decoderOUT2; //second decoder's outputs
  wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7; // register outputs

  decoder firstDec (.inReg(writenum), .outReg(decoderOUT)); //inputting writeNum to decoder
  
  loadEnableCircuit reg0(data_in, (write & decoderOUT[0]), clk, R0);
  loadEnableCircuit reg1(data_in, (write & decoderOUT[1]), clk, R1);
  loadEnableCircuit reg2(data_in, (write & decoderOUT[2]), clk, R2);
  loadEnableCircuit reg3(data_in, (write & decoderOUT[3]), clk, R3);
  loadEnableCircuit reg4(data_in, (write & decoderOUT[4]), clk, R4);
  loadEnableCircuit reg5(data_in, (write & decoderOUT[5]), clk, R5);
  loadEnableCircuit reg6(data_in, (write & decoderOUT[6]), clk, R6);
  loadEnableCircuit reg7(data_in, (write & decoderOUT[7]), clk, R7);

  decoder secondDec(.inReg(readnum),.outReg(decoderOUT2));
  Mux16_8 finalMux (R7, R6, R5, R4, R3, R2, R1, R0, decoderOUT2, data_out);
endmodule

// flip flop
module vDFF1(clk, in, out) ;
  parameter n = 1;  // width
  input clk ;
  input [n-1:0] in ;
  output [n-1:0] out ;
  reg [n-1:0] out ;

  always_ff @(posedge clk)
    out = in ;
endmodule 

// load enable circuit
module loadEnableCircuit(in, load, clk, out);
  input [15:0] in;
  input load, clk;
  output [15:0] out;
  wire [15:0] next = load ? in : out;

  vDFF1 #(16) flipflop(clk, next, out);
endmodule

//16-bit 8 input mux
module Mux16_8(R7, R6, R5, R4, R3, R2, R1, R0, onehotreadnum, data_out) ;
  input [15:0] R7, R6, R5, R4, R3, R2, R1, R0;  // inputs
  input [7:0] onehotreadnum; // one-hot select
  output reg [15:0] data_out ;

  always_comb begin
    case (onehotreadnum)
        8'b00000001: data_out = R0;
        8'b00000010: data_out = R1;
        8'b00000100: data_out = R2;
        8'b00001000: data_out = R3;
        8'b00010000: data_out = R4;
        8'b00100000: data_out = R5;
        8'b01000000: data_out = R6;
        8'b10000000: data_out = R7;
        default: data_out = 16'bxxxxxxxxxxxxxxxx;
    endcase
  end
endmodule


//3:8 decoder 
module decoder (inReg, outReg);
    input [2:0] inReg;
    output [7:0] outReg;
    reg [7:0] outReg;
    
    always@(*)begin
      case(inReg)
      3'b000: outReg = 8'b000_000_01;
      3'b001: outReg = 8'b000_000_10;
      3'b010: outReg = 8'b000_001_00;
      3'b011: outReg = 8'b000_010_00;
      3'b100: outReg = 8'b000_100_00;
      3'b101: outReg = 8'b001_000_00;
      3'b110: outReg = 8'b010_000_00;
      3'b111: outReg = 8'b100_000_00;
      default: outReg = 8'bxxx_xxx_xx;
    endcase
  end
endmodule
