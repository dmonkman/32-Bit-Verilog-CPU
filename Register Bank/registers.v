module registers(enable, ldr_mux, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15);
	input [15:0] enable;
	input [31:0] ldr_mux;
	output reg [31:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;

	always@*
	begin
		case(enable)
		16'b0000000000000001: r0=ldr_mux;
		16'b0000000000000010: r1=ldr_mux;
		16'b0000000000000100: r2=ldr_mux;
		16'b0000000000001000: r3=ldr_mux;
		16'b0000000000010000: r4=ldr_mux;
		16'b0000000000100000: r5=ldr_mux;
		16'b0000000001000000: r6=ldr_mux;
		16'b0000000010000000: r7=ldr_mux;
		16'b0000000100000000: r8=ldr_mux;
		16'b0000001000000000: r9=ldr_mux;
		16'b0000010000000000: r10=ldr_mux;
		16'b0000100000000000: r11=ldr_mux;
		16'b0001000000000000: r12=ldr_mux;
		16'b0010000000000000: r13=ldr_mux;
		16'b0100000000000000: r14=ldr_mux;
		16'b1000000000000000: r15=ldr_mux;
		endcase
	end
endmodule
