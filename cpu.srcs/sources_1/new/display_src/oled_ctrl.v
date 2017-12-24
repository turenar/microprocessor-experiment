`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/09/08 14:33:18
// Design Name:
// Module Name: oled_ctrl
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

module oled_ctrl(
    clk,
    rst,
    cs,
    sdo,
    sclk,
    dc,
    res,
    vbat,
    vdd,
    char_data,
    print_fin
    );
    input wire clk, rst;
    output wire cs, sdo, sclk, dc, res, vbat, vdd;
    input wire [64*8-1:0] char_data;
    output wire print_fin;

    wire init_cs, init_sdo, init_sclk, init_dc, init_en, init_done;
    wire exam_cs, exam_sdo, exam_sclk, exam_dc, exam_en, exam_done;
    reg [1:0] current_state;

    assign cs   = (current_state == `Octrl_init) ? init_cs : exam_cs;
    assign sdo  = (current_state == `Octrl_init) ? init_sdo : exam_sdo;
    assign sclk = (current_state == `Octrl_init) ? init_sclk : exam_sclk;
    assign dc   = (current_state == `Octrl_init) ? init_dc : exam_dc;
    assign print_fin = exam_done;

    assign init_en = (current_state == `Octrl_init) ? 1 : 0;
    assign exam_en = (current_state == `Octrl_exam) ? 1 : 0;

    oled_init o_init(
    .clk(clk),
    .rst(rst),
    .en(init_en),
    .cs(init_cs),
    .sdo(init_sdo),
    .sclk(init_sclk),
    .dc(init_dc),
    .res(res),
    .vbat(vbat),
    .vdd(vdd),
    .fin(init_done)
    );

    oled_exam o_exam(
    .clk(clk),
    .rst(rst),
    .en(exam_en),
    .cs(exam_cs),
    .sdo(exam_sdo),
    .sclk(exam_sclk),
    .dc(exam_dc),
    .fin(exam_done),
    .char_data(char_data)
    );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            current_state <= `Octrl_idle;
        end else begin
            case(current_state)
                `Octrl_idle: begin
                    current_state <= `Octrl_init;
                end
                `Octrl_init: begin
                    if(init_done) begin
                        current_state <= `Octrl_exam;
                    end
                end
                `Octrl_exam: begin
                    if(exam_done) begin
//                        current_state <= `Octrl_done;
                        current_state <= `Octrl_exam;
                    end
                end
                `Octrl_done: begin
                    current_state <= `Octrl_done;
                end
                default: begin
                    current_state <= `Octrl_idle;
                end
            endcase
        end
    end

endmodule
