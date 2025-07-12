

`timescale 1ns / 1ps

module Memory_cycle(
    input clk, rst,
    input RegWriteM,
    input MemWriteM,
    input [1:0] ResultSrcM,
    input [4:0] RD_M,
    input [31:0] PCPlus4M,
    input [31:0] WriteDataM,
    input [31:0] ALU_ResultM,

    output reg RegWriteW,
    output reg [1:0] ResultSrcW,
    output reg [4:0] RD_W,
    output reg [31:0] PCPlus4W,
    output reg [31:0] ALU_ResultW,
    output reg [31:0] ReadDataW
);

    wire [31:0] ReadDataM;

    // Instantiate Data Memory
    Data_mem data_memory (
        .clk(clk),
        .rst(rst),
        .We(MemWriteM),
        .Wd(WriteDataM),
        .A(ALU_ResultM),
        .Rd(ReadDataM)
    );

    // MEM/WB pipeline register logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RegWriteW    <= 0;
            ResultSrcW   <= 0;
            RD_W         <= 0;
            PCPlus4W     <= 0;
            ALU_ResultW  <= 0;
            ReadDataW    <= 0;
        end else begin
            RegWriteW    <= RegWriteM;
            ResultSrcW   <= ResultSrcM;
            RD_W         <= RD_M;
            PCPlus4W     <= PCPlus4M;
            ALU_ResultW  <= ALU_ResultM;
            ReadDataW    <= ReadDataM;
        end
    end

endmodule


module Data_mem (
    input clk,
    input rst,
    input We,
    input [31:0] Wd,
    input [31:0] A,
    output reg [31:0] Rd
);

    reg [31:0] mem [0:255]; // 1 KB of word-addressable memory

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Rd <= 32'b0;
        end else begin
            if (We)
                mem[A[31:0]] <= Wd;   // Word-aligned write
            Rd <= mem[A[31:0]];       // Word-aligned read
        end
    end
    
    integer i;
    initial begin
    for (i = 0; i < 256; i = i + 1) begin
        mem[i] = 32'h000000B;
    end
end

    
    
    
    

endmodule
