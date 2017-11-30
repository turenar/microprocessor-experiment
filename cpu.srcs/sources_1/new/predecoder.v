`include "def.vh"

module predecoder(
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

	task Tset_register(input [4:0] Arar, input [31:0] Arav, input[4:0] Arbr, input [31:0] Arbv); begin
		Rrar <= Arar; Rrav <= Arav; Rrbr <= Arbr; Rrbv <= Arbv;
	end endtask
	task TopR(
		input [5:0] Aopc,
		input [4:0] Arar, input [31:0] Arav, input[4:0] Arbr, input [31:0] Arbv,
		input [4:0] Arout, input [10:0] Aaux); begin
		Ropc <= Aopc; Ropt <= `OPTYPE_R;
		Tset_register(Arar, Arav, Arbr, Arbv);
		Rrout <= Arout; Raux <= Aaux; Rimm <= 0; Raddr <= 0; Rmem_read_addr <= 0;
	end endtask
	task TopImemread_offset(input [5:0] Aopc, input [5:0] Arar, input [4:0] Arout); begin
		Ropc <= Aopc; Ropt <= `OPTYPE_I; Tset_register(Arar, 0, 0, 0);
		Rrout <= Arout; Raux <= 0; Rimm <= WOimm; Raddr <= 0;
	end endtask

	wire _;

	always @ (posedge clk) begin
		if (rst || Rhalt) begin
			if (rst) begin
				Rhalt <= 0;
			end
			Ropc <= 0; Ropt <= 0; Rrar <= 0; Rrav <= 0; Rrbr <= 0; Rrbv <= 0;
			Rrout <= 0; Raux <= 0; Rmem_read_addr <= 0;
		end else if(!Rhalt) begin
			if(WOopc == `OPCODE_AUX) begin
				TopR(WOopc, WOrs, 0, WOrt, 0, WOrd, WOaux);
			end else if(WOopc == `OPCODE_ADDI) begin
				TopR(`OPCODE_AUX, WOrs, 0, 0,
					/* Arbv */{ {16{WOimm[15]}}, WOimm},
					WOrt, 0);
			end else if(WOopc == `OPCODE_HALT) begin
				Ropc <= WOopc;
				Ropt <= `OPTYPE_A;
				Rrar <= 0; Rrav <= 0; Rrbv <= 0; Rrbr <= 0; Rrout <= 0;
			end else if(WOopc == `OPCODE_LW) begin
				TopImemread_offset(WOopc, WOrs, WOrt);
			end else begin
				/* illegal instruction */
				Rhalt <= 1;
			end
		end
	end
endmodule
