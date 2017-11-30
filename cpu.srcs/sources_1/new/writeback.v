module writeback(
	input clk, input rst,
	input [31:0] in_npc,
	input [4:0] in_reg_index,
	input [31:0] in_reg_data,
	input in_pc_enabled,
	input [31:0] in_pc_data,
	input in_mem_enabled,
	input [31:0] in_mem_addr,
	input [31:0] in_mem_data,
	output [4:0] out_reg_index,
	output [31:0] out_reg_data,
	output out_pc_enabled,
	output [31:0] out_pc_data,
	output out_mem_enabled,
	output [31:0] out_mem_addr,
	output [31:0] out_mem_data
	);

	reg [4:0] Rreg_index; assign out_reg_index = Rreg_index;
	reg [31:0] Rreg_data; assign out_reg_data = Rreg_data;
	reg Rpc_enabled; assign out_pc_enabled = Rpc_enabled;
	reg [31:0] Rpc_data; assign out_pc_data = Rpc_data;
	reg Rmem_enabled; assign out_mem_enabled = Rmem_enabled;
	reg [31:0] Rmem_addr; assign out_mem_addr = Rmem_addr;
	reg [31:0] Rmem_data; assign out_mem_data = Rmem_data;

	always @ (posedge clk) begin
		if(rst) begin
			Rreg_index <= 0; Rpc_enabled <= 0; Rmem_enabled <= 0;
		end else begin
			Rreg_index <= in_reg_index;
			Rreg_data <= in_reg_data;
			Rpc_enabled <= in_pc_enabled;
			Rpc_data <= in_pc_data;
			Rmem_enabled <= in_mem_enabled;
			Rmem_addr <= in_mem_addr;
			Rmem_data <= in_mem_data;
		end
	end

endmodule
