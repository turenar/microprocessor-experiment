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


module test_top();
	reg clk;
	reg rst;
	reg [7:0] sw;
	wire [7:0] led;

	top_module tm(
		.sysclk(clk), .cpu_resetn(~rst),
		.sw(sw), .led(led));

    initial begin
		clk <= 0;
		rst <= 0;
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
		sw[0] = 1;
		@(posedge led[7])
			;
		wait_posedge_clk(10);
		$finish;
	end

endmodule
