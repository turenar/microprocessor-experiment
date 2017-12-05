`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/09/06 18:29:33
// Design Name:
// Module Name: topmodule
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
`include "char_def.vh"
`include "state_def.vh"

module display_top(
    input SYSCLK_IP,
    input [7:0] SW_IP,
    input CPU_RESETN_IP,
    output [7:0] LED_OP,
    output OLED_DC_OP,     //Data/Command Pin
    output OLED_RES_OP,    //OLED RES
    output OLED_SCLK_OP,   //SPI Clock
    output OLED_SDIN_OP,   //SPI data out
    output OLED_VBAT_OP,   //VBAT enable
    output OLED_VDD_OP,     //VDD enable
    input WE_IP,
    input [5:0] WRITE_ADDR_IP,
    input [7:0] WRITE_DATA_IP
    );

    reg [7:0] sw_r;
    wire [64*8-1:0] char_data;
    wire print_fin;

    oled_ctrl o_ctrl(
    .clk(SYSCLK_IP),
    .rst(~CPU_RESETN_IP),
    .dc(OLED_DC_OP),
    .res(OLED_RES_OP),
    .sclk(OLED_SCLK_OP),
    .sdo(OLED_SDIN_OP),
    .vbat(OLED_VBAT_OP),
    .vdd(OLED_VDD_OP),
    .char_data(char_data),
    .print_fin(print_fin)
    );

    char_test c_test(
    .clk(SYSCLK_IP),
    .rst(~CPU_RESETN_IP),
    .dout(char_data),
    .print_fin(print_fin),
    .we(WE_IP),
    .wr_addr(WRITE_ADDR_IP),
    .din(WRITE_DATA_IP)
    );

    assign LED_OP = sw_r;

    always @(posedge SYSCLK_IP)
        sw_r <= SW_IP;

endmodule
