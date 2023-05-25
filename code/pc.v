`include "def.v"

module program_counter (
    RST_N,
    CLK,
    PCSRC,
    STALL,
    dr,
    address
);
    // Port Declaration
    input RST_N, CLK, PCSRC, STALL;
    input [`DATA_W-1:0] dr;
    output [`DATA_W-1:0] address;

    // Reg/Wires
    reg [`DATA_W-1:0] q;

    // Assign Ports
    assign address = q;

    // Always Construct
    always @(negedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            q <= `DATA_W'd0;
        end else if (!STALL & PCSRC) begin
            q <= dr;
        end else if (!STALL) begin
            q <= q + `DATA_W'd1;
        end 
    end
endmodule