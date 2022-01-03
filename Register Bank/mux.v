module mux(sel, r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, source);
	input [3:0] sel;
	input [31:0] r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;
	output reg [31:0] source;

	always@*
	begin
		case(sel)
		4'b0000: source=r0;
		4'b0001: source=r1;
		4'b0010: source=r2;
		4'b0011: source=r3;
		4'b0100: source=r4;
		4'b0101: source=r5;
		4'b0110: source=r6;
		4'b0111: source=r7;
		4'b1000: source=r8;
		4'b1001: source=r9;
		4'b1010: source=r10;
		4'b1011: source=r11;
		4'b1100: source=r12;
		4'b1101: source=r13;
		4'b1110: source=r14;
		4'b1111: source=r15;
		default: source=0;
		endcase
	end
endmodule