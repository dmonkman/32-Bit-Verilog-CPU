module master_register(dest, sel1, sel2, ldr_mux, enable, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, source1, source2, OPCODE, REGBANK_ENABLE);
	input [3:0] dest, sel1, sel2, OPCODE;
	input [31:0] ldr_mux;
	input REGBANK_ENABLE;
	output [15:0] enable;
	output [31:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
	output [31:0] source1, source2;
	decoder d1(dest, enable);

	reg [15:0] enable_reg;

	// IF OPCODE DOES NOT REQUIRE A DEST REG, WE MUST SET ENABLE = 16'b0 BECAUSE 4x16 DECODER CANNOT SPECIFY A '16'b0' CONDITION
	always@(*) begin
		casex(OPCODE)
			4'b1000: enable_reg <= 16'b0;	// CMP
			4'b1001: enable_reg <= (REGBANK_ENABLE ? enable : 16'b0);	// LDR
			4'b101x: enable_reg <= 16'b0;	// STR + UNDEFINED
			4'b11xx: enable_reg <= 16'b0;	// NOP + UNDEFINED COMMANDS
			default: enable_reg <= (REGBANK_ENABLE ? enable : 16'b0);
		endcase
	end

	registers reg1(enable_reg, ldr_mux, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15);
	mux m1(sel1, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, source1);
	mux m2(sel2, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, source2);

endmodule

// 0000 0000 0 0000 0000 1101 00101 000 011