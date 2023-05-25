`include "alu.v"
`include "controller.v"
`include "dec_7seg.v"
`include "hazard.v"
`include "memory.v"
`include "pc.v"
`include "registers.v"

module cpu (
    RST_N,
    SW,
    CLK,
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5,
    HEX6,
    HEX7
);
    // Port Declaration
    input RST_N, CLK;
    input [15:0] SW;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
    wire [7:0] t0, t1, t2, t3;

    // Reg/Wires
    // IF
    wire [`DATA_W-1:0] IF_Address, IF_OP;
    // ID
    wire [`OPCODE_W-1:0] ID_OPCODE;
    wire [`REG_W-1:0] ID_ReadReg1, ID_ReadReg2, ID_ReadReg3;
    wire [`MODE_W-1:0] ID_MODE;
    wire [`IMM_W-1:0] ID_IMM;
    wire ID_WRITESRC, ID_ALUSRC, ID_MEMWRITE, ID_MEM2REG, ID_REGWRITE;
    wire [`BRANCH_W-1:0] ID_BRANCH;
    wire [`ALUCTRL_W-1:0] ID_ALUCTRL;
    wire [`DATA_W-1:0] ID_OP, ID_ReadData1, ID_ReadData2, ID_ReadData3, ID_DataF1, ID_DataF2, ID_DataF3;
    // EX
    wire [`REG_W-1:0] EX_ReadReg1, EX_ReadReg2, EX_ReadReg3, EX_WriteReg;
    wire [`IMM_W-1:0] EX_IMM;
    wire EX_WRITESRC, EX_ALUSRC, EX_MEMWRITE, EX_MEM2REG, EX_REGWRITE;
    wire [`ALUCTRL_W-1:0] EX_ALUCTRL;
    wire [`DATA_W-1:0] EX_ReadData1, EX_ReadData2, EX_ReadData3, EX_ALU, EX_Data1, EX_DataF1, EX_DataF2, EX_DataF3;
    // MEM
    wire MEM_MEM2REG, MEM_REGWRITE;
    wire [`REG_W-1:0] MEM_WriteReg;
    wire [`DATA_W-1:0] MEM_ALU, MEM_ReadData;
    // WB
    wire WB_MEM2REG, WB_REGWRITE;
    wire [`REG_W-1:0] WB_WriteReg;
    wire [`DATA_W-1:0] WB_ALU, WB_ReadData, WB_WriteData;
    // Stall Signal
    wire STALL;

    // Assign Construct
    assign ID_OPCODE = ID_OP[`DATA_W-1:`DATA_W-`OPCODE_W];
    assign ID_ReadReg1 = ID_OP[`DATA_W-`OPCODE_W-1:`DATA_W-`OPCODE_W-`REG_W];
    assign ID_ReadReg2 = ID_OP[`DATA_W-`OPCODE_W-`REG_W-1:`REG_W+`MODE_W];
    assign ID_ReadReg3 = ID_OP[`REG_W+`MODE_W-1:`MODE_W];
    assign ID_MODE = ID_OP[`MODE_W-1:0];
    assign ID_IMM = ID_OP[`IMM_W:1];

    assign EX_Data1 = (!EX_ALUSRC) ? EX_DataF1 : EX_IMM;
    assign EX_WriteReg = (!EX_WRITESRC) ? EX_ReadReg3 : EX_ReadReg1;
    assign WB_WriteData = (!WB_MEM2REG) ? WB_ALU : WB_ReadData;

    // Module Instantiate
    program_counter     PC      (RST_N, CLK, ID_PCSRC, STALL, ID_DataF3, IF_Address);
    instruction_memory  IM      (IF_Address, CLK, IF_OP);
    controller          CTRL    (ID_OPCODE, ID_MODE, STALL, ID_WRITESRC, ID_ALUSRC, ID_MEMWRITE, ID_MEM2REG, ID_REGWRITE, ID_BRANCH, ID_ALUCTRL);
    registers           REGS    (RST_N, SW, CLK, WB_REGWRITE, ID_ReadReg1, ID_ReadReg2, ID_ReadReg3, WB_WriteReg, WB_WriteData, ID_ReadData1, ID_ReadData2, ID_ReadData3, t0, t1, t2, t3);
    comparator          COMP    (ID_BRANCH, ID_DataF1, ID_DataF2, ID_PCSRC);
    alu                 ALU     (EX_ALUCTRL, EX_Data1, EX_DataF2, EX_ALU);
    data_memory         DM      (EX_ALU, CLK, EX_DataF3, EX_MEMWRITE, MEM_ReadData);
    // Pipeline Registers
    // IF/ID
    pipeline_register       #(`DATA_W)      IFID0   (RST_N, CLK, STALL, ID_PCSRC, IF_OP, ID_OP);
    // ID/EX
    pipeline_register       #(1)            IDEX0   (RST_N, CLK, 1'b0, 1'b0, ID_WRITESRC, EX_WRITESRC);
    pipeline_register       #(1)            IDEX1   (RST_N, CLK, 1'b0, 1'b0, ID_ALUSRC, EX_ALUSRC);
    pipeline_register       #(1)            IDEX2   (RST_N, CLK, 1'b0, 1'b0, ID_MEMWRITE, EX_MEMWRITE);
    pipeline_register       #(1)            IDEX3   (RST_N, CLK, 1'b0, 1'b0, ID_MEM2REG, EX_MEM2REG);
    pipeline_register       #(1)            IDEX4   (RST_N, CLK, 1'b0, 1'b0, ID_REGWRITE, EX_REGWRITE);
    pipeline_register       #(`ALUCTRL_W)   IDEX5   (RST_N, CLK, 1'b0, 1'b0, ID_ALUCTRL, EX_ALUCTRL);
    pipeline_register       #(`REG_W)       IDEX6   (RST_N, CLK, 1'b0, 1'b0, ID_ReadReg1, EX_ReadReg1);
    pipeline_register       #(`REG_W)       IDEX7   (RST_N, CLK, 1'b0, 1'b0, ID_ReadReg2, EX_ReadReg2);
    pipeline_register       #(`REG_W)       IDEX8   (RST_N, CLK, 1'b0, 1'b0, ID_ReadReg3, EX_ReadReg3);
    pipeline_register       #(`IMM_W)       IDEX9   (RST_N, CLK, 1'b0, 1'b0, ID_IMM, EX_IMM);
    pipeline_register       #(`DATA_W)      IDEX10  (RST_N, CLK, 1'b0, 1'b0, ID_ReadData1, EX_ReadData1);
    pipeline_register       #(`DATA_W)      IDEX11  (RST_N, CLK, 1'b0, 1'b0, ID_ReadData2, EX_ReadData2);
    pipeline_register       #(`DATA_W)      IDEX12  (RST_N, CLK, 1'b0, 1'b0, ID_ReadData3, EX_ReadData3);
    // EX/MEM
    pipeline_register       #(1)            EXMEM0  (RST_N, CLK, 1'b0, 1'b0, EX_MEM2REG, MEM_MEM2REG);
    pipeline_register       #(1)            EXMEM1  (RST_N, CLK, 1'b0, 1'b0, EX_REGWRITE, MEM_REGWRITE);
    pipeline_register       #(`REG_W)       EXMEM2  (RST_N, CLK, 1'b0, 1'b0, EX_WriteReg, MEM_WriteReg);
    pipeline_register       #(`DATA_W)      EXMEM3  (RST_N, CLK, 1'b0, 1'b0, EX_ALU, MEM_ALU);
    // MEM/WB
    pipeline_register       #(1)            MEMWB0  (RST_N, CLK, 1'b0, 1'b0, MEM_MEM2REG, WB_MEM2REG);
    pipeline_register       #(1)            MEMWB1  (RST_N, CLK, 1'b0, 1'b0, MEM_REGWRITE, WB_REGWRITE);
    pipeline_register       #(`REG_W)       MEMWB2  (RST_N, CLK, 1'b0, 1'b0, MEM_WriteReg, WB_WriteReg);
    pipeline_register       #(`DATA_W)      MEMWB3  (RST_N, CLK, 1'b0, 1'b0, MEM_ALU, WB_ALU);
    pipeline_register       #(`DATA_W)      MEMWB4  (RST_N, CLK, 1'b0, 1'b0, MEM_ReadData, WB_ReadData);
    // Hazard_Unit
    hazard_unit HU  (ID_BRANCH, EX_MEM2REG, EX_REGWRITE, MEM_MEM2REG, MEM_REGWRITE, WB_REGWRITE, ID_ReadReg1, ID_ReadReg2, ID_ReadReg3, EX_ReadReg1, EX_ReadReg2, EX_ReadReg3, EX_WriteReg, MEM_WriteReg, WB_WriteReg, ID_ReadData1, ID_ReadData2, ID_ReadData3, EX_ReadData1, EX_ReadData2, EX_ReadData3, MEM_ALU, WB_WriteData, ID_DataF1, ID_DataF2, ID_DataF3, EX_DataF1, EX_DataF2, EX_DataF3, STALL);
    // Output for Dec7Seg
    dec_7seg	H0  (t0[3:0], HEX0);
    dec_7seg	H1  (t0[7:4], HEX1);
    dec_7seg	H2  (t1[3:0], HEX2);
    dec_7seg	H3  (t1[7:4], HEX3);
    dec_7seg	H4  (t2[3:0], HEX4);
    dec_7seg	H5  (t2[7:4], HEX5);
    dec_7seg	H6  (t3[3:0], HEX6);
    dec_7seg	H7  (t3[7:4], HEX7);
endmodule

module testbench;
    reg RST_N, CLK;
    reg [15:0] SW;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, testbench);
        CLK <= 1'b0;
        RST_N <= 1'b0;
        SW <= 16'b0000001000000011;
        #5 RST_N <= 1'b1;
        #100 $finish;
    end

    always #1 CLK <= ~CLK;
    
    cpu CPU(RST_N, SW, CLK, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);
endmodule