`timescale 1ns / 1ps


module Decode_cycle(
    input clk, rst,
    input [31:0] InstrD, PCD, PCPlus4D,
    input RegWriteW,
    input [4:0] RDW,
    input [31:0] ResultW,

    output reg RegWriteE,
    output reg ALUSrcE,
    output reg MemWriteE,
    output reg [1:0] ResultSrcE,
    output reg BranchE,
    output reg [2:0] ALUControlE,

    output reg [31:0] RD1_E,
    output reg [31:0] RD2_E,
    output reg [31:0] Imm_Ext_E,
    output reg [4:0] RD_E,
    output reg [31:0] PCE,
    output reg [31:0] PCPlus4E,
    output reg [4:0] RS1_E,
    output reg [4:0] RS2_E,
    output wire [1023:0]debug_regs_flat
);

    // Intermediate wires
    wire [6:0] opcode = InstrD[6:0];
    wire [2:0] funct3 = InstrD[14:12];
    wire [6:0] funct7 = InstrD[31:25];
    wire [4:0] rs1    = InstrD[19:15];
    wire [4:0] rs2    = InstrD[24:20];
    wire [4:0] rd     = InstrD[11:7];
    wire [1:0] ImmSrc;
    wire RegWrite, ALUSrc, MemWrite, Branch;
    wire [1:0] ResultSrc;
    wire [2:0] ALUControl;
    wire [31:0] ImmExt, RD1, RD2;

    // Register File
    RegisterFile rf (
        .clk(clk),
        .rst(rst),
        .WE3(RegWriteW),
        .A1(rs1),
        .A2(rs2),
        .A3(RDW),
        .WD3(ResultW),
        .RD1(RD1),
        .RD2(RD2),
        .debug_regs_flat(debug_regs_flat)
    );

    // Control Unit
    ControlUnit cu (
        .Op(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUControl(ALUControl)
    );

    // Sign Extend
    Sign_Extend se (
        .In(InstrD),
        .ImmSrc(ImmSrc),
        .Imm_Ext(ImmExt)
    );

    // Pipeline Register (Decode to Execute)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWriteE    <= 0;
            ALUSrcE      <= 0;
            MemWriteE    <= 0;
            ResultSrcE   <= 0;
            BranchE      <= 0;
            ALUControlE  <= 0;
            RD1_E        <= 0;
            RD2_E        <= 0;
            Imm_Ext_E    <= 0;
            RD_E         <= 0;
            PCE          <= 0;
            PCPlus4E     <= 0;
            RS1_E        <= 0;
            RS2_E        <= 0;
        end else begin
            RegWriteE    <= RegWrite;
            ALUSrcE      <= ALUSrc;
            MemWriteE    <= MemWrite;
            ResultSrcE   <= ResultSrc;
            BranchE      <= Branch;
            ALUControlE  <= ALUControl;
            RD1_E        <= RD1;
            RD2_E        <= RD2;
            Imm_Ext_E    <= ImmExt;
            RD_E         <= rd;
            PCE          <= PCD;
            PCPlus4E     <= PCPlus4D;
            RS1_E        <= rs1;
            RS2_E        <= rs2;
        end
    end

endmodule




module RegisterFile (
    input wire clk,
    input wire rst,
    input wire WE3,                 // Write Enable
    input wire [4:0] A1, A2, A3,    // 5-bit addresses (0-31)
    input wire [31:0] WD3,          // Write Data
    output reg [31:0] RD1, RD2,    // Read Data
    output reg [1023:0] debug_regs_flat // Flattened output: 32 regs × 32 bits
);

    // Declare 32 registers of 32-bit width
    reg [31:0] regs[0:31];

    integer i;
    // Reset all registers to 0
    always @(posedge rst) begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] <= 32'b0;
    end

    // Write operation
    always @(posedge clk) begin
        if (WE3 && A3 != 5'b00000)
            regs[A3] <= WD3;

        // Update flattened output every clock (for simulation)
        for (i = 0; i < 32; i = i + 1) begin
            debug_regs_flat[i*32 +: 32] <= regs[i];
        end
    end

    always@(*)
    begin
     RD1 = (A1 == 5'd0) ? 32'd0 : regs[A1];
     RD2 = (A2 == 5'd0) ? 32'd0 : regs[A2];
end

endmodule




module Sign_Extend (
    input wire [31:0] In,
    input wire [1:0] ImmSrc,
    output reg [31:0] Imm_Ext
);

    always @(*) begin
        case (ImmSrc)
            2'b00: begin // I-type (e.g., LW, ADDI)
                Imm_Ext = {{20{In[31]}}, In[31:20]};
            end
            2'b01: begin // S-type (e.g., SW)
                Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]};
            end
            2'b10: begin // B-type (e.g., BEQ)
                Imm_Ext = {{19{In[31]}}, In[31], In[7], In[30:25], In[11:8], 1'b0};
            end
             2'b11: begin // J-type (e.g., JAL)
                Imm_Ext = {{11{In[31]}}, In[31], In[19:12], In[20], In[30:21], 1'b0};
            end
            default: begin
                Imm_Ext = 32'b0;
            end
        endcase
    end

endmodule





module Main_Decoder(
    input wire [6:0] Op,
    output reg RegWrite,
    output reg [1:0] ImmSrc,
    output reg ALUSrc,
    output reg MemWrite,
    output reg [1:0] ResultSrc,
    output reg Branch,
    output reg [1:0] ALUOp
);

    always @(*) begin
        // Default values (NOP)
        RegWrite   = 1'b0;
        ImmSrc     = 2'b00;
        ALUSrc     = 1'b0;
        MemWrite   = 1'b0;
        ResultSrc  = 2'b00;
        Branch     = 1'b0;
        ALUOp      = 2'b00;

        case (Op)
            7'b0110011: begin // R-type (ADD, SUB, AND, OR, etc.)
                RegWrite   = 1'b1;
                ALUSrc     = 1'b0;
                ResultSrc  = 2'b00; // ALU result
                ALUOp      = 2'b10;
            end
            7'b0010011: begin // I-type (ADDI, ORI, ANDI, etc.)
                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                ImmSrc     = 2'b00; // I-type immediate
                ResultSrc  = 2'b00;
                ALUOp      = 2'b10;
            end
            7'b0000011: begin // LW
                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                ImmSrc     = 2'b00; // I-type
                MemWrite   = 1'b0;
                ResultSrc  = 2'b01; // Memory output
                ALUOp      = 2'b00;
            end
            7'b0100011: begin // SW
                RegWrite   = 1'b0;
                ALUSrc     = 1'b1;
                ImmSrc     = 2'b01; // S-type
                MemWrite   = 1'b1;
                ALUOp      = 2'b00;
            end
            7'b1100011: begin // BEQ, BNE (B-type)
                RegWrite   = 1'b0;
                ALUSrc     = 1'b0;
                ImmSrc     = 2'b10; // B-type
                Branch     = 1'b1;
                ALUOp      = 2'b01;
            end
            7'b1101111: begin // JAL
                RegWrite   = 1'b1;
                ALUSrc     = 1'bx;  // Don't care
                ImmSrc     = 2'b11; // J-type
                ResultSrc  = 2'b10; // PC+4
                ALUOp      = 2'b00;
            end
            7'b0110111: begin // LUI
                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                ImmSrc     = 2'b11; // U-type (reused J-type logic)
                ResultSrc  = 2'b00;
                ALUOp      = 2'b00;
            end
            default: begin
                // Invalid or unhandled opcode ? all default (NOP)
            end
        endcase
    end

endmodule

module ALU_Decoder(
    input wire [1:0] ALUOp,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [2:0] ALUControl
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000; // LW, SW
            2'b01: ALUControl = 3'b001; // BEQ -> SUB
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        // ADD/SUB or ADDI
                        if (funct7 == 7'b0100000) // only SUB has funct7 = 0100000
                            ALUControl = 3'b001; // SUB
                        else
                            ALUControl = 3'b000; // ADD or ADDI
                    end
                    3'b111: ALUControl = 3'b100; // AND / ANDI
                    3'b110: ALUControl = 3'b011; // OR / ORI
                    3'b010: ALUControl = 3'b101; // SLT / SLTI
                    default: ALUControl = 3'b000; // Default ADD
                endcase
            end
            default: ALUControl = 3'b000;
        endcase
    end
endmodule




module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output wire RegWrite,
    output wire [1:0] ImmSrc,
    output wire ALUSrc,
    output wire MemWrite,
    output wire[1:0] ResultSrc,
    output wire Branch,
    output wire [2:0] ALUControl
);

    wire [1:0] ALUOp;

    // Instantiate Main Decoder
    Main_Decoder main_decoder (
        .Op(Op),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    // Instantiate ALU Decoder
    ALU_Decoder alu_decoder (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

endmodule
