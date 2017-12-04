`include "def.vh"

module alu(
	input clk,
	input [10:0] aux,
	input [31:0] ra,
	input [31:0] rb,
	output [31:0] rout
	);

	reg [31:0] result;
	wire [4:0] shift_width = aux[10:6];
	wire [5:0] aux_type = aux[5:0];

	always @(posedge clk) begin
		case (aux_type)
			`ALUC_ADD:	result <= ra + rb;
			`ALUC_SUB:	result <= ra - rb;
			`ALUC_AND:	result <= ra & rb;
			`ALUC_OR:	result <= ra | rb;
			`ALUC_XOR:	result <= ra ^ rb;
			`ALUC_NOR:	result <= ~(ra | rb);
			`ALUC_SLL:	result <= ra << shift_width;
			`ALUC_SRL:	result <= ra >> shift_width;
			`ALUC_SRA:	result <= ra >>> shift_width;
		endcase
	end

	assign rout = result;
endmodule
