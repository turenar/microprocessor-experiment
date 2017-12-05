`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/09/08 14:33:18
// Design Name:
// Module Name: oled_init
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

module oled_init(
    clk,
    rst,
    en,
    cs,
    sdo,
    sclk,
    dc,
    res,
    vbat,
    vdd,
    fin
    );
    input wire clk, rst, en;
    output wire cs, dc, res, sclk, sdo, vbat, vdd, fin;

    reg t_dc, t_res, t_vbat, t_vdd, t_fin;
    reg [4:0] current_state, after_state;
    reg spi_en, delay_en;
    reg [7:0] spi_data;
    wire [11:0] delay_ms = (after_state == `DispContrast1) ?
                            12'b000001100100 : 12'b000000000001;

    wire spi_fin, delay_fin;

    assign dc = t_dc;
    assign res = t_res;
    assign vbat = t_vbat;
    assign vdd = t_vdd;
    assign fin = t_fin;

    spi_ctrl sctrl(
    .clk(clk),
    .rst(rst),
    .spi_en(spi_en),
    .spi_data(spi_data),
    .cs(cs),
    .sdo(sdo),
    .sclk(sclk),
    .spi_fin(spi_fin)
    );

    delay_gen dgen(
    .clk(clk),
    .rst(rst),
    .delay_ms(delay_ms),
    .delay_en(delay_en),
    .delay_fin(delay_fin)
    );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            current_state <= `Idle;
            after_state <= `Idle;
            spi_data <= 8'b0;
            t_dc <= 0;
            t_res <= 0;
            t_vbat <= 1;
            t_vdd <= 1;
            t_fin <= 0;
            spi_en <= 0;
            delay_en <= 0;
        end else begin
            case(current_state)
                `Idle: begin
                    if(en) begin
                        t_res <= 1;
                        current_state <= `VddOn;
                    end
                end
                `VddOn: begin
                    t_vdd <= 0;
                    current_state <= `Wait1;
                end
                `Wait1: begin
                    current_state <= `Transition3;
                    after_state <= `DispOff;
                end
                `DispOff: begin
                    spi_data <= 8'b10101110;
                    current_state <= `Transition1;
                    after_state <= `ResetOn;
                end
                `ResetOn: begin
                    t_res <= 0;
                    current_state <= `Wait2;
                end
                `Wait2: begin
                    current_state <= `Transition3;
                    after_state <= `ResetOff;
                end
                `ResetOff: begin
                    t_res <= 1;
                    current_state <= `Transition3;
                    after_state <= `ChargePump1;
                end
                `ChargePump1: begin
                    spi_data <= 8'b10001101;
                    current_state <= `Transition1;
                    after_state <= `ChargePump2;
                end
                `ChargePump2: begin
                    spi_data <= 8'b00010100;
                    current_state <= `Transition1;
                    after_state <= `PreCharge1;
                end
                `PreCharge1: begin
                    spi_data <= 8'b11011001;
                    current_state <= `Transition1;
                    after_state <= `PreCharge2;
                end
                `PreCharge2: begin
                    spi_data <= 8'b11110001;
                    current_state <= `Transition1;
                    after_state <= `VbatOn;
                end
                `VbatOn: begin
                    t_vbat <= 0;
                    current_state <= `Wait3;
                end
                `Wait3: begin
                    current_state <= `Transition3;
                    after_state <= `DispContrast1;
                end
                `DispContrast1: begin
                    spi_data <= 8'b10000001;
                    current_state <= `Transition1;
                    after_state <= `InvertDisp1;
                end
                `DispContrast2: begin
                    spi_data <= 8'b00001111;
                    current_state <= `Transition1;
                    after_state <= `InvertDisp1;
                end
                `InvertDisp1: begin
                    spi_data <= 8'b10100000;
                    current_state <= `Transition1;
                    after_state <= `InvertDisp2;
                end
                `InvertDisp2: begin
                    spi_data <= 8'b11000000;
                    current_state <= `Transition1;
                    after_state <= `ComConfig1;
                end
                `ComConfig1: begin
                    spi_data <= 8'b11011010;
                    current_state <= `Transition1;
                    after_state <= `ComConfig2;
                end
                `ComConfig2: begin
                    spi_data <= 8'b00000000;
                    current_state <= `Transition1;
                    after_state <= `ComConfig3;
                end
                `ComConfig3: begin
                    spi_data <= 8'b11000000;
                    current_state <= `Transition1;
                    after_state <= `ComConfig4;
                end
                `ComConfig4: begin
                    spi_data <= 8'b00100000;
                    current_state <= `Transition1;
                    after_state <= `ComConfig5;
                end
                `ComConfig5: begin
                    spi_data <= 8'b00000000;
                    current_state <= `Transition1;
                    after_state <= `DispOn;
                end
                `DispOn: begin
                    spi_data <= 8'b10101111;
                    current_state <= `Transition1;
                    after_state <= `Done;
                end
                `Done: begin
                    if(!en) begin
                        t_fin <= 0;
                        current_state <= `Idle;
                    end else begin
                        t_fin <= 1;
                    end
                end

                `Transition1: begin
                    spi_en <= 1;
                    current_state <= `Transition2;
                end
                `Transition2: begin
                    if(spi_fin) begin
                        current_state <= `Transition5;
                    end
                end

                `Transition3: begin
                    delay_en <= 1;
                    current_state <= `Transition4;
                end
                `Transition4: begin
                    if(delay_fin) begin
                        current_state <= `Transition5;
                    end
                end

                `Transition5: begin
                    spi_en <= 0;
                    delay_en <= 0;
                    current_state <= after_state;
                end

                default: begin
                    current_state <= `Idle;
                end
            endcase
        end
    end
endmodule
