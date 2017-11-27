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
	input [7:0] r1_addr,
	input [31:0] r1_data,
	input [7:0] r2_addr,
	input [31:0] r2_data,
	input [7:0] w_addr,
	input [31:0] w_data
);
	reg [4:0] addr1_reg;
	reg [4:0] addr2_reg;
	reg [31:0] mem [0:255];

	integer i;
	initial begin
		// for(i=0;i<65536;i=i+1) mem[i] <= 0;
		$readmemb("../../../../init.ram", mem);
	end

	always @(posedge clk) begin
		if(we) mem[w_addr] <= w_data; //書き込みのタイミングを同期
		addr1_reg <= r1_addr;           //読み出しアドレスを同期
		addr2_reg <= r2_addr;           //読み出しアドレスを同期
	end

	assign r1_data = mem[addr1_reg];
	assign r2_data = mem[addr2_reg];
endmodule
