`include "def.vh"

module executor(
	input clk,
	input rst,
	output halt,
	input [5:0] opcode,
	input [1:0] optype, // 1=R, 2=I, 3=A
	input [31:0] rav,
	input [31:0] rbv,
	input [4:0] rout,
	input [10:0] aux,
	input [31:0] mem_v,
	output [4:0] out_reg_index,
	output [31:0] out_reg_data,
	output out_pc_enabled,
	output [31:0] out_pc_data,
	output out_mem_enabled,
	output [31:0] out_mem_addr,
	output [31:0] out_mem_data
	);

	wire [31:0] Walu_routv;
	reg Rhalt; assign halt = Rhalt;
	reg Ralu_enabled;
	reg [4:0] Rreg_index; assign out_reg_index = Rreg_index;
	reg [31:0] Rreg_data;
	reg Rpc_enabled; assign out_pc_enabled = Rpc_enabled;
	reg [31:0] Rpc_data; assign out_pc_data = Rpc_data;
	reg Rmem_enabled; assign out_mem_enabled = Rmem_enabled;
	reg [31:0] Rmem_addr; assign out_mem_addr = Rmem_addr;
	reg [31:0] Rmem_data; assign out_mem_data = Rmem_data;
	assign out_reg_data = Ralu_enabled ? Walu_routv : Rreg_data;

	alu alu0(
		.clk(clk), .aux(aux),
		.ra(rav), .rb(rbv), .rout(Walu_routv));

	always @ (posedge clk) begin
		if (rst || Rhalt) begin
			if (rst) begin
				Rhalt <= 0;
			end
			Ralu_enabled <= 0;
			Rreg_index <= 0; Rpc_enabled <= 0; Rmem_enabled <= 0;
			Rreg_data <= 0; Rpc_data <= 0; Rmem_addr <= 0; Rmem_data <= 0;
		end else if (!Rhalt) begin
			if (opcode == `OPCODE_AUX) begin
				Ralu_enabled <= 1;
				Rreg_index <= rout;
				Rpc_enabled <= 0;
				Rmem_enabled <= 0;
			end else if (opcode == `OPCODE_LW) begin
				Ralu_enabled <= 0;
				Rreg_index <= rout;
				Rreg_data <= mem_v;
				Rpc_enabled <= 0;
				Rmem_enabled <= 0;
			end else if (opcode == `OPCODE_SW) begin
				Ralu_enabled <= 0;
				Rreg_index <= 0;
				Rreg_data <= 0;
				Rpc_enabled <= 0;
				Rmem_enabled <= 1;
				Rmem_addr <= rbv;
				Rmem_data <= rav;
			end else if (opcode == `OPCODE_HALT) begin
				Rhalt <= 1;
			end
		end
	end
endmodule
