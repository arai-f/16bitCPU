`include "def.v"

module register (
    RST_N,
    CLK,
    EN,
    D_IN,
    D_OUT
);
    // Port Declaration
    input RST_N, CLK, EN;
    input [`DATA_W-1:0] D_IN;
    output [`DATA_W-1:0] D_OUT;

    // Reg/Wires
    reg [`DATA_W-1:0] q;

    // Assign Ports
    assign D_OUT = q;

    // Always Construct
    always @(negedge CLK) begin
        if (!RST_N) begin
            q <= `DATA_W'd0;
        end else if (EN) begin
            q <= D_IN;
        end
    end
endmodule

module registers (
    RST_N,
    SW,
    CLK,
    REGWRITE,
    ReadReg1,
    ReadReg2,
    ReadReg3,
    WriteReg,
    WriteData,
    ReadData1,
    ReadData2,
    ReadData3,
    // For Dec7Seg
    t0,
    t1,
    t2,
    t3
);
    // Port Declaration
    input RST_N, CLK, REGWRITE;
    input [15:0] SW;
    input [`REG_W-1:0] ReadReg1, ReadReg2, ReadReg3, WriteReg;
    input [`DATA_W-1:0] WriteData;
    output [`DATA_W-1:0] ReadData1, ReadData2, ReadData3;
    output [7:0] t0, t1, t2, t3;

    // Reg/Wires
    wire [`DATA_W-1:0] zero_out, p_out, t0_out, t1_out, t2_out, t3_out, i0_out, i1_out;

    // Functions
    function [`DATA_W-1:0] data_out;
        input [`REG_W-1:0] reg_select;
        input [`DATA_W-1:0] zero_out, p_out, t0_out, t1_out, t2_out, t3_out, i0_out, i1_out;
        begin
            case (reg_select)
                `zero:      data_out = zero_out;
                `p:         data_out = p_out;
                `t0:        data_out = t0_out;
                `t1:        data_out = t1_out;
                `t2:        data_out = t2_out;
                `t3:        data_out = t3_out;
                `i0:        data_out = i0_out;
                `i1:        data_out = i1_out;
                default:    data_out = zero_out;
            endcase
        end
    endfunction

    // Assign Ports
    assign ReadData1 = data_out(ReadReg1, zero_out, p_out, t0_out, t1_out, t2_out, t3_out, i0_out, i1_out);
    assign ReadData2 = data_out(ReadReg2, zero_out, p_out, t0_out, t1_out, t2_out, t3_out, i0_out, i1_out);
    assign ReadData3 = data_out(ReadReg3, zero_out, p_out, t0_out, t1_out, t2_out, t3_out, i0_out, i1_out);
    // It can only read Lower 8bit due to display area limitations.
    assign t0 = t0_out[7:0]; // -> HEX1, HEX0
    assign t1 = t1_out[7:0]; // -> HEX3, HEX2
    assign t2 = t2_out[7:0]; // -> HEX5, HEX4
    assign t3 = t3_out[7:0]; // -> HEX7, HEX6

    // Module Instantiate
    register    zero_reg    (RST_N, CLK, 1'b1, {`DATA_W{1'b0}}, zero_out);
    register    p_reg       (RST_N, CLK, {REGWRITE & (WriteReg == `p)}, WriteData, p_out);
    register    t0_reg      (RST_N, CLK, {REGWRITE & (WriteReg == `t0)}, WriteData, t0_out);
    register    t1_reg      (RST_N, CLK, {REGWRITE & (WriteReg == `t1)}, WriteData, t1_out);
    register    t2_reg      (RST_N, CLK, {REGWRITE & (WriteReg == `t2)}, WriteData, t2_out);
    register    t3_reg      (RST_N, CLK, {REGWRITE & (WriteReg == `t3)}, WriteData, t3_out);
    register    i0_reg      (RST_N, CLK, 1'b1, {8'd0, SW[7:0]}, i0_out);
    register    i1_reg      (RST_N, CLK, 1'b1, {8'd0, SW[15:8]}, i1_out);
endmodule

module pipeline_register #(parameter PIPE_W = 16) (
    RST_N,
    CLK,
    STALL,
    FLUSH,
    D_IN,
    D_OUT
);
    // Port Declaration
    input RST_N, CLK, STALL, FLUSH;
    input [PIPE_W-1:0] D_IN;
    output [PIPE_W-1:0] D_OUT;

    // Reg/Wires
    reg [PIPE_W-1:0] q;

    // Assign Ports
    assign D_OUT = q;

    // Always Construct
    always @(posedge CLK) begin
        if ((!STALL & FLUSH) | !RST_N) begin
            q <= 0;
        end else if (!STALL) begin
            q <= D_IN;
        end
    end
endmodule