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
	output [7:0] led,
	output oled_dc,     //Data/Command Pin
	output oled_res,    //OLED RES
	output oled_sclk,   //SPI Clock
	output oled_sdin,   //SPI data out
	output oled_vbat,   //VBAT enable
	output oled_vdd     //VDD enable
	);

	wire halt;
	wire instruction_executed;
	wire [`ERRC_BITDEF] errno;
	cpu c0(
		.sysclk(sysclk), .rst(~cpu_resetn),
		.halt(halt), .instruction_executed(instruction_executed), .errno(errno));

	wire [63:0] hcsc_counter;
	hardware_counter hc_sysclk(
		.CLK_IP(sysclk & ~halt), .RSTN_IP(cpu_resetn),
		.COUNTER_OP(hcsc_counter));

	wire [63:0] hccc_counter;
	hardware_counter hc_cpuclk(
		.CLK_IP(instruction_executed), .RSTN_IP(cpu_resetn),
		.COUNTER_OP(hccc_counter));

	reg [2:0] counter;
	reg dt_we;
	reg [5:0] dt_waddr;
	reg [7:0] dt_wdata;
	wire [7:0] dt_led;
	display_top dt(
		.SYSCLK_IP(sysclk), .SW_IP(sw), .CPU_RESETN_IP(cpu_resetn),
		.LED_OP(dt_led), .OLED_DC_OP(oled_dc), .OLED_RES_OP(oled_res),
		.OLED_SCLK_OP(oled_sclk), .OLED_SDIN_OP(oled_sdin),
		.OLED_VBAT_OP(oled_vbat), .OLED_VDD_OP(oled_vdd),
		.WE_IP(ms_we), .WRITE_ADDR_IP(ms_addr), .WRITE_DATA_IP(ms_data));

	assign led[7] = errno != 0;
	assign led[6:0] = 7'b0 | errno;

	always @ (posedge sysclk) begin
		if (~cpu_resetn) begin
			counter <= 0;
			dt_we <= 0; dt_waddr <= 0; dt_wdata <= 0;
		end else if (halt) begin
			if (counter[2] == 0) begin
				counter <= counter + 1;
			end else begin
				dt_we <= 0;
			end
		end
	end
endmodule
