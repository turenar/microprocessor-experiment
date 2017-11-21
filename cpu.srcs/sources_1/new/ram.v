`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/21 13:45:28
// Design Name: 
// Module Name: ram
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



module ram(
	input clk,
	input we,
	input [7:0] r_addr,
	input [31:0] r_data,
	input [7:0] w_addr,
	input [31:0] w_data
);
	reg [4:0] addr_reg;
	reg [31:0] mem [0:255];

	always @(posedge clk) begin
		if(we) mem[w_addr] <= w_data; //書き込みのタイミングを同期
		addr_reg <= r_addr;           //読み出しアドレスを同期
	end

	assign r_data = mem[addr_reg];
endmodule
