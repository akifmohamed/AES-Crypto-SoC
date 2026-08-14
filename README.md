# AES-128 Crypto Accelerator SoC

**Full RTL → GDSII on Sky130 · Timing-closed · DRC-clean / LVS-match · NIST FIPS-197 verified · 227× faster than software**

![flow](https://img.shields.io/badge/Flow-RTL--to--GDSII-blue) ![pdk](https://img.shields.io/badge/PDK-Sky130--130nm-lightgrey) ![timing](https://img.shields.io/badge/Timing-%2B14.07ns%20setup%20%2F%20%2B0.29ns%20hold-brightgreen) ![signoff](https://img.shields.io/badge/Signoff-DRC%20clean%20%E2%80%A2%20LVS%20match-brightgreen) ![nist](https://img.shields.io/badge/NIST%20FIPS--197-5%2F5%20vectors-green) ![speedup](https://img.shields.io/badge/Speedup-227.3%C3%97%20vs%20SW-red)

An AES-128 encryption accelerator SoC written in Verilog from scratch, verified against official NIST test vectors, and implemented through a complete RTL-to-GDSII flow on the Sky130 130 nm open PDK. The iterative engine encrypts one 128-bit block in **11 cycles @ 50 MHz (220 ns)** versus ~50,000 ns for software AES on a typical MCU — a **227.3× speedup** for real-time IoT security.

---

## Measured Results

| Metric | Result |
|---|---|
| Technology | Sky130 (`sky130_fd_sc_hd`), 130 nm |
| Die / core | 1000 × 1000 µm (1 mm²) / 900 × 900 µm, 45% utilization target |
| Synthesis (Yosys) | **25,902 cells · 185,254 µm² · 8.3% sequential** |
| Clock | 20 ns / 50 MHz |
| Setup worst slack | **+14.07 ns** (nom_tt) |
| Hold worst slack | **+0.29 ns** (nom_tt) |
| DRC / LVS | **Clean / Match** |
| Antenna | 5 violations → automatic diode repair → 1 documented residual (met3, ratio 567 vs 400 limit) |
| Routing | ~1.8 m total wire, ~374 k vias |
| Latency / throughput | 11 cycles = 220 ns per block |
| Speedup vs MCU software | **227.3×** (50,000 ns vs 220 ns) |
| Functional verification | **5/5 NIST FIPS-197 vectors** (TV1: key `2B7E…4F3C`, plain `6BC1…172A` → cipher `3AD7…EF97`) |
| Deliverable | `gds/aes_soc.gds` (versioned with Git LFS) |

---

## Architecture

```
        ┌────────────────────────────────────────────┐
  UART  │  aes_soc (top)                             │
 rx ───►│  uart_rx ──► CTRL FSM ──► aes_core         │
        │   (2-FF sync)   │     ┌──────────────────┐ │
 tx ◄───│  uart_tx ◄──────┘     │ add_round_key    │ │
        │                     │ sub_bytes (16×SBox)│ │
 LED ───│                     │ shift_rows (wiring)│ │
        │   key_expand ──────►│ mix_columns GF(2^8)│ │
        │   (11 round keys)   └──────────────────┘ │
        └────────────────────────────────────────────┘
```

- **Iterative 1-round datapath:** one round unit reused for 10 rounds + initial AddRoundKey = 11 cycles. Chosen over a pipelined alternative (~10× the area and power) to fit low-power IoT targets.
- **SubBytes:** 16 parallel 256-entry S-Box LUTs. **ShiftRows:** pure wiring — synthesizes to **0 cells**. **MixColumns:** GF(2⁸) matrix multiply with shared xtime logic. **Key expansion:** on-the-fly generation of 11 round keys (1408 bits, Rcon 01…36).
- **SoC shell:** UART 115,200 baud @ 50 MHz (BAUD_DIV 434) with 2-FF input synchronizer; command protocol `0xAE` + key + plaintext → ciphertext, `0x55` → `0xAA` status; ciphertext MSB drives LEDs (TV1 → `0x97`).

## Layout

| Full chip (KLayout) | Metal routing | Antenna-repair diodes | Virtuoso (licensed) |
|---|---|---|---|
| ![](docs/layout_views/klayout_full_chip.png) | ![](docs/layout_views/klayout_metal_routing.png) | ![](docs/layout_views/klayout_antenna_diodes.png) | ![](virtuoso/screenshots/full_chip.png) |

Additional views: [`docs/layout_views/`](docs/layout_views) (KLayout, PDK-colored) and [`virtuoso/screenshots/`](virtuoso/screenshots) (Cadence Virtuoso 6.1.5 import via XStream with a custom Sky130 GDS layer map).

## Repository Structure

```
├── rtl/            Verilog RTL: crypto core (12 files), UART peripherals, SoC top
├── tb/             Testbenches: NIST vectors + SoC UART protocol
├── synth/          Yosys synthesis script + report (25,902 cells / 185,254 µm²)
├── timing/         OpenSTA scripts + SDC (20 ns clock, I/O delays, false paths)
├── pnr/            OpenLane 2 config (1 mm² die, 45% util) + RTL source set
├── gds/            Final GDS-II (aes_soc.gds, Git LFS)
├── docs/           Architecture, NIST verification, Virtuoso guide, flow doc,
│                   one-page summary PDF, KLayout views, demo log
├── virtuoso/       Licensed-Cadence signoff screenshots
├── fpga/           Basys3 (.xdc) and iCEstick (.pcf) constraint files
├── sw/             pc_demo.py — SW-vs-HW speedup + NIST check (UART when board attached)
└── run_sim.sh      RTL simulation entry point
```

## Tool Flow

| Stage | Tool | Notes |
|---|---|---|
| Simulation | Icarus Verilog | 5/5 NIST FIPS-197 vectors |
| Synthesis | Yosys | `synth/synth.tcl`, sky130_fd_sc_hd |
| STA | OpenSTA | `timing/sta.tcl` + `constraints.sdc` |
| Place & Route | OpenLane 2.3.10 | floorplan → placement → CTS → routing → GDS |
| DRC / LVS | Magic / KLayout / Netgen | clean / match |
| Signoff viewing | Cadence Virtuoso 6.1.5 | XStream import + custom layer map |
| Demo | Python / Vivado / IceStorm | `sw/pc_demo.py`, board-ready constraints |

## Reproducing the Flow

```bash
bash run_sim.sh                      # RTL simulation vs NIST vectors
yosys -s synth/synth.tcl             # synthesis -> netlist + report
sta timing/sta.tcl                   # static timing analysis
openlane pnr/config.json             # full PNR -> GDS (≈30 min)
klayout gds/aes_soc.gds              # layout viewing
python3 sw/pc_demo.py                # 227.3x speedup demo (+ UART when FPGA attached)
```

## Engineering Notes (selected debugging highlights)

- **Structural timing discovery:** post-CTS STA showed −38 ns worst slack on ~900 endpoints; 3,300 resizer iterations improved it only to −32 ns — proving the path was architectural, not tunable. The path report drove an RTL re-architecture (iterative 1-round pipeline) that closed timing at **+14.07 ns** on the next spin.
- **SDC portability:** removed a Synopsys-only `set_fix_hold` command that crashed OpenSTA; hold is repaired inside PNR (`repair_timing`).
- **Antenna signoff:** enabled `RUN_ANTENNA_REPAIR`; diode insertion reduced 5 violations to 1 residual (visible as `DIODE` cells in the layout view above).
- **Flow resilience:** per-step state saving allowed resuming the PNR flow after a mid-run power cut (`--run-tag … --from <step>`).
- **Large-binary hygiene:** 64 MB GDS versioned through Git LFS after a plain-push HTTP 408 on a slow uplink.

## Team

| | |
|---|---|
| **Akif Mohamed** | Physical design: floorplan, placement, CTS, routing, signoff, Virtuoso review, FPGA demo |
| **Nandikha** | RTL design, Yosys synthesis, OpenSTA timing analysis |

## Previous Work

PipeCore-GDS — 8-bit pipelined ALU, 168 cells / 1,513 µm², RTL-to-GDS on Sky130. This project scales that experience ~50× in complexity with crypto-domain verification and licensed-tool signoff.

---

*Educational tapeout-style project. GDSII provided for portfolio/review purposes.*
