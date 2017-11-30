`include "def.vh"

module decoder(
	input clk,
	input rst,
	input [5:0] in_opc,
	input [1:0] in_opt,
	input [31:0] in_rav,
	input [31:0] in_rbv,
	input [4:0] in_rout,
	input [10:0] in_aux,
	input [15:0] in_imm,
	input [25:0] in_addr,
	input [31:0] in_mem_read_addr,
	output [5:0] out_opc,
	output [1:0] out_opt,
	output [31:0] out_rav,
	output [31:0] out_rbv,
	output [4:0] out_rout,
	output [10:0] out_aux,
	output [31:0] out_mem_read_addr
	);

	reg [5:0] Ropc; assign out_opc = Ropc;
	reg [1:0] Ropt; assign out_opt = Ropt;
	reg [31:0] Rrav; assign out_rav = Rrav;
	reg [31:0] Rrbv; assign out_rbv = Rrbv;
	reg [4:0] Rrout; assign out_rout = Rrout;
	reg [10:0] Raux; assign out_aux = Raux;
	reg [31:0] Rmem_read_addr; assign out_mem_read_addr = Rmem_read_addr;

	always @ (posedge clk) begin
		if (rst) begin
			Ropc <= 0; Ropt <= 0; Rrav <= 0; Rrbv <= 0;
			Rrout <= 0; Raux <= 0; Rmem_read_addr <= 0;
		end else begin
			Ropc <= in_opc; Ropt <= in_opt; Rrav <= in_rav; Rrbv <= in_rbv;
			Rrout <= in_rout; Raux <= in_aux;
			if (in_opc == `OPCODE_LW) begin
				Rmem_read_addr <= Rrav + in_imm;
			end else begin
				Rmem_read_addr <= in_mem_read_addr;
			end
		end
	end
endmodule
