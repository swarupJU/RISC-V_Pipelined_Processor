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

module Fetch_cycle(
    input wire clk,
    input wire rst,
    input wire PCSrcE,
    input wire [31:0] PCTargetE,
    output wire [31:0] InstrD,
    output wire [31:0] PCD,
    output wire [31:0] PCPlus4D
);

    // --- Intermediate wires ---
    wire [31:0] PC_current;
    wire [31:0] PC_next;
    wire [31:0] PC_plus4;
    wire [31:0] instr_fetched;

    // --- Output registers (pipeline registers) ---
    reg [31:0] instr_reg;
    reg [31:0] pc_reg;
    reg [31:0] pc_plus4_reg;

    // --- PC Mux: choose between PC+4 or branch target ---
    mux2x1 pc_mux (
        .I0(PC_plus4),
        .I1(PCTargetE),
        .S0(PCSrcE),
        .out(PC_next)
    );

    // --- Program Counter Register ---
    PC pc_module (
        .clk(clk),
        .rst(rst),
        .PC_in(PC_next),
        .PC_out(PC_current)
    );

    // --- Instruction Memory (asynchronous read) ---
    InstrMem instr_mem (
        .rst(rst),
        .addr(PC_current),
        .instr_out(instr_fetched)
    );

    // --- PC + 4 Adder ---
    Adder pc_adder (
        .I0(PC_current),
        .I1(32'd4),
        .out(PC_plus4)
    );

    // --- Pipeline register update on clk ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            instr_reg     <= 32'h00000000;
            pc_reg        <= 32'h00000000;
            pc_plus4_reg  <= 32'h00000000;
        end
        else begin
            instr_reg     <= instr_fetched;
            pc_reg        <= PC_current;
            pc_plus4_reg  <= PC_plus4;
        end
    end

    // --- Output assignments from registered values ---
    assign InstrD     = instr_reg;
    assign PCD        = pc_reg;
    assign PCPlus4D   = pc_plus4_reg;

endmodule


module mux2x1(input wire[31:0] I0,
              input wire [31:0]I1,
              input wire       S0,
              output wire [31:0]out);
              
              
    assign out=S0?I1:I0;          
              
              
              endmodule
              
  module PC(clk,rst,PC_in,PC_out);
  input wire clk,rst;
  input[31:0] PC_in;
  output reg [31:0] PC_out;
  
  
  always@(posedge clk or posedge rst)
  begin
  if(rst) PC_out<={32{1'b0}};
  else PC_out<=PC_in;
  end
             
    endmodule           
              
    
    module Adder(I0,I1,out);
             input wire [31:0] I0,I1;
             output wire [31:0] out;
             assign out=I0+I1;
              

              endmodule
             
             
module InstrMem (
    input wire rst,                // Reset: initializes memory
    input wire [31:0] addr,        // Byte address
    output reg [31:0] instr_out   // Instruction output (assembled from 4 bytes)
);

    reg [7:0] imem[0:255];  // 1 KB instruction memory (256 bytes)
always@(*)begin
    // Output 4 bytes as 1 instruction (Little Endian)
    instr_out = {imem[addr + 3], imem[addr + 2], imem[addr + 1], imem[addr]};
end
    // Initialize contents during reset
    integer i;
    always @(posedge rst) begin
        if (rst) begin
            for (i = 0; i < 256; i = i + 1)
                imem[i] = 8'h00;  // NOPs (safe default)

            // Sample instructions (little-endian)
// ADDI x7, x0, 100
imem[0] = 8'h93;
imem[1] = 8'h03;
imem[2] = 8'h40;
imem[3] = 8'h06;


// ADDI x8, x0, 55
imem[4] = 8'h13;
imem[5] = 8'h04;
imem[6] = 8'h70;
imem[7] = 8'h03;

// JAL x0, 32 ? jump to address 0x28 (i.e., skip 8 instructions or 32 bytes)
imem[8]  = 8'h6F;
imem[9]  = 8'h00;
imem[10] = 8'h00;
imem[11] = 8'h02;

// ADDI x2, x0, 9
imem[12] = 8'h13;
imem[13] = 8'h01;
imem[14] = 8'h90;
imem[15] = 8'h00;

// ADDI x1, x0, 8
imem[16] = 8'h93;
imem[17] = 8'h00;
imem[18] = 8'h80;
imem[19] = 8'h00;

// ADDI x5, x0, 1
imem[20] = 8'h93;
imem[21] = 8'h02;
imem[22] = 8'h10;
imem[23] = 8'h00;

// ADDI x6, x0, 2
imem[24] = 8'h13;
imem[25] = 8'h03;
imem[26] = 8'h20;
imem[27] = 8'h00;

// ADDI x5, x0, 1
imem[28] = 8'h93;
imem[29] = 8'h02;
imem[30] = 8'hA0;
imem[31] = 8'h00;

imem[32] = 8'h23;  // opcode
imem[33] = 8'h00;  // imm[4:0] + funct3
imem[34] = 8'h73;  // rs1 + rs2
imem[35] = 8'h04;  // imm[11:5]


//// LW x9, 0(x7)
//imem[36] = 8'h83;
//imem[37] = 8'hA4;
//imem[38] = 8'h03;
//imem[39] = 8'h00;

// LW x9, 0(x7)
imem[36] = 8'h83;
imem[37] = 8'hA4;
imem[38] = 8'h03;
imem[39] = 8'h00;

        end
    end

endmodule

              
