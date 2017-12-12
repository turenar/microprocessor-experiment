`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2016/09/08 14:33:18
// Design Name:
// Module Name: char_test
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

module char_test(
    clk,
    rst,
    print_fin,
    dout,
    we,
    wr_addr,
    din
    );
    input wire clk, rst, print_fin, we;
    input wire [5:0] wr_addr;
    input wire [7:0] din;
    output wire [64*8-1:0] dout;

    reg [64*8-1:0] c_data;

    assign dout = c_data;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            c_data <= {`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,
                        `Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,
                        `Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,
                        `Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null,`Null};
        end else begin
//            if(print_fin) begin
//                c_data <= {c_data[63*8-1:0],c_data[64*8-1:63*8]};
//            end
            if(we) begin
                case(wr_addr)
                    6'd0 : c_data[64*8-1:63*8] <= din;
                    6'd1 : c_data[63*8-1:62*8] <= din;
                    6'd2 : c_data[62*8-1:61*8] <= din;
                    6'd3 : c_data[61*8-1:60*8] <= din;
                    6'd4 : c_data[60*8-1:59*8] <= din;
                    6'd5 : c_data[59*8-1:58*8] <= din;
                    6'd6 : c_data[58*8-1:57*8] <= din;
                    6'd7 : c_data[57*8-1:56*8] <= din;
                    6'd8 : c_data[56*8-1:55*8] <= din;
                    6'd9 : c_data[55*8-1:54*8] <= din;
                    6'd10 : c_data[54*8-1:53*8] <= din;
                    6'd11 : c_data[53*8-1:52*8] <= din;
                    6'd12 : c_data[52*8-1:51*8] <= din;
                    6'd13 : c_data[51*8-1:50*8] <= din;
                    6'd14 : c_data[50*8-1:49*8] <= din;
                    6'd15 : c_data[49*8-1:48*8] <= din;
                    6'd16 : c_data[48*8-1:47*8] <= din;
                    6'd17 : c_data[47*8-1:46*8] <= din;
                    6'd18 : c_data[46*8-1:45*8] <= din;
                    6'd19 : c_data[45*8-1:44*8] <= din;
                    6'd20 : c_data[44*8-1:43*8] <= din;
                    6'd21 : c_data[43*8-1:42*8] <= din;
                    6'd22 : c_data[42*8-1:41*8] <= din;
                    6'd23 : c_data[41*8-1:40*8] <= din;
                    6'd24 : c_data[40*8-1:39*8] <= din;
                    6'd25 : c_data[39*8-1:38*8] <= din;
                    6'd26 : c_data[38*8-1:37*8] <= din;
                    6'd27 : c_data[37*8-1:36*8] <= din;
                    6'd28 : c_data[36*8-1:35*8] <= din;
                    6'd29 : c_data[35*8-1:34*8] <= din;
                    6'd30 : c_data[34*8-1:33*8] <= din;
                    6'd31 : c_data[33*8-1:32*8] <= din;
                    6'd32 : c_data[32*8-1:31*8] <= din;
                    6'd33 : c_data[31*8-1:30*8] <= din;
                    6'd34 : c_data[30*8-1:29*8] <= din;
                    6'd35 : c_data[29*8-1:28*8] <= din;
                    6'd36 : c_data[28*8-1:27*8] <= din;
                    6'd37 : c_data[27*8-1:26*8] <= din;
                    6'd38 : c_data[26*8-1:25*8] <= din;
                    6'd39 : c_data[25*8-1:24*8] <= din;
                    6'd40 : c_data[24*8-1:23*8] <= din;
                    6'd41 : c_data[23*8-1:22*8] <= din;
                    6'd42 : c_data[22*8-1:21*8] <= din;
                    6'd43 : c_data[21*8-1:20*8] <= din;
                    6'd44 : c_data[20*8-1:19*8] <= din;
                    6'd45 : c_data[19*8-1:18*8] <= din;
                    6'd46 : c_data[18*8-1:17*8] <= din;
                    6'd47 : c_data[17*8-1:16*8] <= din;
                    6'd48 : c_data[16*8-1:15*8] <= din;
                    6'd49 : c_data[15*8-1:14*8] <= din;
                    6'd50 : c_data[14*8-1:13*8] <= din;
                    6'd51 : c_data[13*8-1:12*8] <= din;
                    6'd52 : c_data[12*8-1:11*8] <= din;
                    6'd53 : c_data[11*8-1:10*8] <= din;
                    6'd54 : c_data[10*8-1:9*8] <= din;
                    6'd55 : c_data[9*8-1:8*8] <= din;
                    6'd56 : c_data[8*8-1:7*8] <= din;
                    6'd57 : c_data[7*8-1:6*8] <= din;
                    6'd58 : c_data[6*8-1:5*8] <= din;
                    6'd59 : c_data[5*8-1:4*8] <= din;
                    6'd60 : c_data[4*8-1:3*8] <= din;
                    6'd61 : c_data[3*8-1:2*8] <= din;
                    6'd62 : c_data[2*8-1:1*8] <= din;
                    6'd63 : c_data[1*8-1:0] <= din;
                endcase
            end
        end
    end
endmodule
