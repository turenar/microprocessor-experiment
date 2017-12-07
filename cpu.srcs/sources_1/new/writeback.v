`include "def.vh"

module writeback(
	input clk, input rst,
	input [`ERRC_BITDEF] in_errno,
	output [`ERRC_BITDEF] out_errno,
	input [31:0] in_npc,
	input [31:0] in_reg_map,
	input [4:0] in_reg_index,
	input [31:0] in_reg_data,
	input in_pc_enabled,
	input [31:0] in_pc_addr,
	input in_mem_enabled,
	input [31:0] in_mem_addr,
	input [31:0] in_mem_data,
	output out_set_pc_pulse,
	output [4:0] out_reg_index,
	output [31:0] out_reg_map,
	output [31:0] out_reg_data,
	output out_pc_enabled,
	output [31:0] out_pc_addr,
	output out_mem_enabled,
	output [31:0] out_mem_addr,
	output [31:0] out_mem_data
	);

	reg [`ERRC_BITDEF] Rerrno; assign out_errno = Rerrno;
	reg Rset_pc_pulse; assign out_set_pc_pulse = Rset_pc_pulse;
	reg [31:0] Rreg_map; assign out_reg_map = Rreg_map;
	reg [4:0] Rreg_index; assign out_reg_index = Rreg_index;
	reg [31:0] Rreg_data; assign out_reg_data = Rreg_data;
	reg Rpc_enabled; assign out_pc_enabled = Rpc_enabled;
	reg [31:0] Rpc_addr; assign out_pc_addr = Rpc_addr;
	reg Rmem_enabled; assign out_mem_enabled = Rmem_enabled;
	reg [31:0] Rmem_addr; assign out_mem_addr = Rmem_addr;
	reg [31:0] Rmem_data; assign out_mem_data = Rmem_data;

	always @ (posedge clk or posedge rst) begin
		if(rst) begin
			Rerrno <= 0; Rreg_map <= 0;
			Rreg_index <= 0; Rpc_enabled <= 0; Rmem_enabled <= 0;
			Rreg_data <= 0; Rpc_addr <= 0; Rmem_addr <= 0; Rmem_data <= 0;
		end else begin
			Rerrno <= in_errno;
			Rreg_map <= in_reg_map;
			Rreg_index <= in_reg_index;
			Rreg_data <= in_reg_data;
			Rpc_enabled <= in_pc_enabled;
			Rset_pc_pulse <= in_pc_enabled;
			Rpc_addr <= in_pc_addr;
			Rmem_enabled <= in_mem_enabled;
			Rmem_addr <= in_mem_addr;
			Rmem_data <= in_mem_data;
		end
	end

	always @ (negedge clk) begin
		Rset_pc_pulse <= 0;
	end
endmodule
