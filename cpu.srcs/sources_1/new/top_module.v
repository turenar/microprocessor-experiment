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
	wire c_extmem_wenabled;
	wire [31:0] c_extmem_addr, c_extmem_data;
	cpu c0(
		.sysclk(sysclk), .rst(~cpu_resetn),
		.halt(halt), .instruction_executed(instruction_executed), .errno(errno),
		.extmem_wenabled(c_extmem_wenabled), .extmem_addr(c_extmem_addr),
		.extmem_data(c_extmem_data));

	wire [63:0] hcsc_counter;
	hardware_counter hc_sysclk(
		.CLK_IP(sysclk & ~halt), .RSTN_IP(cpu_resetn),
		.COUNTER_OP(hcsc_counter));

	wire [63:0] hccc_counter;
	hardware_counter hc_cpuclk(
		.CLK_IP(instruction_executed), .RSTN_IP(cpu_resetn),
		.COUNTER_OP(hccc_counter));

	reg tm_em_wenabled;
	reg [31:0] tm_em_addr, tm_em_data;
	wire extmem_wenabled; assign extmem_wenabled = c_extmem_wenabled || tm_em_wenabled;
	wire [31:0] extmem_addr, extmem_data;
	assign extmem_addr = c_extmem_wenabled ? c_extmem_addr : tm_em_addr;
	assign extmem_data = c_extmem_wenabled ? c_extmem_data : tm_em_data;
	wire ms_we;
	wire [5:0] ms_addr;
	wire [7:0] ms_data;

	multipaged_screen ms(
		.clk(sysclk), .rst(~cpu_resetn),
		.write_enabled(extmem_wenabled), .address(extmem_addr),
		.data(extmem_data), .page(sw[1:0]),
		.oled_write_enabled(ms_we), .oled_addr(ms_addr),
		.oled_data(ms_data));

	reg [31:0] cpu_inst_executed;
	wire [7:0] dt_led;
	display_top dt(
		.SYSCLK_IP(sysclk), .SW_IP(sw), .CPU_RESETN_IP(cpu_resetn),
		.LED_OP(dt_led), .OLED_DC_OP(oled_dc), .OLED_RES_OP(oled_res),
		.OLED_SCLK_OP(oled_sclk), .OLED_SDIN_OP(oled_sdin),
		.OLED_VBAT_OP(oled_vbat), .OLED_VDD_OP(oled_vdd),
		.WE_IP(ms_we), .WRITE_ADDR_IP(ms_addr), .WRITE_DATA_IP(ms_data));

	assign led[7] = errno != 0;
	assign led[6:0] = 7'b0 | errno;

	reg [7:0] counter;

	task Textmem_write(input [5:0] addr, input [31:0] data);
		begin
			tm_em_addr <= {22'h3fffff, 2'b01 /*page*/, addr, 2'b00 /* 4byte align*/};
			tm_em_data <= data;
		end
	endtask

	always @ (posedge sysclk or negedge cpu_resetn) begin
		if (~cpu_resetn) begin
			counter <= 0; cpu_inst_executed <= 0;
			tm_em_wenabled <= 0; tm_em_addr <= 0; tm_em_data <= 0;
		end else if (halt) begin
			if (counter[5] == 0) begin
				tm_em_wenabled <= 1;
				if (counter[4] == 0) begin
					Textmem_write(8 + counter[2:0], hcsc_counter >> ((7 - counter[2:0]) << 3));
				end else begin
					Textmem_write(24 + counter[2:0], hccc_counter >> ((7 - counter[2:0]) << 3));
				end
				counter <= counter + 1;
			end else begin
				tm_em_wenabled <= 0;
			end
		end
	end
endmodule
