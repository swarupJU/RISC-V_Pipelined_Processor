`timescale 1ns / 1ps

module WriteBack_Cycle(
    input clk,
    input rst,
    input [1:0] ResultSrcW,          // Controls what gets written back
    input [31:0] PCPlus4W,           // PC + 4 (for JAL return)
    input [31:0] ALU_ResultW,        // ALU result (for arithmetic)
    input [31:0] ReadDataW,          // Data from memory (for lw)
    input [4:0] RD_W_in,             // Destination register from MEM/WB pipeline
    input RegWriteW_in,              // Write enable from MEM/WB pipeline

    output reg [31:0] ResultW,       // Final value to be written to register file
    output reg [4:0] RDW,            // Final destination register to be written
    output reg RegWriteW             // Final write-enable for register file
);

    wire [31:0] mux_out;

    // MUX to select write-back value
    mux4x1 wb_mux (
        .I0(ALU_ResultW),    // 00 - ALU result
        .I1(ReadDataW),      // 01 - Memory output
        .I2(PCPlus4W),       // 10 - PC + 4 (e.g., for JAL)
        .sel(ResultSrcW),
        .out(mux_out)
    );

    // Latch final write-back outputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ResultW   <= 32'b0;
            RDW       <= 5'b0;
            RegWriteW <= 1'b0;
        end else begin
            ResultW   <= mux_out;
            RDW       <= RD_W_in;
            RegWriteW <= RegWriteW_in;
        end
    end

endmodule
