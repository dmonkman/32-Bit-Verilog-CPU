// Drayton Monkman, 53------
// Dec 3, 2021

// CPU PACKAGE INCLUDING ALL SUBMODULES
module CPU_32(
    input CLK,
    input RESET,
    output [7:0] PC,
    output [31:0] INSTR_O,
    output [31:0] ALU_RES,
    output [15:0] RAM_ADDR,
    output RAM_RW_,
    output [3:0] DEST_O,
    output [3:0] SRC1_REG,
    output [31:0] SRC1_DATA_O,
    output [3:0] SRC2_REG,
    output [31:0] SRC2_DATA_O,
    output [31:0] RAM_DATABUS_IN,
    output [31:0] R0,
    output [31:0] R1,
    output [31:0] R2,
    output [31:0] R3,
    output [31:0] R4,
    output [31:0] R5,
    output [31:0] R6,
    output [31:0] R7,
    output [31:0] R8,
    output [31:0] R9,
    output [31:0] R10,
    output [31:0] R11,
    output [31:0] R12,
    output [31:0] R13,
    output [31:0] R14,
    output [31:0] R15,
    output [3:0] NZCV
);

    // CTRL UNIT REGISTERS
    //***************************************************// BEGIN CONTROL UNIT

    // INTERNAL CU REGISTERS
    reg [1:0] CU_STATE;     // FSM STATE  
    reg RESET_BUFFER;       // Ensures negedge operation not performed after reset; Ensures that next action will occur at POSEDGE CLK

    // CU OUTPUT REGISTERS
    reg REGBANK_ENABLE;     // IF == 1, ALLOW WRITE TO DEST REG; IF == 0, DO NOT
    reg ALU_ENABLE;         // IF == 1, CHANGE ALU OUTPUT; IF == 0, RETAIN ALU OUTPUT BEFORE NEGEDGE
    reg PC_INC;             // Reg will tell the PC when to incriment
    reg [3:0] MEM_CTRL_OPCODE_BUFFER;   // This buffer controls what OPCODE the MEMCTRL sees to ensure the memory controller doesn't get stuck on LDR or STR. Default NOP.

    // INSTRUCTION REGISTER
    reg [31:0] INSTR;
    //***************************************************// END CONTROL UNIT

    // Assign wires for clarity
    wire [3:0] COND;
    assign COND = INSTR[31:28];

    wire [3:0] OPCODE;
    assign OPCODE = INSTR[27:24];

    wire S;
    assign S = INSTR[23];

    wire [3:0] DEST;
    assign DEST = INSTR[22:19];

    wire [3:0] SRC1;
    assign SRC1 = INSTR[18:15];

    wire [3:0] SRC2;
    assign SRC2 = INSTR[14:11];

    wire [4:0] SHIFT_ROR;
    assign SHIFT_ROR = INSTR[10:6];

    wire [2:0] SHIFT_ROR_CTRL;
    assign SHIFT_ROR_CTRL = INSTR[2:0];

    wire [15:0] IMMEDIATE_VALUE;
    assign IMMEDIATE_VALUE = INSTR[18:3];
    
    // DEBUG
    assign INSTR_O = INSTR;

    // 1. PROGRAM COUNTER
    wire [7:0] PROGRAM_COUNT;
    PROGRAM_COUNTER PCOUNT(
        .INCREMENT(PC_INC),
        .RESET(RESET),
        .COUNT(PROGRAM_COUNT)
    );

    // DEBUG
    assign PC = PROGRAM_COUNT;

    // 2. RAM
    wire RAM_RW;
    wire [31:0] RAM_DataIn, RAM_DataOut;
    wire [15:0] RAM_AddressBus;
    wire [31:0] RAM_INSTR_Access;

    RAM_32_64K RAM(
        .RW(RAM_RW),
        .DataIn(RAM_DataIn),
        .DataOut(RAM_DataOut),
        .AddressBus(RAM_AddressBus)
    );

    // DEBUG
    assign RAM_RW_ = RAM_RW;

    // 3. ALU
    wire [31:0] ALU_OUT;
    wire [31:0] SRC1_DATA;
    wire [31:0] SRC2_DATA;
    wire CND_MET;

    ALU_32 ALU(
        .RESET(RESET),
        .ENABLE(ALU_ENABLE),
        .OPCODE(OPCODE),
        .COND(COND),
        .S(S),
        .IM_VAL(IMMEDIATE_VALUE), 
        .SHIFT_ROR_CTRL(SHIFT_ROR_CTRL), 
        .SR1(SRC1_DATA), 
        .SR2(SRC2_DATA), 
        .RESULT(ALU_OUT), 
        .NZCV(NZCV),
        .CND_MET(CND_MET)
    );
    
    // DEBUG
    assign ALU_RES = ALU_OUT;

    // 4. REGISTER BANK
    wire [31:0] LDR_MUX_OUT;   // Wire from LDR MUX to Regsiter Bank
    wire [15:0] REG_BANK_ENABLE;

    master_register REG_BANK(
        .dest(DEST),
        .sel1(SRC1), 
        .sel2(SRC2), 
        .ldr_mux(LDR_MUX_OUT), 
        .enable(REG_BANK_ENABLE),
        .source1(SRC1_DATA), 
        .source2(SRC2_DATA),
        .r0(R0),
        .r1(R1),
        .r2(R2),
        .r3(R3),
        .r4(R4),
        .r5(R5),
        .r6(R6),
        .r7(R7),
        .r8(R8),
        .r9(R9),
        .r10(R10),
        .r11(R11),
        .r12(R12),
        .r13(R13),
        .r14(R14),
        .r15(R15),
        .OPCODE(OPCODE),
        .REGBANK_ENABLE(REGBANK_ENABLE)
    );

    // DEBUG
    assign DEST_O = DEST;
    assign SRC1_REG = SRC1;
    assign SRC1_DATA_O = SRC1_DATA;
    assign SRC2_REG = SRC2;
    assign SRC2_DATA_O = SRC1_DATA;

    // 5. MEMORY CONTROLLER

    Master_Mem_control MEM_CTRL(
        .CLK(CLK),
        .PC_Instruction_Acces(PROGRAM_COUNT),
        .Source_1(SRC1_DATA),
        .Source_2(ALU_OUT),         // ALU_OUT WILL PROVIDE THE CORRECT DATA FOR STR, LDR
        .ALU_out(ALU_OUT),
        .OP_code(MEM_CTRL_OPCODE_BUFFER),
        .DataBus_in(RAM_DataOut),
        .DataBus_out(RAM_DataIn),
        .ADDRESS_bus(RAM_AddressBus),
        .REG_bus(LDR_MUX_OUT),
        .RW(RAM_RW)
    );

    assign RAM_ADDR = RAM_AddressBus;
    assign RAM_DATABUS_IN = RAM_DataIn;

    //* CONTROL UNIT INTERNAL LOGIC *//
    //******************************************************************// BEGIN CONTROL UNIT

    // CPU NEEDS 1 CLOCK CYCLE (POSEDGE AND NEGEDGE) FOR ALL BASIC OPS 
    // LDR REQUIRES 2 CLOCK CYCLES
    // STR REQUIRES 3 CLOCK CYCLES
    always@(posedge CLK or negedge RESET) begin
        
        // RESET
        if(!RESET) begin
            INSTR <= 32'b00001111000000000000000000000000;
            CU_STATE <= 2'b00;
            PC_INC <= 1'b0;
            MEM_CTRL_OPCODE_BUFFER <= 4'b1111;
            REGBANK_ENABLE <= 0;
            RESET_BUFFER <= 1;
        end

        else begin
            // 1. READ CYCLE: INCREMENT PC; LOAD INSTR; NOP MEMORY CONTROLLER
            if(CU_STATE == 2'b00) begin
                ALU_ENABLE <= 0;        // FREEZE ALU RESULT
                PC_INC <= 1;            // INCREMENT PC FROM A TO B
                INSTR <= RAM_DataOut;   // LOAD INSTR #A
                REGBANK_ENABLE <= 0;    // DISABLE R0 -R15 WRITE
            end

            // 3. RAM WRITE ENABLE
            else if(CU_STATE == 2'b01) begin
                ALU_ENABLE <= 0;                    // FREEZE ALU RESULT
                MEM_CTRL_OPCODE_BUFFER <= 4'b1010;  // NOW SET MEM_CTRL OPCODE TO 'STR'; ENABLES RAM_RW
            end

            // 5. CLEAR LDR REGBANK_WRITE IF LDR INSTRUCTION; WASTED CLK EDGE FOR STR
            else if(CU_STATE == 2'b10) begin
                REGBANK_ENABLE <= 0;            // STOP WRITING TO REGBANK FOR 'LDR'; REDUNDANT FOR STR
                ALU_ENABLE <= 0;                // FREEZE ALU RESULT
            end
        end
    end

    always@(negedge CLK) begin

        // MAKE SURE NEGEDGE DOES NOTHING IF RESET OCCURED ON POSEDGE
        if(RESET_BUFFER == 1'b1) begin
            RESET_BUFFER <= 0;
            PC_INC <= 1;            // INITIAL PC INCRIMENT FROM -1 TO ZERO. ALLOWS LOAD OF FIRST INSTRUCTION INSTANTLY
        end

        // ALWAYS CHECK CND FIRST
        else begin
            
            // ALWAYS ENSURE PC_INC IS SET TO ZERO ON NEGEDGE
            PC_INC <= 0;

            if(CND_MET) begin   
                // 2. PERFORM ALU OP; WRITE RESULT TO REG OR RAM
                if(CU_STATE == 2'b00) begin
                    // DETERMINE IF REGISTER BANK WRITE IS REQUIRED
                    casex(OPCODE)
                        4'b1000: REGBANK_ENABLE <= 1'b0;	// CMP
                        4'b1001: REGBANK_ENABLE <= 1'b1;	// LDR
                        4'b101x: REGBANK_ENABLE <= 1'b0;	// STR + UNDEFINED
                        4'b11xx: REGBANK_ENABLE <= 1'b0;	// NOP + UNDEFINED COMMANDS
                        default: REGBANK_ENABLE <= 1'b1;
                    endcase
                
                    ALU_ENABLE <= 1;
                    MEM_CTRL_OPCODE_BUFFER <= OPCODE;

                    // IF STR WE MUST PERFORM RAM WRITE
                    if(OPCODE == 4'b1010) begin
                        MEM_CTRL_OPCODE_BUFFER <= 4'b1001;  // WE SHOW THE MEM_CTRL TO PERFORM LDR TO SET THE PC / ADDRESS MUX BEFORE WRITE
                        CU_STATE = 2'b01;
                    end

                    // IF LDR, WE PERFORM LDR IN REG BANK
                    else if(OPCODE == 4'b1001) begin
                        CU_STATE = 2'b10;               // NEED EXTRA CLK CYCLE TO PERFORM LDR SAFELY
                    end
                end

                // 4. RAM WRITE DISABLE
                else if(CU_STATE == 2'b01) begin
                    MEM_CTRL_OPCODE_BUFFER <= 4'b1001;  // SET STR TO LDR; KEEPS SAME RAM ADDRESS BUT DISABLES RAM_RW
                    CU_STATE <= 2'b10;
                end

                // 6. RESET STATE; CLEAR LDR/STR FLAG
                else if(CU_STATE == 2'b10) begin
                    CU_STATE <= 2'b00;                  // RESET STATE
                    MEM_CTRL_OPCODE_BUFFER <= 4'b1111;  // IF OPCODE WAS STILL STR OR LDR, ADDRESS MUX IN MEM_CTRL WOULDN'T POINT TO ADDRESS=PC
                end
            end 
        end
    end
    //******************************************************************// END CONTROL UNIT

endmodule