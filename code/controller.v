`include "def.v"

module controller (
    OPCODE,
    MODE,
    STALL,
    WRITESRC,
    ALUSRC,
    MEMWRITE,
    MEM2REG,
    REGWRITE,
    BRANCH,
    ALUCTRL
);
    // Port Declaration
    input [`OPCODE_W-1:0] OPCODE;
    input [`MODE_W-1:0] MODE;
    input STALL;
    output WRITESRC, ALUSRC, MEMWRITE, MEM2REG, REGWRITE;
    output [`BRANCH_W-1:0] BRANCH;
    output [`ALUCTRL_W-1:0] ALUCTRL;

    // Reg/Wires
    wire [`DECODE_W-1:0] DECODE;

    // Functions
    function [`DECODE_W-1:0] decode;
        input [`OPCODE_W-1:0] OPCODE;
        begin
            case (OPCODE << `MODE_W)
                `NOP:       decode = `DECODE_W'b00000;
                `ADD:       decode = `DECODE_W'b00001;
                `SW:        decode = `DECODE_W'b00100;
                `LW:        decode = `DECODE_W'b00011;
                `MV:        decode = `DECODE_W'b11001;
                `AND:       decode = `DECODE_W'b00001;
                `XOR:       decode = `DECODE_W'b00001;
                `OR:        decode = `DECODE_W'b00001;
                `NOT:       decode = `DECODE_W'b00001;
                `JMP:       decode = `DECODE_W'b00000;
                `BGT:       decode = `DECODE_W'b00000;
                `BLT:       decode = `DECODE_W'b00000;
                `BEQ:       decode = `DECODE_W'b00000;
                `SLL:       decode = `DECODE_W'b00001;
                `SRL:       decode = `DECODE_W'b00001;
                default:    decode = `DECODE_W'd0;
            endcase
        end
    endfunction

    function [`ALUCTRL_W-1:0] branch;
        input [`OPCODE_W-1:0] OPCODE;
        input [`MODE_W-1:0] MODE;
        begin
            case ({OPCODE, MODE})
                `NOP:       branch = `BRANCH_W'd0;
                `ADD:       branch = `BRANCH_W'd0;
                `SW:        branch = `BRANCH_W'd0;
                `LW:        branch = `BRANCH_W'd0;
                `MV:        branch = `BRANCH_W'd0;
                `AND:       branch = `BRANCH_W'd0;
                `XOR:       branch = `BRANCH_W'd0;
                `OR:        branch = `BRANCH_W'd0;
                `NOT:       branch = `BRANCH_W'd0;
                `JMP:       branch = `BRANCH_W'd1;
                `BGT:       branch = `BRANCH_W'd2;
                `BLT:       branch = `BRANCH_W'd3;
                `BEQ:       branch = `BRANCH_W'd4;
                `SLL:       branch = `BRANCH_W'd0;
                `SRL:       branch = `BRANCH_W'd0;
                default:    branch = `BRANCH_W'd0;
            endcase
        end
    endfunction

    function [`ALUCTRL_W-1:0] aluctrl;
        input [`OPCODE_W-1:0] OPCODE;
        input [`MODE_W-1:0] MODE;
        begin
            case ({OPCODE, MODE})
                `NOP:       aluctrl = `ALUCTRL_W'd0;
                `ADD:       aluctrl = `ALUCTRL_W'd1;
                `SW:        aluctrl = `ALUCTRL_W'd0;
                `LW:        aluctrl = `ALUCTRL_W'd0;
                `MV:        aluctrl = `ALUCTRL_W'd0;
                `AND:       aluctrl = `ALUCTRL_W'd2;
                `XOR:       aluctrl = `ALUCTRL_W'd3;
                `OR:        aluctrl = `ALUCTRL_W'd4;
                `NOT:       aluctrl = `ALUCTRL_W'd5;
                `JMP:       aluctrl = `ALUCTRL_W'd0;
                `BGT:       aluctrl = `ALUCTRL_W'd0;
                `BLT:       aluctrl = `ALUCTRL_W'd0;
                `BEQ:       aluctrl = `ALUCTRL_W'd0;
                `SLL:       aluctrl = `ALUCTRL_W'd6;
                `SRL:       aluctrl = `ALUCTRL_W'd7;
                default:    aluctrl = `ALUCTRL_W'd0;
            endcase
        end
    endfunction

    // Assign Ports
    assign DECODE = decode(OPCODE);
    assign WRITESRC = DECODE[4] & (!STALL);
    assign ALUSRC = DECODE[3] & (!STALL);
    assign MEMWRITE = DECODE[2] & (!STALL);
    assign MEM2REG = DECODE[1] & (!STALL);
    assign REGWRITE = DECODE[0] & (!STALL);
    assign BRANCH = branch(OPCODE, MODE);
    assign ALUCTRL = aluctrl(OPCODE, MODE) & (~({`ALUCTRL_W{STALL}}));
endmodule