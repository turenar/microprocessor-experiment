`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/09/08 14:33:18
// Design Name:
// Module Name: spi_ctrl
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

module spi_ctrl(
    clk,
    rst,
    spi_en,
    spi_data,
    cs,
    sdo,
    sclk,
    spi_fin
    );
    input wire clk, rst, spi_en;
    input wire [7:0] spi_data;
    output wire cs, sdo, sclk, spi_fin;

    reg t_sdo, falling;
    reg [2:0] current_state;
    reg [7:0] shift_register;
    reg [3:0] shift_counter;
    reg [4:0] counter;

    wire clk_divided = ~counter[4];
    assign sclk = clk_divided;
    assign sdo = t_sdo;

    assign cs = (current_state == `spi_idle && spi_en == 1) ? 1 : 0;
    assign spi_fin = (current_state == `spi_done) ? 1 : 0;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            current_state <= `spi_idle;
        end else begin
            case(current_state)
                `spi_idle: begin
                    if(spi_en) begin
                        current_state <= `spi_send;
                    end
                end
                `spi_send: begin
                    if(shift_counter == 4'b1000 && falling == 0) begin
                        current_state <= `spi_hold1;
                    end
                end
                `spi_hold1: begin
                    current_state <= `spi_hold2;
                end
                `spi_hold2: begin
                    current_state <= `spi_hold3;
                end
                `spi_hold3: begin
                    current_state <= `spi_hold4;
                end
                `spi_hold4: begin
                    current_state <= `spi_done;
                end
                `spi_done: begin
                    if(spi_en == 0) begin
                        current_state <= `spi_idle;
                    end
                end
                default: begin
                    current_state <= `spi_idle;
                end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            counter <= 5'b0;
        end
        else if(current_state == `spi_send) begin
            counter <= counter + 1;
        end
        else begin
            counter <= 5'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            falling <= 0;
            shift_counter <= 4'b0;
            shift_register <= 8'b0;
        end
        else if(current_state == `spi_idle) begin
            shift_counter <= 4'b0;
            shift_register <= spi_data;
            t_sdo <= 1;
        end
        else if(current_state == `spi_send) begin
            if(clk_divided == 0 && falling == 0) begin
                falling <= 1;
                t_sdo <= shift_register[7];
                shift_register <= {shift_register[6:0], 1'b0};
                shift_counter <= shift_counter + 1;
            end
            else if(clk_divided == 1) begin
                falling <= 0;
            end
        end
    end

endmodule
