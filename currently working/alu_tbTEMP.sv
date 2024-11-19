module alu_tbTEMP();
  reg [15:0] Ain, Bin;
  reg [1:0] ALUop;
  wire [15:0] out;
  wire [2:0] Z;
  reg err;

  ALUVER2 DUT(
    .Ain(Ain),
    .Bin(Bin),
    .ALUop(ALUop),
    .out(out),
    .Z(Z)
  );

  initial begin
    err = 0;

    //ALUop = 00 (Ain + Bin)
    Ain = 16'h0005;  // 5 in hex
    Bin = 16'h0003;  // 3 in hex
    ALUop = 2'b00;
    #10;
    if (out !== 16'h0008 || Z !== 3'b000) begin
      $display("ERROR! :( ALUop=00, expected out=8, Z=000; actually out=%d, Z=%b", out, Z);
      err = 1;
    end

    // ALUop = 01 (Ain - Bin, pos)
    Ain = 16'h0005;  // 5
    Bin = 16'h0003;  // 3
    ALUop = 2'b01;
    #10;
    if (out !== 16'h0002 || Z !== 3'b000) begin
      $display("ERROR! :( ALUop=01, expected out=2, Z=000; actually out=%d, Z=%b", out, Z);
      err = 1;
    end

    //ALUop = 01 (Ain - Bin, zero)
    Ain = 16'h0003;
    Bin = 16'h0003;
    ALUop = 2'b01;
    #10;
    if (out !== 16'h0000 || Z !== 3'b100) begin
      $display("ERROR! :( ALUop=01, expected out=0, Z=100; actually out=%d, Z=%b", out, Z);
      err = 1;
    end

    //ALUop = 10 (Ain & Bin), not same
    Ain = 16'h000F;  // 0000 0000 0000 1111
    Bin = 16'h00F0;  // 0000 0000 1111 0000
    ALUop = 2'b10;
    #10;
    if (out !== 16'h0000 || Z !== 3'b100) begin
      $display("ERROR! :( ALUop=10, expected out=0, Z=100; actually out=%d, Z=%b", out, Z);
      err = 1;
    end

    //ALUop = 10 (Ain & Bin), same
    Ain = 16'hF00F;  // 1111 0000 0000 1111
    Bin = 16'hF0F0;  // 1111 0000 1111 0000
    ALUop = 2'b10;
    #10;
    if (out !== 16'hF000 || Z !== 3'b010) begin
      $display("ERROR! :( ALUop=10, expected out=0, Z=010; actually out=%d, Z=%b", out, Z);
      err = 1;
    end

    //ALUop = 11 (~Bin)
    Bin = 16'h00F0;  // 0000 0000 1111 0000
    ALUop = 2'b11;
    #10;
    if (out !== 16'hFF0F || Z !== 3'b010) begin
      $display("ERROR! :( ALUop=11, expected out=FF0F, Z=010; actually out=%d, Z=%b", out, Z);
      err = 1;
    end

    //NEW TESTS

    //ALUop = 01 (Ain - Bin)
    Ain = 16'h0003;  // 3 in hex
    Bin = 16'h0005;  // 5 in hex
    ALUop = 2'b01;
    #10;
    if (out !== 16'b1111111111111110 || Z !== 3'b010) begin
      $display("ERROR! :( ALUop=01, expected out=1111111111111110, Z=010; actually out=%d, Z=%b", out, Z);
      err = 1;
    end

    //ALUop = 00 (Ain + Bin)
    Ain = 16'hFFFF;  // -1 in hex
    Bin = 16'h0001;  // 1 in hex
    ALUop = 2'b00;
    #10;
    if (out !== 16'h0000 || Z !== 3'b100) begin
      $display("ERROR! :( ALUop=00, expected out=16'h0000, Z=101; actually out=%d, Z=%b", out, Z);
      err = 1;
    end

    //ALUop = 00 (Ain + Bin)
    Ain = 16'h7FFF;  // max positive value in hex
    Bin = 16'h0001;  // 1 in hex
    ALUop = 2'b00;
    #10;
    if (out !== 16'h8000 || Z !== 3'b011) begin // expect the max negative number
      $display("ERROR! :( ALUop=00, expected out=16'hFFFF, Z=011; actually out=%h, Z=%b", out, Z);
      err = 1;
    end

    //ALUop = 01 (Ain - Bin)
    Ain = 16'h8000;  // max negative value in hex
    Bin = 16'h0001;  // 1 in hex
    ALUop = 2'b01;
    #10;
    if (out !== 16'h7FFF || Z !== 3'b001) begin
      $display("ERROR! :( ALUop=01, expected out=7FFF, Z=011; actually out=%h, Z=%b", out, Z);
      err = 1;
    end
    
    //ALUop = 01 (Ain - Bin)
    Ain = 16'h7FFF;  // max pos value in hex
    Bin = 16'hFFFF;  // -1 in hex
    ALUop = 2'b01;
    #10;
    if (out !== 16'h8000 || Z !== 3'b011) begin
      $display("ERROR! :( ALUop=01, expected out=7FFF, Z=011; actually out=%h, Z=%b", out, Z);
      err = 1;
    end

    //ALUop = 00 (Ain + Bin)
    Ain = 16'h8000;  // max NEG value in hex
    Bin = 16'hFFFF;  // -1 in hex
    ALUop = 2'b00;
    #10;
    if (out !== 16'h7FFF || Z !== 3'b001) begin // expect the max POS number
      $display("ERROR! :( ALUop=00, expected out=7FFF, Z=001; actually out=%h, Z=%b", out, Z);
      err = 1;
    end

    if (err == 0) begin
      $display("passed all tests!!! :)");
    end else begin
      $display("failed tests :(");
    end

  end
endmodule

