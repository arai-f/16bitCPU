`include "def.v"

module instruction_memory (
    Address,
    CLK,
    Data
);
    // Port Declaration
    input CLK;
    input [`DATA_W-1:0] Address;
    output [`DATA_W-1:0] Data;

    // Reg/Wires
    reg [`DATA_W-1:0] address;
    reg [`DATA_W-1:0] memory[0:`MEM_WORD-1];

    // Initial Construct
    initial begin
        $readmemb("../assembler/test5_ml.txt", memory, 0, `MEM_WORD-1);
    end

    // Assign Ports
    assign Data = memory[address];

    // Always Construct
    always @(posedge CLK) begin
        address <= Address;
    end
endmodule

module data_memory (
    Address,
    CLK,
    WriteData,
    MEMWRITE,
    ReadData
);
    // Port Declaration
    input CLK, MEMWRITE;
    input [`DATA_W-1:0] Address, WriteData;
    output [`DATA_W-1:0] ReadData;

    // Reg/Wires
    reg memwrite;
    reg [`DATA_W-1:0] address, writedata;
    reg [`DATA_W-1:0] memory[0:`MEM_WORD-1];

    // Variable Declaration
    integer i;

    // Initial Construct
    initial begin
        memory[0] <= `DATA_W'h1234;
        memory[1] <= `DATA_W'h5678;
        for (i = 2; i < `MEM_WORD; i = i + 1'b1) begin
            memory[i] <= `DATA_W'd0;
        end
    end

    // Assign Ports
    assign ReadData = memory[address];

    // Always Consruct
    always @(posedge CLK) begin
        if (memwrite) begin
            memory[address] <= writedata;
        end
        address <= Address;
        writedata <= WriteData;
        memwrite <= MEMWRITE;
    end
endmodule