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

