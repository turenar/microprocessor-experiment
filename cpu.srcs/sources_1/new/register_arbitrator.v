module register_arbitrator (
	input clk, input rst,
	input [4:0] pdc_r1_index,
	input [4:0] pdc_r2_index,
	input [4:0] pdc_w_index,
	output pdc_no_conflict,
	output [31:0] pdc_using_register_map,
	input [31:0] wb_using_register_map);

	reg [31:0] Rusing_register_map;
	reg [31:0] Rpdc_using_register_map; assign pdc_using_register_map = Rpdc_using_register_map;
	reg Rpdc_no_conflict; assign pdc_no_conflict = Rpdc_no_conflict;

	wire [31:0] Wpdc_using_register_map;
	assign Wpdc_using_register_map =
		(pdc_r1_index ? (1 << pdc_r1_index) : 0)
		| (pdc_r2_index ? (1 << pdc_r2_index) : 0)
		| (pdc_w_index ? (1 << pdc_w_index) : 0);
	wire [31:0] Wusing_register_map; // map after wb unlocked
	assign Wusing_register_map = Rusing_register_map & ~wb_using_register_map;
	wire [31:0] Whoge;
	assign Whoge = Wpdc_using_register_map & ~Wusing_register_map;

	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			Rusing_register_map <= 0;
			Rpdc_no_conflict <= 0;
			Rpdc_using_register_map <= 0;
		end else begin
			if (Wpdc_using_register_map == Whoge) begin
				Rpdc_no_conflict <= 1;
				Rpdc_using_register_map <= Wpdc_using_register_map;
				Rusing_register_map <= Wusing_register_map | Wpdc_using_register_map;
			end else begin
				Rpdc_no_conflict <= 0;
				Rpdc_using_register_map <= 0;
				Rusing_register_map <= Wusing_register_map;
			end
		end
	end
endmodule // register_arbitrator
