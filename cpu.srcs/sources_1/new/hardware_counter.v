`include "display_src/char_def.vh"

module hardware_counter(
    input CLK_IP,
    input RSTN_IP,
    output [63:0] COUNTER_OP
    );

    function [7:0] decoded_byte(
        input [3:0] hex_byte
    );
    begin
        if(hex_byte<4'd10) begin
            decoded_byte = hex_byte+`Num0;
        end else begin
            decoded_byte = hex_byte+`UpA-4'd10;
        end
    end
    endfunction

    reg [31:0] cycles;

    always @(posedge CLK_IP or negedge RSTN_IP) begin
        if(!RSTN_IP)begin
            cycles <= 32'h0;
        end else if(CLK_IP) begin
            cycles <= cycles + 1;
        end
    end // always @(posedge CLKIN or negedge RSTN_IN)

    assign COUNTER_OP ={
		decoded_byte(cycles[31:28]), decoded_byte(cycles[27:24]),
		decoded_byte(cycles[23:20]), decoded_byte(cycles[19:16]),
		decoded_byte(cycles[15:12]), decoded_byte(cycles[11:8]),
		decoded_byte(cycles[7:4]), decoded_byte(cycles[3:0]) };

endmodule // hardware_counter
