module register_arbitrator (
	input clk, input rst,
	input pdc_check,
	input [4:0] pdc_r1_index,
	input [4:0] pdc_r2_index,
	input [4:0] pdc_w_index,
	output pdc_no_conflict,
	output [31:0] pdc_using_register_map,
	input wb_check,
	input [31:0] wb_using_register_map);

	reg [31:0] Rregister_lock;
	reg [31:0] Rpdc_using_register_map; assign pdc_using_register_map = Rpdc_using_register_map;
	reg Rpdc_no_conflict; assign pdc_no_conflict = Rpdc_no_conflict;

	wire [31:0] Wpdc_write_lock;
	assign Wpdc_write_lock = pdc_w_index ? (1 << pdc_w_index) : 0;
	wire [31:0] Wpdc_read_checker;
	assign Wpdc_read_checker =
		(pdc_r1_index ? (1 << pdc_r1_index) : 0)
		| (pdc_r2_index ? (1 << pdc_r2_index) : 0)
		| Wpdc_write_lock;
	wire [31:0] Wregister_lock; // map after wb unlocked
	assign Wregister_lock = Rregister_lock & ~(wb_check ? wb_using_register_map : 0);

	always @ (posedge clk or posedge rst) begin
		if (rst) begin
			Rregister_lock <= 0;
			Rpdc_no_conflict <= 1;
			Rpdc_using_register_map <= 0;
		end else begin
			if (pdc_check) begin
				if (Wpdc_read_checker == (Wpdc_read_checker & ~Wregister_lock)) begin
					Rpdc_no_conflict <= 1;
					Rpdc_using_register_map <= Wpdc_write_lock;
					Rregister_lock <= Wregister_lock | Wpdc_write_lock;
				end else begin
					Rpdc_no_conflict <= 0;
					Rpdc_using_register_map <= 0;
					Rregister_lock <= Wregister_lock;
				end
			end else begin
				Rregister_lock <= Wregister_lock;
			end
		end
	end
endmodule // register_arbitrator
