`define EXTSGN16to32(_val_) { {16{_val_[15]}}, _val_}

`define PC_ILLEGAL 32'hffff_ffff

`define OPTYPE_WIDTH 3
`define OPTYPE_BITDEF (`OPTYPE_WIDTH-1):0
`define OPTYPE_R	3'b001
`define OPTYPE_I	3'b010
`define OPTYPE_A	3'b011
`define OPTYPE_VJ	3'b100

`define OPCODE_AUX  6'b00_0000
`define OPCODE_ADDI 6'b00_0001
`define OPCODE_LW	6'b01_0000
`define OPCODE_SW	6'b01_1000
`define OPCODE_BEQ	6'b10_0000
`define OPCODE_BNE	6'b10_0001
`define OPCODE_BLT	6'b10_0010
`define OPCODE_BLE	6'b10_0011
`define OPCODE_J	6'b10_1000
`define OPCODE_HALT 6'b11_1111
