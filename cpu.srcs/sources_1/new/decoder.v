`include "def.vh"

module decoder(
	input clk,
	input rst,
	output halt,
	input [31:0] instruction,
	input [31:0] rsv,
	input [31:0] rtv,
	output [5:0] opcode,
	output [1:0] optype, // 1=R, 2=I, 3=A
	output [31:0] rav,
	output [31:0] rbv,
	output [4:0] rout,
	output [10:0] aux,
	output [15:0] imm,
	output [25:0] addr
	);

	reg halt;
	reg [5:0] Ropc;
	reg [1:0] Ropt;
	reg [31:0] Rrav;
	reg [31:0] Rrbv;
	reg [4:0] Rrout;
	reg [10:0] Raux;
	reg [15:0] Rimm;
	reg [25:0] Raddr;

	wire [5:0] WOopc; assign WOopc = instruction[31:26];
	// wire [4:0] WOrs; assign WOrs = instruction[25:21];
	wire [4:0] WOrt; assign WOrt = instruction[20:16];
	wire [4:0] WOrd; assign WOrd = instruction[15:11];
	wire [10:0]WOaux; assign WOaux = instruction[10:0];
	wire [15:0]WOimm; assign WOimm = instruction[15:0];
	wire [25:0]WOaddr; assign WOaddr = instruction[25:0];

	wire [4:0] Wshift; assign Wshift = Raux[10:6];
	wire [5:0] WauxV; assign WauxV = Raux[5:0];

	always @ (posedge clk) begin
		if(!halt) begin
			Ropc <= WOopc;
			if(WOopc == `OPCODE_AUX) begin
				Ropt <= `OPTYPE_R;
				Rrav <= rsv;
				Rrbv <= rtv;
				Rrout <= WOrd;
				Raux <= WOaux;
			end else if(WOopc == `OPCODE_ADDI) begin
				Ropt <= `OPTYPE_R;
				Rrav <= rsv;
				Rrbv <= { {16{WOimm[15]}}, WOimm};
				Rrout <= WOrt;
				Raux <= 0;
			end else if(WOopc == `OPCODE_HALT) begin
				halt <= 1;
			end
		end
	end
endmodule
