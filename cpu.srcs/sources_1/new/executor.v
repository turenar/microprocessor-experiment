`include "def.vh"

module executor(
	input wire clk,
	input wire rst,
	input wire enabled,
	input wire in_valid,
	input wire [`ERRC_BITDEF] in_errno,
	output wire [`ERRC_BITDEF] out_errno,
	input wire [31:0] in_npc,
	input wire [31:0] in_reg_map,
	input wire [5:0] opcode,
	input wire [`OPTYPE_BITDEF] optype, // 1=R, 2=I, 3=A
	input wire [31:0] rav,
	input wire [31:0] rbv,
	input wire [4:0] rout,
	input wire [10:0] aux,
	input wire [31:0] mem_v,
	output wire [31:0] out_npc,
	output wire [31:0] out_reg_map,
	output wire [4:0] out_reg_index,
	output wire [31:0] out_reg_data,
	output wire out_pc_enabled,
	output wire [31:0] out_pc_addr,
	output wire out_mem_enabled,
	output wire [31:0] out_mem_addr,
	output wire [31:0] out_mem_data
	);

	reg [31:0] Rnpc; assign out_npc = Rnpc;
	reg [31:0] Rreg_map; assign out_reg_map = Rreg_map;
	wire [31:0] Walu_routv;
	wire [`ERRC_BITDEF] Walu_errno;
	reg [`ERRC_BITDEF] Rerrno;
	assign out_errno = Rerrno;
	reg [4:0] Rreg_index; assign out_reg_index = Rreg_index;
	reg [31:0] Rreg_data;
	reg Rpc_enabled; assign out_pc_enabled = Rpc_enabled;
	reg [31:0] Rpc_addr; assign out_pc_addr = Rpc_addr;
	reg Rmem_enabled; assign out_mem_enabled = Rmem_enabled;
	reg [31:0] Rmem_addr; assign out_mem_addr = Rmem_addr;
	reg [31:0] Rmem_data; assign out_mem_data = Rmem_data;
	assign out_reg_data = Rreg_data;

	alu alu0(
		.errno(Walu_errno), .aux(aux),
		.ra(rav), .rb(rbv), .rout(Walu_routv));


	task Tzalu;
		begin
			// do nothing
		end
	endtask
	task Tualu(input Aenabled, input[4:0] Areg_index);
		begin
			Rreg_index <= Areg_index; Rreg_data <= Walu_routv; Rerrno <= Walu_errno;
		end
	endtask
	task Tzreg;
		begin
			Rreg_index <= 0; // Rreg_data <= `PC_ILLEGAL;
		end
	endtask
	task Tureg(input[4:0] Areg_index, input[31:0] Areg_data);
		begin
			Rreg_index <= Areg_index; Rreg_data <= Areg_data;
		end
	endtask
	task Tzpc;
		begin
			Rpc_enabled <= 0; // Rpc_addr <= `PC_ILLEGAL;
		end
	endtask
	task Tupc(input Apc_enabled, input[31:0] Apc_addr);
		begin
			Rpc_enabled <= Apc_enabled; Rpc_addr <= Apc_addr;
		end
	endtask
	task Tzmem;
		begin
			Rmem_enabled <= 0; // Rmem_addr <= 0; Rmem_data <= 0;
		end
	endtask
	task Tumem(input Amem_enabled, input[31:0] Amem_addr, input[31:0] Amem_data);
		begin
			Rmem_enabled <= Amem_enabled; Rmem_addr <= Amem_addr; Rmem_data <= Amem_data;
		end
	endtask
	task Treset;
		begin
			if (rst) begin
				Rerrno <= 0;
			end
			Rreg_map <= 0; Rnpc <= `PC_ILLEGAL;
			Rreg_index <= 0; Rpc_enabled <= 0; Rmem_enabled <= 0;
			Rreg_data <= 0; Rpc_addr <= 0; Rmem_addr <= 0; Rmem_data <= 0;
		end
	endtask

	always @ (posedge clk) begin
		if (rst || Rerrno || (enabled && !in_valid)) begin
			Treset;
		end else if (in_errno != 0) begin
			Rerrno <= in_errno;
		end else if (enabled && in_valid) begin
			Rnpc <= in_npc; Rreg_map <= in_reg_map;
			if (optype == `OPTYPE_VJ) begin
				Tzalu; Tzreg; Tzmem;
				Tupc(rav != 0, rbv);
			end else if (opcode == `OPCODE_AUX) begin
				Tzpc; Tzmem;
				Tualu(1, rout);
			end else if (opcode == `OPCODE_LW) begin
				Tzalu; Tzpc; Tzmem;
				Tureg(rout, mem_v);
			end else if (opcode == `OPCODE_SW) begin
				Tzalu; Tzreg; Tzpc;
				Tumem(1, rbv, rav);
			end else if (opcode == `OPCODE_JAL) begin
				Tzalu; Tzmem;
				Tureg(31, in_npc+4);
				Tupc(1, rav);
			end else if (opcode == `OPCODE_JR) begin
				Tzalu; Tzreg; Tzmem;
				Tupc(1, rav);
			end else if (opcode == `OPCODE_HALT) begin
				Tzalu; Tzreg; Tzpc; Tzmem;
				Rerrno <= `ERRC_HALTED;
			end
		end
	end
	always @ (negedge clk) begin
		if (rst) begin
			Treset;
		end
	end
endmodule
