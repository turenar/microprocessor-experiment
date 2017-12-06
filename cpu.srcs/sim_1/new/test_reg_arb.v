`timescale 1ns / 1ps

module test_reg_arb();
	reg clk, rst;
	reg [4:0] pdc_r1_index, pdc_r2_index, pdc_w_index;
	wire pdc_no_conflict;
	wire [31:0] pdc_using_register_map;
	reg [31:0] wb_using_register_map;
	register_arbitrator ra1(
		.clk(~clk), .rst(rst),
		.pdc_r1_index(pdc_r1_index), .pdc_r2_index(pdc_r2_index),
		.pdc_w_index(pdc_w_index),
		.pdc_no_conflict(pdc_no_conflict), .pdc_using_register_map(pdc_using_register_map),
		.wb_using_register_map(wb_using_register_map));

	initial begin
		clk <= 0;
		rst <= 0;
		pdc_r1_index <= 0;
		pdc_r2_index <= 0;
		pdc_w_index <= 0;
		wb_using_register_map <= 0;
    end

	always #5 begin
		clk <= ~clk;
	end

	task wait_posedge_clk;
		input   n;
		integer n;

		begin
			for(n=n; n>0; n=n-1) begin
				@(posedge clk)
					;
			end
		end
	endtask

	initial begin
		wait_posedge_clk(1);
		rst <= 1;
		wait_posedge_clk(1);
		rst <= 0;
		wait_posedge_clk(1);
		pdc_r1_index <= 1;
		wait_posedge_clk(4);
		pdc_r1_index <= 2;
		pdc_r2_index <= 3;
		pdc_w_index <= 4;
		wait_posedge_clk(2);
		pdc_w_index <= 1;
		wait_posedge_clk(4);
		wb_using_register_map <= 4'b1110;
		wait_posedge_clk(1);
		wb_using_register_map <= 0;
		wait_posedge_clk(4);

		$finish;
	end
endmodule
