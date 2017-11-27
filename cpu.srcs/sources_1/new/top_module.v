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

	wire halt;

	wire mem_wenabled;
	assign mem_wenabled = 0;
	wire [7:0] mem_r1_addr, mem_r2_addr, mem_w_addr;
	wire [31:0]mem_r1_data, mem_r2_data, mem_w_data;

	wire [4:0] reg_r1_index, reg_r2_index, reg_w_index;
	wire [31:0]reg_r1_data, reg_r2_data, reg_w_data;

	wire ic_set_enabled;
	wire ic_next_enabled;
	assign ic_set_enabled = 0; assign ic_next_enabled = sw[0];
	reg [31:0] ic_set_addr;
	wire [31:0] ic_next_addr;

	wire [31:0] dec_inst;
	wire [5:0] dec_opc;
	wire [1:0] dec_opt;
	wire [4:0] dec_rar, dec_rbr, dec_ror;
	wire [31:0] dec_rav, dec_rbv;
	wire [10:0] dec_aux;
	wire [15:0] dec_imm;
	wire [20:0] dec_ddr;

	wire [10:0] alu_aux;
	wire [31:0] alu_ra, alu_rb, alu_rout;

	instruction_counter ic0(
		.clk(sysclk), .rst(~cpu_resetn),
		.set_enabled(ic_set_enabled), .next_enabled(ic_next_enabled),
		.set_addr(ic_set_addr), .pc_addr(ic_next_addr));
	assign mem_r1_addr = ic_next_addr;
	ram ram0(
		.clk(~sysclk), .we(mem_wenabled),
		.r1_addr(mem_r1_addr), .r1_data(mem_r1_data),
		.r2_addr(mem_r2_addr), .r2_data(mem_r2_data),
		.w_addr(mem_w_addr), .w_data(mem_w_data));
	register reg0(
		.clk(~sysclk), .rst(~cpu_resetn),
		.r1_index(reg_r1_index), .r1_data(reg_r1_data),
		.r2_index(reg_r2_index), .r2_data(reg_r2_data),
		.w_index(reg_w_index), .w_data(reg_w_data));
	assign reg_r1_index = dec_rar;
	assign reg_r2_index = dec_rbr;
	assign dec_inst = mem_r1_data;
	decoder dec0(
		.clk(sysclk), .rst(~cpu_resetn), .halt(halt),
		.instruction(dec_inst),
		.opcode(dec_opc), .optype(dec_opt),
		.rar(dec_rar), .rav(dec_rav), .rbr(dec_rbr), .rbv(dec_rbv),
		.rout(dec_ror), .aux(dec_aux), .imm(dec_imm), .addr(dec_addr));
	assign alu_aux = dec_aux;
	assign alu_ra = dec_rar ? reg_r1_data : dec_rav;
	assign alu_rb = dec_rbr ? reg_r2_data : dec_rbv;
	alu alu0(
		.clk(sysclk), .aux(alu_aux),
		.ra(alu_ra), .rb(alu_rb), .rc(alu_rout));
endmodule
