module memory_arbitrator (
	input clk, input rst,
	output dec_locked_fault,
	input dec_r_enabled,
	input [31:0] dec_r_addr,
	input dec_w_enabled,
	input [31:0] dec_w_addr,
	input wb_w_enabled,
	input [31:0] wb_w_addr);

	reg Rlocked;
	reg Rdec_locked_fault; assign dec_locked_fault = Rdec_locked_fault;

	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			Rlocked <= 0; Rdec_locked_fault <= 0;
		end else begin
			Rlocked <= (Rlocked && ~wb_w_enabled) || dec_w_enabled;
			Rdec_locked_fault <= Rlocked && (dec_r_enabled || dec_w_enabled);
		end
	end
endmodule // register_arbitrator
