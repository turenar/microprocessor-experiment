`include "def.vh"

module decoder(
	input clk,
	input rst,
	input enabled,
	input [`ERRC_BITDEF] in_errno,
	output [`ERRC_BITDEF] out_errno,
	input in_valid,
	input [31:0] in_npc,
	input [31:0] in_reg_map,
	input [5:0] in_opc,
	input [`OPTYPE_BITDEF] in_opt,
	input [31:0] in_rav,
	input [31:0] in_rbv,
	input [4:0] in_rout,
	input [10:0] in_aux,
	input [15:0] in_imm,
	input [25:0] in_addr,
	output [31:0] out_npc,
	output [31:0] out_reg_map,
	output [5:0] out_opc,
	output [`OPTYPE_BITDEF] out_opt,
	output [31:0] out_rav,
	output [31:0] out_rbv,
	output [4:0] out_rout,
	output [10:0] out_aux,
	output out_mem_read_enabled,
	output [31:0] out_mem_read_addr,
	output out_mem_write_enabled,
	output [31:0] out_mem_write_addr
	);

	reg [`ERRC_BITDEF] Rerrno; assign out_errno = Rerrno;
	reg [31:0] Rnpc; assign out_npc = Rnpc;
	reg [31:0] Rreg_map; assign out_reg_map = Rreg_map;
	reg [5:0] Ropc; assign out_opc = Ropc;
	reg [`OPTYPE_BITDEF] Ropt; assign out_opt = Ropt;
	reg [31:0] Rrav; assign out_rav = Rrav;
	reg [31:0] Rrbv; assign out_rbv = Rrbv;
	reg [4:0] Rrout; assign out_rout = Rrout;
	reg [10:0] Raux; assign out_aux = Raux;
	reg Rmem_read_enabled; assign out_mem_read_enabled = Rmem_read_enabled;
	reg [31:0] Rmem_read_addr; assign out_mem_read_addr = Rmem_read_addr;
	reg Rmem_write_enabled; assign out_mem_write_enabled = Rmem_write_enabled;
	reg [31:0] Rmem_write_addr; assign out_mem_write_addr = Rmem_write_addr;

	task Tzmread;
		begin
			Rmem_read_enabled <= 0; Rmem_read_addr <= 0;
		end
	endtask
	task Tzmwrite;
		begin
			Rmem_write_enabled <= 0; Rmem_write_addr <= 0;
		end
	endtask
	task Tzmem;
		begin
			Tzmread; Tzmwrite;
		end
	endtask
	task Tsmread(input Aenabled, input[31:0] Aaddr);
		begin
			Rmem_read_enabled <= Aenabled; Rmem_read_addr <= Aaddr;
		end
	endtask
	task Tsmwrite(input Aenabled, input[31:0] Aaddr);
		begin
			Rmem_write_enabled <= Aenabled; Rmem_write_addr <= Aaddr;
		end
	endtask
	task Treset;
		begin
			Rerrno <= 0; Rnpc <= `PC_ILLEGAL; Rreg_map <= 0;
			Ropc <= 0; Ropt <= 0; Rrav <= 0; Rrbv <= 0;
			Rrout <= 0; Raux <= 0; Tzmem;
		end
	endtask
	always @ (posedge clk) begin
		if (rst || (enabled && !in_valid)) begin
			Treset;
		end else if (enabled && in_valid) begin
			Rerrno <= in_errno; Rnpc <= in_npc; Rreg_map <= in_reg_map;
			Ropc <= in_opc; Ropt <= in_opt; /*Rrav <= in_rav; Rrbv <= in_rbv; */
			Rrout <= in_rout; Raux <= in_aux;
			if (in_opc == `OPCODE_LW) begin
				Tsmread(1, in_rav + `EXTSGN16to32(in_imm));
				Rrav <= in_rav; Rrbv <= in_rbv; Tzmwrite;
			end else if (in_opc == `OPCODE_SW) begin
				Tsmwrite(1, in_rbv + `EXTSGN16to32(in_imm));
				Rrbv <= in_rbv + `EXTSGN16to32(in_imm); Rrav <= in_rav; Tzmread;
			end else if (in_opt == `OPTYPE_VJ) begin
				if (in_opc == `OPCODE_J) begin
					Rrav <= 1;
					Rrbv <= in_addr;
					Tzmem;
				end else begin
					case (in_opc)
						`OPCODE_BEQ: Rrav <= (in_rav == in_rbv);
						`OPCODE_BNE: Rrav <= (in_rav != in_rbv);
						`OPCODE_BLT: Rrav <= (in_rav < in_rbv);
						`OPCODE_BLE: Rrav <= (in_rav <= in_rbv);
						// default: ;
					endcase
					Rrbv <= in_npc + 4 + `EXTSGN16to32(in_imm); Tzmem;
				end
			end else if (in_opc == `OPCODE_JAL) begin
				Rrav <= in_addr; Rrbv <= 0; Tzmem;
			end else begin
				Tzmem; Rrav <= in_rav; Rrbv <= in_rbv;
			end
		end
	end
	always @ (negedge clk) begin
		if (rst) begin
			Treset;
		end
	end
endmodule
