`timescale 1ns / 1ps




module Hazard_Control(
    input  wire [4:0] RS1_E, RS2_E,   // Source registers in Execute stage
    input  wire [4:0] RD_M, RD_W,     // Destination registers from MEM and WB
    input  wire       RegWriteM,      // Write-back enable from MEM
    input  wire       RegWriteW,      // Write-back enable from WB
    output reg  [1:0] ForwardA_E,     // Forward control for operand A
    output reg  [1:0] ForwardB_E      // Forward control for operand B
);

    always @(*) begin
        // Default: no forwarding
        ForwardA_E = 2'b00;
        ForwardB_E = 2'b00;

        // ForwardA logic
        if (RegWriteM && (RD_M != 0) && (RD_M == RS1_E))
            ForwardA_E = 2'b10;  // Forward from MEM
        else if (RegWriteW && (RD_W != 0) && (RD_W == RS1_E))
            ForwardA_E = 2'b01;  // Forward from WB

        // ForwardB logic
        if (RegWriteM && (RD_M != 0) && (RD_M == RS2_E))
            ForwardB_E = 2'b10;  // Forward from MEM
        else if (RegWriteW && (RD_W != 0) && (RD_W == RS2_E))
            ForwardB_E = 2'b01;  // Forward from WB
    end

endmodule

