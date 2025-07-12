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

module Execute_Cycle(
    input clk, rst,
    input RegWriteE, ALUSrcE, MemWriteE, BranchE,
    input [1:0] ResultSrcE,
    input [2:0] ALUControlE,
    input [31:0] RD1_E, RD2_E, Imm_Ext_E,
    input [4:0] RD_E,
    input [31:0] PCE, PCPlus4E,
    input [1:0] ForwardA_E, ForwardB_E,
    input [31:0] ResultW, 

    output reg RegWriteM, MemWriteM,
    output reg [1:0] ResultSrcM,
    output reg [4:0] RD_M,
    output reg [31:0] PCPlus4M,
    output reg [31:0] WriteDataM,
    output reg [31:0] ALU_ResultM,
    output reg PCSrcE,
    output reg [31:0] PCTargetE
);

    // Intermediate wires
    wire [31:0] SrcA, SrcB, ALU_inputB;
    wire [31:0] ALUResult;
    wire Zero;
    wire[31:0] PCTargetE0;
    wire PCSrcE0;
    
    // Forwarding logic for operand A
    mux4x1 ForwardA_MUX (
        .I0(RD1_E),
        .I1(ResultW),
        .I2(ALU_ResultM),
        .sel(ForwardA_E),
        .out(SrcA)
    );

    // Forwarding logic for operand B
    mux4x1 ForwardB_MUX (
        .I0(RD2_E),
        .I1(ResultW),
        .I2(ALU_ResultM),
        .sel(ForwardB_E),
        .out(SrcB)
    );

    // ALUSrc MUX to choose between SrcB and immediate
    wire [31:0] ALU_B;
    mux2x1 ALUSrc_MUX (
        .I0(SrcB),
        .I1(Imm_Ext_E),
        .S0(ALUSrcE),
        .out(ALU_B)
    );

    // ALU unit
    wire dummy_OF, dummy_CF, dummy_N;
    ALU alu (
        .A(SrcA),
        .B(ALU_B),
        .ALUControl(ALUControlE),
        .Result(ALUResult),
        .OverFlow(dummy_OF),
        .Carry(dummy_CF),
        .Zero(Zero),
        .Negative(dummy_N)
    );

    // Branch target address calculation
    Adder Branch_Adder (
        .I0(PCE),
        .I1(Imm_Ext_E),
        .out(PCTargetE0)
    );

    // PCSrcE: whether to take the branch
    assign PCSrcE0 = BranchE & Zero;

    // Pipeline register: Execute to Memory stage
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWriteM   <= 0;
            MemWriteM   <= 0;
            ResultSrcM  <= 0;
            RD_M        <= 0;
            PCPlus4M    <= 0;
            WriteDataM  <= 0;
            ALU_ResultM <= 0;
            PCTargetE<=0;
             PCSrcE<=0;
        end else begin
            RegWriteM   <= RegWriteE;
            MemWriteM   <= MemWriteE;
            ResultSrcM  <= ResultSrcE;
            RD_M        <= RD_E;
            PCPlus4M    <= PCPlus4E;
            WriteDataM  <= SrcB;          // WriteData is from forwarded SrcB
            ALU_ResultM <= ALUResult;
             PCSrcE<= PCSrcE0;
             PCTargetE<=PCTargetE0;
        end
    end

endmodule




module mux4x1(input wire [31:0]I0,I1,I2,
              input wire [1:0] sel,
              output wire[31:0] out);
              
              assign out=(sel==2'b00)?I0:(sel==2'b01)?I1:(sel==2'b10)?I2:32'h00000000;
              
              
              endmodule
              
              
     

module ALU (
    input  wire [31:0] A,          // Operand A
    input  wire [31:0] B,          // Operand B
    input  wire [2:0]  ALUControl, // ALU operation selector
    output reg  [31:0] Result,     // ALU result
    output wire        OverFlow,   // Overflow flag
    output wire        Carry,      // Carry-out (only meaningful for addition)
    output wire        Zero,       // Zero flag
    output wire        Negative    // Negative flag (sign bit)
);

    wire [32:0] sum_ext;   // To capture carry out
    reg [31:0] logic_result;
    reg        of_flag;

    // Extended sum with carry
    assign sum_ext = {1'b0, A} + {1'b0, B};

    // ALU Operations
    always @(*) begin
        case (ALUControl)
            3'b000: begin // ADD
                Result = A + B;
                of_flag = (A[31] == B[31]) && (Result[31] != A[31]);  // overflow detection
            end
            3'b001: begin // SUB
                Result = A - B;
                of_flag = (A[31] != B[31]) && (Result[31] != A[31]);
            end
            3'b010: begin // AND
                Result = A & B;
                of_flag = 1'b0;
            end
            3'b011: begin // OR
                Result = A | B;
                of_flag = 1'b0;
            end
            3'b100: begin // XOR
                Result = A ^ B;
                of_flag = 1'b0;
            end
            3'b101: begin // SLT (Set Less Than)
                Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
                of_flag = 1'b0;
            end
            3'b110: begin // NOR
                Result = ~(A | B);
                of_flag = 1'b0;
            end
            default: begin
                Result = 32'd0;
                of_flag = 1'b0;
            end
        endcase
    end

    // Flags
    assign Carry    = sum_ext[32];       // Only valid for addition
    assign OverFlow = of_flag;
    assign Zero     = (Result == 32'd0);
    assign Negative = Result[31];

endmodule


