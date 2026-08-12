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
- **Design:** AES-128 Encryption Core + UART SoC (Iterative 1-Round Pipelined Architecture, 11 cycles = 220ns @50MHz vs SW 50,000ns = 227x faster)
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
│   │   ├── aes_sbox.v
│   │   ├── aes_inv_sbox.v
│   │   ├── sub_bytes.v
│   │   ├── shift_rows.v          # Pure wiring FREE 0 gates
│   │   ├── gf_mult2.v
│   │   ├── gf_mult3.v
│   │   ├── mix_column.v
│   │   ├── mix_columns.v
│   │   ├── add_round_key.v
│   │   ├── aes_enc_round.v
│   │   ├── key_expand.v          # Iterative 1-Round Pipelined (4 S-Boxes/round)
│   │   └── aes_core.v            # FSM iterative 11 cycles (@50MHz = 220ns)
│   ├── peripheral/
│   │   ├── uart_rx.v             # 115200 baud BAUD_DIV 434 @50MHz
│   │   └── uart_tx.v
│   └── top/
│       └── aes_soc.v             # UART protocol 0xAE / 0x55 LEDs (0x97 last byte)
├── tb/
│   ├── tb_aes_core.v
│   └── tb_aes_soc.v
├── synth/
│   ├── synth.tcl
│   ├── get_pdk.sh
│   ├── sky130.lib
│   ├── synth_report.txt
│   └── netlist/
│       └── aes_soc_synth.v
├── timing/
│   ├── constraints.sdc           # 20.0ns period; set_fix_hold commented for standalone STA
│   ├── sta.tcl
│   └── reports/
├── pnr/                          # Person B (Akif)
│   ├── config.json               # DIE 1000x1000um CLOCK 20 UTIL 45%
│   ├── src/                      # MUST match rtl/ (synced in 207b341)
│   └── runs/
├── gds/
├── reports/
├── docs/
├── virtuoso/screenshots/
├── fpga/
├── sw/pc_demo.py
├── prompts/
├── README.md
├── TEAM_SPLIT.md
├── PERSON_A_TASKS.md
├── PERSON_B_TASKS.md
└── FULL_REPO_CHECKLIST.md
```

---

## CURRENT STATUS

### Overall Phase
```
CURRENT PHASE: Person A handover COMPLETE (207b341) -> Person B Phase 5 OpenLane PNR
PHASE STATUS:  - Phase 1: Env reuse verified.
               - Phase 2: RTL 15 files, 5/5 NIST FIPS-197 / SP 800-38A.
               - Phase 3: Yosys synthesis 85a09f0. Area 185,253.92 µm², seq 8.30%.
               - Phase 4: OpenSTA + iterative 1-round pipeline. Hold +0.1208 ns MET.
                         Setup target +15 to +16 ns @ 20 ns / 50 MHz.
               - Handover 2026-08-12: pnr/src synced to pipelined rtl (old unrolled
                 key_expand removed; rewrite ~740 lines). Commit 207b341 pushed to
                 origin/feature/aes-rtl-synth-timing.
               - Working tree clean except untracked .history_sta (do NOT commit).
               - WARNING: `git diff main` shows ~-3021 lines. That is main (fat
                 skeleton 89271f6) vs this branch. NOT a wipe. Do not restore from main.
NEXT PHASE:    Phase 5: Akif runs `openlane pnr/config.json` after pull of 207b341.
```

### Person A Status (Nandikha)
```
NAME/ROLE:      Nandikha / Lead RTL, Yosys, OpenSTA
LAST COMPLETED: Phase 4 STA + OpenLane source sync
                - Commit 207b341 [AES][STA][A] Iterative 1-round pipeline + sync pnr/src
                - rtl/crypto/aes_core.v and key_expand.v rewritten (iterative)
                - pnr/src/key_expand.v rewrite 98% — matches golden RTL
                - pnr/config.json CLOCK_PERIOD 20.0, DIE 0 0 1000 1000, CORE 50 50 950 950
                - create_clock 20.00 ns; set_fix_hold commented in timing/constraints.sdc
CURRENT TASK:   Idle on tools. Support Akif if OpenLane fails for RTL/SDC reasons.
                Optional: commit this PROJECT_STATE.md update only (no git add -A).
BLOCKED ON:     Akif Phase 5 OpenLane log
DO NOT:         Re-run Yosys/STA unless PNR proves front-end broken.
                Do not paste markdown into the bash prompt.
                Do not commit .history_sta.
```

### Person B Status (Akif)
```
NAME/ROLE:      Akif / PNR, Virtuoso, FPGA
LAST COMPLETED: Phase 1 & OpenLane prep (config + src copy — src NOW updated by A)
CURRENT TASK:   Phase 5 OpenLane
                1. git fetch && git checkout feature/aes-rtl-synth-timing
                2. Confirm git log -1 is 207b341 (or later PROJECT_STATE-only commit)
                3. sudo swapon --show  (8GB swap; 16GB RAM class machine)
                4. openlane pnr/config.json   (~20–40 min)
                5. Expect: 0 DRC, LVS MATCH, antenna clean
                   -> pnr/runs/RUN_*/final/gds/aes_soc.gds
                6. Virtuoso 4 shots: full_chip, std_cells, metal_routing, power_grid
                7. FPGA + python3 sw/pc_demo.py -> 227.3x, LED 0x97
BLOCKED ON:     Nothing if 207b341 is pulled. Do NOT run OpenLane on main / old pnr/src.
```

---

## KNOWN ERRORS AND FIXES (PipeCore Reuse + AES Lessons)

| Error / Symptom | Who Hit It | Immediate Fix Applied |
| :--- | :--- | :--- |
| `fatal: A branch named 'feature/aes-rtl-synth-timing' already exists` | Nandikha | `git checkout feature/aes-rtl-synth-timing` |
| `! [rejected] feature/aes-rtl-synth-timing (fetch first)` | Nandikha | Pull with `--allow-unrelated-histories` only if needed; prefer file checkout |
| Merge markers `<<<<<<<` in Verilog/Tcl | Nandikha | Clean markers; do not synthesize marked files |
| `ERROR: No such command: yosys` in script mode | Nandikha | Remove `yosys -import` from `synth.tcl` when using `-s` |
| `stat ... -tee` syntax | Nandikha | `tee -o synth/synth_report.txt stat -liberty synth/sky130.lib` |
| OpenSTA `{` concatenation parse error | Nandikha | `write_verilog -noattr -noexpr -simple-lhs` |
| `cp: cannot stat ~/PipeCore-GDS/synth/sky130.lib` | Nandikha | `cp ~/sky130_lib/*.lib synth/sky130.lib` |
| `invalid command name set_fix_hold` in OpenSTA | Nandikha | Comment `set_fix_hold` in SDC for standalone STA; keep for OpenLane CTS |
| Setup slack `-49 ns` (68.67 ns delay) | Nandikha | Iterative 1-round key expand (4 S-Boxes), not 40-S-Box combo chain |
| `a21oi_1` 18.75 ns (fanout 128) | Nandikha | `-dont_use *lpflow* *clkinv* *probe*` + `insbuf buf_4` max load 16 |
| `pnr/src` differed from `rtl/` after STA | Nandikha | Copied rtl → pnr/src; committed 207b341. Always diff before OpenLane |
| `git diff` shows −3000 lines, looks like wipe | Nandikha | That is `diff main` vs feature branch. `git diff HEAD` was empty. Do not restore from main |
| Markdown pasted into bash (`Date:: command not found`) | Nandikha | Edit files with nano/vscode. Do not paste PROJECT_STATE body into the shell |
| OpenLane OOM on AES | New AES | 16GB RAM + 8GB swap; close Chrome |

---

## GIT RULES
```
Person A branch: feature/aes-rtl-synth-timing (Nandikha)
Person B branch: feature/aes-pnr-gds-virtuoso (Akif)
Main branch:     main (merge only when a phase is verified)

Golden RTL commit for PNR: 207b341
  [AES][STA][A] Iterative 1-round pipeline + sync pnr/src for OpenLane (hold +0.12ns MET)

Commit format:   [AES][PHASE][PERSON] description

If histories diverge: git checkout origin/<branch> -- <files>
Never: git add -A while docs/RTL look mass-deleted vs main
```

---

## INTERVIEW NUMBERS (Memorize)

| Parameter | PipeCore ALU | AES-128 SoC |
|---|---|---|
| Gate Count | 168 cells | ~8,200 gates (~8K–12K Sky130 cells) |
| Silicon Area | 1,513 µm² | **185,254 µm²** (1 mm² die) |
| Sequential | ~15% | **8.30%** (15,381 µm²) — 91.7% combo S-Box |
| ShiftRows | N/A | **0 cells** |
| Key Expand | N/A | Iterative 4 S-Boxes/round (saves ~38.72 ns) |
| High-fanout | Unbuffered | `insbuf` max load 16 (18.75 ns → ~0.3 ns) |
| Clock | 10 ns / 100 MHz | **20 ns / 50 MHz** |
| Setup slack | +6.55 ns MET | +15 to +16 ns expected @ 20 ns |
| Hold slack | −0.14 ns pre-CTS | **+0.1208 ns MET** (internal FF paths) |
| Die / Util | ~3785 µm² / 40% | **1000×1000 µm / 45%** |
| Speedup | Pipeline ALU | **227.3×** (220 ns vs 50,000 ns) |
| Verification | 25/25 | **5/5 NIST FIPS-197** |

**TV1:**
- Key: `2B7E151628AED2A6ABF7158809CF4F3C`
- Plain: `6BC1BEE22E409F96E93D7E117393172A`
- Cipher: `3AD77BB40D7A3660A89ECAF32466EF97` (LED last byte **`0x97`**)

---

## NEXT SESSION INSTRUCTIONS

### PERSON A (NANDIKHA)
```
STATUS:     Phases 2–4 + pnr/src handover DONE (207b341). Tree clean.
NEXT STEP:  Wait for Akif OpenLane log. Do not re-synth unless he fails.
            If updating this file on the laptop: nano PROJECT_STATE.md,
            add only this file, commit, push. Never paste this text into bash.
```

### PERSON B (AKIF)
```
START FROM: git pull feature/aes-rtl-synth-timing @ 207b341+
COMMAND:    openlane pnr/config.json
OUTPUT:     pnr/runs/RUN_*/final/gds/aes_soc.gds (DRC 0, LVS MATCH)
NEXT:       Virtuoso screenshots, then FPGA + pc_demo.py
```

---

## LAST UPDATED
```
Updated by: Nandikha (Person A)
Date:       2026-08-12
Summary:    Handover complete. Commit 207b341 on feature/aes-rtl-synth-timing:
            iterative aes_core/key_expand synced into pnr/src (old unrolled
            key expand removed). CLOCK_PERIOD 20.0 in pnr/config.json.
            Working tree clean except untracked .history_sta.
            Do not treat git diff vs main as a file wipe.
            Person A blocked on Akif Phase 5 OpenLane log.
```
