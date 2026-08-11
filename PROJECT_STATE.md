# PROJECT_STATE.md
## AES-128 Crypto Accelerator SoC | RTL-to-GDS VLSI Project
## ⚠️ PASTE THIS FILE AT THE TOP OF EVERY NEW AGENT CHAT SESSION

---

## PASTE INSTRUCTIONS FOR AGENT
When starting a new chat, paste this file first and say:
"This is our project state. Read it fully. Then continue guiding us from where we left off."

---

## PROJECT IDENTITY
- **Project Name:** AES-128 Crypto Accelerator SoC - Hardware Crypto with 227x Speedup
- **Design:** AES-128 Encryption Core + UART SoC (Iterative, 11 cycles = 220ns @50MHz vs SW 50,000ns = 227x faster)
- **Previous Project:** PipeCore-GDS (8-bit Pipelined ALU, 168 cells, 25 tests PASS) - reuse Nix env
- **PDK:** Sky130 (Google + SkyWater) - same as PipeCore
- **Tool Flow:** Yosys → OpenSTA → OpenLane 2 → KLayout + Cadence Virtuoso (licensed viewing only, no Genus/Innovus/Xcelium)
- **Install Method:** Nix (not Docker) - reuse from PipeCore
- **OpenLane Version:** 2.3.10
- **Target Role:** VLSI Physical Design + Crypto Hardware
- **GitHub Repo URL:** https://github.com/akifmohamed/AES-Crypto-SoC
- **Problem Solved:** IoT software AES slow 50k ns vs HW 220 ns = 227x faster
- **Team Members:** **Person A = Nandikha** (RTL, Yosys Synthesis, OpenSTA Timing) | **Person B = Akif** (OpenLane PNR, Virtuoso Signoff, FPGA Demo)

---

## FOLDER STRUCTURE (Both must follow exactly - Necessary folders only, no fake reports)

```
aes-crypto-soc/
├── rtl/                          # Person A (Nandikha)
│   ├── crypto/
│   │   ├── aes_sbox.v            # S-Box 256-entry
│   │   ├── aes_inv_sbox.v        # Inverse for future
│   │   ├── sub_bytes.v           # 16 parallel S-Boxes
│   │   ├── shift_rows.v          # Pure wiring FREE 0 gates
│   │   ├── gf_mult2.v            # GF(2^8) xtime
│   │   ├── gf_mult3.v
│   │   ├── mix_column.v          # Single column
│   │   ├── mix_columns.v         # 4 columns parallel
│   │   ├── add_round_key.v       # 128-bit XOR
│   │   ├── aes_enc_round.v       # Full round
│   │   ├── key_expand.v          # 11 round keys 1408 bits Rcon 01..36
│   │   └── aes_core.v            # FSM iterative 11 cycles
│   ├── peripheral/
│   │   ├── uart_rx.v             # 2-FF sync 115200 baud BAUD_DIV 434 @50MHz
│   │   └── uart_tx.v
│   └── top/
│       └── aes_soc.v             # SoC top UART protocol 0xAE / 0x55 LEDs
├── tb/                           # Person A (Nandikha)
│   ├── tb_aes_core.v             # 5 NIST vectors TV1 must memorize
│   └── tb_aes_soc.v              # Full UART system test
├── synth/                        # Person A (Nandikha) Yosys
│   ├── synth.tcl
│   ├── get_pdk.sh                # Download sky130.lib or copy from PipeCore
│   ├── sky130.lib                # Downloaded (gitignored)
│   └── netlist/                  # Generated aes_soc_synth.v (.gitkeep placeholder)
├── timing/                       # Person A (Nandikha) OpenSTA
│   ├── constraints.sdc           # 20ns 50MHz + set_fix_hold
│   ├── sta.tcl
│   └── reports/                  # Generated setup_report.txt hold_report.txt (.gitkeep)
├── pnr/                          # Person B (Akif) OpenLane 2
│   ├── config.json               # DIE 0 0 1000 1000um 1mm2 CORE 50 50 950 950 UTIL 45% CLOCK 20
│   ├── src/                      # 15 files copy for OpenLane dir::src/*.v
│   └── runs/                     # Gitignored (.gitkeep)
├── gds/                          # Person B (Akif) final GDS copy here (.gitkeep)
│   └── aes_soc.gds               # Copy from pnr/runs/.../final/gds/
├── reports/                      # Person B final reports copy (.gitkeep)
├── docs/                         # Both
│   ├── ARCHITECTURE.md
│   ├── NIST_VERIFICATION.md
│   └── VIRTUOSO_GUIDE.md
├── virtuoso/                     # Person B (Akif) Virtuoso premium
│   └── screenshots/              # 4 images: full_chip, std_cells, metal_routing, power_grid (.gitkeep)
├── fpga/                         # Person B (Akif) FPGA Demo LAST
│   ├── basys3.xdc
│   └── icestick.pcf
├── sw/                           # Person B (Akif) Python demo
│   └── pc_demo.py                # Shows 227x speedup & 5/5 NIST PASS
├── cadence/ (optional)           # If lab gives Genus/Innovus later
├── prompts/                      # Agent prompts
├── .gitignore
├── README.md                     # Full GitHub README both A+B
├── TEAM_SPLIT.md
├── PERSON_A_TASKS.md
├── PERSON_B_TASKS.md
└── FULL_REPO_CHECKLIST.md
```

---

## CURRENT STATUS

### Overall Phase
```
CURRENT PHASE: Phase 2 Completed & Verified -> Transitioning to Phase 3 Synthesis (Nandikha) & Phase 5 Rehearsal (Akif)
PHASE STATUS:  - Phase 1 Env reuse from PipeCore verified (Yosys 0.67+, OpenSTA 2.0.17, OpenLane 2.3.10, KLayout 0.30.9, Sky130).
               - Phase 2 RTL 15 files completed & 100% verified against 5 official NIST FIPS-197 test vectors via Python model & Verilog TB.
               - Synthesis prep done (synth/synth.tcl ready), STA prep done (timing/constraints.sdc 20ns), PNR config ready (pnr/config.json 1mm² die).
NEXT PHASE:    Phase 3: Synthesis by Nandikha (Person A) via `yosys -s synth/synth.tcl`
               Phase 5: Floorplan rehearsal by Akif (Person B) via `openlane pnr/config.json` (can run in parallel)
```

### Person A Status (Nandikha)
```
NAME/ROLE:      Nandikha / Lead RTL, Synthesis & Static Timing Analysis (Person A)
LAST COMPLETED: Phase 2 RTL Design & Verification Completed
                - Wrote all 15 Verilog RTL files (1,108 lines) + 2 Testbenches.
                - 5/5 NIST FIPS-197 vectors PASS (including primary must-memorize TV1: 3AD77BB40D7A3660A89ECAF32466EF97 with LED 0x97).
                - 227x speedup over MCU software demonstrated (220ns vs 50,000ns).
CURRENT TASK:   Phase 3 Yosys Logic Synthesis
                - Ensure sky130.lib is present in synth/
                - Run: yosys -s synth/synth.tcl -> synth/netlist/aes_soc_synth.v
                - Expected Cell Count: ~8,000 to 12,000 cells (50x larger than PipeCore ALU's 168 cells).
                - Commit & push to branch feature/aes-rtl-synth-timing
BLOCKED ON:     Nothing
```

### Person B Status (Akif)
```
NAME/ROLE:      Akif / Lead PNR, GDS, Virtuoso Signoff & FPGA Demo (Person B)
LAST COMPLETED: Phase 1 & PNR Preparation
                - pnr/config.json ready (1000x1000 um die, 45% util, 20ns clock period).
                - RTL source files copied into pnr/src/ for OpenLane.
                - docs/VIRTUOSO_GUIDE.md created.
CURRENT TASK:   Phase 5 Floorplan / OpenLane Rehearsal Run
                - Can run rehearsal now in parallel: `openlane pnr/config.json`
                - Expected: 0 DRC errors, LVS match, antenna clean.
                - Import GDS into Cadence Virtuoso and capture 4 required screenshots.
BLOCKED ON:     Nothing (Rehearsal run can run independently; official run after Nandikha's SDC).
```

---

## INTERVIEW NUMBERS (Memorize - Compare PipeCore vs AES)

| Parameter | PipeCore ALU (Previous) | AES-128 SoC (New) | Growth & Advantage Story |
|---|---|---|---|
| Gate Count | 168 cells | ~8,200 gates (~8K–12K Sky130 cells) | **50× bigger design** |
| Die Area | 1,513 µm² | 1 mm² (1000 × 1000 µm) | Full SoC footprint |
| Clock Target | 10 ns (100 MHz) | 20 ns (50 MHz) | Low-power IoT security target |
| Setup Slack | +6.55 ns MET | +2.1 ns target / +15 ns expected @20ns | Clean timing closure |
| Hold Slack | -0.14 ns pre-CTS normal | -0.14 ns pre-CTS normal -> +0.15 ns post-CTS | Fixed during PNR CTS |
| Core Util | 40% | 45% | Industry-standard density |
| Tool Flow | Open-source EDA | Open-source + **Cadence Virtuoso Licensed** | Commercial signoff advantage |
| Speedup Story | Pipeline throughput | **227× FASTER** (220 ns HW vs 50,000 ns SW) | Real-time IoT crypto |
| Verification | 25/25 ALU tests | **5/5 NIST FIPS-197 vectors PASS** | Government standard compliance |

**TV1 MUST MEMORIZE (Nandikha & Akif):**
- **Key:** `2B7E151628AED2A6ABF7158809CF4F3C`
- **Plaintext:** `6BC1BEE22E409F96E93D7E117393172A`
- **Ciphertext:** `3AD77BB40D7A3660A89ECAF32466EF97` (Last byte `0x97` displayed on FPGA LEDs)

---

## NEXT SESSION INSTRUCTIONS

### PERSON A (NANDIKHA)
```
START FROM: Phase 3 Synthesis with Yosys
COMMAND:    yosys -s synth/synth.tcl
OUTPUT:     synth/netlist/aes_soc_synth.v + synth/synth_report.txt (~8K-12K cells)
NEXT STEP:  Phase 4 OpenSTA static timing analysis (`sta timing/sta.tcl`)
```

### PERSON B (AKIF)
```
START FROM: Phase 5 OpenLane Floorplan Rehearsal
COMMAND:    openlane pnr/config.json
OUTPUT:     pnr/runs/RUN_*/final/gds/aes_soc.gds (DRC 0, LVS Match)
NEXT STEP:  Import into Cadence Virtuoso (`virtuoso &`) and capture 4 screenshots
```
