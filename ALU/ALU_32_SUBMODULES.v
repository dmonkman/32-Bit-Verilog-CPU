// Drayton Monkman, 53------
// Date: Nov 15, 2021

// A 32-bit adder with carry
module ALU_ADD_32(
    input [31:0] SR1, 
    input [31:0] SR2, 
    output reg CARRY,
    output reg [31:0] RESULT);
    always@(*) begin
        {CARRY, RESULT} <= SR1 + SR2;
    end
endmodule

// A 32-bit subtractor with carry
module ALU_SUB_32(
    input [31:0] SR1, 
    input [31:0] SR2, 
    output reg CARRY,
    output reg [31:0] RESULT);

    wire [31:0] SR2_INV;
    assign SR2_INV = ~SR2;
    always@(*) begin
        {CARRY, RESULT} <= SR1 + SR2_INV + 1;   // NOTE: We use 6502 / ARM convention to calculate carry
    end
endmodule

// A 32-bit multiplier with overflow bits
module ALU_MUL_32(
    input [31:0] SR1, 
    input [31:0] SR2, 
    output reg [31:0] RESULT);
    always@(*) begin
        RESULT <= SR1 * SR2;
    end
endmodule

// A 32-bit bitwise ANDing
module ALU_AND_32(
    input [31:0] SR1, 
    input [31:0] SR2, 
    output reg [31:0] RESULT);
    always@(*) begin
        RESULT <= SR1 & SR2;
    end
endmodule

// A 32-bit bitwise ORing
module ALU_OR_32(
    input [31:0] SR1, 
    input [31:0] SR2, 
    output reg [31:0] RESULT);
    always@(*) begin
        RESULT <= SR1 | SR2;
    end
endmodule

// A 32-bit bitwise XORing
module ALU_XOR_32(
    input [31:0] SR1, 
    input [31:0] SR2, 
    output reg [31:0] RESULT);
    always@(*) begin
        RESULT <= SR1 ^ SR2;
    end
endmodule

// A parameterized 32-bit right shift register that shifts the input by n-bit
// NOTE: I assume 'parameterized' in the project description means passing SHIFT_ROR_VAL as an input parameter
module ALU_RSHIFT_32(
    input [31:0] SR2, 
    input [4:0] N,
    output reg [31:0] RESULT);
    always @(*) begin
        RESULT = SR2 >> N;
    end
endmodule

// A parameterized 32-bit left shift register that shifts the input by n-bit
// NOTE: I assume 'parameterized' in the project description means passing SHIFT_ROR_VAL as an input parameter
module ALU_LSHIFT_32(
    input [31:0] SR2, 
    input [4:0] N,
    output reg [31:0] RESULT);
    always @(*) begin
        RESULT = SR2 << N;
    end
endmodule

// A parameterized 32-bit register that right rotates the input by n-bit
// NOTE: I assume 'parameterized' in the project description means passing SHIFT_ROR_VAL as an input parameter
module ALU_RROT_32(
    input [31:0] SR2, 
    input [4:0] N,
    output reg [31:0] RESULT);

    // SWITCH THE HIGH AND LOW BIT SEGMENTS
    always @(*) begin
        // Explaination:
        // Step 1: Shift R2 value to the right by N. This will give us our final lowest (32 - N) bits, and leave 0s where the highest bits will be.
        // Step 2: Shift R2 value to the left by (32 - N). This will give us our final highest (32 - N) bits, and leave 0s where the lowest bits will be.
        // Step 3: Take the bitwise OR of these values to combine the (32 - N) lowest bits and N highest bits.
        RESULT = (SR2 >> N) | (SR2 << (32 - N));
    end
endmodule

// Flags register
module FLAGS_REGISTER(
    input RESET,
    input WRITE,
    input [3:0] NZCV_IN,
    output reg [3:0] NZCV_OUT
);
    always @(negedge RESET) begin
        NZCV_OUT <= 4'b0000;
    end
    always @(*) begin
        if(WRITE) NZCV_OUT <= NZCV_IN;
    end
endmodule

// NOTE: Not currently utilized by the ALU. Will be needed for Final Project however. Separate from ALU.
module PROGRAM_COUNTER(
    input INCREMENT,
    input RESET,
    output reg [7:0] COUNT
);
    // POSEDGE INCREMENT WITH NEGEDGE RESET
    always @(posedge INCREMENT or negedge RESET) begin
        if(!RESET) COUNT <= 8'b11111111;
        else COUNT <= COUNT + 1;
    end
endmodule

// A 32-line 16x1 Multiplexer (each input/output is an 32-bit wide)
// A module that checks the S-bit /CMP instruction and generates the 4-bit flag accordingly. You may need to Google to learn how the four flags will be calculated.
// 8-bit Counter (Program Counter (PC))
// Other small modules that cover the remaining functions of the 15-instruction set (such as MOV and LDR).


// Why are MOV, LDR and SDR supposed to be part of the ALU? They can be handled entirely by the MEM controller and Register Banks.
// In our final CPU, ALU should
// ALU simply sends value to result; Memory Controller / Reg Bank should store RESULT in SR1
module ALU_MOV_32(
    input [31:0] VAL,
    output reg [31:0] RESULT);
    always @(*) begin
        RESULT <= VAL;
    end
endmodule

// ALU simply sends R1 (SR1) to result; Memory Controller should load content at memory address SR1
module ALU_LDR_32(
    input [31:0] SR1,
    output reg [31:0] RESULT);
    always @(*) begin
        RESULT <= SR1;
    end
endmodule

// ALU simply sends R2 or N (aka SR2) to result; Memory Controller should store content at memory address SR1
// Same code as ALU_MOV_32
module ALU_STR_32(
    input [31:0] SR2,
    output reg [31:0] RESULT);
    always @(*) begin
        RESULT <= SR2;
    end
endmodule

// Compare SR1 and SR2 then set flags

// NOTE: S CONDITION IS ALSO HANDLED BY THE FLAG REGISTER
module ALU_CMP_32(
    input S,
    input [31:0] SR1, 
    input [31:0] SR2,
    output [3:0] NZCV);

    wire [31:0] SR2_INV;
    assign SR2_INV = ~SR2;
    
    wire [32:0] DIFF;
    assign DIFF = SR1 + SR2_INV + 1;   // NOTE: We use 6502 / ARM convention to calculate carry


    // SET V (OVERFLOW) OVERFLOW FLAG BY :  
        // 1. COMPARING THE SIGN OF THE ORIGINAL VALUES: SR1[31] AND ~SR2[31] (FLIP SR2 SIGN BECAUSE SUBTRACTION IS ADDITION OF A NEGATIVE)
        // 2. IF BOTH SR1 AND SR2 HAVE THE SAME SIGN (IMAGINING SR1 + (-SR2)), A SIGN FLIP ON THE RESULT INDICATES OVERFLOW
    assign NZCV[0] = ((SR1[31] == (~SR2[31])) ? ((SR1[31] == DIFF[31]) ? 1'b0 : 1'b1 ) : 1'b0);
        // ARE SIGNS EQUAL ? (IS RESULT SIGN EQUAL TO SR1 AND SR2 SIGN ? V = 0 : V = 1) : V = 0;

    // SET C (CARRY) FLAG BY CHECKING THE CARRY BIT DIFF[32]
    assign NZCV[1] = (DIFF[32] ? 1'b1 : 1'b0);
    
    // SET Z (ZERO) FLAG (BECAUSE WE USE ARM CARRY CONVENTION, ONLY CHECK LOWER 32 BITS TO PREVENT FALSE NONZERO)
    assign NZCV[2] = ((DIFF[31:0] == 0) ? 1'b1 : 1'b0);

    // SET N (NEGATIVE FLAG)
    assign NZCV[3] = ((DIFF[31]) ? 1'b1 : 1'b0);
endmodule


// CONDITION CHECK UNIT
module ALU_COND_CHECK(
    input [3:0] COND,
    input [3:0] NZCV,
    output reg CONDITION_MET);

    // ASSIGN FLAG WIRES FOR CLARITY
    wire N_FLAG, Z_FLAG, C_FLAG, V_FLAG;
    assign {N_FLAG, Z_FLAG, C_FLAG, V_FLAG} = NZCV;

    always@ (*) begin
        // EXECUTE COND
        case(COND)
            // NO CONDITION
            4'b0000: CONDITION_MET <= 1'b1;

            // EQ - Equal
            4'b0001: CONDITION_MET <= (Z_FLAG == 1) ? 1'b1 : 1'b0;

            // GT - Greater Than
            4'b0010: CONDITION_MET <= (Z_FLAG == 0) & (N_FLAG == V_FLAG) ? 1'b1 : 1'b0;

            // LT - Lesser Than
            4'b0011: CONDITION_MET <= (N_FLAG != V_FLAG) ? 1'b1 : 1'b0;

            // GE - Greater than or Equal To
            4'b0100: CONDITION_MET <= (N_FLAG == V_FLAG) ? 1'b1 : 1'b0;

            // LE - Lesser than or Equal To
            4'b0101: CONDITION_MET <= (Z_FLAG == 1) | (N_FLAG != V_FLAG) ? 1'b1 : 1'b0;

            // HI - Unsighed Higher
            4'b0110: CONDITION_MET <= (C_FLAG == 1) & (Z_FLAG == 0) ? 1'b1 : 1'b0;

            // L0 - Unsighed Lower
            4'b0111: CONDITION_MET <= (C_FLAG == 0) ? 1'b1 : 1'b0;

            // HS - Unsigned Higher or Same
            4'b1000: CONDITION_MET <= (C_FLAG == 1) ? 1'b1 : 1'b0;

            // If the OPCODE is undefined, do not perform an operation
            default: CONDITION_MET <= 1'b0;
        
        //CALCULATE FLAGS
        endcase
    end
endmodule
