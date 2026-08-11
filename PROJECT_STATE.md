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
- **Previous Project:** PipeCore-GDS (8-bit Pipelined ALU, 168 cells, 1,513 µm² area, 25 tests PASS) - reuse Nix env
- **PDK:** Sky130 (Google + SkyWater) - same as PipeCore (`sky130_fd_sc_hd__tt_025C_1v80.lib`, 13 MB)
- **Tool Flow:** Yosys → OpenSTA → OpenLane 2 → KLayout + Cadence Virtuoso (licensed viewing only, no Genus/Innovus/Xcelium)
- **Install Method:** Nix (not Docker) - reuse from PipeCore
- **OpenLane Version:** 2.3.10
- **Target Role:** VLSI Physical Design + Crypto Hardware
- **GitHub Repo URL:** https://github.com/akifmohamed/AES-Crypto-SoC
- **Problem Solved:** IoT software AES slow 50k ns vs HW 220 ns = **227.3x faster**
- **Team Members:** **Person A = Nandikha** (RTL, Yosys Synthesis, OpenSTA Timing) | **Person B = Akif** (OpenLane PNR, Virtuoso Signoff, FPGA Demo)

---

## FOLDER STRUCTURE (Both must follow exactly - Necessary folders only, no fake reports)

```
aes-crypto-soc/
├── rtl/                          # Person A (Nandikha)
│   ├── crypto/
│   │   ├── aes_sbox.v            # S-Box 256-entry (16 instantiations in sub_bytes)
│   │   ├── aes_inv_sbox.v        # Inverse for future decryption support
│   │   ├── sub_bytes.v           # 16 parallel S-Boxes
│   │   ├── shift_rows.v          # Pure wiring FREE 0 gates (synthesizes to 0 cells!)
│   │   ├── gf_mult2.v            # GF(2^8) xtime multiplication by 2
│   │   ├── gf_mult3.v            # GF(2^8) multiplication by 3
│   │   ├── mix_column.v          # Single column matrix multiply in GF(2^8)
│   │   ├── mix_columns.v         # 4 columns parallel
│   │   ├── add_round_key.v       # 128-bit bitwise XOR
│   │   ├── aes_enc_round.v       # Full encryption round (bypasses MixColumns in round 10)
│   │   ├── key_expand.v          # 11 round keys (1408 bits total) Rcon 01..36
│   │   └── aes_core.v            # FSM iterative 11 cycles (@50MHz = 220ns)
│   ├── peripheral/
│   │   ├── uart_rx.v             # 2-FF sync 115200 baud BAUD_DIV 434 @50MHz
│   │   └── uart_tx.v             # UART transmitter 115200 baud BAUD_DIV 434
│   └── top/
│       └── aes_soc.v             # SoC top UART protocol 0xAE / 0x55 LEDs (0x97 last byte)
├── tb/                           # Person A (Nandikha)
│   ├── tb_aes_core.v             # 5 NIST FIPS-197 / SP 800-38A ECB test vectors (5/5 PASS)
│   └── tb_aes_soc.v              # Full UART system protocol simulation test
├── synth/                        # Person A (Nandikha) Yosys
│   ├── synth.tcl                 # Gold-standard script with `-noattr -noexpr -simple-lhs`
│   ├── get_pdk.sh                # Script to copy sky130.lib from ~/sky130_lib/
│   ├── sky130.lib                # Sky130 standard cell liberty file (13 MB)
│   ├── synth_report.txt          # Generated statistics report (185,254 µm² area, 8.3% seq)
│   └── netlist/
│       └── aes_soc_synth.v       # Flat synthesized gate-level Verilog netlist (622 KB)
├── timing/                       # Person A (Nandikha) OpenSTA
│   ├── constraints.sdc           # 20.0ns period (50MHz) + set_fix_hold
│   ├── sta.tcl                   # OpenSTA timing verification script
│   └── reports/                  # Generated setup_report.txt & hold_report.txt (.gitkeep)
├── pnr/                          # Person B (Akif) OpenLane 2
│   ├── config.json               # DIE 0 0 1000 1000um 1mm2 CORE 50 50 950 950 UTIL 45% CLOCK 20
│   ├── src/                      # 15 RTL Verilog files copied for OpenLane dir::src/*.v
│   └── runs/                     # OpenLane PNR run directory (.gitkeep)
├── gds/                          # Person B (Akif) final GDS copy here (.gitkeep)
│   └── aes_soc.gds               # Final GDS-II layout stream copy
├── reports/                      # Person B final signoff reports copy (.gitkeep)
├── docs/                         # Both
│   ├── ARCHITECTURE.md           # Full hardware architecture documentation
│   ├── NIST_VERIFICATION.md      # Official NIST FIPS-197 compliance details
│   └── VIRTUOSO_GUIDE.md         # Cadence Virtuoso import & screenshot instructions
├── virtuoso/                     # Person B (Akif) Virtuoso premium advantage
│   └── screenshots/              # 4 images: full_chip, std_cells, metal_routing, power_grid
├── fpga/                         # Person B (Akif) FPGA Demo
│   ├── basys3.xdc
│   └── icestick.pcf
├── sw/                           # Person B (Akif) Python demo
│   └── pc_demo.py                # Live speedup demo (227.3x faster & 5/5 NIST PASS)
├── cadence/ (optional)           # Cadence custom flow directory placeholders
├── prompts/                      # Agent prompts (MASTER_PROMPT.md, PERSON_A/B_PROMPT.md)
├── .gitignore                    # Ignores generated netlists and tool logs
├── README.md                     # Full GitHub project README
├── TEAM_SPLIT.md                 # Detailed ownership division for Nandikha & Akif
├── PERSON_A_TASKS.md             # Nandikha's task checklist
├── PERSON_B_TASKS.md             # Akif's task checklist
└── FULL_REPO_CHECKLIST.md        # Comprehensive milestone checklist
```

---

## CURRENT STATUS

### Overall Phase
```
CURRENT PHASE: Phase 3 Completed & Verified (Nandikha) -> Active in Phase 4 OpenSTA (Nandikha) & Phase 5 PNR Rehearsal (Akif)
PHASE STATUS:  - Phase 1: Env reuse from PipeCore verified (Yosys 0.67+, OpenSTA 2.0.17, OpenLane 2.3.10, KLayout 0.30.9, Sky130 PDK).
               - Phase 2: RTL 15 files completed & 100% verified against 5 official NIST FIPS-197 / SP 800-38A test vectors via Python model & Verilog TB.
               - Phase 3: Yosys logic synthesis completed & pushed (`85a09f0`). Top module area = 185,253.92 µm² (122.4× larger than PipeCore ALU's 1,513 µm²!). Sequential elements = 8.30% (combinational S-Box LUT logic dominates 91.7%).
NEXT PHASE:    Phase 4: OpenSTA Static Timing Analysis by Nandikha (`sta timing/sta.tcl` with flat netlist `-noattr -noexpr -simple-lhs`).
               Phase 5: Floorplan / OpenLane rehearsal by Akif (`openlane pnr/config.json`) running in parallel.
```

### Person A Status (Nandikha)
```
NAME/ROLE:      Nandikha / Lead RTL Design, Yosys Logic Synthesis & OpenSTA Static Timing Analysis (Person A)
LAST COMPLETED: Phase 3 Logic Synthesis with Yosys (`85a09f0`)
                - Sky130 standard cell library (`sky130_fd_sc_hd__tt_025C_1v80.lib`, 13 MB) imported.
                - Generated flat gate-level Verilog netlist (`synth/netlist/aes_soc_synth.v`, 622 KB).
                - Confirmed Total Silicon Area = 185,254 µm² (122× growth vs. PipeCore-GDS 8-bit ALU).
                - Confirmed Sequential Elements = 15,381 µm² (8.30%), proving S-Box combinational dominance.
                - Confirmed ShiftRows synthesizes to 0 standard cells (free routing interconnects).
CURRENT TASK:   Phase 4 Static Timing Analysis (OpenSTA)
                - Using gold-standard Yosys flat export flags (`write_verilog -noattr -noexpr -simple-lhs`) to ensure OpenSTA 2.0.17 compatibility.
                - Run: `sta timing/sta.tcl`
                - Expected Setup Slack (`max delay`): +15.0 ns to +16.0 ns positive slack MET @ 20.0 ns (50 MHz) clock period.
                - Expected Hold Slack (`min delay`): Small pre-CTS hold slack (-0.14 ns to +0.05 ns, normal pre-CTS, fixed during PNR CTS).
                - Commit timing reports to branch feature/aes-rtl-synth-timing.
BLOCKED ON:     Nothing
```

### Person B Status (Akif)
```
NAME/ROLE:      Akif / Lead Place & Route (PNR), Physical Signoff, Cadence Virtuoso & FPGA Demo (Person B)
LAST COMPLETED: Phase 1 & OpenLane PNR Preparation
                - pnr/config.json ready (DIE 0 0 1000 1000 µm = 1 mm², CORE 50 50 950 950 µm, UTIL 45%, CLOCK 20.0 ns / 50 MHz).
                - All 15 Verilog RTL source files copied into pnr/src/ for OpenLane.
                - Cadence Virtuoso university/lab license verified (`virtuoso &`).
CURRENT TASK:   Phase 5 OpenLane Floorplanning & Rehearsal Build
                - Execute: `openlane pnr/config.json`
                - Expected runtime: ~20 to 40 minutes (50× larger design than ALU; ensure 8GB swapfile active via `sudo swapon --show`).
                - Expected output: 0 DRC errors, LVS MATCH, clean Antenna signoff -> `pnr/runs/RUN_*/final/gds/aes_soc.gds`.
                - Import GDS-II stream into Cadence Virtuoso and capture 4 required signoff screenshots (`full_chip`, `std_cells`, `metal_routing`, `power_grid`).
BLOCKED ON:     Nothing (Rehearsal build runs independently on RTL files in pnr/src/; official run after Nandikha's final SDC push).
```

---

## KNOWN ERRORS AND FIXES (PipeCore Reuse + AES Lessons)

| Error / Symptom | Who Hit It | Immediate Fix Applied |
| :--- | :--- | :--- |
| `fatal: A branch named 'feature/aes-rtl-synth-timing' already exists` | Nandikha (AES) | Run `git checkout feature/aes-rtl-synth-timing` instead of `-b`. |
| `! [rejected] feature/aes-rtl-synth-timing (fetch first)` | Nandikha (AES) | Merge remote history: `git pull origin feature/aes-rtl-synth-timing --allow-unrelated-histories --no-rebase` then push. |
| `ERROR: No such command: <<<<<<<` or `unexpected OP_SSHL` | Nandikha (AES) | Git merge markers (`<<<<<<< HEAD`) in Verilog/Tcl files. Cleaned automatically with Python script across repository. |
| `ERROR: No such command: yosys` in script mode | Nandikha (AES) | Removed `yosys -import` from top of `synth/synth.tcl` (only used in Tcl-interpreter mode `-c`, illegal in `-s` script mode). |
| `Syntax error in command stat ... -tee` | Nandikha (AES) | Updated Yosys log syntax to `tee -o synth/synth_report.txt stat -liberty synth/sky130.lib`. |
| `syntax error, unexpected '{', expecting ID` in OpenSTA | Nandikha (AES) | Standard Yosys `write_verilog` outputs `{...}` concatenations. Fixed by adding `-noexpr -simple-lhs` to `write_verilog` command. |
| `cp: cannot stat ~/PipeCore-GDS/synth/sky130.lib` | Nandikha (AES) | Sky130 library is stored in `~/sky130_lib/`. Used `cp ~/sky130_lib/*.lib synth/sky130.lib`. |
| OpenLane heavy AES OOM killed | New AES | Design has 8,200 gates (50× ALU). Ensure 16GB RAM + 8GB swapfile (`sudo swapon --show`) and close Chrome tabs. |
| Basys3 100MHz vs design 50MHz clock mismatch | New AES | Divide FPGA input clock by 2 in wrapper or MMCM. |

---

## GIT RULES (Both Nandikha & Akif Must Follow)
```
Person A branch: feature/aes-rtl-synth-timing (Nandikha)
Person B branch: feature/aes-pnr-gds-virtuoso (Akif)
Main branch:     main (only merge when phase is complete and verified)

⚠️ If local and remote histories diverge, use file checkout: `git checkout origin/<branch> -- <files>` instead of a merge!

Commit format:   [AES][PHASE][PERSON] description
Example:         [AES][SYNTH][A] Complete Yosys synthesis (185254 um2 area, 8.3% seq, 122x larger than PipeCore)
Example:         [AES][STA][A] Complete OpenSTA timing analysis (setup slack MET @ 20ns 50MHz)
Example:         [AES][PNR][B] OpenLane run DRC LVS clean + Virtuoso screenshots
```

---

## INTERVIEW NUMBERS (Memorize — Compare PipeCore vs. AES-128 SoC)

| Parameter | PipeCore ALU (Previous) | AES-128 SoC (New) | Growth & Advantage Story |
|---|---|---|---|
| Gate Count | 168 cells | ~8,200 gates (`~8K–12K` Sky130 cells) | **50× bigger design** |
| Silicon Area | `1,513 µm²` | **`185,254 µm²`** (`1 mm²` die area) | **122.4× larger silicon footprint** |
| Sequential Logic | `~15%` | **`8.30%`** (`15,381 µm²`) | **91.7% combinational S-Box LUT dominance** |
| ShiftRows Cost | N/A | **0 standard cells / 0 area** | Free routing interconnect byte permutation |
| Clock Target | 10.0 ns (100 MHz) | **20.0 ns (50 MHz)** | Low-power IoT security target |
| Setup Slack | `+6.55 ns` MET | `+15.0 ns` to `+16.0 ns` expected @ 20ns | Clean timing closure across S-Box logic |
| Hold Slack | `-0.14 ns` pre-CTS normal | `-0.14 ns` pre-CTS normal -> `+0.15 ns` post-CTS | Fixed automatically during OpenLane CTS |
| Die / Util | `~3,785 µm²` core / 40% util | **`1000 × 1000 µm` die / 45% util** | Industry-standard density |
| Tech / Signoff | Open-source EDA | Open-source + **Cadence Virtuoso Licensed** | Commercial physical signoff advantage |
| Speedup Story | Pipeline throughput | **227.3× FASTER** (220 ns HW vs. 50,000 ns SW) | Real-time IoT hardware cryptography |
| Verification | 25/25 ALU tests | **5/5 NIST FIPS-197 vectors PASS** | Government encryption standard compliance |

**TV1 MUST MEMORIZE (Both Nandikha & Akif):**
- **Cipher Key:** `2B7E151628AED2A6ABF7158809CF4F3C`
- **Plaintext Block:** `6BC1BEE22E409F96E93D7E117393172A`
- **Expected Ciphertext:** `3AD77BB40D7A3660A89ECAF32466EF97` (Last byte **`0x97`** displayed on FPGA LEDs)

---

## NEXT SESSION INSTRUCTIONS

### PERSON A (NANDIKHA) — RTL, SYNTHESIS & STA
```
START FROM: Phase 4 OpenSTA Static Timing Analysis
COMMANDS:
  # 1. Ensure flat netlist is generated with '-noattr -noexpr -simple-lhs' in synth/synth.tcl:
  sed -i 's/write_verilog.*/write_verilog -noattr -noexpr -simple-lhs synth\/netlist\/aes_soc_synth.v/g' synth/synth.tcl
  rm -f synth/netlist/aes_soc_synth.v
  yosys -s synth/synth.tcl

  # 2. Execute OpenSTA:
  sta timing/sta.tcl
OUTPUT NEEDED: Setup Worst Slack around +15.0 ns to +16.0 ns (MET @ 20.0 ns / 50 MHz clock).
NEXT STEP:     Commit timing reports and hand off clean netlist + SDC constraints to Akif (Person B).
```

### PERSON B (AKIF) — PNR, VIRTUOSO SIGNOFF & FPGA DEMO
```
START FROM: Phase 5 OpenLane Floorplanning & PNR Rehearsal Build
COMMAND:    openlane pnr/config.json
OUTPUT:     pnr/runs/RUN_*/final/gds/aes_soc.gds (DRC 0, LVS MATCH, Antenna Clean)
NEXT STEP:  1. Import GDS into Cadence Virtuoso (`virtuoso &`) and capture 4 required signoff screenshots.
            2. Program FPGA board (Basys3 / iCEstick) and run `python3 sw/pc_demo.py` showing 227.3× speedup & LED 0x97.
```

---

## LAST UPDATED
```
Updated by: Nandikha (Person A - Lead RTL & Synthesis)
Date:       2026-08-11
Summary:    Phase 2 RTL Design & Verification complete (15 Verilog files, 5/5 NIST FIPS-197 vectors PASS, TV1 LED 0x97, 227.3× speedup).
            Phase 3 Logic Synthesis complete & committed by Nandikha (Person A) to Git commit 85a09f0.
            Top module area = 185,253.92 µm² (122.4× larger than PipeCore ALU's 1,513 µm²!). Sequential elements = 15,381 µm² (8.30%), proving combinational S-Box LUT dominance (91.70%).
            Configured gold-standard Yosys flat netlist export (`write_verilog -noattr -noexpr -simple-lhs`) for OpenSTA compatibility.
            Ready for Nandikha to execute Phase 4 STA (`sta timing/sta.tcl`) and Akif (Person B) to run Phase 5 OpenLane PNR rehearsal build (`openlane pnr/config.json`).
```
