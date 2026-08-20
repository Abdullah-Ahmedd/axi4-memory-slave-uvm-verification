# AXI4-Compliant Memory-Mapped Slave Verification using UVM

A full UVM verification environment for an AXI4-compliant memory-mapped slave (AXI4 slave interface + synchronous internal memory), built on top of an earlier class-based SystemVerilog CDV testbench for the same DUT.

## DUT Overview

The design under test is a simplified AXI4 subsystem:

- **`axi4_slave`** — Interprets and manages AXI4 transactions (burst reads/writes, protocol enforcement), and executes read/write operations against the connected memory.
- **`axi4_memory`** — Synchronous single-port RAM, word-addressable, 1024 x 32-bit (4 KB total), used as the read/write target.

Protocol characteristics covered:
- Separate address, data, and (for writes) response channels with independent VALID/READY handshakes
- Burst-based transfers via `AWLEN`/`ARLEN` (beats = `LEN + 1`) and `AWSIZE`/`ARSIZE` (fixed at word size, 4 bytes, in this design)
- 4 KB burst-boundary compliance checking, with `SLVERR` response on violation
- Word-aligned internal memory access (byte address `>> 2`)

Per the project spec, the UVM environment targets **basic READ and WRITE functionality without the burst feature** as the primary scope, with burst verification as an optional extension.

## UVM Environment Structure

```
uvm_test
 └── uvm_env
      ├── uvm_agent (active)
      │    ├── sequencer
      │    ├── driver     — drives axi4_packet items onto the AW/W/B/AR/R channels
      │    └── monitor     — samples DUT-side signals, reconstructs transactions
      ├── scoreboard        — predicted vs. actual checking
      └── coverage          — functional coverage collector (covergroups/coverpoints)

uvm_sequence → uvm_sequence_item (axi4_packet) → sequencer → driver → DUT
                                                              monitor ← DUT
```

- **Transaction item**: `axi4_packet` — encapsulates address, burst length/size, data, and response fields, with constraints for legal AXI4 stimulus (address alignment, boundary-safe bursts) and directed constraints for corner/error cases.
- **Driver**: Converts `axi4_packet` sequence items into pin-level AW/W/B (write) and AR/R (read) channel activity, respecting VALID/READY handshake timing.
- **Monitor**: Passively observes the interface, reconstructs transactions, and publishes them via analysis port(s) to the scoreboard and coverage collector.
- **Scoreboard**: Compares expected vs. actual read data and write responses; flags mismatches via UVM reporting (`uvm_error`/`uvm_info`).
- **Coverage**: Covergroups sampling burst length, burst size, address regions, and read/write transaction types, with cross coverage where meaningful.
- **Assertions**: Concurrent SVA bound to the interface, checking VALID/READY handshake stability, `WLAST`/`RLAST` correctness, and address/boundary rules.

## Bugs Found and Fixed During Bring-Up

- **Read data capture gating** — monitor was originally sampling `RDATA` off the wrong handshake condition; fixed to gate capture on `RVALID && RREADY`.
- **Inverted `wait()` logic** in driver/monitor handshake waits, causing transactions to be missed or duplicated.
- **Scoreboard response boundary off-by-one** — expected/actual comparison window was misaligned by one beat on multi-beat sequences.
- **SVA naming and implication operator issues** — property naming collisions and incorrect `|->` vs `|=>` usage in handshake/stability assertions, corrected for proper same-cycle vs. next-cycle semantics.
- Various QuestaSim **compile-order and filelist** issues resolved for clean, repeatable builds.

## Coverage Goals

Per spec:
- 100% functional coverage
- 100% code coverage (line/toggle/branch/condition)
- 100% assertion coverage

Where 100% is not reached, uncovered bins are documented with justification (illegal, unreachable, or explicitly out of scope per the "no burst" simplification) in the submission PDF.

## Optional Extensions (if implemented — see status below)

- **Burst feature verification** on top of the base READ/WRITE-only scope.
- **`error_sequence`** — inherits from the base sequence, drives stimulus that exceeds address margins to exercise `SLVERR` response paths; paired with an `error_test` that uses factory override (`set_type_override`) to substitute the error sequence.
- **Passive + active agent split** — a passive agent monitoring only input-side (AW/W) transactions feeding a golden/reference model, and an active agent monitoring output-side (R/B) transactions, both connected to the scoreboard via separate analysis exports/`tlm_fifo`s for expected-vs-actual checking.

## Repository Structure

```
.
├── design/            # axi4_slave.sv, axi4_memory.sv (post-SV-project bugfixes)
├── tb/                 # axi4_packet, driver, monitor, sequencer, sequence library
├── env/                # agent, scoreboard, coverage, environment, test(s)
├── if/                  # AXI4 interface with modports
├── sva/                # concurrent assertions bound to the interface
├── sim/                # run.do and QuestaSim scripts
└── docs/                # code/waveform/log/coverage snippets for submission PDF
```

## Running the Simulation

Simulated in **QuestaSim**.

```tcl
do sim/run.do
```

`run.do` compiles the interface, design, UVM testbench, and assertion files in dependency order and runs the configured test(s), including functional coverage, code coverage, and assertion coverage collection.

## Status

- [x] AXI4 interface with modports
- [x] `axi4_packet` transaction with constrained randomization
- [x] Driver, monitor, sequencer, agent
- [x] Scoreboard (predicted vs. actual)
- [x] Functional coverage (covergroups/coverpoints)
- [x] SVA handshake and stability assertions
- [x] Base READ/WRITE (non-burst) test scenarios passing
- [ ] Burst feature verification (optional)
- [ ] `error_sequence` / `error_test` with factory override (optional)
- [ ] Passive/active dual-agent scoreboard split (optional)
- [ ] Final coverage closure report + waveform/log snippet capture for submission PDF

## Deliverables (per assignment spec)
- `<name>_uvm_project.rar` — all UVM/design files + `run.do`
