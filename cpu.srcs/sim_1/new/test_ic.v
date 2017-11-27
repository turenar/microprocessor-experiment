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


module test_ic();
    reg clk, rst;

	reg set_enabled;
	reg next_enabled;
	reg [31:0] set_addr;
	wire [31:0] pc_addr;

	instruction_counter ic(
		.clk(clk), .rst(rst),
		.set_enabled(set_enabled), .next_enabled(next_enabled),
		.set_addr(set_addr), .pc_addr(pc_addr)
		);

    initial begin
		clk <= 0;
		rst <= 0;
		set_enabled <= 0;
		next_enabled <= 0;
		set_addr <= 0;
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
		next_enabled <= 1;
		wait_posedge_clk(4);
		next_enabled <= 0;
		wait_posedge_clk(4);
		set_enabled <= 1;
		set_addr <= 'hffff0080;
		wait_posedge_clk(1);
		set_enabled <= 0;
		wait_posedge_clk(1);
		next_enabled <= 1;
		wait_posedge_clk(16);

		$finish;
	end

endmodule
