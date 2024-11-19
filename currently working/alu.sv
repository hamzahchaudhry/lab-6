module ALU(Ain,Bin,ALUop,out,Z); 
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output reg [15:0] out;
    output reg [2:0] Z; //Z CHANGED FROM 1BIT TO 3 BITS
    //outputs initialized as reges

    always @(*) begin
        case(ALUop)
            2'b00: out = Ain + Bin; //addition
            2'b01: out = Ain - Bin; //subtraction
            2'b10: out = Ain & Bin; //bitwise and
            2'b11: out = ~Bin; //not
        endcase

        //STATUS REGISTER 
        //Z[2] = ZERO FLAG
        //Z[1] = NEGATIVE FLAG
        //Z[0] = OVERFLOW TAG

        //Z[2] = ZERO FLAG
        if (out == 16'b0) begin
            Z[2] = 1'b1; // if output is 0, Z = 1
        end else begin
            Z[2] = 1'b0;
        end

        //Z[1] = NEGATIVE FLAG
        if (out[15] == 1'b1) begin
            Z[1] = 1'b1;
        end else begin
            Z[1] = 1'b0;
        end    

        //Z[0] = OVERFLOW FLAG
        //Only occurs when two positive integers are being added or two negative integers are being added
        //And the answer changes sign
        if ( ((Ain[15] == Bin[15] && (ALUop == 00)) || ((Ain[15] != Bin[15]) && (ALUop == 01))) && (Ain[15] != out[15])) begin 
            Z[0] = 1'b1;
        end else begin
            Z[0] = 1'b0;
        end
    end
endmodule
