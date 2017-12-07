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


module cpu(
    input sysclk,
	input rst,
	output halt,
	output instruction_executed,
	output [`ERRC_BITDEF] errno
    );

	wire clk;
	wire cpu_clk; assign cpu_clk = clk;
	assign instruction_executed = 1; // FIXME

	wire pipeline_flush;

	wire mem_wenabled;
	wire [31:0] mem_r1_addr, mem_r2_addr, mem_w_addr;
	wire [31:0] mem_r1_data, mem_r2_data, mem_w_data;

	wire [4:0] reg_r1_index, reg_r2_index, reg_w_index;
	wire [31:0]reg_r1_data, reg_r2_data, reg_w_data;

	wire ic_set_enabled;
	wire ic_next_enabled;
	wire [31:0] ic_set_addr;
	wire [31:0] ic_next_addr;

	instruction_counter ic0(
		.clk(clk), .rst(rst),
		.set_enabled(ic_set_enabled), .next_enabled(ic_next_enabled),
		.set_addr(ic_set_addr), .pc_addr(ic_next_addr));
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

	wire rab_pdc_check;
	wire rab_pdc_no_conflict;
	wire [31:0] rab_using_reg_map;
	wire [31:0] rab_wb_in_using_register_map;
	wire [4:0] pdc_rar, pdc_rbr, pdc_ror;
	assign ic_next_enabled = rab_pdc_no_conflict;
	register_arbitrator rab (
		.clk(~clk), .rst(rst || pipeline_flush), .pdc_check(~clk),
		.pdc_r1_index(pdc_rar), .pdc_r2_index(pdc_rbr), .pdc_w_index(pdc_ror),
		.pdc_no_conflict(rab_pdc_no_conflict), .pdc_using_register_map(rab_using_reg_map),
		.wb_check(~clk),
		.wb_using_register_map(rab_wb_in_using_register_map));

	wire mab_locked_fault;
	wire mab_dec_r_enabled, mab_dec_w_enabled, mab_wb_w_enabled;
	wire [31:0] mab_dec_r_addr, mab_dec_w_addr, mab_wb_w_addr;
	memory_arbitrator mab (
		.clk(~clk), .rst(rst || pipeline_flush), .dec_locked_fault(mab_locked_fault),
		.dec_r_enabled(mab_dec_r_enabled), .dec_w_enabled(mab_dec_w_enabled),
		.dec_r_addr(mab_dec_r_addr), .dec_w_addr(mab_dec_w_addr),
		.wb_w_enabled(mab_wb_w_enabled), .wb_w_addr(mab_wb_w_addr));

	wire [`ERRC_BITDEF] pdc_errno;
	wire pdc_enabled;
	wire [31:0] pdc_npc;
	wire [31:0] pdc_inst;
	wire [5:0] pdc_opc;
	wire [`OPTYPE_BITDEF] pdc_opt;
	// wire [4:0] pdc_rar, pdc_rbr, pdc_ror;
	wire [31:0] pdc_rav, pdc_rbv;
	wire [10:0] pdc_aux;
	wire [15:0] pdc_imm;
	wire [25:0] pdc_addr;
	wire [31:0] pdc_read_mem_addr;
	assign reg_r1_index = pdc_rar;
	assign reg_r2_index = pdc_rbr;
	assign pdc_inst = mem_r1_data;
	assign pdc_enabled = rab_pdc_no_conflict && ~mab_locked_fault;
	predecoder pdc0(
		.clk(clk), .rst(rst || pipeline_flush),
		.enabled(pdc_enabled), .errno(pdc_errno),
		.in_npc(mem_r1_addr), .instruction(mem_r1_data),
		.out_npc(pdc_npc), .opcode(pdc_opc), .optype(pdc_opt),
		.rar(pdc_rar), .rav(pdc_rav), .rbr(pdc_rbr), .rbv(pdc_rbv),
		.rout(pdc_ror), .aux(pdc_aux), .imm(pdc_imm), .addr(pdc_addr));

	wire [`ERRC_BITDEF] dec_errno;
	wire dec_enabled;
	wire [31:0] dec_npc;
	wire [31:0] dec_reg_map;
	wire [5:0] dec_opc;
	wire [`OPTYPE_BITDEF] dec_opt;
	wire [4:0] dec_ror;
	wire [31:0] dec_in_rav, dec_in_rbv, dec_rav, dec_rbv;
	wire [10:0] dec_aux;
	wire dec_mem_r_enabled, dec_mem_w_enabled;
	wire [31:0] dec_mem_r_addr, dec_mem_w_addr;
	assign mab_dec_r_enabled = dec_mem_r_enabled;
	assign mab_dec_w_enabled = dec_mem_w_enabled;
	assign mab_dec_r_addr = dec_mem_r_addr;
	assign mab_dec_w_addr = dec_mem_w_addr;
	assign mem_r2_addr = mab_dec_r_addr;
	assign dec_in_rav = pdc_rar != 0 ? reg_r1_data : pdc_rav;
	assign dec_in_rbv = pdc_rbr != 0 ? reg_r2_data : pdc_rbv;
	assign dec_enabled = ~mab_locked_fault;

	decoder dec0(
		.clk(clk), .rst(rst || pipeline_flush),
		.enabled(dec_enabled), .in_valid(rab_pdc_no_conflict),
		.in_errno(pdc_errno), .out_errno(dec_errno),
		.in_npc(pdc_npc), .in_reg_map(rab_using_reg_map), .in_opc(pdc_opc), .in_opt(pdc_opt),
		.in_rav(dec_in_rav), .in_rbv(dec_in_rbv),
		.in_rout(pdc_ror), .in_aux(pdc_aux), .in_imm(pdc_imm), .in_addr(pdc_addr),
		.out_npc(dec_npc), .out_reg_map(dec_reg_map), .out_opc(dec_opc), .out_opt(dec_opt),
		.out_rav(dec_rav), .out_rbv(dec_rbv),
		.out_rout(dec_ror), .out_aux(dec_aux),
		.out_mem_read_enabled(dec_mem_r_enabled), .out_mem_write_enabled(dec_mem_w_enabled),
		.out_mem_read_addr(dec_mem_r_addr), .out_mem_write_addr(dec_mem_w_addr));

	wire [`ERRC_BITDEF] exec_errno;
	wire exec_enabled;
	wire [31:0] exec_npc;
	wire [31:0] exec_reg_map;
	wire [31:0] exec_rav, exec_rbv;
	wire [4:0] exec_reg_index;
	wire [31:0] exec_reg_data;
	wire exec_pc_enabled;
	wire [31:0] exec_pc_addr;
	wire exec_mem_enabled;
	wire [31:0] exec_mem_addr;
	wire [31:0] exec_mem_data;
	assign exec_enabled = rab_pdc_no_conflict;

	executor exec0(
		.clk(clk), .rst(rst || pipeline_flush),
		.enabled(1'b1), .in_valid(~mab_locked_fault),
		.in_errno(dec_errno), .out_errno(exec_errno),
		.in_npc(dec_npc), .in_reg_map(dec_reg_map), .opcode(dec_opc), .optype(dec_opt),
		.rav(dec_rav), .rbv(dec_rbv), .rout(dec_ror),
		.aux(dec_aux), .mem_v(mem_r2_data),
		.out_npc(exec_npc), .out_reg_map(exec_reg_map),
		.out_reg_index(exec_reg_index), .out_reg_data(exec_reg_data),
		.out_pc_enabled(exec_pc_enabled), .out_pc_addr(exec_pc_addr), .out_mem_enabled(exec_mem_enabled),
		.out_mem_addr(exec_mem_addr), .out_mem_data(exec_mem_data));

	wire wb_set_pc_pulse;
	wire [`ERRC_BITDEF] wb_errno;
	wire [31:0] wb_reg_map; assign rab_wb_in_using_register_map = wb_reg_map;
	wire wb_pc_enabled;
	wire [31:0] wb_pc_addr;

	writeback wb0(
		.clk(clk), .rst(rst),
		.in_errno(exec_errno), .out_errno(wb_errno),
		.in_npc(exec_npc), .in_reg_map(exec_reg_map), .in_reg_index(exec_reg_index),
		.in_reg_data(exec_reg_data),
		.in_pc_enabled(exec_pc_enabled), .in_pc_addr(exec_pc_addr),
		.in_mem_enabled(exec_mem_enabled), .in_mem_addr(exec_mem_addr),
		.in_mem_data(exec_mem_data), .out_set_pc_pulse(wb_set_pc_pulse),
		.out_reg_index(reg_w_index), .out_reg_map(wb_reg_map), .out_reg_data(reg_w_data),
		.out_pc_enabled(wb_pc_enabled), .out_pc_addr(wb_pc_addr),
		.out_mem_enabled(mem_wenabled), .out_mem_addr(mem_w_addr),
		.out_mem_data(mem_w_data));
	assign mem_r1_addr = wb_pc_enabled ? wb_pc_addr : ic_next_addr;
	assign mab_wb_w_enabled = mem_wenabled;
	assign mab_wb_w_addr = mem_w_addr;
	assign ic_set_enabled = wb_pc_enabled;
	assign ic_set_addr = wb_pc_addr + 4;
	assign pipeline_flush = wb_set_pc_pulse;

	assign halt = wb_errno != `ERRC_NOERR;
	assign errno = wb_errno;
	assign clk = sysclk & ~halt;
endmodule
