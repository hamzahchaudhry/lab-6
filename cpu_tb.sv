// WARNING: This is NOT the autograder that will be used mark you.  
// Passing the checks in this file does NOT (in any way) guarantee you 
// will not lose marks when your code is run through the actual autograder.  
// You are responsible for designing your own test benches to verify you 
// match the specification given in the lab handout.

// To work with our autograder you MUST be able to get your cpu.v to work
// without making ANY changes to this file.  Refer to Section 4 in the Lab
// 6 handout for more details.

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

    in = 16'b1101000000000111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'h7) begin
      err = 1;
      $display("FAILED: MOV R0, #7");
      $stop;
    end

    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1101000100000010;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'h2) begin
      err = 1;
      $display("FAILED: MOV R1, #2");
      $stop;
    end

    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b1010000101001000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'h10) begin
      err = 1;
      $display("FAILED: ADD R2, R1, R0, LSL#1");
      $stop;
    end
    if (~err) $display("TEST 1 PASSED");

    //NEW TEST ANDING 15 AND 120

    err = 0;
    reset = 1; s = 0; load = 0; in = 16'b0;
    #10;
    reset = 0; 
    #10;

    in = 16'b110_10_000_00001111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'b00000000_00001111) begin
      err = 1;
      $display("FAILED: MOV R0, #15");
      $stop;
    end else begin
      $display("Passed: MOV R0, #15");
    end

    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b110_10_001_01111000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'b00000000_01111000) begin
      err = 1;
      $display("FAILED: MOV R1, #120");
      $stop;
    end else begin
      $display("Passed: MOV R1, #120");
    end

    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b101_10_000_010_00_001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'b00000000_00001000) begin
      err = 1;
      $display("FAILED: AND R2, R1, R0, LSL#0");
      $stop;
    end
    if (~err) $display("TEST 2 PASSED");


    //NEW TEST ANDING 15 AND 120 SHIFTED TO THE RIGHT

    err = 0;
    reset = 1; s = 0; load = 0; in = 16'b0;
    #10;
    reset = 0; 
    #10;

    in = 16'b110_10_000_00001111;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R0 !== 16'b00000000_00001111) begin
      err = 1;
      $display("FAILED: MOV R0, #15");
      $stop;
    end else begin
      $display("Passed: MOV R0, #15");
    end

    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b110_10_001_01111000;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'b00000000_01111000) begin
      err = 1;
      $display("FAILED: MOV R1, #120");
      $stop;
    end else begin
      $display("Passed: MOV R1, #120");
    end

    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b101_10_000_010_10_001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'b00000000_00001100) begin
      err = 1;
      $display("FAILED: AND R2, R1, R0, LSL#1");
      $stop;
    end
    if (~err) $display("TEST 3 PASSED");


    //NEW TEST MOVshift on R1
    //CURRENTLY R2 = 0000000000001100
    //CURRENTLY R1 = 0000000001111000
    //CURRENTLY R0 = 0000000000001111

    err = 0;
    reset = 1; s = 0; load = 0; in = 16'b0;
    #10;
    reset = 0; 
    #10;

    $display("R2 = %b,  R1 = %b, R0 = %b ", cpu_tb.DUT.DP.REGFILE.R2,cpu_tb.DUT.DP.REGFILE.R1,cpu_tb.DUT.DP.REGFILE.R0);


    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b110_00_000_001_10_001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R1 !== 16'b00000000_00111100) begin
      err = 1;
      $display("FAILED: MOVsh R1, R1, LSR#1 actually R1=%b", cpu_tb.DUT.DP.REGFILE.R1);
      $stop;
    end
    if (~err) $display("TEST 4 PASSED");


    //NEW TEST MVN 0 expect -1
    //CURRENTLY R2 = 0000000000001100
    //CURRENTLY R1 = 00000000_00111100
    //CURRENTLY R0 = 0000000000001111

    @(negedge clk); // wait for falling edge of clock before changing inputs
    in = 16'b101_11_000_010_00_001;
    load = 1;
    #10;
    load = 0;
    s = 1;
    #10
    s = 0;
    @(posedge w); // wait for w to go high again
    #10;
    if (cpu_tb.DUT.DP.REGFILE.R2 !== 16'b1111_1111_1100_0011) begin
      err = 1;
      $display("FAILED: MVN R2, R1, LSR#0 actually R2=%b", cpu_tb.DUT.DP.REGFILE.R2);
      $stop;
    end
    if (~err) $display("TEST 5 PASSED");
    


    $stop;
  end
endmodule

