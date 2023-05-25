`include "def.v"

module hazard_unit (
    // Control Signals
    ID_BRANCH,
    EX_MEM2REG,
    EX_REGWRITE,
    MEM_MEM2REG,
    MEM_REGWRITE,
    WB_REGWRITE,
    // Target Registers
    ID_ReadReg1,
    ID_ReadReg2,
    ID_ReadReg3,
    EX_ReadReg1,
    EX_ReadReg2,
    EX_ReadReg3,
    EX_WriteReg,
    MEM_WriteReg,
    WB_WriteReg,
    // Data
    ID_ReadData1,
    ID_ReadData2,
    ID_ReadData3,
    EX_ReadData1,
    EX_ReadData2,
    EX_ReadData3,
    MEM_ALU,
    WB_WriteData,
    // Forwarding Data
    ID_DataF1,
    ID_DataF2,
    ID_DataF3,
    EX_DataF1,
    EX_DataF2,
    EX_DataF3,
    // Stall Signal
    STALL
);
    // Port Declaration
    input EX_MEM2REG, EX_REGWRITE, MEM_MEM2REG, MEM_REGWRITE, WB_REGWRITE;
    input [`BRANCH_W-1:0] ID_BRANCH;
    input [`REG_W-1:0] ID_ReadReg1, ID_ReadReg2, ID_ReadReg3, EX_ReadReg1, EX_ReadReg2, EX_ReadReg3, EX_WriteReg, MEM_WriteReg, WB_WriteReg;
    input [`DATA_W-1:0] ID_ReadData1, ID_ReadData2, ID_ReadData3, EX_ReadData1, EX_ReadData2, EX_ReadData3, MEM_ALU, WB_WriteData;
    output STALL;
    output [`DATA_W-1:0] ID_DataF1, ID_DataF2, ID_DataF3, EX_DataF1, EX_DataF2, EX_DataF3;

    // Reg/Wires
    wire LW_STALL, BRANCH_STALL;

    // Assign Ports
    assign LW_STALL = ((EX_ReadReg3 == ID_ReadReg1) | (EX_ReadReg3 == ID_ReadReg2) | (EX_ReadReg3 == ID_ReadReg3)) & EX_MEM2REG;
    assign BRANCH_STALL = (EX_REGWRITE & (ID_BRANCH != `BRANCH_W'd0) & ((EX_WriteReg == ID_ReadReg1) | (EX_WriteReg == ID_ReadReg2) | (EX_WriteReg == ID_ReadReg3))) | (MEM_MEM2REG & (ID_BRANCH != `BRANCH_W'd0) & ((MEM_WriteReg == ID_ReadReg1) | (MEM_WriteReg == ID_ReadReg2) | (MEM_WriteReg == ID_ReadReg3)));
    assign STALL = LW_STALL | BRANCH_STALL;
    assign ID_DataF1 = (MEM_REGWRITE & (ID_ReadReg1 != `REG_W'd0) & (MEM_WriteReg == ID_ReadReg1)) ? MEM_ALU : (WB_REGWRITE & (ID_ReadReg1 != `REG_W'd0) & (WB_WriteReg == ID_ReadReg1)) ? WB_WriteData : ID_ReadData1;
    assign ID_DataF2 = (MEM_REGWRITE & (ID_ReadReg2 != `REG_W'd0) & (MEM_WriteReg == ID_ReadReg2)) ? MEM_ALU : (WB_REGWRITE & (ID_ReadReg2 != `REG_W'd0) & (WB_WriteReg == ID_ReadReg2)) ? WB_WriteData : ID_ReadData2;
    assign ID_DataF3 = (MEM_REGWRITE & (ID_ReadReg3 != `REG_W'd0) & (MEM_WriteReg == ID_ReadReg3)) ? MEM_ALU : (WB_REGWRITE & (ID_ReadReg3 != `REG_W'd0) & (WB_WriteReg == ID_ReadReg3)) ? WB_WriteData : ID_ReadData3;
    assign EX_DataF1 = (MEM_REGWRITE & (EX_ReadReg1 != `REG_W'd0) & (MEM_WriteReg == EX_ReadReg1)) ? MEM_ALU : (WB_REGWRITE & (EX_ReadReg1 != `REG_W'd0) & (WB_WriteReg == EX_ReadReg1)) ? WB_WriteData : EX_ReadData1;
    assign EX_DataF2 = (MEM_REGWRITE & (EX_ReadReg2 != `REG_W'd0) & (MEM_WriteReg == EX_ReadReg2)) ? MEM_ALU : (WB_REGWRITE & (EX_ReadReg2 != `REG_W'd0) & (WB_WriteReg == EX_ReadReg2)) ? WB_WriteData : EX_ReadData2;
    assign EX_DataF3 = (MEM_REGWRITE & (EX_ReadReg3 != `REG_W'd0) & (MEM_WriteReg == EX_ReadReg3)) ? MEM_ALU : (WB_REGWRITE & (EX_ReadReg3 != `REG_W'd0) & (WB_WriteReg == EX_ReadReg3)) ? WB_WriteData : EX_ReadData3;
endmodule