  /* Copyright 2025 Swarup Saha Roy

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.*/

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
