module datapath_tb();
  reg clk;
  reg [2:0] readnum, writenum;
  reg [15:0] datapath_in;
  reg [1:0] ALUop, shift;
  reg asel, bsel, vsel, loada, loadb, loadc, loads, write;
  wire Z_out;
  wire [15:0] datapath_out;
  reg err;

  datapath DUT (
    .clk(clk),
    .readnum(readnum),
    .vsel(vsel),
    .loada(loada),
    .loadb(loadb),
    .shift(shift),
    .asel(asel),
    .bsel(bsel),
    .ALUop(ALUop),
    .loadc(loadc),
    .loads(loads),
    .writenum(writenum),
    .write(write),
    .datapath_in(datapath_in),
    .Z_out(Z_out),
    .datapath_out(datapath_out)
  );

  initial begin
    clk = 0;
    forever #10 clk = ~clk;  // 10 time units period
  end

  initial begin
    err = 0;

    // Test 1: Write 42 to register 3 and read back
    #5;
    datapath_in = 16'h002A;    // Set datapath_in to 42
    writenum = 3'b011;         // Select register 3
    write = 1'b1;              // Enable write
    vsel = 1'b1;               // Select datapath_in as source for write

    #20;
    write = 1'b0;

    // Test 2: Check if register 3 holds 42
    readnum = 3'b011;
    loadb = 1'b1;

    #10;
    if (DUT.REGFILE.data_out !== 16'h002A) begin
      $display("ERROR! expected data_out = 42, actually %d", DUT.REGFILE.data_out);
      err = 1;
    end

    loadb = 0;

    // Test 3: Check loada signal functionality
    loada = 1'b1;
    readnum = 3'b011;

    #10;
    loada = 0;
    #10;
    if (DUT.A !== 16'h002A) begin
      $display("ERROR! A register did not load correctly with loada asserted");
      err = 1;
    end

    // Verify that A does not change without loada asserted
    readnum = 3'b101;
    loada = 0;

    #20;
    if (DUT.A !== 16'h002A) begin
      $display("ERROR! A register changed value without loada asserted");
      err = 1;
    end

    // Test 4: Check loadb signal functionality
    loadb = 1'b1;
    readnum = 3'b101;

    #10;
    loadb = 0;
    if (DUT.B !== DUT.REGFILE.data_out) begin
      $display("ERROR! B register did not load correctly with loadb asserted");
      err = 1;
    end

    readnum = 3'b011;
    #20;
    if (DUT.B !== DUT.REGFILE.data_out) begin
      $display("ERROR! B register changed value without loadb asserted");
      err = 1;
    end

    // Test 5: Check loadc functionality
    ALUop = 2'b00;
    asel = 0;
    bsel = 0;
    loadc = 1'b1;

    #10;
    loadc = 0;
    if (DUT.C !== 16'h002A + 16'h000D) begin
      $display("ERROR! C register did not load correctly with loadc asserted");
      err = 1;
    end

    // Verify that C does not change without loadc asserted
    ALUop = 2'b01;  // Change ALU operation
    #20;
    if (DUT.C !== 16'h002A + 16'h000D) begin
      $display("ERROR! C register changed value without loadc asserted");
      err = 1;
    end

    // Test 6: Check final ALU output
    if (datapath_out !== DUT.C) begin
      $display("ERROR! ALU output is incorrect");
      err = 1;
    end

    // Final result check
    if (err == 0) begin
      $display("All tests passed! :)");
    end else begin
      $display("Some tests failed. :(");
    end

    $stop;
  end
endmodule
