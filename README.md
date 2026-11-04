# RISC-V 32-Bit Single-Cycle CPU Core (RV32I Subset)

A Verilog implementation of a single-cycle RISC-V processor core targeted for the **Gowin Tang Nano 9K FPGA**. The design includes a full datapath, control unit, memory-mapped I/O (MMIO), a physical UART transmitter, and an automated verification testbench.

---

## Architecture Overview

- **Instruction Set Architecture:** RV32I subset (`ADDI`, `ADD`, `SUB`, `AND`, `OR`, `SLT`, `SW`, `LW`, `BEQ`).
- **Datapath:** Single-cycle execution with asynchronous read / synchronous write register file (32 x 32-bit).
- **Peripherals & I/O:**
  - Memory-Mapped I/O (MMIO) targeting address `0x00000040`.
  - Dedicated hardware UART transmitter module operating at 115200 baud (27MHz system clock).
  - 6-bit visual instruction/PC indicator mapped to onboard LEDs.
- **Clock Management:** Custom frequency divider scaling the onboard 27MHz clock to about 10 Hz for stable hardware execution.
- **Reset:** The reset button (active low) restarts the program. The PC uses an asynchronous reset, because the divided clock is held low while the button is pressed.

---

## Supported Instructions

| Type       | Instruction | Opcode    | Funct3 | Funct7    | Description                      |
|:-----------|:------------|:----------|:-------|:----------|:---------------------------------|
| **R-Type** | `ADD`       | `0110011` | `000`  | `0000000` | Register addition                |
|            | `SUB`       | `0110011` | `000`  | `0100000` | Register subtraction             |
|            | `AND`       | `0110011` | `111`  | `0000000` | Bitwise AND                      |
|            | `OR`        | `0110011` | `110`  | `0000000` | Bitwise OR                       |
|            | `SLT`       | `0110011` | `010`  | `0000000` | Signed set less than             |
| **I-Type** | `ADDI`      | `0010011` | `000`  | N/A       | Add immediate                    |
|            | `LW`        | `0000011` | `010`  | N/A       | Load word from data memory       |
| **S-Type** | `SW`        | `0100011` | `010`  | N/A       | Store word to data memory / MMIO |
| **B-Type** | `BEQ`       | `1100011` | `000`  | N/A       | Branch if equal                  |

---

## Board build vs. simulation build

The same source files serve both purposes. The top module `cpu` has a parameter `SIM`:

| | `SIM = 0` (default, board) | `SIM = 1` (simulation) |
|:--|:--|:--|
| Clock for PC / regfile / dmem | divided clock, about 10 Hz | the fast clock directly |
| Program in `imem` | UART demo, prints `HELLO FROM RISC-V!` | self-checking test program |
| Registers at start | not initialised | initialised to 0 |

The Gowin project uses the default (`SIM = 0`), so the board build is unchanged. `cpu_tb.v` instantiates the core with `cpu #(.SIM(1))`.

---

## Verification & Self-Checking Testbench

The core is verified using an automated self-checking testbench simulated with Icarus Verilog. Each instruction writes its result to the register file, and the testbench samples the registers after execution to validate the state.

### Run the simulation

```
cd src
iverilog -o sim *.v
vvp sim
```

(In the Gowin project, add every file in `src` except `cpu_tb.v`.)

### Simulation Summary

```
==========================================
   STARTING SELF-CHECKING VERIFICATION    
==========================================
[PASS] ADDI (x1)    | x1  = 10
[PASS] ADDI (x2)    | x2  = 20
[PASS] ADD          | x3  = 30
[PASS] SUB          | x4  = 10
[PASS] AND          | x5  = 0
[PASS] OR           | x6  = 30
[PASS] SLT          | x7  = 1
[PASS] SW and LW    | x8  = 30
[PASS] BEQ SKIP     | x9  = 0
[PASS] BEQ TARGET   | x10 = 1
------------------------------------------
>>> ALL TESTS PASSED SUCCESSFULLY! <<<
==========================================
```
