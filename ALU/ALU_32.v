// Drayton Monkman, 53------
// Date: Nov 15, 2021

// FULL ALU MODULE DESIGNED AS A BLACK BOX WITH INPUTS AND OUTPUTS
module ALU_32(
    input ENABLE,
    input RESET,
    input [3:0] OPCODE,                     // OPCODE DEFINES THE OPERATION TO PERFORM
    input [3:0] COND,                       // CONDITIONAL BITS; UNUSED FOR MOST OPERATIONS
    input S,                                // IF S = 1, COMPUTE AND SET FLAGS
    input [15:0] IM_VAL,                    // IMMEDIATE VALUE
    input [2:0] SHIFT_ROR_CTRL,
    input [31:0] SR1,                       // INPUT VALUE FROM SOURCE REG 1
    input [31:0] SR2,                       // INPUT VALUE FROM SOURCE REG 2
    output reg [31:0] RESULT,               // RESULT OF THE OPERATION
    output [3:0] NZCV,                       // ALLOW US TO SEE FLAGS IN TESTBENCH
    output CND_MET
);
    // ASSIGN SHIFT CTRL WIRE TO IM
    wire [4:0] SHIFT_ROR_VAL;
    assign SHIFT_ROR_VAL = IM_VAL[7:3]; 

    // FLAG REGISTER BUS
    reg [3:0] NZCV_IN;   // THIS REGISTER IS FOR INPUT TO FLAGS AND DOES NOT CONTAIN THE ACTUAL FLAG VALUES
    wire [3:0] NZCV_OUT; // THIS CONTAINS THE TRUE FLAG VALUES FROM THE FLAGS REGISTER

    // FLAGS REGISTER
    FLAGS_REGISTER ALU_FLAGS_REGISTER(
        .RESET(RESET),
        .WRITE(S | OPCODE == 4'b1000),     // IF S == 0, DON'T SET FLAGS; IF S == 1, SET FLAGS. THIS WIRE ENSURES THAT FLAGS WILL NEVER CHANGE IF S == 0 UNLESS CMP
        .NZCV_IN(NZCV_IN),
        .NZCV_OUT(NZCV_OUT)
    );
    
    always @(negedge RESET) begin
        NZCV_IN <= 4'b0000;
    end

    assign NZCV = NZCV_OUT;
    
 
    // ASSIGN FLAG WIRES FOR CLARITY
    wire N_FLAG, Z_FLAG, C_FLAG, V_FLAG;
    assign {N_FLAG, Z_FLAG, C_FLAG, V_FLAG} = NZCV_OUT;

    /* COMPONENTS AND COMPONENT OUTPUT WIRES */

    // COMBINATIONAL LOGIC FOR R2 SHIFTS
    // RIGHT SHIFT UNIT REGISTER
    wire [31:0] RSHIFT_OUT;
    ALU_RSHIFT_32 RSHIFT_32(
        .SR2(SR2),
        .N(SHIFT_ROR_VAL),
        .RESULT(RSHIFT_OUT)
    );

    // LEFT SHIFT UNIT REGISTER
    wire [31:0] LSHIFT_OUT;
    ALU_LSHIFT_32 LSHIFT_32(
        .SR2(SR2),
        .N(SHIFT_ROR_VAL),
        .RESULT(LSHIFT_OUT)
    );

    // RIGHT ROTATE REGISTER
    wire [31:0] RROT_OUT;
    ALU_RROT_32 RROT_32(
        .SR2(SR2),
        .N(SHIFT_ROR_VAL),
        .RESULT(RROT_OUT)
    );

    // SET SR2 DEPENDING ON SHIFT_ROR_CTRL
    reg [31:0] SR2_SHIFT;
    always @(*) begin
        case(SHIFT_ROR_CTRL)
            // NO SHIFT SR2
            3'b000: SR2_SHIFT <= SR2;

            // LOGICAL RIGHT SHIFT
            3'b001: SR2_SHIFT <= RSHIFT_OUT;

            // LOGICAL LEFT SHIFT
            3'b010: SR2_SHIFT <= LSHIFT_OUT;

            // RIGHT ROTATE
            3'b011: SR2_SHIFT <= RROT_OUT;

            // DEFAULT (INVALID INSTRUCTION)
            default: SR2_SHIFT <= 32'bz;
        endcase
    end

    // PERFORM OPERATIONS USING SHIFTED (OR UNSHIFTED) SR2

    // ADDITION UNIT
    wire [31:0] ADD_OUT;
    wire C_ADD;
    ALU_ADD_32 ADD_32(
        .SR1(SR1),
        .SR2(SR2_SHIFT),
        .CARRY(C_ADD),
        .RESULT(ADD_OUT)
    );

    // SUBTRACTION UNIT
    wire [31:0] SUB_OUT;
    wire C_SUB;
    ALU_SUB_32 SUB_32(
        .SR1(SR1),
        .SR2(SR2_SHIFT),
        .CARRY(C_SUB),
        .RESULT(SUB_OUT)
    );

    // MULTIPLICATION UNIT
    //
    wire [31:0] MUL_OUT;
    ALU_MUL_32 MUL_32(
        .SR1(SR1),
        .SR2(SR2_SHIFT),
        .RESULT(MUL_OUT)
    );

    // BITWISE AND UNIT
    wire [31:0] AND_OUT;
    ALU_AND_32 AND_32(
        .SR1(SR1),
        .SR2(SR2_SHIFT),
        .RESULT(AND_OUT)
    );

    // BITWISE OR UNIT
    wire [31:0] ORR_OUT;
    ALU_OR_32 ORR_32(
        .SR1(SR1),
        .SR2(SR2_SHIFT),
        .RESULT(ORR_OUT)
    );

    // BITWISE XOR UNIT
    wire [31:0] XOR_OUT;
    ALU_XOR_32 XOR_32(
        .SR1(SR1),
        .SR2(SR2_SHIFT),
        .RESULT(XOR_OUT)
    );

    // MOV UNIT FOR "MOV R1, n" OPERATION
    wire [31:0] MOV_n_OUT;
    ALU_MOV_32 MOV_n_32(
        .VAL({16'b0, IM_VAL}),
        .RESULT(MOV_n_OUT)
    );  

    // MOV UNIT FOR "MOV R1, R2" OPERATION
    wire [31:0] MOV_SR2_OUT;
    ALU_MOV_32 MOV_SR2_32(
        .VAL(SR2_SHIFT),
        .RESULT(MOV_SR2_OUT)
    );

    // COMPARE UNIT
    wire [3:0] CMP_FLAGS_OUT;
    ALU_CMP_32 CMP_32(
        .S(1'b1),
        .SR1(SR1),
        .SR2(SR2_SHIFT),
        .NZCV(CMP_FLAGS_OUT)
    );

    // ALU "LOAD REGISTER 1 FROM MEMORY" UNIT (BASICALLY PASSES ADDRESS VALUE IN R1 TO RESULT)
    wire [31:0] LDR_OUT;
    ALU_LDR_32 LDR_32(
        .SR1(SR1),
        .RESULT(LDR_OUT)
    );

    // ALU "STORE REGISTER 2 VALUE IN MEMORY" UNIT (BASICALLY PASSES VALUE IN SR2_SHIFT TO RESULT)
    wire [31:0] STR_OUT;
    ALU_STR_32 STR_32(
        .SR2(SR2_SHIFT),
        .RESULT(STR_OUT)
    );

    // CHECK CONDITIONAL BITS BEFORE PERFORMING OPERATION
    wire CONDITION_MET;     // CONDITION WIRE BETWEEN COMBINATIONAL LOGIC
    ALU_COND_CHECK COND_UNIT(
        .COND(COND),
        .NZCV(NZCV_OUT),
        .CONDITION_MET(CONDITION_MET)
    );

    assign CND_MET = CONDITION_MET;

    // MODIFY ALU_OUT REG AND CALCULATE FLAGS ONLY AT POSEDGE ENABLE
    always@ (posedge ENABLE) begin
        // CHECK THAT CONDITION HAS BEEN MET
        if(CONDITION_MET) begin
            // EXECUTE OPCODE COMMANDS
            case(OPCODE)
                // ADD R1, R2, R3
                4'b0000: begin
                    RESULT <= ADD_OUT;
                    NZCV_IN[3] <= ADD_OUT[31] == 1 ? 1'b1 : 1'b0; // NEGATIVE
                    NZCV_IN[2] <= ADD_OUT == 0 ? 1'b1 : 1'b0;      // ZERO
                    NZCV_IN[1] <= C_ADD;           // CARRY
                    NZCV_IN[0] <= (SR1[31] == SR2[31]) ? ((SR1[31] == ADD_OUT[31]) ? 1'b0 : 1'b1 ) : 1'b0; //OVERFLOW
                end

                // SUB R1, R2, R3
                4'b0001: begin
                    RESULT <= SUB_OUT;
                    NZCV_IN[3] <= SUB_OUT[31] == 1 ? 1'b1 : 1'b0;   // NEGATIVE
                    NZCV_IN[2] <= SUB_OUT == 0 ? 1'b1 : 1'b0;       // ZERO
                    NZCV_IN[1] <= C_SUB;              // CARRY
                    NZCV_IN[0] <= (SR1[31] == ~SR2[31]) ? ((SR1[31] == SUB_OUT[31]) ? 1'b0 : 1'b1 ) : 1'b0; //OVERFLOW
                end

                // MUL R1, R2, R3
                4'b0010: begin 
                    RESULT <= MUL_OUT;
                    NZCV_IN[3] <= MUL_OUT[31] == 1 ? 1'b1 : 1'b0;   // NEGATIVE
                    NZCV_IN[2] <= MUL_OUT == 0 ? 1'b1 : 1'b0;       // ZERO

                    // This ALU does not calculate carry for MUL; Assuming 32 bit limit of result
                    NZCV_IN[1] <= 1'b0;              // CARRY
                    NZCV_IN[0] <= (SR1[31] == ~SR2[31]) ? ((SR1[31] == MUL_OUT[31]) ? 1'b0 : 1'b1 ) : 1'b0; // OVERFLOW
                end

                // ORR R1, R2, R3
                4'b0011: begin
                    RESULT <= ORR_OUT;
                    NZCV_IN[3] <= ORR_OUT[31] == 1 ? 1'b1 : 1'b0;   // NEGATIVE
                    NZCV_IN[2] <= ORR_OUT == 0 ? 1'b1 : 1'b0;       // ZERO
                    NZCV_IN[1] <= 1'b0;              // CARRY
                    NZCV_IN[0] <= 1'b0;              // OVERFLOW
                end

                // AND R1, R2, R3
                4'b0100: begin 
                    RESULT <= AND_OUT;
                    NZCV_IN[3] <= AND_OUT[31] == 1 ? 1'b1 : 1'b0;   // NEGATIVE
                    NZCV_IN[2] <= AND_OUT == 0 ? 1'b1 : 1'b0;       // ZERO
                    NZCV_IN[1] <= 1'b0;              // CARRY
                    NZCV_IN[0] <= 1'b0;              // OVERFLOW
                end
                
                // EOR R1, R2, R3
                4'b0101: begin 
                    RESULT <= XOR_OUT;
                    NZCV_IN[3] <= XOR_OUT[31] == 1 ? 1'b1 : 1'b0;   // NEGATIVE
                    NZCV_IN[2] <= XOR_OUT == 0 ? 1'b1 : 1'b0;       // ZERO
                    NZCV_IN[1] <= 1'b0;              // CARRY
                    NZCV_IN[0] <= 1'b0;              // OVERFLOW
                end

                // MOV R1, n
                4'b0110: begin 
                    RESULT <= MOV_n_OUT;
                    NZCV_IN[3] <= MOV_n_OUT[31] == 1 ? 1'b1 : 1'b0;   // NEGATIVE
                    NZCV_IN[2] <= MOV_n_OUT == 0 ? 1'b1 : 1'b0;       // ZERO
                    NZCV_IN[1] <= 1'b0;              // CARRY
                    NZCV_IN[0] <= 1'b0;              // OVERFLOW
                end

                // MOV R1, R2
                4'b0111: begin 
                    RESULT <= MOV_SR2_OUT;
                    NZCV_IN[3] <= MOV_SR2_OUT[31] == 1 ? 1'b1 : 1'b0;   // NEGATIVE
                    NZCV_IN[2] <= MOV_SR2_OUT == 0 ? 1'b1 : 1'b0;       // ZERO
                    NZCV_IN[1] <= 1'b0;              // CARRY
                    NZCV_IN[0] <= 1'b0;              // OVERFLOW
                end

                // CMP R1, R2
                4'b1000: begin 
                    RESULT <= 32'bx;    // CMP SETS FLAGS AND DOES NOT RETURN A VALUE
                    NZCV_IN <= CMP_FLAGS_OUT;
                end

                // LDR R2, [R1]
                4'b1001: begin 
                    RESULT <= LDR_OUT;
                    NZCV_IN <= 4'bz; // DO NOT CHANGE FLAGS FOR LDR
                end        

                // STR R2, [R1]
                4'b1010: begin 
                    RESULT <= STR_OUT;
                    NZCV_IN <= 4'bz; // DO NOT CHANGE FLAGS FOR STR
                end

                // NOP
                4'b1111: begin
                    RESULT <= 32'bz;
                    NZCV_IN <= 4'bz; // DO NOT CHANGE FLAGS FOR NOP
                end

                // INVALID OPCODE
                default: begin
                    RESULT <= 32'bz;
                    NZCV_IN <= 4'bz;
                end
            
            endcase
        end
        // IF CONDITION WAS NOT MET
        else RESULT = 32'bx;
    end
endmodule