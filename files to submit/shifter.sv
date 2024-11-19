module shifter(in,shift,sout);
    input [15:0] in;
    input [1:0] shift;
    output reg [15:0] sout;

    always @(*) begin
        case (shift)
            2'b00: sout = in; //stays the same 
            2'b01: sout = in << 1; //bit shift to the left
            2'b10: sout = in >> 1; //bit shift to the right
            2'b11: sout = {in[15], in[15:1]} ; //right bit shift but replacing 0 with 1
            default: sout = 16'hxxxx; // default 
        endcase
    end

endmodule