`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/09/08 14:33:18
// Design Name:
// Module Name: delay_gen
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

module delay_gen(
    clk,
    rst,
    delay_ms,
    delay_en,
    delay_fin
    );
    input clk, rst, delay_en;
    input [11:0] delay_ms;
    output delay_fin;

    reg [16:0] clk_counter;
    reg [11:0] ms_counter;
    reg [1:0]  current_state;

    assign delay_fin = (current_state == `Delay_done && delay_en == 1) ? 1 : 0;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            current_state <= `Delay_idle;
        end else begin
            case(current_state)
                `Delay_idle: begin
                    if(delay_en) begin
                        current_state <= `Delay_hold;
                    end
                end
                `Delay_hold: begin
                    if(ms_counter == delay_ms) begin
                        current_state <= `Delay_done;
                    end
                end
                `Delay_done: begin
                    if(!delay_en) begin
                        current_state <= `Delay_idle;
                    end
                end
                default: begin
                    current_state <= `Delay_idle;
                end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            clk_counter <= 17'b0;
            ms_counter  <= 12'b0;
        end else begin
            if(current_state == `Delay_hold) begin
                if(clk_counter == 17'b11000011010100000) begin
//                if(clk_counter == 17'b00000000000000100) begin
                    clk_counter <= 17'b0;
                    ms_counter <= ms_counter + 1;
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end else begin
                clk_counter <= 17'b0;
                ms_counter <= 12'b0;
            end
        end
    end

endmodule
