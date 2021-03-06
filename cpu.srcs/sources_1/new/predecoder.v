`include "def.vh"

module predecoder(
	input clk,
	input rst,
	output [`ERRC_BITDEF] errno,
	input [31:0] in_npc,
	input [31:0] instruction,
	output [31:0] out_npc,
	output [5:0] opcode,
	output [`OPTYPE_BITDEF] optype, // 1=R, 2=I, 3=A
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

	reg [`ERRC_BITDEF] Rerrno; assign errno = Rerrno;
	reg [31:0] Rnpc; assign out_npc = Rnpc;
	reg [5:0] Ropc; assign opcode = Ropc;
	reg [`OPTYPE_BITDEF] Ropt; assign optype = Ropt;
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

	task Tset_register(input [4:0] Arar, input [31:0] Arav, input[4:0] Arbr, input [31:0] Arbv);
		begin
			Rrar <= Arar; Rrav <= Arav; Rrbr <= Arbr; Rrbv <= Arbv;
		end
	endtask
	task TopR(
		input [5:0] Aopc,
		input [4:0] Arar, input [31:0] Arav, input[4:0] Arbr, input [31:0] Arbv,
		input [4:0] Arout, input [10:0] Aaux);
		begin
			Ropc <= Aopc; Ropt <= `OPTYPE_R;
			Tset_register(Arar, Arav, Arbr, Arbv);
			Rrout <= Arout; Raux <= Aaux; Rimm <= 0; Raddr <= 0; Rmem_read_addr <= 0;
		end
	endtask
	task TopImemread_offset(input [5:0] Aopc, input [5:0] Arar, input [4:0] Arout);
		begin
			Ropc <= Aopc; Ropt <= `OPTYPE_I; Tset_register(Arar, 0, 0, 0);
			Rrout <= Arout; Raux <= 0; Rimm <= WOimm; Raddr <= 0;
		end
	endtask
	task TopImemwrite_offset(input [5:0] Aopc, input [5:0] Arsrc, input [4:0] Araddr);
		begin
			Ropc <= Aopc; Ropt <= `OPTYPE_I; Tset_register(Arsrc, 0, Araddr, 0);
			Rrout <= 0; Raux <= 0; Rimm <= WOimm; Raddr <= 0;
		end
	endtask
	task TopIpass(input [5:0] Aopc, input [`OPTYPE_BITDEF] Aopt);
		begin
			Ropc <= Aopc; Ropt <= Aopt; Tset_register(WOrs, 0, WOrt, 0);
			Rrout <= 0; Raux <= 0; Rimm <= WOimm; Raddr <= 0;
		end
	endtask
	task TopApass(input [5:0] Aopc, input [`OPTYPE_BITDEF] Aopt);
		begin
			Ropc <= Aopc; Ropt <= Aopt; Tset_register(0, 0, 0, 0);
			Rrout <= 0; Raux <= 0; Rimm <= 0; Raddr <= WOaddr;
		end
	endtask

	always @ (posedge clk or posedge rst) begin
		if (rst || Rerrno) begin
			if (rst) begin
				Rerrno <= 0;
			end
			Rnpc <= `PC_ILLEGAL;
			Ropc <= 0; Ropt <= 0; Rrar <= 0; Rrav <= 0; Rrbr <= 0; Rrbv <= 0;
			Rrout <= 0; Raux <= 0; Rmem_read_addr <= 0;
		end else if(Rerrno == 0) begin
			Rnpc <= in_npc;
			if(WOopc == `OPCODE_AUX) begin
				TopR(WOopc, WOrs, 0, WOrt, 0, WOrd, WOaux);
			end else if(WOopc == `OPCODE_ADDI) begin
				TopR(`OPCODE_AUX, WOrs, 0, 0,
					/* Arbv */ `EXTSGN16to32(WOimm),
					WOrt, `ALUC_ADD);
			end else if(WOopc == `OPCODE_LUI) begin
				TopR(`OPCODE_AUX, 0, 0, 0,
					/* Arbv */ WOimm << 16,
					WOrt, `ALUC_OR);
			end else if(WOopc == `OPCODE_ANDI) begin
				TopR(`OPCODE_AUX, WOrs, 0, 0,
					/* Arbv */ `EXTZER16to32(WOimm),
					WOrt, `ALUC_AND);
			end else if(WOopc == `OPCODE_ORI) begin
				TopR(`OPCODE_AUX, WOrs, 0, 0,
					/* Arbv */ `EXTZER16to32(WOimm),
					WOrt, `ALUC_OR);
			end else if(WOopc == `OPCODE_XORI) begin
				TopR(`OPCODE_AUX, WOrs, 0, 0,
					/* Arbv */ `EXTZER16to32(WOimm),
					WOrt, `ALUC_XOR);
			end else if(WOopc == `OPCODE_HALT) begin
				Ropc <= WOopc;
				Ropt <= `OPTYPE_A;
				Rrar <= 0; Rrav <= 0; Rrbv <= 0; Rrbr <= 0; Rrout <= 0;
			end else if(WOopc == `OPCODE_LW) begin
				TopImemread_offset(WOopc, WOrs, WOrt);
			end else if(WOopc == `OPCODE_SW) begin
				TopImemwrite_offset(WOopc, WOrt, WOrs);
			end else if(WOopc == `OPCODE_BEQ || WOopc == `OPCODE_BNE
				|| WOopc == `OPCODE_BLT || WOopc == `OPCODE_BLE) begin
				TopIpass(WOopc, `OPTYPE_VJ);
			end else if(WOopc == `OPCODE_J) begin
				TopApass(WOopc, `OPTYPE_VJ);
			end else if(WOopc == `OPCODE_JAL) begin
				TopApass(WOopc, `OPTYPE_A); // not simple jump!
			end else if(WOopc == `OPCODE_JR) begin
				TopR(WOopc, WOrs, 0, 0, 0, 0, `ALUC_NONE);
			end else begin
				/* illegal instruction */
				Rerrno <= `ERRC_ILL;
			end
		end
	end
endmodule
