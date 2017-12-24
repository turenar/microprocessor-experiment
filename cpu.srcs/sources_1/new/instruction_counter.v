module instruction_counter(
	input wire clk,
	input wire rst,
	input wire set_enabled,
	input wire next_enabled,
	input wire [31:0] set_addr,
	output wire [31:0] pc_addr
	);

	reg [31:0] pc;

	always @(posedge clk) begin
		if (rst) begin
			pc <= 0;
		end else begin
			if (set_enabled) begin
				pc <= set_addr;
			end else if (next_enabled) begin
				pc <= pc + 4;
			end
		end
	end

	assign pc_addr = pc;
endmodule
