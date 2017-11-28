`include "def.vh"

module decoder(
	input clk,
	input rst,
	output halt,
	input [31:0] instruction,
	output [5:0] opcode,
	output [1:0] optype, // 1=R, 2=I, 3=A
	output [4:0] rar,
	output [31:0] rav,
	output [4:0] rbr,
	output [31:0] rbv,
	output [4:0] rout,
	output [10:0] aux,
	output [15:0] imm,
	output [25:0] addr,
	output [31:0] mem_read_addr
	);

	reg Rhalt; assign halt = Rhalt;
	reg [5:0] Ropc; assign opcode = Ropc;
	reg [1:0] Ropt; assign optype = Ropt;
	reg [4:0] Rrar; assign rar = Rrar;
	reg [31:0] Rrav; assign rav = Rrav;
	reg [4:0] Rrbr; assign rbr = Rrbr;
	reg [31:0] Rrbv; assign rbv = Rrbv;
	reg [4:0] Rrout; assign rout = Rrout;
	reg [10:0] Raux; assign aux = Raux;
	reg [15:0] Rimm; assign imm = Rimm;
	reg [25:0] Raddr; assign addr = Raddr;
	reg [31:0] Rmem_read_addr; assign mem_read_addr = Rmem_read_addr;

	wire [5:0] WOopc; assign WOopc = instruction[31:26];
	wire [4:0] WOrs; assign WOrs = instruction[25:21];
	wire [4:0] WOrt; assign WOrt = instruction[20:16];
	wire [4:0] WOrd; assign WOrd = instruction[15:11];
	wire [10:0]WOaux; assign WOaux = instruction[10:0];
	wire [15:0]WOimm; assign WOimm = instruction[15:0];
	wire [25:0]WOaddr; assign WOaddr = instruction[25:0];

	wire [4:0] Wshift; assign Wshift = Raux[10:6];
	wire [5:0] WauxV; assign WauxV = Raux[5:0];

	always @ (posedge clk) begin
		if(rst) begin
			Rhalt <= 0;
			Ropc <= 0; Ropt <= 0; Rrar <= 0; Rrav <= 0; Rrbr <= 0; Rrbv <= 0;
			Rrout <= 0; Raux <= 0; Rimm <= 0; Raddr <= 0; Rmem_read_addr <= 0;
		end else if(!Rhalt) begin
			if(WOopc == `OPCODE_AUX) begin
				Ropc <= WOopc;
				Ropt <= `OPTYPE_R;
				Rrar <= WOrs;
				Rrbr <= WOrt;
				Rrout <= WOrd;
				Raux <= WOaux;
			end else if(WOopc == `OPCODE_ADDI) begin
				Ropc <= `OPCODE_AUX;
				Ropt <= `OPTYPE_R;
				Rrar <= WOrs;
				Rrbr <= 0;
				Rrbv <= { {16{WOimm[15]}}, WOimm};
				Rrout <= WOrt;
				Raux <= 0;
			end else if(WOopc == `OPCODE_HALT) begin
				Rhalt <= 1;
			end
		end
	end
endmodule
