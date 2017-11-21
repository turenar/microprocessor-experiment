`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2017/11/21 13:45:28
// Design Name:
// Module Name: top_module
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


module top_module(
    input sysclk,
	input cpu_resetn,
    input [7:0] sw,
    output [7:0] led
    );

	wire [4:0] r1_index;
	wire [4:0] r2_index;
	wire [4:0] w_index;

endmodule
