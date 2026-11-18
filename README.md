# Project_2_ECE2700
Microprocesser Unit stuff
# EE 2700: Project 3 – Microprocessor Controller

## Overview
This project completes the 8-bit microprocessor designed in Project 2 by adding a behavioral VHDL controller module (Finite State Machine). The controller generates and asserts all internal control signals dynamically based on instruction opcodes and status flags.

---

## 1. Controller Design Requirements (Behavioral VHDL FSM)
* **Reset State**:
  * On global reset, the controller must enter an initial state that puts the Program Counter (`PC`) onto the address bus and asserts the read signal (`rd_L`).
  * The first instruction opcode is fetched onto the internal data bus.
* **Instruction Execution**:
  * Decodes the fetched opcode and checks status flags (e.g., Carry flag `C` for conditional jump instructions like `op_jc` and `op_jnc`).
  * Steps through a sequence of execution states tailored to each opcode (`LDI`, `ADDI`, `ADCI`, `XORI`, `LDM`, `ADDM`, `ADCM`, `XORM`, `STM`, `JMP`, `JC`, `JNC`, `HALT`).
* **Fetch Loop**:
  * Upon instruction completion, the state machine returns `PC` to the address bus to fetch the next instruction opcode.

---

## 2. Top-Level Integration & Architecture Guidelines
* **Module Integration**:
  * Instantiate the VHDL controller module into the top-level microprocessor.
  * Internalize all control signals previously driven by the Project 2 test bench.
  * Export external memory control signals: active-low read (`rd_L`) and active-low write (`wr_L`).
* **Hardware & Design Rules**:
  * **Global Asynchronous Reset**: All reset-capable flip-flops/registers must share a single global asynchronous reset signal. No internally generated asynchronous resets are permitted.
  * **Global Clock**: All sequential elements must run off a single global clock (`clk`). No gated or internally generated clocks allowed.
  * **No Internal Bidirectional Busses**: Internal busses must be unidirectional; tri-state bidirectional logic is strictly limited to the external I/O data bus port.

---

## 3. Test Bench & Simulation Requirements
* **Libraries & Opcodes**:
  * Use `IEEE.std_logic_1164.all`, `IEEE.numeric_std.all`, and `IEEE.std_logic_unsigned.all`.
  * Declare opcode constants in the test bench architecture matching your instruction set (e.g., `op_halt = X"00"`, `op_jmp = X"01"`, `op_ldi = X"10"`, `op_stm = X"30"`, etc.).
* **RAM Initialization (Euclid's Algorithm)**:
  * Model a $256 \times 8$-bit RAM array (`type ram_type is array (0 to 255) of STD_LOGIC_VECTOR(7 downto 0);`).
  * Pre-initialize RAM with the program that runs Euclid's Algorithm to find the Greatest Common Factor (GCF) of $145\text{ (91}_{16}\text{)}$ and $232\text{ (E8}_{16}\text{)}$.
  * Standard synchronous RAM process: writes on `rising_edge(clk)` when `wr = '1'`, outputs data when `rd = '1'`, otherwise drives high-impedance (`"ZZZZZZZZ"`).
* **Simulation Verification**:
  * Assert global reset briefly, then run the simulation for **at least 135 clock cycles**.
  * **Success Criteria**: Address location `63` (`3F`16) must contain the value **`29` (`1D`16)** at the end of execution.

---

## 4. Submission Deliverables
1. Top-level microprocessor schematic / block diagram.
2. VHDL source code for the FSM Controller and Top-Level Microprocessor modules.
3. Simulation waveform export (showing address and data bus values during the final two write cycles).