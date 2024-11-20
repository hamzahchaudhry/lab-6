// states
`define waitState       10'b0000000001
`define getAState       10'b0000000010
`define getBState       10'b0000000100
`define ALUState        10'b0000001000
`define writeRegRmState 10'b0000010000
`define writeRegRdState 10'b0000100000
`define shiftState      10'b0001000000
`define movImmState     10'b0010000000
`define statusState     10'b0100000000
`define Decode          10'b1000000000

module cpu(clk,reset,s,load,in,out,N,V,Z,w);
    input clk, reset, s, load;
    input [15:0] in;
    output [15:0] out;
    output reg N, V, Z, w;

    reg [9:0] present_state;

    // datapath module initialization
    wire clk;
    reg asel, bsel, loada, loadb, loadc, loads, write; 
    wire [1:0] ALUop, shift;
    wire [2:0] readnum, writenum;
    wire [2:0] Z_out;
    reg [3:0] vsel;
    wire [7:0] PC;
    assign PC = 8'b0;
    wire [15:0] datapath_out, mdata, sximm8, sximm5;

    // instrucDecoder initialization
    reg [2:0] nsel;
    wire [2:0] opcode;  // from/to FSM
    wire [1:0] op; // to FSM

    // instruction register initialization
    wire [15:0] InstructionOUT;

    // instruction register block
    loadEnableCircuit InstructionRegister(
        .in          (in),
        .load        (load),
        .clk         (clk),
        .out         (InstructionOUT)
        );

    //instruction decoder block
    instrucDecoder InstructionDecoder(
        .instrucreg  (InstructionOUT),
        .nsel        (nsel),
        .opcode      (opcode),
        .op          (op),
        .ALUop       (ALUop),
        .sximm5      (sximm5),
        .sximm8      (sximm8),
        .shift       (shift),
        .readnum     (readnum),
        .writenum    (writenum)
        );

    // state machine
    always_ff @(posedge clk) begin
        if (reset) begin  // reset
            present_state = `waitState;
            w = 1;
        end
        else begin
            case (present_state)  // if not reset then
                `waitState: begin
                    //resetting control signals
                    nsel = 3'b000;
                    vsel = 4'b0000;
                    asel = 0;
                    bsel = 0;
                    loada = 0;
                    loadb = 0;
                    loads = 0;
                    loadc = 0;
                    write = 0;
                    
                    // 1 if not in operation
                    w = 1;

                    if (~s) begin  // if s = 0, wait state
                        present_state = `waitState;
                    end else begin
                        present_state = `Decode;
                    end
                end

                `Decode:  begin
                    if (opcode == 3'b110) begin  // MOV instructions
                                    case (op)  // move instructions
                                        2'b10:  present_state = `movImmState;    // MOVimm starts at movImmState
                                        2'b00:  present_state = `getBState;      // MOV with shift starts at getAState
                                        default:  present_state = `waitState;    // if no appropriate input, give 9'bx
                                    endcase
                                end else if (opcode == 3'b101) begin
                                    case (ALUop)  // ALU instructions
                                        2'b00, 2'b01, 2'b10:  present_state = `getAState;  // ADD, CMP, AND start at getAState
                                        2'b11:  present_state = `getBState;                // MVN starts at getBState
                                        default:  present_state = `waitState;              // if no appropriate input, give 9'bx
                                    endcase
                                end
                    end
                
                `getAState: begin
                                // outputs to get A
                                nsel = 3'b100;
                                vsel = 4'b0000;
                                asel = 0;
                                bsel = 0;
                                loada = 1;
                                loadb = 0;
                                loads = 0;
                                loadc = 0;
                                write = 0;
                                w = 0;

                                if (opcode == 3'b101) begin
                                    case (ALUop)
                                        2'b00, 2'b01, 2'b10:  present_state = `getBState;  // ADD, CMP, AND goes to getBState (1)
                                        2'b11:  present_state = `shiftState;               // MVN goes to shiftState (1)
                                        default:  present_state = `getAState;              // if no appropriate input, give 9'bx
                                    endcase
                                end else begin
                                    present_state = `getAState;                            // if no appropriate input, give 9'bx
                                end
                end

                `getBState: begin
                                //outputs to get B
                                nsel = 3'b001;
                                vsel = 4'b0000;
                                asel = 0;
                                bsel = 0;
                                loada = 0;
                                loadb = 1;
                                loads = 0;
                                loadc = 0;
                                write = 0;
                                w = 0;

                                if (ALUop == 2'b00 && opcode == 3'b101) begin 
                                    present_state = `ALUState;                          // ADD branch goes to ALU for additionA (2)
                                end else if (ALUop == 2'b01 && opcode == 3'b101) begin
                                    present_state = `statusState;                       // CMP branch goes to Status for comparison (2)
                                end else if (ALUop == 2'b10 && opcode == 3'b101) begin
                                    present_state = `ALUState;                          // AND branch goes to ALU for anding (2)
                                end else if (ALUop == 2'b11 && opcode == 3'b101) begin
                                    present_state = `statusState;                       // MVN branch goes to shift for shifting (1)
                                end else if (op == 2'b00 && opcode == 3'b110) begin
                                    present_state = `shiftState;                        // MOV branch goes to shift for shifting (1)
                                end else begin
                                    present_state = `getBState;                         // if no appropriate input, give 9'bx
                                end
                                
                end

                `ALUState:  begin
                                // output to complete ALU operation
                                nsel = 3'b000;
                                vsel = 4'b0000;
                                asel = 0;
                                bsel = 0;
                                loada = 0;
                                loadb = 0;
                                loads = 0;
                                loadc = 1;
                                write = 0;
                                w = 0;

                                if (opcode == 3'b101) begin
                                    case (ALUop)
                                        2'b00, 2'b10:  present_state = `writeRegRdState;  // ADD (2), AND (2), go to writeRegRdState
                                        default:  present_state = `ALUState;              // if no appropriate input, give 9'bx
                                    endcase
                                end else begin
                                    present_state = `ALUState;
                                end
                            end
            
                `writeRegRdState:   begin
                                        // output to write value to register Rd
                                        nsel = 3'b010;
                                        vsel = 4'b0001;
                                        asel = 0;
                                        bsel = 0;
                                        loada = 0;
                                        loadb = 0;
                                        loads = 0;
                                        loadc = 0;
                                        write = 1;
                                        w = 0;      
                                                                          
                                        present_state = `waitState; // ADD (3*), AND (3*) go back to waitState
                                    end

                `writeRegRmState:   begin
                                        //output to write value to register Rm
                                        nsel = 3'b001;
                                        vsel = 2'b0001;
                                        asel = 0;
                                        bsel = 0;
                                        loada = 0;
                                        loadb = 0;
                                        loads = 0;
                                        loadc = 0;
                                        write = 1;
                                        w = 0;

                                        present_state = `waitState;  // MVN (3*), MOV shift (3*), finish and go back to waitState
                                    end

                `shiftState:    begin 
                                    // output to shift value in B
                                    nsel = 3'b000;
                                    vsel = 4'b0000;
                                    asel = 1;
                                    bsel = 0;
                                    loada = 0;
                                    loadb = 0;
                                    loads = 0;
                                    loadc = 1;
                                    write = 0;
                                    w = 0;

                                    present_state = `writeRegRmState;  // MVN (2), MOV shift (2), go to writeRegRmState
                                end

                `movImmState:   begin
                                    // output to move immediate value into reg
                                    nsel = 3'b100;
                                    vsel = 4'b0100;
                                    asel = 0;
                                    bsel = 0;
                                    loada = 0;
                                    loadb = 0;
                                    loads = 0;
                                    loadc = 0;
                                    write = 1;
                                    w = 0;

                                    present_state = `waitState;  // MOV imm has 1 state then goes back to waitState
                                end

                `statusState:   begin
                                    nsel = 3'b000;
                                    vsel = 4'b0000;
                                    asel = 0;
                                    bsel = 0;
                                    loada = 0;
                                    loadb = 0;
                                    loads = 1;
                                    loadc = 0;
                                    write = 0;
                                    w = 0;

                                    present_state = `waitState; // CMP (3*) 
                                end     
                default:  present_state = `waitState;
            endcase

        end
    
    end

   
    // datapath block
    datapath DP(
        .clk         (clk),

        // register operand fetch stage
        .readnum     (readnum),
        .vsel        (vsel),
        .loada       (loada),
        .loadb       (loadb),

        // computation stage
        .shift       (shift),
        .asel        (asel),
        .bsel        (bsel),
        .ALUop       (ALUop),
        .loadc       (loadc),
        .loads       (loads),

        // set when "writing back" to register file
        .writenum    (writenum),
        .write       (write),  

        // new inputs lab 6
        .mdata       (mdata),
        .sximm5      (sximm5),
        .sximm8      (sximm8),
        .PC          (PC),

        // outputs
        .Z_out       (Z_out),
        .datapath_out(datapath_out)
        );
endmodule



// ------------------------ helper modules -------------------------- //

// // flip flop
// module vDFF(clk, in, out) ;
//   parameter n = 1;  // width
//   input clk ;
//   input [n-1:0] in ;
//   output [n-1:0] out ;
//   reg [n-1:0] out ;

//   always_ff @(posedge clk)
//     out = in ;
// endmodule

// // load enable circuit
// module loadEnableCircuit(in, load, clk, out);
//   input [15:0] in;
//   input load, clk;
//   output [15:0] out;
//   wire [15:0] next = load ? in : out;

//   vDFF #(16) flipflop(clk, next, out);
// endmodule

// instruction decoder block
module instrucDecoder(instrucreg, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
    input [15:0] instrucreg;  // from instruction register
    input [2:0] nsel;  // from FSM TBD
    output [2:0] opcode; // to FSM
    output [1:0] op; // to FSM
    output [1:0] ALUop, shift; // to datapath
    output [15:0] sximm5, sximm8; // to datapath
    output reg [2:0] readnum, writenum; // to datapath

    // to FSM
    assign opcode = instrucreg[15:13];
    assign op = instrucreg[12:11];

    // sign extend
    signExtend #(5) imm5 (instrucreg[4:0], sximm5);
    signExtend #(8) imm8 (instrucreg[7:0], sximm8);

    // to datapath
    assign ALUop = instrucreg[12:11];
    assign shift = instrucreg[4:3];

    always @(*) begin
        case(nsel)
        3'b001: begin
            readnum = instrucreg [2:0];
            writenum = instrucreg [2:0];
        end
        3'b010: begin
            readnum = instrucreg [7:5];
            writenum = instrucreg [7:5];
        end
        3'b100: begin
            readnum = instrucreg [10:8];
            writenum = instrucreg [10:8];
        end
        endcase
    end
    
endmodule

// sign extend
module signExtend (in, out);
    parameter n = 1;  // width
    input [n-1:0] in;
    output [15:0] out;

    assign out = {{(16-n){in[n-1]}}, in};
endmodule 