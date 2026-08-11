# Person A Tasks — Nandikha (RTL, Synthesis & STA)

## Overview
As **Person A**, Nandikha owns the digital front-end flow: writing the Verilog RTL for the AES-128 Crypto Accelerator SoC, verifying it against NIST FIPS-197 test vectors, synthesizing the design with Yosys, and performing static timing analysis with OpenSTA.

---

## Task Checklist

### Phase 1: Environment Setup (Reuse PipeCore)
- [x] Verify Yosys 0.67+ and OpenSTA 2.0.17 are working (`yosys -V`, `sta -version`).
- [x] Check Sky130 standard cell library (`sky130_fd_sc_hd__tt_025C_1v80.lib`) in `synth/`.

### Phase 2: Verilog RTL Design & Verification
- [x] Code 12 cryptographic modules in `rtl/crypto/` (`aes_sbox.v`, `sub_bytes.v`, `shift_rows.v`, `mix_columns.v`, `key_expand.v`, `aes_core.v`, etc.).
- [x] Code 2 peripheral UART modules in `rtl/peripheral/` (`uart_rx.v`, `uart_tx.v`) with 2-FF input synchronizer (`115200 baud @ 50MHz`, `BAUD_DIV=434`).
- [x] Code top-level SoC module `rtl/top/aes_soc.v` implementing protocol `0xAE` command → 16B key → 16B plaintext → status `0x55/0xAA` → 16B ciphertext + LED status (`0x97`).
- [x] Verify 5/5 NIST FIPS-197 / SP 800-38A test vectors via Python model (`sw/pc_demo.py`) and Verilog testbench (`tb/tb_aes_core.v`).
- [x] Confirm 227× speedup target (220 ns HW vs 50,000 ns SW).

### Phase 3: Logic Synthesis with Yosys (Current/Next Step)
- [ ] Run synthesis script: `yosys -s synth/synth.tcl`
- [ ] Inspect generated gate-level netlist: `synth/netlist/aes_soc_synth.v`
- [ ] Analyze `synth/synth_report.txt`:
  - Target cell count: `~8,000 to 12,000 standard cells` (vs. PipeCore 168 cells).
  - Target flip-flop count: `~200 to 400 FFs`.
  - Confirm S-Box LUT logic dominates ~70–80% of cell area.
  - Confirm `ShiftRows` synthesizes to **0 cells** (free wiring).
- [ ] Commit progress to `feature/aes-rtl-synth-timing`:
  ```bash
  git commit -m "[AES][SYNTH][A] Complete Yosys synthesis (~8-12K cells vs PipeCore 168)"
  ```

### Phase 4: Static Timing Analysis with OpenSTA
- [ ] Review SDC constraints in `timing/constraints.sdc` (`20.0 ns` / `50 MHz` clock, `set_fix_hold`).
- [ ] Run OpenSTA: `sta timing/sta.tcl`
- [ ] Verify timing reports:
  - Check setup slack in `timing/reports/setup_report.txt` (target positive slack, expected `+15 ns` @ `20 ns` period).
  - Check hold slack in `timing/reports/hold_report.txt` (pre-CTS negative slack `-0.14 ns` is normal and fixed by Akif during PNR CTS).
- [ ] Hand off netlist and SDC constraints to Akif (Person B) for OpenLane PNR.
