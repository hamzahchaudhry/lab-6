// note: removed datapath_in input from lab5

module datapath(clk, readnum, writenum,
                ALUop, shift, asel, bsel, vsel,
                loada, loadb, loadc, loads, write,
                Z_out, datapath_out,
                // lab 6 new inputs/outputs
                sximm8, sximm5, mdata, PC);

    // Declaring the inputs
    input clk;
    input [2:0] readnum, writenum;                              // Reg select signals
    input [1:0] ALUop, shift;                                   // ALU and shift component inputs
    input asel, bsel, loada, loadb, loadc, loads, write;  
    input [3:0] vsel;  // changed to 2 bits
    output reg [2:0] Z_out;       //changed to 3 bits                                    // Zero output
    output [15:0] datapath_out;

    // lab 6 new inputs
    input [15:0] mdata, sximm8, sximm5;
    input [7:0] PC;

    reg [15:0] data_in, data_out, loadAout, loadBout, Ain, Bin, sout, out; // Declared as wires because these are connections between different blocks
    wire [2:0] Z; // changed to 3 bits

    // block 9: MUX
    // Multiplexer with inputs mdata,sximm8, PC, and datapath_out with vsel as select
    always @(*) begin
        case (vsel)
            4'b0001:  data_in = datapath_out;
            4'b0010:  data_in = {8'b0,PC};
            4'b0100:  data_in = sximm8;
            4'b1000:  data_in = mdata;
            default: data_in = 16'bx; // default 
        endcase
    end

    // block 1: Register Block
    // This register is responsible for storing and retrieving data based on the read and write signals.
    // It stores data from data_in into the register by writenum when write is high,
    // and outputs data to data_out from the register specified by readnum.
    regfile REGFILE (
        .data_in(data_in),
        .writenum(writenum),
        .write(write),
        .readnum(readnum),
        .clk(clk),
        .data_out(data_out)
    );

    // block 3: Load A 
    // Holds data for the A register. The data from data_out is loaded into loadAout
    // on the rising edge of clk if loada is high
    loadEnableCircuit A (
        .in(data_out),
        .load(loada),
        .clk(clk),
        .out(loadAout)
    );

    // block 6: MUX
    // Multiplexer with inputs 0 and loadAout with asel as select
    assign Ain = asel ? 16'b0 : loadAout;

    // block 4: Load B 
    // Holds data for the B register. The data from data_out is loaded into loadBout
    // on the rising edge of clk if loadb is high
    loadEnableCircuit B (
        .in(data_out),
        .load(loadb),
        .clk(clk),
        .out(loadBout)
    );

    // block 8: Shift Block
    // Takes loadBout and performs bit shift on it based on shift signal
    shifter U1 (
        .in(loadBout),
        .shift(shift),
        .sout(sout)
    );

    // block 7: MUX
    // Multiplexer with inputs sximm5 and sout with bsel as select
    assign Bin = bsel ? sximm5 : sout;

    // block 2: Arithmetic Logic Unit
    // Performs arithmetic operation on Ain and Bin based on specified input ALUop
    // Z is 1 if out comes out to ZERO.
    ALU U2 (
        .Ain(Ain),
        .Bin(Bin),
        .ALUop(ALUop),
        .out(out),
        .Z(Z)
    );

    // block 5: Load C
    // Holds data for the C register. The data from data_out is loaded into loadBout
    // on the rising edge of clk if loadc is high
    loadEnableCircuit C (
        .in(out),
        .load(loadc),
        .clk(clk),
        .out(datapath_out)
    );

    // block 10: Z_out updated to Z when loads is high
    always @(posedge clk) begin
        if (loads)
            Z_out <= Z;
    end
endmodule
