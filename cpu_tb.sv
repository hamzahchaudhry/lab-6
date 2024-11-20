module cpu_tb;
  reg clk, reset, s, load;
  reg [15:0] in;
  wire [15:0] out;
  wire N,V,Z,w;

  reg err;

  cpu DUT(clk,reset,s,load,in,out,N,V,Z,w);

  initial begin
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end

  initial begin
    err = 0;
    reset = 1; s = 0; load = 0; in = 16'b0;
    #10;
    reset = 0;
    #10;

    // MOV R0, #255
    in = 16'b1101000011111111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (lab6_check.DUT.DP.REGFILE.R0 !== 16'h255) begin
      err = 1;
      $display("FAILED: MOV R0, #255, expected R0 = 255, instead %d", DUT.DP.REGFILE.R0);
      $stop;
    end

    @(negedge clk); // wait for falling edge of clock before changing inputs
    // MOV R1, [R0, LSL #1]
    in = 16'b110_00_000_01_01_11;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (lab6_check.DUT.DP.REGFILE.R2 !== 16'b10) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0, LSL#1");
      $stop;
    end


    @(negedge clk); // wait for falling edge of clock before changing inputs
    // AND  
    in = 16'b101_11_000_01_01_11;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (lab6_check.DUT.DP.REGFILE.R2 !== 16'b10) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0, LSL#1");
      $stop;
    end
    

    $stop;
  end
endmodule
