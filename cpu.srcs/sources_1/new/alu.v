`include "def.vh"

module alu(
	input clk, input rst,
	output [`ERRC_BITDEF] errno,
	input [10:0] aux,
	input [31:0] ra,
	input [31:0] rb,
	output [31:0] rout
	);

	reg [`ERRC_BITDEF] Rerrno; assign errno = Rerrno;
	reg [31:0] result;
	wire [4:0] shift_width = aux[10:6];
	wire [5:0] aux_type = aux[5:0];

	task Treturn(input [31:0] Aresult);
		begin
			Rerrno <= `ERRC_NOERR; result <= Aresult;
		end
	endtask

	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			Rerrno <= 0; result <= 0;
		end else begin
			case (aux_type)
				`ALUC_ADD:	Treturn(ra + rb);
				`ALUC_SUB:	Treturn(ra - rb);
				`ALUC_AND:	Treturn(ra & rb);
				`ALUC_OR:	Treturn(ra | rb);
				`ALUC_XOR:	Treturn(ra ^ rb);
				`ALUC_NOR:	Treturn(~(ra | rb));
				`ALUC_SLL:	Treturn(ra << shift_width);
				`ALUC_SRL:	Treturn(ra >> shift_width);
				`ALUC_SRA:	Treturn(ra >>> shift_width);
				31:			Rerrno <= `ERRC_NOERR;
				default:	Rerrno <= `ERRC_ILLAUX;
			endcase
		end
	end

	assign rout = result;
endmodule
