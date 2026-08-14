<<<<<<< HEAD
# Team Split & Responsibilities — AES-128 Crypto Accelerator SoC

Our team consists of two members working in parallel across the RTL-to-GDSII VLSI Physical Design flow. This division ensures clear accountability and allows concurrent development (e.g., Nandikha running synthesis & STA while Akif runs OpenLane PNR rehearsal).

---

## 👥 Member Roles & Ownership

### Person A: Nandikha — Lead RTL Design, Logic Synthesis & Static Timing Analysis
- **Primary Domain:** Front-end digital design, RTL coding, gate-level netlist generation, and timing closure.
- **Assigned Phases:**
  - **Phase 2:** Verilog RTL design (all 15 modules in `rtl/crypto/`, `rtl/peripheral/`, `rtl/top/`) and verification against NIST FIPS-197 test vectors.
  - **Phase 3:** Logic synthesis using **Yosys** (`yosys -s synth/synth.tcl`), mapping to Google SkyWater Sky130 standard cells (`sky130_fd_sc_hd`), and analyzing area/gate count growth (~8,200 gates vs. PipeCore 168 cells).
  - **Phase 4:** Static Timing Analysis using **OpenSTA** (`sta timing/sta.tcl`), writing SDC constraints (`20ns` period / `50MHz` clock), and verifying positive setup/hold slack.
- **Git Branch:** `feature/aes-rtl-synth-timing`

---

### Person B: Akif — Lead Place & Route (PNR), Physical Signoff, Cadence Virtuoso & FPGA Demo
- **Primary Domain:** Back-end physical design, floorplanning, CTS, routing, GDS-II generation, commercial DRC/LVS signoff, and hardware demonstration.
- **Assigned Phases:**
  - **Phase 5:** Die floorplanning (`1000 × 1000 µm` die area, `45%` core utilization), power ring/strap generation, and I/O pin placement.
  - **Phase 6:** Global/detailed placement and Clock Tree Synthesis (CTS) targeting `<145ps` clock skew.
  - **Phase 7:** Global/detailed routing, DRC/LVS signoff in OpenLane 2, and exporting final GDS-II stream (`gds/aes_soc.gds`).
  - **Phase 8 (Licensed Premium Advantage):** Importing final GDSII stream into **Cadence Virtuoso**, performing measurements, and capturing 4 required signoff screenshots (`full_chip`, `std_cells`, `metal_routing`, `power_grid`).
  - **Phase 9:** Programming FPGA demo board (Basys3 / iCEstick), running Python live demo (`sw/pc_demo.py`) showing **227× speedup**, and verifying LED `0x97` output.
- **Git Branch:** `feature/aes-pnr-gds-virtuoso`

---

## 🤝 Shared Responsibilities (Both Nandikha & Akif)
- **Phase 1:** Environment setup (Reusing PipeCore Nix environment: Yosys 0.67+, OpenSTA 2.0.17, OpenLane 2.3.10, KLayout 0.30.9, Sky130 PDK, Cadence Virtuoso license verification).
- **Phase 9:** Documentation (`README.md`, `ARCHITECTURE.md`, `NIST_VERIFICATION.md`, `VIRTUOSO_GUIDE.md`), final 1-page project summary PDF, and technical interview Q&A prep.
=======
# TEAM SPLIT - AES-128 Crypto SoC
## 2-Person Team - Same as PipeCore-GDS

### Project Overview (Recap from Master Note)
- **Name:** AES-128 Hardware Crypto Accelerator SoC
- **Speedup Story:** SW 50,000ns vs HW 220ns = 227x FASTER
- **Design:** Iterative AES (1 round reused 10x = 11 cycles), 8.2K gates, 1mm2, 45% util, 50MHz, UART interface
- **NIST TV1 Must Memorize:** Key 2B7E151628AED2A6ABF7158809CF4F3C Plain 6BC1BEE22E409F96E93D7E117393172A Cipher 3AD77BB40D7A3660A89ECAF32466EF97
- **Tools:** Yosys, OpenSTA, OpenLane 2.3.10, KLayout, Sky130 via Nix + Cadence Virtuoso (licensed viewing only) - No Genus/Innovus/Xcelium

### Person A - RTL + Synthesis + STA
**OS Recommendation:** Ubuntu 22.04 LTS (like Nandhika in PipeCore)
**Responsibility:** Design the chip logically, prove timing meets.

**Phases:**
1. Phase 2: RTL Design (Done ✅) - 15 Verilog files, NIST verified
2. Phase 3: Synthesis with Yosys - Generate `synth/netlist/aes_soc_synth.v`
3. Phase 4: STA with OpenSTA - Generate setup/hold reports, slack positive?

**Deliverables to Person B:**
- `synth/netlist/aes_soc_synth.v` (optional - OpenLane can re-synth from RTL)
- `timing/constraints.sdc` (REAL SDC with 20ns clock + set_fix_hold)
- `timing/reports/setup_report.txt` + `hold_report.txt`
- Updated PROJECT_STATE.md Phase 3-4 numbers

**Branch:** `feature/aes-rtl-synth-timing`
**Tasks file:** `PERSON_A_TASKS.md`

**Interview Focus:**
- SubBytes 16 S-Boxes parallel in 1 cycle, generate loop
- ShiftRows 0 gates free wiring
- MixColumns GF(2^8) xtime
- KeyExpansion Rcon/RotWord/SubWord
- Why iterative not pipelined (8K vs 80K gates)
- Setup/hold slack, critical path, Cap/Slew/Delay

---

### Person B - PNR + GDS + Virtuoso + FPGA
**OS Recommendation:** Ubuntu 22.04 LTS, Ryzen 7 16GB RAM + 8GB swap (like Akif in PipeCore)
**Responsibility:** Build the physical chip, see it in Virtuoso, demo on FPGA.

**Phases:**
1. Phase 5: Floorplan - DIE 1000x1000um, 45% util, power grid
2. Phase 6: Placement & CTS - Place ~8K gates, clock skew target 145ps
3. Phase 7: Routing & GDS - Route Metal1-4, DRC 0, LVS MATCH, export GDS
4. Phase 8: Virtuoso Viewing - Import GDS into Virtuoso (licensed advantage!), 4 screenshots
5. Phase 9: FPGA Demo LAST! - Basys3/iCEstick, UART demo showing 227x speedup

**Deliverables:**
- `pnr/runs/.../final/gds/aes_soc.gds` -> copy to `gds/`
- `virtuoso/screenshots/` 4 images
- `fpga/basys3.xdc` bitstream (optional)
- `gds/aes_soc.gds` final
- Updated PROJECT_STATE.md Phase 5-9

**Branch:** `feature/aes-pnr-gds-virtuoso`
**Tasks file:** `PERSON_B_TASKS.md`

**Interview Focus:**
- Die area, core area, utilization tradeoff
- Power rings/stripes, PDN
- Placement density, CTS skew
- Routing Metal layers, DRC/LVS/Antenna
- Virtuoso import flow, measurements
- FPGA clock divider (100MHz->50MHz), UART baud calc, speedup calculation

---

### Both Together - Phase 8+ Documentation

- Final reports: area, power, timing, DRC
- GitHub README with Virtuoso screenshots (premium!)
- 1-page project summary PDF
- 10 interview Q&A (5 each from their phases)
- Demo video: Full flow + Virtuoso viewing + FPGA live encryption

---

### Git Workflow (You learned this hard way in PipeCore - Unrelated Histories!)

```bash
# Person A
git checkout -b feature/aes-rtl-synth-timing
# ... do RTL/Synth/STA ...
git add rtl/ synth/ timing/
git commit -m "[AES][RTL+SYNTH+STA][A] Done"
git push origin feature/aes-rtl-synth-timing

# Person B fetches A's SDC (like PipeCore Phase 5 official run)
git fetch origin
git checkout -b feature/aes-pnr-gds-virtuoso
git checkout origin/feature/aes-rtl-synth-timing -- timing/constraints.sdc
# ... do PNR ...
git add pnr/ gds/ virtuoso/
git commit -m "[AES][PNR+GDS+VIRTUOSO][B] DRC LVS clean + Virtuoso"
git push origin feature/aes-pnr-gds-virtuoso

# Finally merge both to main (careful - branches have unrelated histories from earlier re-clone!)
# Use checkout --files method not merge if you get "unrelated histories" error
```

---

### Timeline Suggestion (Based on PipeCore dates)

- **Week 1 (Person A):** RTL already done, Synthesis + STA (2-3 days)
- **Week 2 (Person B):** OpenLane rehearsal run (1 day, 20-40 mins runtime) + Official run with real SDC (1 day) + Virtuoso screenshots (half day)
- **Week 3 (Both):** FPGA demo + Documentation + Interview prep

You already took 3 days for PipeCore ALU (168 cells). AES is bigger (8K cells) so allocate double time.

---

### Tool Checks Before Starting (Reuse PipeCore env)

Person A:
```bash
yosys -V  # should be 0.67+84+
sta -version  # OpenSTA 2.0.17
ls synth/sky130.lib  # or need to download
```

Person B:
```bash
openlane --smoke-test
klayout -v  # 0.30.9
nix --version  # 2.6.0
free -h  # check swap 8GB
virtuoso &  # should open licensed Virtuoso!
```

---

### What Makes This Project Stand Out vs PipeCore?

| PipeCore ALU | AES Crypto SoC (New) |
|---|---|
| Simple ALU, 8 ops, 2-stage pipeline | Complex crypto, 10 rounds, S-Box LUT, GF math |
| 168 cells | ~8,200 cells (50x bigger, shows you can handle larger design) |
| No industry crypto relevance | AES is everywhere (IoT, security) - hot topic |
| No Virtuoso advantage story | Virtuoso licensed = BIG ADVANTAGE (most students don't have) |
| No speedup story | 227x speedup story = impressive pitch |
| 25 tests | NIST FIPS-197 official vectors |
| No FPGA protocol | UART protocol live demo |

Resume: Shows progression - you went from small ALU to bigger crypto SoC, adding security domain + Virtuoso + UART SoC integration.

---

### Current Status (2026-07-28)

- RTL done ✅
- Synth/STA scripts ready
- OpenLane config ready + pnr/src/ copied
- Virtuoso guide ready
- Team split docs ready
- Next: Person A runs Yosys, Person B can start rehearsal PNR in parallel (no blocker)
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
