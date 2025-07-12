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

module Top_Pipeline(
    input wire clk,
    input wire rst,
    output wire  [1023:0] reg_dump
);

    // === Fetch to Decode Wires ===
    wire [31:0] InstrD, PCD, PCPlus4D;
    wire PCSrcE;
    wire [31:0] PCTargetE;

    // === Decode to Execute Wires ===
    wire RegWriteE, ALUSrcE, MemWriteE, BranchE;
    wire [1:0] ResultSrcE;
    wire [2:0] ALUControlE;
    wire [31:0] RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E;
    wire [4:0] RD_E, RS1_E, RS2_E;

    // === Execute to Memory Wires ===
    wire RegWriteM, MemWriteM;
    wire [1:0] ResultSrcM;
    wire [4:0] RD_M;
    wire [31:0] PCPlus4M, WriteDataM, ALU_ResultM;

    // === Memory to Writeback Wires ===
    wire [4:0] RD_W;
    wire [1:0] ResultSrcW;
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;
    wire RegWriteW;

    // === Final Writeback to Register File ===
    wire [4:0] RDW;
    wire [31:0] ResultW;
    wire RegWriteFinalW;

    // === Forwarding Signals ===
    wire [1:0] ForwardA_E, ForwardB_E;

    // === Fetch Stage ===
    Fetch_cycle FETCH (
        .clk(clk),
        .rst(rst),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D)
    );

    // === Decode Stage ===
    Decode_cycle DECODE (
        .clk(clk),
        .rst(rst),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RegWriteW(RegWriteFinalW),  // From WB Cycle
        .RDW(RDW),                   // From WB Cycle
        .ResultW(ResultW),          // From WB Cycle
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .RS1_E(RS1_E),
        .RS2_E(RS2_E),
        .debug_regs_flat(reg_dump)
    );

    // === Execute Stage ===
    Execute_Cycle EXECUTE (
        .clk(clk),
        .rst(rst),
        .RegWriteE(RegWriteE),
        .ALUSrcE(ALUSrcE),
        .MemWriteE(MemWriteE),
        .BranchE(BranchE),
        .ResultSrcE(ResultSrcE),
        .ALUControlE(ALUControlE),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Imm_Ext_E(Imm_Ext_E),
        .RD_E(RD_E),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .ForwardA_E(ForwardA_E),
        .ForwardB_E(ForwardB_E),
        .ResultW(ResultW),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE)
    );

    // === Memory Stage ===
    Memory_cycle MEMORY (
        .clk(clk),
        .rst(rst),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RD_M(RD_M),
        .PCPlus4M(PCPlus4M),
        .WriteDataM(WriteDataM),
        .ALU_ResultM(ALU_ResultM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .RD_W(RD_W),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW)
    );

    // === WriteBack Stage ===
    WriteBack_Cycle WB (
        .clk(clk),
        .rst(rst),
        .ResultSrcW(ResultSrcW),
        .PCPlus4W(PCPlus4W),
        .ALU_ResultW(ALU_ResultW),
        .ReadDataW(ReadDataW),
        .RD_W_in(RD_W),
        .RegWriteW_in(RegWriteW),
        .ResultW(ResultW),
        .RDW(RDW),
        .RegWriteW(RegWriteFinalW)
    );

    // === Hazard Detection and Forwarding Unit ===
    Hazard_Control HAZARD (
        .RS1_E(RS1_E),
        .RS2_E(RS2_E),
        .RD_M(RD_M),
        .RD_W(RDW),                   // Final WB destination
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteFinalW),
        .ForwardA_E(ForwardA_E),
        .ForwardB_E(ForwardB_E)
    );

endmodule
