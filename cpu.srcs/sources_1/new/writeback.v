`include "def.vh"

module writeback(
	input wire clk, input wire rst,
	input wire [`ERRC_BITDEF] in_errno,
	output wire [`ERRC_BITDEF] out_errno,
	input wire [31:0] in_npc,
	input wire [31:0] in_reg_map,
	input wire [4:0] in_reg_index,
	input wire [31:0] in_reg_data,
	input wire in_pc_enabled,
	input wire [31:0] in_pc_addr,
	input wire in_mem_enabled,
	input wire [31:0] in_mem_addr,
	input wire [31:0] in_mem_data,
	output wire [31:0] out_npc,
	output wire out_set_pc_pulse,
	output wire [4:0] out_reg_index,
	output wire [31:0] out_reg_map,
	output wire [31:0] out_reg_data,
	output wire out_pc_enabled,
	output wire [31:0] out_pc_addr,
	output wire out_mem_enabled,
	output wire [31:0] out_mem_addr,
	output wire [31:0] out_mem_data,
	output wire out_extmem_enabled,
	output wire [31:0] out_extmem_addr,
	output wire [31:0] out_extmem_data
	);

	reg [`ERRC_BITDEF] Rerrno; assign out_errno = Rerrno;
	reg Rset_pc_pulse; assign out_set_pc_pulse = Rset_pc_pulse;
	reg [31:0] Rreg_map; assign out_reg_map = Rreg_map;
	reg [31:0] Rnpc; assign out_npc = Rnpc;
	reg [4:0] Rreg_index; assign out_reg_index = Rreg_index;
	reg [31:0] Rreg_data; assign out_reg_data = Rreg_data;
	reg Rpc_enabled; assign out_pc_enabled = Rpc_enabled;
	reg [31:0] Rpc_addr; assign out_pc_addr = Rpc_addr;
	reg Rmem_enabled; assign out_mem_enabled = Rmem_enabled;
	reg [31:0] Rmem_addr; assign out_mem_addr = Rmem_addr;
	reg [31:0] Rmem_data; assign out_mem_data = Rmem_data;
	reg Rextmem_enabled; assign out_extmem_enabled = Rextmem_enabled;
	assign out_extmem_addr = Rmem_addr;
	assign out_extmem_data = Rmem_data;

	always @ (posedge clk) begin
		if(rst) begin
			Rerrno <= 0; Rnpc <= `PC_ILLEGAL; Rreg_map <= 0;
			Rreg_index <= 0; Rpc_enabled <= 0; Rmem_enabled <= 0;
			Rreg_data <= 0; Rpc_addr <= 0; Rmem_addr <= 0; Rmem_data <= 0;
			Rset_pc_pulse <= 0; Rextmem_enabled <= 0;
		end else begin
			if (in_pc_enabled && in_pc_addr[1:0] != 0) begin
				// pc must be 4byte addressing
				Rerrno <= in_errno ? in_errno : `ERRC_INPC;
			end else begin
				Rerrno <= in_errno;
			end
			Rnpc <= in_npc;
			Rreg_map <= in_reg_map;
			Rreg_index <= in_reg_index;
			Rreg_data <= in_reg_data;
			Rpc_enabled <= in_pc_enabled;
			Rset_pc_pulse <= in_pc_enabled;
			Rpc_addr <= in_pc_addr;
			Rmem_enabled <= in_mem_enabled && in_mem_addr[31] == 0;
			Rmem_addr <= in_mem_addr;
			Rmem_data <= in_mem_data;
			Rextmem_enabled <= in_mem_enabled && in_mem_addr[31] == 1;
		end
	end

	always @ (negedge clk) begin
		if(!rst) begin
			Rset_pc_pulse <= 0;
		end
	end
endmodule
