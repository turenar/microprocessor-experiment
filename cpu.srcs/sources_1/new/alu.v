`include "def.vh"

module alu(
	output [`ERRC_BITDEF] errno,
	input [10:0] aux,
	input [31:0] ra,
	input [31:0] rb,
	output [31:0] rout
	);

	wire [4:0] shift_width = aux[10:6];
	wire [5:0] aux_type = aux[5:0];

	assign rout =
		  (aux_type == `ALUC_ADD) ? (ra + rb)
		: (aux_type == `ALUC_SUB) ? (ra - rb)
		: (aux_type == `ALUC_AND) ? (ra & rb)
		: (aux_type == `ALUC_OR) ? (ra | rb)
		: (aux_type == `ALUC_XOR) ? (ra ^ rb)
		: (aux_type == `ALUC_NOR) ? (~(ra | rb))
		: (aux_type == `ALUC_SLL) ? (ra << shift_width)
		: (aux_type == `ALUC_SRL) ? (ra >> shift_width)
		: (aux_type == `ALUC_SRA) ? (ra >>> shift_width)
		: 0;
	assign errno =
		( aux_type == `ALUC_ADD
		|| aux_type == `ALUC_SUB
		|| aux_type == `ALUC_AND
		|| aux_type == `ALUC_OR
		|| aux_type == `ALUC_XOR
		|| aux_type == `ALUC_NOR
		|| aux_type == `ALUC_SLL
		|| aux_type == `ALUC_SRL
		|| aux_type == `ALUC_SRA
		|| aux_type == 31) ? 0 : `ERRC_ILLAUX;
endmodule
