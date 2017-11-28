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

`define MEM_SIZE 65536

module ram(
	input clk,
	input we,
	input [31:0] r1_addr,
	input [31:0] r1_data,
	input [31:0] r2_addr,
	input [31:0] r2_data,
	input [31:0] w_addr,
	input [31:0] w_data
);
	reg [13:0] addr1_reg;
	reg [13:0] addr2_reg;
	reg [31:0] mem [0:(`MEM_SIZE-1)];

	wire [13:0] Wr1_index, Wr2_index, Ww_index;
	assign Wr1_index = r1_addr[15:2];
	assign Wr2_index = r2_addr[15:2];
	assign Ww_index = w_addr[15:2];


	integer i;
	initial begin
		for(i = 0; i < `MEM_SIZE; i=i+1) mem[i] = 0;
		$readmemb("../../../../init.ram", mem);
	end

	always @(posedge clk) begin
		if(we) mem[Ww_index] <= w_data; //書き込みのタイミングを同期
		addr1_reg <= Wr1_index;           //読み出しアドレスを同期
		addr2_reg <= Wr2_index;           //読み出しアドレスを同期
	end

	assign r1_data = mem[addr1_reg];
	assign r2_data = mem[addr2_reg];
endmodule
