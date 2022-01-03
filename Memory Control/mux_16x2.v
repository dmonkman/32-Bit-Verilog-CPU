module mux_16x2(sel, A, B, out);
	input sel;
	input [15:0] A,B;
	output reg [15:0] out;

	always@*
	begin
		case(sel)
		1'b1: out = A;
		1'b0: out = B;
		endcase
	end
endmodule
