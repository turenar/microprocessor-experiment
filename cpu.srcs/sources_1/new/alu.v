module alu(
	input clk,
	input [10:0] aux,
	input [31:0] ra,
	input [31:0] rb,
	output [31:0] rc
	);

	reg [31:0] result;
	wire [4:0] shift_width = aux[10:6];
	wire [5:0] aux_type = aux[5:0];

	always @(posedge clk) begin
		case (aux_type)
			6'h00:	result <= ra + rb;
			6'h02:	result <= ra - rb;
			6'h08:	result <= ra & rb;
			6'h09:	result <= ra | rb;
			6'h0a:	result <= ra ^ rb;
			6'h0b:	result <= ~(ra | rb);
			6'h10:	result <= ra << shift_width;
			6'h11:	result <= ra >> shift_width;
			6'h12:	result <= ra >>> shift_width;
		endcase
	end

	assign rc = result;
endmodule
