# AES-128 Crypto Accelerator SoC | RTL-to-GDSII VLSI Project

**AES-128 Hardware Crypto Accelerator System-on-Chip (SoC)** designed from Verilog RTL to GDSII layout using Google SkyWater **Sky130 130nm** PDK and open-source EDA tools (Yosys, OpenSTA, OpenLane 2, KLayout) plus **Cadence Virtuoso** for physical signoff and layout viewing.

---

## 🚀 Key Highlights & 227x Speedup Pitch
- **227x Speedup over MCU Software:** Slow software AES on MCU = ~50,000 ns per block vs. Hardware AES-128 SoC = 11 cycles @ 50 MHz = **220 ns per block** (**227.3x faster**).
- **50x Gate Growth vs. Previous Project:** Scaled from an 8-bit Pipelined ALU (**168 cells**, **1,513 µm²**) to an iterative AES-128 SoC (**~8,200 gates**, **1 mm² die**, **45% utilization**).
- **Official NIST FIPS-197 Compliance:** Hardware core verified against 5 official NIST test vectors (including TV1: Key `2B7E...`, Plaintext `6BC1...`, Ciphertext `3AD7...`).
- **SoC Integration:** UART RX/TX peripheral (115,200 baud @ 50 MHz clock, BAUD_DIV=434) with 2-FF input synchronizer, FSM protocol (`0xAE` command byte), and status LEDs.
- **Licensed Cadence Virtuoso Signoff:** Layout imported into Virtuoso for measurements and signoff screenshots (Full Chip, Standard Cells, Metal Routing, Power Grid).

---

## 🛠️ Toolchain & Environment (Reuse from PipeCore-GDS)
| Stage | Tool | Version / PDK |
| :--- | :--- | :--- |
| **Synthesis** | Yosys | OSS CAD Suite 0.67+ / Sky130 (`sky130_fd_sc_hd`) |
| **Static Timing Analysis** | OpenSTA | 2.0.17 |
| **Place & Route (PNR)** | OpenLane 2 | 2.3.10 |
| **Layout Viewing & DRC** | KLayout | 0.30.9 |
| **Physical Signoff & Import** | Cadence Virtuoso | Licensed Industry Advantage |
| **FPGA Demo & Verification** | Vivado / IceStorm / Python | Basys3 / iCEstick / `sw/pc_demo.py` |

---

## 👥 Team Split (Parallel Workflow)
- **Person A (Akif - Lead RTL & Synthesis):** Verilog coding (15 files), Yosys logic synthesis, OpenSTA static timing analysis (`20ns` / `50MHz` clock target).
- **Person B (Teammate - Lead PNR & Signoff):** OpenLane 2 floorplan, placement, CTS, routing, GDS export, Cadence Virtuoso viewing/screenshots, FPGA UART demo.
- **Both Together:** NIST FIPS-197 verification, project documentation, interview Q&A prep.

---

## 📁 Repository Structure
```
aes-crypto-soc/
├── rtl/                # Verilog RTL (Person A - 15 files)
│   ├── crypto/         # aes_sbox.v, sub_bytes.v, shift_rows.v, mix_columns.v, aes_core.v, key_expand.v
│   ├── peripheral/     # uart_rx.v (2-FF sync), uart_tx.v
│   └── top/            # aes_soc.v (SoC Top FSM + LEDs)
├── tb/                 # Verilog Testbenches (tb_aes_core.v, tb_aes_soc.v)
├── synth/              # Yosys synthesis script (synth.tcl) and netlist/
├── timing/             # OpenSTA constraints (constraints.sdc 20ns) and sta.tcl
├── pnr/                # OpenLane 2 config.json (1000x1000 um die, 45% util) & src/
├── gds/                # Final exported GDS-II layout (aes_soc.gds)
├── virtuoso/           # Cadence Virtuoso signoff screenshots
├── fpga/               # FPGA constraints (Basys3 .xdc / iCEstick .pcf)
└── sw/                 # Python demo script (pc_demo.py - 227x speedup & NIST check)
```
