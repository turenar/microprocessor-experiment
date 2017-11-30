`define PC_ILLEGAL 32'hffff_ffff

`define OPTYPE_R 2'b01
`define OPTYPE_I 2'b10
`define OPTYPE_A 2'b11

`define OPCODE_AUX  6'b00_0000
`define OPCODE_ADDI 6'b00_0001
`define OPCODE_LW	6'b01_0000
`define OPCODE_SW	6'b01_1000
`define OPCODE_HALT 6'b11_1111
