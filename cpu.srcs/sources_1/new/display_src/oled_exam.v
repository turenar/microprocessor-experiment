`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/09/08 14:33:18
// Design Name:
// Module Name: oled_exam
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

module oled_exam(
    clk,
    rst,
    en,
    cs,
    sdo,
    sclk,
    dc,
    fin,
    char_data
    );
    input wire clk, rst, en;
    output wire cs, sdo, sclk, dc, fin;
    input wire [64*8-1:0] char_data;

    reg t_dc;
    reg [4:0] current_state, after_state, after_page_state,
                after_char_state, after_update_state;
    reg spi_en, delay_en;
    reg [7:0] spi_data;
    reg [7:0] current_screen [0:63];
    reg [11:0] delay_ms;

    reg [7:0] t_char;
    reg [10:0] t_addr;
    wire [7:0] dout;
    reg [1:0] t_page;
    reg [3:0] t_index;

    wire spi_fin, delay_fin;

    integer i;

    assign dc = t_dc;
    assign fin = (current_state == `Wait1_e) ? 1 : 0;

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

    char_rom crom(
    .rst(rst),
    .addr(t_addr),
    .dout(dout)
    );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            current_state <= `Idle_e;
            after_state <= `Idle_e;
            after_page_state <= `Idle_e;
            after_char_state <= `Idle_e;
            after_update_state <= `Idle_e;
            spi_data <= 8'b0;
            delay_ms <= 12'b0;
            t_char <= 8'b0;
            t_addr <= 11'b0;
            t_page <= 2'b0;
            t_index <= 4'b0;
            t_dc <= 0;
            spi_en <= 0;
            delay_en <= 0;
        end else begin
            case(current_state)
                `Idle_e: begin
                    if(en) begin
                        current_state <= `ClearDC;
                        after_page_state <= `STR1;
                        t_page <= 2'b0;
                        t_index <= 4'b0;
                    end
                end
                `STR1: begin
                    current_state <= `UpdateScreen;
                    after_update_state <= `Wait1_e;
                    for(i=63;i>=0;i=i-1) begin
                        current_screen[63-i] <= char_data[(8*i) +: 7];
                    end
                end
                `Wait1_e: begin
                    if(!en) begin
                        current_state <= `Idle_e;
                    end else begin
                        delay_ms <= 12'b000001100100; //100ms
                        current_state <= `Transition3_e;
                        after_state <= `STR1;
                    end
                end

                `UpdateScreen: begin
                    t_char <= current_screen[t_page*16+t_index];
                    current_state <= `SendChar1;
                    if(t_index == 4'b1111) begin
                        t_index <= 0;
                        t_page <= t_page + 1;
                        after_char_state <= `ClearDC;
                        if(t_page == 2'b11) begin
                            after_page_state <= after_update_state;
                        end else begin
                            after_page_state <= `UpdateScreen;
                        end
                    end else begin
                        t_index <= t_index + 1;
                        after_char_state <= `UpdateScreen;
                    end
                end

                `ClearDC: begin
                    t_dc <= 0;
                    current_state <= `SetPage;
                end
                `SetPage: begin
                    spi_data <= 8'b00100010;
                    current_state <= `Transition1_e;
                    after_state <= `PageNum;
                end
                `PageNum: begin
                    spi_data <= {6'b000000, t_page};
                    current_state <= `Transition1_e;
                    after_state <= `LeftColumn1;
                end
                `LeftColumn1: begin
                    spi_data <= 8'b00000000;
                    current_state <= `Transition1_e;
                    after_state <= `LeftColumn2;
                end
                `LeftColumn2: begin
                    spi_data <= 8'b00010000;
                    current_state <= `Transition1_e;
                    after_state <= `SetDC;
                end
                `SetDC: begin
                    t_dc <= 1;
                    current_state <= after_page_state;
                end

                `SendChar1: begin
                    t_addr <= {t_char, 3'b000};
                    current_state <= `ReadMem;
                    after_state <= `SendChar2;
                end
                `SendChar2: begin
                    t_addr <= {t_char, 3'b001};
                    current_state <= `ReadMem;
                    after_state <= `SendChar3;
                end
                `SendChar3: begin
                    t_addr <= {t_char, 3'b010};
                    current_state <= `ReadMem;
                    after_state <= `SendChar4;
                end
                `SendChar4: begin
                    t_addr <= {t_char, 3'b011};
                    current_state <= `ReadMem;
                    after_state <= `SendChar5;
                end
                `SendChar5: begin
                    t_addr <= {t_char, 3'b100};
                    current_state <= `ReadMem;
                    after_state <= `SendChar6;
                end
                `SendChar6: begin
                    t_addr <= {t_char, 3'b101};
                    current_state <= `ReadMem;
                    after_state <= `SendChar7;
                end
                `SendChar7: begin
                    t_addr <= {t_char, 3'b110};
                    current_state <= `ReadMem;
                    after_state <= `SendChar8;
                end
                `SendChar8: begin
                    t_addr <= {t_char, 3'b111};
                    current_state <= `ReadMem;
                    after_state <= after_char_state;
                end
                `ReadMem: begin
                    current_state <= `ReadMem2;
                end
                `ReadMem2: begin
                    spi_data <= dout;
                    current_state <= `Transition1_e;
                end

                `Transition1_e: begin
                    spi_en <= 1;
                    current_state <= `Transition2_e;
                end
                `Transition2_e: begin
                    if(spi_fin) begin
                        current_state <= `Transition5_e;
                    end
                end

                `Transition3_e: begin
                    delay_en <= 1;
                    current_state <= `Transition4_e;
                end
                `Transition4_e: begin
                    if(delay_fin) begin
                        current_state <= `Transition5_e;
                    end
                end

                `Transition5_e: begin
                    spi_en <= 0;
                    delay_en <= 0;
                    current_state <= after_state;
                end

                default: begin
                    current_state <= `Idle_e;
                end
            endcase
        end
    end
endmodule
