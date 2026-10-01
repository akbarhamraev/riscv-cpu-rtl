# RISC-V CPU Project Status

## Architecture

32-bit single-cycle RISC-V processor implemented in synthesizable SystemVerilog.

## Supported Instructions

### R-type
- ADD
- SUB
- AND
- OR
- XOR

### I-type
- ADDI
- LW

### S-type
- SW

### B-type
- BEQ

### J-type
- JAL

## RTL Modules

- ALU
- Register File
- Immediate Generator
- Control Unit
- ALU Control
- Instruction Memory
- Data Memory
- CPU Top Level

## Verification

The CPU testbench verifies:

- Register writes
- ALU operations
- Load/store operation
- Branch operation
- Jump operation
- JAL link register
- Register zero behavior

## Automation

Python regression script automatically:

1. Compiles the RTL using Verilator.
2. Runs the simulation.
3. Checks the CPU test result.
4. Reports build or verification failure.

## Current Status

All implemented instruction tests pass.
