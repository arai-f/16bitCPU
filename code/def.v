// R [OPCODE(4)][sra(3)][srb(3)][dr(3)][MODE(3)]
// I [OPCODE(4)][dr(3)][IMMEDIATE(8)][Don'tCare(1)]

`define OPCODE_W    4
`define REG_W       3
`define MODE_W      3
`define IMM_W       8
`define DECODE_W    5
`define BRANCH_W    3
`define ALUCTRL_W   3
`define OPMD_W      7
`define DATA_W      16
`define MEM_WORD    256

`define FW_W 2

// REGISTER
`define zero    `REG_W'd0
`define p       `REG_W'd1
`define t0      `REG_W'd2
`define t1      `REG_W'd3
`define t2      `REG_W'd4
`define t3      `REG_W'd5
`define i0      `REG_W'd6
`define i1      `REG_W'd7

// OPCODE & MODE
`define NOP `OPMD_W'b0000000
`define ADD `OPMD_W'b0001000
`define SW  `OPMD_W'b0010000
`define LW  `OPMD_W'b0011000
`define MV  `OPMD_W'b0100000
`define AND `OPMD_W'b0101000
`define XOR `OPMD_W'b0101001
`define OR  `OPMD_W'b0101010
`define NOT `OPMD_W'b0101011
`define JMP `OPMD_W'b0110000
`define BGT `OPMD_W'b0110001
`define BLT `OPMD_W'b0110010
`define BEQ `OPMD_W'b0110011
`define SLL `OPMD_W'b0111000
`define SRL `OPMD_W'b0111001