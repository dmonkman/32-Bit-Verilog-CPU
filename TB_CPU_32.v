
// COMPREHENSIVE TESTBENCH FOR ALL CPU COMPONENTS
module TB_CPU_32();
    reg CLK;
    reg RESET;                  
    wire [7:0] PC;
    wire [15:0] RAM_ADDR;
    wire [31:0] INSTR;
    wire [31:0] ALU_RES;
    wire [3:0] DEST;
    wire [3:0] SRC1_REG;
    wire [31:0] SRC1_DATA;
    wire [3:0] SRC2_REG;
    wire [31:0] SRC2_DATA;
    wire [31:0] RAM_DATABUS_IN;
    wire [31:0] R0;
    wire [31:0] R1;
    wire [31:0] R2;
    wire [31:0] R3;
    wire [31:0] R4;
    wire [31:0] R5;
    wire [31:0] R6;
    wire [31:0] R7;
    wire [31:0] R8;
    wire [31:0] R9;
    wire [31:0] R10;
    wire [31:0] R11;
    wire [31:0] R12;
    wire [31:0] R13;
    wire [31:0] R14;
    wire [31:0] R15;
    wire [3:0] NZCV;
    wire RAM_RW;

    integer i;

    CPU_32 TB_CPU(
        .CLK(CLK),
        .RESET(RESET),  
        .PC(PC),
        .RAM_ADDR(RAM_ADDR),
        .INSTR_O(INSTR),
        .ALU_RES(ALU_RES),
        .DEST_O(DEST),
        .SRC1_REG(SRC1_REG),
        .SRC1_DATA_O(SRC1_DATA),
        .SRC2_REG(SRC2_REG),
        .SRC2_DATA_O(SRC2_DATA),
        .RAM_DATABUS_IN(RAM_DATABUS_IN),
        .RAM_RW_(RAM_RW),
        .R0(R0),     
        .R1(R1),   
        .R2(R2),   
        .R3(R3),   
        .R4(R4),   
        .R5(R5),   
        .R6(R6),   
        .R7(R7),   
        .R8(R8),   
        .R9(R9),   
        .R10(R10),   
        .R11(R11),   
        .R12(R12),   
        .R13(R13),   
        .R14(R14),   
        .R15(R15),                
        .NZCV(NZCV)
    );

    initial begin
        #10 RESET <= 1; 
        #10 RESET <= 0;     // reset CPU; default values to zero
        #10 RESET <= 1;

        #10  CLK <= 0;
        // Display initial condition
        //$display("PC=%d, INSTR=%b, R0=%d, R1=%d, R2=%d, R3=%d, R4=%d, R5=%d, R6=%d, R7=%d, R8=%d, R9=%d, R10=%d, R11=%d, R12=%d, R13=%d, R14=%d, R15=%d, NZCV=%b", 
        //    PC, INSTR, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, NZCV);
        // 1. LOAD INSTRUCTIONS TO RAM; VERIFY
        // $readmemb("LDR Instruction Set v2.txt", TB_CPU.RAM.mem);
        $readmemb("mem_input.txt", TB_CPU.RAM.mem);

        // Monitor results of interest
        // $monitor("CLK = %b, PC=%d, INSTR=%b, RAM_ADDR=%b, RAM_RW=%b, RAM_DATABUS_IN=%d, DEST=%d SRC1_REG=%d, SRC1_DATA=%d, SRC2_REG=%d, SRC2_DATA=%d, ALU_RES=%d, R0=%d, R1=%d, R2=%d, R3=%d, R4=%d, R5=%d, R6=%d, R7=%d, R8=%d, R9=%d, R10=%d, R11=%d, R12=%d, R13=%d, R14=%d, R15=%d, NZCV=%b", 
         //      CLK, PC, INSTR, RAM_ADDR, RAM_RW, RAM_DATABUS_IN, DEST, SRC1_REG, SRC1_DATA, SRC2_REG, SRC2_DATA, ALU_RES, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, NZCV);
        
        #5;

        // 2 - 6 CLOCK CYCLES PER INSTRUCTION
        for(i = 0; i < 16; i = i + 1) begin
            #5 CLK <= 1;
            #10 CLK <= 0;
            // Display results of interest
            #5 $display("PC=%d, INSTR=%b, R0=%d, R1=%d, R2=%d, R3=%d, R4=%d, R5=%d, R6=%d, R7=%d, R8=%d, R9=%d, R10=%d, R11=%d, R12=%d, R13=%d, R14=%d, R15=%d, NZCV=%b", 
                PC - 1, INSTR, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, NZCV);
        end

        #100 $writememb("mem_result.txt", TB_CPU.RAM.mem);
        //#10 $display("RESULT: PC=%d, R0=%d, R1=%d, R2=%d, R3=%d, R4=%d, R5=%d, R6=%d, R7=%d, R8=%d, R9=%d, R10=%d, R11=%d, R12=%d, R13=%d, R14=%d, R15=%d, NZCV=%b", 
        //        PC, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, NZCV);
    end
endmodule

// TODO: CMP C FLAG PATCH TO ARM CONVENTION