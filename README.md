# RISCV RTL and Verification

RTL Design and Verification of a RISC-V RV32I implementation.

A special emphasis has been put on verification.
My goal is to not only design and implement an RV32I Core, but to also fully and professionally verify that implementation.

Each RTL module is paired with a UVM verification environment consisting of:
- Functional coverage
- Constrained-random and directed UVM sequences
- Behavioral reference models (SystemVerilog and C++ via DPI-C)
- SystemVerilog assertions

Note: I am actively developing this project.

## Project Structure

```
├── rtl/
│   ├── common/         # Typedefs, config, control enumerations
│   ├── alu.sv          # Arithmetic logic unit
│   ├── reg_file.sv     # 32x32 register file
│   ├── lut_ram.sv      # Generic parameterized LUT-RAM
│   ├── data_mem.sv     # Byte-addressable data memory
│   ├── inst_mem.sv     # Read-only instruction memory (ROM)
│   ├── imm_gen.sv      # Immediate generation unit
│   ├── if_stage.sv     # Instruction fetch stage
│   └── data_path.sv    # Data path module
│
├── verify/
│   ├── tb/             # Top-level testbenches
│   ├── tests/          # uvm_test classes
│   ├── sequences/      # uvm_sequence / uvm_sequence_item classes
│   ├── agents/         # uvm_agent classes (sequencer, driver, monitor)
│   ├── env/            # uvm_env classes (agent + scoreboard + coverage)
│   ├── ref_model/      # Behavioral reference models (SV and C++ via DPI-C)
│   ├── coverage/       # Functional coverage
│   ├── assert/         # SVA assertion modules (bound into RTL)
│   ├── interface/      # Interfaces with clocking blocks
│   └── common/         # Shared verification package
│
├── scripts/
│   ├── xsim/
│   │   ├── filelist/   # Compilation dependencies
│   │   ├── testlist/   # Regression testlists
│   │   └── *.tcl       # Waveform and simulation TCL scripts
│   └── gen/            # Python scripts for test data generation
│
├── xsim_comp.sh        # Compile script (Xilinx xvlog)
└── xsim_sim.sh         # Simulate/Regression script (Xilinx xsim)
```

## RTL Modules
I've currently implemented and verified the following modules with 100% coverage:
- ALU
- Register File
- LUT RAM
- Data Memory
- Instruction Memory
- Immediate Generator
- IF Stage

## Verification

Each RTL module is paired with a UVM verification environment consisting of:
- Functional coverage models
- Behavioral reference models (SystemVerilog and C++ via DPI-C)
- Assertions (SVA)
- UVM tests (directed or constrained-random) targeting different coverage elements
- Testbenches to instantiate the DUT, interfaces, assertions, and run the UVM tests

### Functional Coverage

Each module is accompanied by a functional coverage model defining the nominal
and corner-case behavior each module must exercise at some point during testing
to be considered verified.

Coverage is written using SystemVerilog coverpoints and crosses describing
key values and scenarios (transitions, boundary computations, overflows, read-after-writes ...)

For a module to be considered verified the testbench must hit 100% coverage.
A large part of the verification process involves going back and forth between
the sequences and coverage, tuning the constraints until we are hitting 100%.
If needed a separate directed test may be required to hit certain coverage elements.

### Assertions (SVA)

Each RTL module is paired with an assertion module that is bound directly into the RTL.

Once bound, assertions run alongside the RTL during simulation and provide a passive
secondary check of individual properties and functionalities within the RTL.

Assertions can be used hierarchically just like the RTL — child module assertions can be bound inside parent
assertion modules. For example `data_mem_assert` instantiates the `lut_ram`'s `lut_ram_assert`
module directly inside itself.

### Reference Models

Each module has a behavioral reference model (written in SystemVerilog or C++ via DPI-C) used by the scoreboard to verify the DUT's output.

Reference model implementations are intentionally kept as independent as possible from the RTL.
This is done by using either a different implementation than the RTL
or by writing the reference model in a completely different language (C or C++)
and integrating it into SystemVerilog via a Programming Interface (DPI-C).

Maximizing the difference between RTL and reference model implementations helps ensure
that we are not just duplicating the same bugs in both.
Ideally a completely different person would write the verification for each module than
the one who wrote the RTL, but obviously that's not possible with a personal project.

## Scripts

- `scripts/gen/gen_rand_inst_mem.py`
    - Generates weighted-random 32-bit values to fill test instruction memories for testing.
- `xsim_comp.sh`
    - Compiles SystemVerilog files.
    - Looks for an optional filelist (`scripts/xsim/filelist/<module>.f`) listing
      dependencies and compiles those too.
    - Automatically compiles any C++ DPI-C files found in the filelist using `xsc`.
- `xsim_sim.sh`
    - Compiles, elaborates, and simulates a testbench.
    - Runs a single UVM test with `-t <test_name>`, or a full regression with `-r <testlist>`.
    - Regression mode runs every test in the testlist, captures per-test logs, and merges coverage across all runs.
    - Supports CLI and GUI (`-g`) modes.

## How to Compile and Run Simulations

Prerequisites
- Xilinx Vivado (xvlog, xelab, xsim, xsc, xcrg must be on PATH)

```bash
# Compile a testbench and its dependencies
./xsim_comp.sh verify/tb/tb_alu.sv

# Run a single UVM test (CLI)
./xsim_sim.sh verify/tb/tb_alu.sv -t alu_rand_test

# Run a single UVM test in the GUI waveform viewer
./xsim_sim.sh verify/tb/tb_alu.sv -t alu_rand_test -g

# Run a regression (every test in the testlist, with merged coverage)
./xsim_sim.sh verify/tb/tb_alu.sv -r scripts/xsim/testlist/tb_alu.tests
```

Simulation outputs (logs, coverage databases, merged coverage reports) land under `sim/xsim/<tb_name>/`.

## Next Steps

- Short Term:
    - Continue implementing and verifying RTL modules towards a single-cycle RV32I Core.

- Long Term:
    - Implement 5-stage pipelining with forwarding, hazard detection and branch prediction.
    - Implement memory hierarchy with an L1 cache.
    - Get a version of the core running on an FPGA.

I am actively developing the project.

## Example Verification Results

Below are example results from the ALU verification environment.

### Test Output

<img width="400" alt="alu_test_output" src="https://github.com/user-attachments/assets/de2a3af2-4959-4123-abd8-41d84298c638" />

### Functional Coverage Report

<img width="1024" height="1684" alt="alu_coverage" src="https://github.com/user-attachments/assets/0b7d0fba-8e15-43b8-ba9b-b2101dbb6e38" />

