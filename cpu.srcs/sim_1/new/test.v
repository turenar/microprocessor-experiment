`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/11/21 15:05:57
// Design Name:
// Module Name: test
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module test();
    reg clk, rst;

	reg [4:0] r1_index;
	reg [4:0] r2_index;
	reg [4:0] w_index;
	wire [31:0] r1_data;
	wire [31:0] r2_data;
	reg [31:0] w_data;

	register r(
	   .clk(clk), .rst(rst),
	   .r1_index(r1_index), .r1_data(r1_data),
	   .r2_index(r2_index), .r2_data(r2_data),
	   .w_index(w_index), .w_data(w_data));

    initial begin
		clk <= 0;
		rst <= 0;
        r1_index <= 0;
        r2_index <= 0;
        w_index <= 0;
        w_data <= 0;
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
		wait_posedge_clk(4);
		w_index <= 3;
		w_data <= 14;
		wait_posedge_clk(4);
		w_index <= 0;
		w_data <= 0;
		r1_index <= 3;
		r2_index <= 3;
		wait_posedge_clk(4);
		$finish;
	end

endmodule
