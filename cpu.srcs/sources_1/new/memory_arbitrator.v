module memory_arbitrator (
	input clk, input rst,
	output dec_locked_fault,
	input dec_r_enabled,
	input [31:0] dec_r_addr,
	input dec_w_enabled,
	input [31:0] dec_w_addr,
	input wb_w_enabled,
	input [31:0] wb_w_addr);

	reg [3:0] Rlocked;
	reg Rdec_locked_fault; assign dec_locked_fault = Rdec_locked_fault;
	wire [3:0] Wdec_r_bitmask, Wdec_w_bitmask, Wwb_w_bitmask;

	function [3:0] Fbitmask(input Aenabled, input [31:0] Aaddr);
		Fbitmask = Aenabled ? (1 << Aaddr[3:2]) : 0;
	endfunction
	assign Wdec_r_bitmask = Fbitmask(dec_r_enabled, dec_r_addr);
	assign Wdec_w_bitmask = Fbitmask(dec_w_enabled, dec_w_addr);
	assign Wwb_w_bitmask = Fbitmask(wb_w_enabled, wb_w_addr);

	task Treset;
		begin
			Rlocked <= 0; Rdec_locked_fault <= 0;
		end
	endtask

	always @ (posedge clk) begin
		if (rst) begin
			Treset;
		end else begin
			Rlocked <= (Rlocked & ~Wwb_w_bitmask) | Wdec_w_bitmask;
			Rdec_locked_fault <= 0 != ((Rlocked & ~Wwb_w_bitmask) & (Wdec_r_bitmask | Wdec_w_bitmask));
		end
	end
	always @ (negedge clk) begin
		if (rst) begin
			Treset;
		end
	end

endmodule // register_arbitrator
