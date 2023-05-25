`include "def.v"

module alu (
    ALUCTRL,
    DATA1,
    DATA2,
    ALUOUT
);
    // Port Declaration
    input [`ALUCTRL_W-1:0] ALUCTRL;
    input [`DATA_W-1:0] DATA1, DATA2;
    output [`DATA_W-1:0] ALUOUT;

    // Functions
    function [`DATA_W-1:0] calc;
        input [`ALUCTRL_W-1:0] ALUCTRL;
        input [`DATA_W-1:0] DATA1, DATA2;
        begin
            case (ALUCTRL)
                `ALUCTRL_W'd0:  calc = DATA1;
                `ALUCTRL_W'd1:  calc = DATA1 + DATA2;
                `ALUCTRL_W'd2:  calc = DATA1 & DATA2;
                `ALUCTRL_W'd3:  calc = DATA1 ^ DATA2;
                `ALUCTRL_W'd4:  calc = DATA1 | DATA2;
                `ALUCTRL_W'd5:  calc = ~DATA1;
                `ALUCTRL_W'd6:  calc = DATA1 << DATA2;
                `ALUCTRL_W'd7:  calc = DATA1 >> DATA2;
                default:        calc = DATA1;
            endcase
        end
    endfunction

    // Assign Ports
    assign ALUOUT = calc(ALUCTRL, DATA1, DATA2);
endmodule

module comparator (
    BRANCH,
    DATA1,
    DATA2,
    PCSRC
);
    // Port Declaration
    input [`BRANCH_W-1:0] BRANCH;
    input [`DATA_W-1:0] DATA1, DATA2;
    output PCSRC;

    // Functions
    function [`BRANCH_W-1:0] compare;
        input [`DATA_W-1:0] DATA1, DATA2;
        begin
            case ({(DATA1 > DATA2), (DATA1 < DATA2), (DATA1 == DATA2)})
                3'b100:     compare = `BRANCH_W'd2;
                3'b010:     compare = `BRANCH_W'd3;
                3'b001:     compare = `BRANCH_W'd4;
                default:    compare = `BRANCH_W'd5;
            endcase
        end
    endfunction

    // Assign Ports
    assign PCSRC = (BRANCH == `BRANCH_W'd1) | (BRANCH == compare(DATA1, DATA2));
endmodule