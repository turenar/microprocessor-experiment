`define EXTSGN16to32(_val_) { {16{_val_[15]}}, _val_}
`define EXTZER16to32(_val_) { {16'b0}, _val_}

`define PC_ILLEGAL 32'hffff_ffff

`define OPTYPE_WIDTH 3
`define OPTYPE_BITDEF (`OPTYPE_WIDTH-1):0
`define OPTYPE_R	3'b001
`define OPTYPE_I	3'b010
`define OPTYPE_A	3'b011
`define OPTYPE_VJ	3'b100

`define OPCODE_AUX  6'b00_0000
`define OPCODE_ADDI 6'b00_0001
`define OPCODE_LUI	6'b00_0011
`define OPCODE_ANDI	6'b00_0100
`define OPCODE_ORI	6'b00_0101
`define OPCODE_XORI	6'b00_0110
`define OPCODE_LW	6'b01_0000
`define OPCODE_SW	6'b01_1000
`define OPCODE_BEQ	6'b10_0000
`define OPCODE_BNE	6'b10_0001
`define OPCODE_BLT	6'b10_0010
`define OPCODE_BLE	6'b10_0011
`define OPCODE_J	6'b10_1000
`define OPCODE_JAL	6'b10_1001
`define OPCODE_HALT 6'b11_1111

`define ALUC_ADD	6'h00
`define ALUC_SUB	6'h02
`define ALUC_AND	6'h08
`define ALUC_OR		6'h09
`define ALUC_XOR	6'h0a
`define ALUC_NOR	6'h0b
`define ALUC_SLL	6'h10
`define ALUC_SRL	6'h11
`define ALUC_SRA	6'h12
