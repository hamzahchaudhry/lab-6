module tb_signExtend;

    // Testbench signals
    reg [7:0] in_8bit;
    reg [3:0] in_4bit;
    wire [15:0] out_8bit;
    wire [15:0] out_4bit;

    // Instantiate the signExtend module for 8-bit input
    signExtend #(8) SE8 (.in(in_8bit), .out(out_8bit));

    // Instantiate the signExtend module for 4-bit input
    signExtend #(4) SE4 (.in(in_4bit), .out(out_4bit));

    // Test procedure
    initial begin
        $display("Starting test for signExtend module...");

        // Initialize signals
        in_8bit = 0;
        in_4bit = 0;
        #10;

        // Test case 1: 8-bit input (positive value)
        in_8bit = 8'b00101101;  // +45 in decimal
        #10;
        $display("Input (8-bit): %b, Output (16-bit): %b", in_8bit, out_8bit);

        // Test case 2: 8-bit input (negative value)
        in_8bit = 8'b11101101;  // -19 in decimal (2's complement)
        #10;
        $display("Input (8-bit): %b, Output (16-bit): %b", in_8bit, out_8bit);

        // Test case 3: 4-bit input (positive value)
        in_4bit = 4'b0101;  // +5 in decimal
        #10;
        $display("Input (4-bit): %b, Output (16-bit): %b", in_4bit, out_4bit);

        // Test case 4: 4-bit input (negative value)
        in_4bit = 4'b1101;  // -3 in decimal (2's complement)
        #10;
        $display("Input (4-bit): %b, Output (16-bit): %b", in_4bit, out_4bit);

        // Test case 5: 4-bit input (zero)
        in_4bit = 4'b0000;  // Zero
        #10;
        $display("Input (4-bit): %b, Output (16-bit): %b", in_4bit, out_4bit);

        // Test case 6: 8-bit input (maximum positive value)
        in_8bit = 8'b01111111;  // +127 in decimal
        #10;
        $display("Input (8-bit): %b, Output (16-bit): %b", in_8bit, out_8bit);

        // Test case 7: 8-bit input (maximum negative value)
        in_8bit = 8'b10000000;  // -128 in decimal
        #10;
        $display("Input (8-bit): %b, Output (16-bit): %b", in_8bit, out_8bit);

        $display("Test completed.");
        $finish;
    end

endmodule
