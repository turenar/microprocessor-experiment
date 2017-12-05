`include "def.vh"

module decoder(
	input clk,
	input rst,
	input [`ERRC_BITDEF] in_errno,
	output [`ERRC_BITDEF] out_errno,
	input [31:0] in_npc,
	input [5:0] in_opc,
	input [`OPTYPE_BITDEF] in_opt,
	input [31:0] in_rav,
	input [31:0] in_rbv,
	input [4:0] in_rout,
	input [10:0] in_aux,
	input [15:0] in_imm,
	input [25:0] in_addr,
	input [31:0] in_mem_read_addr,
	input [31:0] in_mem_write_addr,
	output [31:0] out_npc,
	output [5:0] out_opc,
	output [`OPTYPE_BITDEF] out_opt,
	output [31:0] out_rav,
	output [31:0] out_rbv,
	output [4:0] out_rout,
	output [10:0] out_aux,
	output [31:0] out_mem_read_addr
	);

	reg [`ERRC_BITDEF] Rerrno; assign out_errno = Rerrno;
	reg [31:0] Rnpc; assign out_npc = Rnpc;
	reg [5:0] Ropc; assign out_opc = Ropc;
	reg [`OPTYPE_BITDEF] Ropt; assign out_opt = Ropt;
	reg [31:0] Rrav; assign out_rav = Rrav;
	reg [31:0] Rrbv; assign out_rbv = Rrbv;
	reg [4:0] Rrout; assign out_rout = Rrout;
	reg [10:0] Raux; assign out_aux = Raux;
	reg [31:0] Rmem_read_addr; assign out_mem_read_addr = Rmem_read_addr;

	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			Rerrno <= 0; Rnpc <= `PC_ILLEGAL;
			Ropc <= 0; Ropt <= 0; Rrav <= 0; Rrbv <= 0;
			Rrout <= 0; Raux <= 0; Rmem_read_addr <= 0;
		end else begin
			Rerrno <= in_errno; Rnpc <= in_npc;
			Ropc <= in_opc; Ropt <= in_opt; /*Rrav <= in_rav; Rrbv <= in_rbv; */
			Rrout <= in_rout; Raux <= in_aux;
			if (in_opc == `OPCODE_LW) begin
				Rmem_read_addr <= in_rav + `EXTSGN16to32(in_imm); Rrav <= in_rav; Rrbv <= in_rbv;
			end else if (in_opc == `OPCODE_SW) begin
				Rrbv <= in_rbv + `EXTSGN16to32(in_imm); Rrav <= in_rav; Rmem_read_addr <= 0;
			end else if (in_opt == `OPTYPE_VJ) begin
				if (in_opc == `OPCODE_J) begin
					Rrav <= 1;
					Rrbv <= in_addr;
					Rmem_read_addr <= 0;
				end else begin
					case (in_opc)
						`OPCODE_BEQ: Rrav <= (in_rav == in_rbv);
						`OPCODE_BNE: Rrav <= (in_rav != in_rbv);
						`OPCODE_BLT: Rrav <= (in_rav < in_rbv);
						`OPCODE_BLE: Rrav <= (in_rav <= in_rbv);
						// default: ;
					endcase
					Rrbv <= in_npc + 4 + `EXTSGN16to32(in_imm); Rmem_read_addr <= 0;
				end
			end else if (in_opc == `OPCODE_JAL) begin
				Rrav <= in_addr; Rrbv <= 0; Rmem_read_addr <= 0;
			end else begin
				Rmem_read_addr <= in_mem_read_addr; Rrav <= in_rav; Rrbv <= in_rbv;
			end
		end
	end
endmodule
