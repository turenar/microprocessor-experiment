module multipaged_screen(
	input clk, input rst,
	input write_enabled,
	input [31:0] address,
	input [31:0] data,
	input [1:0] page,
	output oled_write_enabled,
	output [5:0] oled_addr,
	output [7:0] oled_data
	);

	reg [7:0] Rdata[0:255];
	reg Rdirty;
	reg [1:0] Rpage;
	reg [5:0] Roffset;
	reg Roled_write_enabled; assign oled_write_enabled = Roled_write_enabled;
	reg [5:0] Roled_addr; assign oled_addr = Roled_addr;
	reg [7:0] Roled_data; assign oled_data = Roled_data;

	function [7:0] Fcalc_offset(input [1:0] page, input[5:0] index);
		Fcalc_offset = (page << 6) | index;
	endfunction

	integer i;
	always @ (posedge clk) begin
		if(rst) begin
			for(i=0; i<256; i=i+1) begin
				Rdata[i] <= 0;
			end
			Rdirty <= 0; Roffset <= 0; Rpage <= 0;
			Roled_write_enabled <= 0; Roled_addr <= 0; Roled_data <= 0;
		end else if (Rdirty) begin
			Roled_write_enabled <= 1;
			Roled_addr <= Roffset;
			Roled_data <= Rdata[Fcalc_offset(Rpage, Roffset)];
			Roffset <= Roffset + 1;
			if(Roffset[5:0] == 6'b111111) begin
				Rdirty <= 0;
			end
		end else begin
			Roled_write_enabled <= 0;
		end
	end
	always @ (negedge clk) begin
		if(!rst) begin
			if ((write_enabled && address[31:12] == 20'hfffff) || Rpage != page) begin
				if (write_enabled) begin
					Rdata[address[9:2]] <= data[7:0];
				end else begin
					Rpage <= page;
				end
				Rdirty <= 1;
				Roffset <= 0;
			end
		end
	end
endmodule
