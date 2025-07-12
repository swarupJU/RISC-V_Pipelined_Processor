# 32-bit Pipelined RISC-V Processor

This project is a fully functional 32-bit pipelined RISC-V processor implemented in Verilog HDL. It supports the RV32I base integer instruction set and follows the classic 5-stage pipeline: Fetch, Decode, Execute, Memory, and Writeback.

## Supported Operations

The processor can execute the following instruction types and operations:

### R-type instructions
- ADD
- SUB
- AND
- OR
- SLT

### I-type instructions
- ADDI
- ANDI
- ORI
- LW

### S-type instructions
- SW

### B-type instructions
- BEQ
- BNE

### J-type instruction
- JAL

### U-type instruction
- LUI

## Summary

- 32-bit architecture (RV32I)
- Implements a 5-stage pipelined datapath
- Includes register file, ALU, control unit, immediate generation, and pipeline registers
- Suitable for basic CPU design education and simulation

## Limitations

- No interrupt or exception support
- No CSR or RV32M/A/F extensions
## File structure
### i) src-
#### 1) Fetch Cycle
#### 2) Decode Cycle
#### 3) Execute Cycle
#### 4) Memory Cycle
#### 5) Writeback Cycle
#### 6) Hazard Unit
#### 7) Top_Pipeline
### ii) testbench-
#### tb_TopPipeline

## License

   Copyright 2025 Swarup Saha Roy

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.


## Contributing

Feel free to contribute by suggesting improvements, reporting bugs, or adding more instructions and pipeline enhancements!

---

## Author

Developed by: Swarup Saha Roy

Contact: swarupsaharoy2004@gmail.com 

Institution: Jadavpur University

