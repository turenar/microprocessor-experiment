module register(
	input clk,
	input rst,
	input [4:0] r1_index,
	output [31:0] r1_data,
	input [4:0] r2_index,
	output [31:0] r2_data,
	input [4:0] w_index,
	input [31:0] w_data
	);
	reg [4:0] r1_i;
	reg [4:0] r2_i;
	reg [31:0] files [0:31];

	integer i;
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			for (i = 0; i<32; i=i+1) begin
				files[i] <= 0;
			end
			r1_i <= 0;
			r2_i <= 0;
		end else begin
			if(w_index) files[w_index] <= w_data;
			r1_i <= r1_index;
			r2_i <= r2_index;
		end
	end

	assign r1_data = files[r1_i];
	assign r2_data = files[r2_i];
endmodule
