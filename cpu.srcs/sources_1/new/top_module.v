`timescale 1ns / 1ps
`include "def.vh"
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

	wire halt;
	wire instruction_executed;
	wire [`ERRC_BITDEF] errno;
	cpu c0(
		.sysclk(sysclk), .rst(~cpu_resetn),
		.halt(halt), .instruction_executed(instruction_executed), .errno(errno));
	assign led[7] = errno != 0;
	assign led[6:0] = 7'b0 | errno;
endmodule
