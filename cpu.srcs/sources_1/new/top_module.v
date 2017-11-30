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

	wire clk;
	reg [1:0] counter;
	wire cpu_clk; assign cpu_clk = counter == 0;
	wire rst; assign rst = ~cpu_resetn;
	wire halt;
	reg [7:0] Rled; assign led = Rled;

	wire mem_wenabled;
	wire [31:0] mem_r1_addr, mem_r2_addr, mem_w_addr;
	wire [31:0] mem_r1_data, mem_r2_data, mem_w_data;

	wire [4:0] reg_r1_index, reg_r2_index, reg_w_index;
	wire [31:0]reg_r1_data, reg_r2_data, reg_w_data;

	wire ic_set_enabled;
	wire ic_next_enabled;
	assign ic_set_enabled = 0; assign ic_next_enabled = counter == 3;
	wire [31:0] ic_set_addr;
	wire [31:0] ic_next_addr;

	instruction_counter ic0(
		.clk(clk), .rst(rst),
		.set_enabled(ic_set_enabled), .next_enabled(ic_next_enabled),
		.set_addr(ic_set_addr), .pc_addr(ic_next_addr));
	assign mem_r1_addr = ic_next_addr;
	ram ram0(
		.clk(~clk), .we(mem_wenabled),
		.r1_addr(mem_r1_addr), .r1_data(mem_r1_data),
		.r2_addr(mem_r2_addr), .r2_data(mem_r2_data),
		.w_addr(mem_w_addr), .w_data(mem_w_data));
	register reg0(
		.clk(~clk), .rst(rst),
		.r1_index(reg_r1_index), .r1_data(reg_r1_data),
		.r2_index(reg_r2_index), .r2_data(reg_r2_data),
		.w_index(reg_w_index), .w_data(reg_w_data));

	wire pdc_halt;
	wire [5:0] pdc_opc;
	wire [1:0] pdc_opt;
	wire [4:0] pdc_rar, pdc_rbr, pdc_ror;
	wire [31:0] pdc_rav, pdc_rbv;
	wire [10:0] pdc_aux;
	wire [15:0] pdc_imm;
	wire [25:0] pdc_addr;
	wire [31:0] pdc_read_mem_addr;
	assign reg_r1_index = pdc_rar;
	assign reg_r2_index = pdc_rbr;
	assign pdc_inst = mem_r1_data;
	predecoder pdc0(
		.clk(clk && (counter == 0 || rst)), .rst(rst), .halt(pdc_halt),
		.instruction(mem_r1_data),
		.opcode(pdc_opc), .optype(pdc_opt),
		.rar(pdc_rar), .rav(pdc_rav), .rbr(pdc_rbr), .rbv(pdc_rbv),
		.rout(pdc_ror), .aux(pdc_aux), .imm(pdc_imm), .addr(pdc_addr),
		.mem_read_addr(pdc_read_mem_addr));

	wire dec_halt;
	wire [5:0] dec_opc;
	wire [1:0] dec_opt;
	wire [4:0] dec_ror;
	wire [31:0] dec_in_rav, dec_in_rbv, dec_rav, dec_rbv;
	wire [10:0] dec_aux;
	assign dec_in_rav = pdc_rar != 0 ? reg_r1_data : pdc_rav;
	assign dec_in_rbv = pdc_rbr != 0 ? reg_r2_data : pdc_rbv;

	decoder dec0(
		.clk(clk && (counter == 1 || rst)), .rst(rst),
		.in_opc(pdc_opc), .in_opt(pdc_opt),
		.in_rav(dec_in_rav), .in_rbv(dec_in_rbv),
		.in_rout(pdc_ror), .in_aux(pdc_aux), .in_imm(pdc_imm), .in_addr(pdc_addr),
		.in_mem_read_addr(pdc_read_mem_addr),
		.out_opc(dec_opc), .out_opt(dec_opt),
		.out_rav(dec_rav), .out_rbv(dec_rbv),
		.out_rout(dec_ror), .out_aux(dec_aux),
		.out_mem_read_addr(mem_r2_addr));

	wire exec_halt;
	wire [31:0] exec_rav, exec_rbv;
	wire [4:0] exec_reg_index;
	wire [31:0] exec_reg_data;
	wire exec_pc_enabled;
	wire [31:0] exec_pc_data;
	wire exec_mem_enabled;
	wire [31:0] exec_mem_addr;
	wire [31:0] exec_mem_data;

	executor exec0(
		.clk(clk && (counter == 2 || rst)), .rst(rst), .halt(exec_halt),
		.opcode(dec_opc), .optype(dec_opt),
		.rav(dec_rav), .rbv(dec_rbv), .rout(dec_ror),
		.aux(dec_aux), .mem_v(mem_r2_data),
		.out_reg_index(exec_reg_index), .out_reg_data(exec_reg_data),
		.out_pc_enabled(exec_pc_enabled), .out_mem_enabled(exec_mem_enabled),
		.out_mem_addr(exec_mem_addr), .out_mem_data(exec_mem_data));

	writeback wb0(
		.clk(clk && (counter == 3 || rst)), .rst(rst),
		.in_reg_index(exec_reg_index), .in_reg_data(exec_reg_data),
		.in_pc_enabled(exec_pc_enabled), .in_pc_data(exec_pc_data),
		.in_mem_enabled(exec_mem_enabled), .in_mem_addr(exec_mem_addr),
		.in_mem_data(exec_mem_data),
		.out_reg_index(reg_w_index), .out_reg_data(reg_w_data),
		.out_pc_enabled(ic_set_enabled), .out_pc_data(ic_set_addr),
		.out_mem_enabled(mem_wenabled), .out_mem_addr(mem_w_addr),
		.out_mem_data(mem_w_data));

	assign clk = sysclk | (dec_halt | exec_halt);
	assign halt = dec_halt || exec_halt;

	initial begin
		Rled <= 0;
	end
	always @ (posedge clk) begin
		if(rst) begin
			counter <= 0;
		end else if (halt) begin
			Rled <= 1;
		end else begin
			counter <= counter + 1;
		end
	end
endmodule
