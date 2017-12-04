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
	wire [31:0] r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15;

	// debug
	assign r1 = files[1];
	assign r2 = files[2];
	assign r3 = files[3];
	assign r4 = files[4];
	assign r5 = files[5];
	assign r6 = files[6];
	assign r7 = files[7];
	assign r8 = files[8];
	assign r9 = files[9];
	assign r10 = files[10];
	assign r11 = files[11];
	assign r12 = files[12];
	assign r13 = files[13];
	assign r14 = files[14];
	assign r15 = files[15];

	integer i;
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			for (i = 0; i<32; i=i+1) begin
				files[i] = 0;
			end
		end else begin
			if(w_index) files[w_index] <= w_data;
			r1_i <= r1_index;
			r2_i <= r2_index;
		end
	end

	assign r1_data = files[r1_i];
	assign r2_data = files[r2_i];
endmodule
