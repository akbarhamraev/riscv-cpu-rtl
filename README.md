# Single-Cycle RISC-V Processor

This is a small 32-bit single-cycle RISC-V processor written in synthesizable SystemVerilog. I built it as an exercise in RTL design and verification, and the project covers simulation, assertion-based checking, Python-driven automation, and synthesis with Yosys.

## Architecture

The core is made up of a program counter, instruction memory, a control unit, an ALU control block, a register file, an immediate generator, the ALU, and data memory. It also includes the writeback path and the logic that handles branches and jumps. Each instruction is fetched, decoded, executed, and written back within a single clock cycle.

## Supported Instructions

The processor implements a deliberately small subset of RV32I, not the full specification.

| Format | Instructions |
|--------|--------------|
| R-type | ADD, SUB, AND, OR, XOR |
| I-type | ADDI, LW |
| S-type | SW |
| B-type | BEQ |
| J-type | JAL |

## RTL Structure

    rtl/
    ├── alu.sv
    ├── alu_control.sv
    ├── control_unit.sv
    ├── data_memory.sv
    ├── imm_gen.sv
    ├── instruction_memory.sv
    ├── register_file.sv
    └── riscv_cpu.sv

## Verification

Simulation is done with Verilator, and basic hardware invariants are checked with SystemVerilog assertions.

The testbench covers ADD, SUB, AND, OR, XOR, ADDI, LW, SW, BEQ, and JAL, including the JAL link address. It also checks the behavior of register x0 and memory reads and writes.

Two assertions run alongside the tests. One confirms that x0 always stays zero, and the other confirms that the PC remains word aligned.

## Automated Regression

A Python script runs the full regression flow. It compiles the SystemVerilog RTL, builds the Verilator simulation, and runs the CPU testbench. It then checks the functional results and any assertion failures, runs RTL synthesis with Yosys, and reports the overall regression status.

To run it:

    make regress

## Simulation

To build and run the CPU:

    make

To run the full regression:

    make regress

To generate waveforms for viewing:

    make wave

The waveforms can be opened in GTKWave to inspect the PC, the current instruction, ALU inputs and result, immediate values, branch decisions, memory accesses, and register activity.

## Synthesis

The RTL is synthesized with Yosys:

    make synth

The synthesis report includes statistics on wires, memories, processes, and synthesized cells.

The memories in this design are inferred and are meant for educational use. A production ASIC flow would normally use technology-specific SRAM macros or a memory compiler instead.

## Tools

- SystemVerilog
- Verilator
- GTKWave
- Yosys
- Python
- Make
- Git
- Linux / WSL

## Project Goals

The project was meant to build hands-on experience in RTL design with SystemVerilog, datapath and control design, and CPU architecture. It also covers RTL verification with SystemVerilog assertions, simulation and waveform debugging, Python automation, Make-based build flows, RTL synthesis, and Git-based development.

## Current Status

| Check | Result |
|-------|--------|
| Functional simulation | Pass |
| Assertions | Pass |
| Automated regression | Pass |
| RTL synthesis | Pass |

Supported ISA: RV32I subset

## Future Improvements

Possible next steps include:

- Adding more RV32I instructions
- Expanding testing with constrained-random stimulus and functional coverage
- Writing additional SystemVerilog assertions
- Moving to a pipelined implementation, with hazard detection and forwarding
- Adding CSR and interrupt support
- Targeting an FPGA
