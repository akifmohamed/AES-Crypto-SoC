> HISTORICAL v1 planning document (kept for the team record).
> Numbers below are v1-era and superseded by v2 (see README): 200 ns / 10 cycles,
> 67.6% utilization, 745 FFs, 114-128x vs software, DFT + power analysis added.
> The role split itself is still accurate.

# TEAM SPLIT - AES-128 Crypto SoC
## 2-Person Team - Same as PipeCore-GDS

### Project Overview (Recap from Master Note)
- **Name:** AES-128 Hardware Crypto Accelerator SoC
- **Speedup Story:** SW 50,000ns vs HW 220ns = 227x FASTER
- **Design:** Iterative AES (1 round reused 10x = 11 cycles), 25,902 cells / 185,254 um2 measured, 1mm2 die (20.2% util achieved), 50MHz, UART interface
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
- `timing/constraints.sdc` (20ns clock SDC; Synopsys-only set_fix_hold removed for OpenSTA portability)
- `timing/reports/setup_report.txt` + `hold_report.txt`
- (team state tracking kept private; public numbers live in README/docs)

**Branch:** `feature/aes-rtl-synth-timing`
**Scope:** RTL, synthesis, STA

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
1. Phase 5: Floorplan - DIE 1000x1000um, 45% util planned (20.2% achieved), power grid
2. Phase 6: Placement & CTS - Place ~26K cells, clock skew target 145ps
3. Phase 7: Routing & GDS - Route Metal1-4, DRC 0, LVS MATCH, export GDS
4. Phase 8: Virtuoso Viewing - Import GDS into Virtuoso (licensed advantage!), 4 screenshots
5. Phase 9: FPGA Demo LAST! - Basys3/iCEstick, UART demo showing 227x speedup

**Deliverables:**
- `pnr/runs/.../final/gds/aes_soc.gds` -> copy to `gds/`
- `virtuoso/screenshots/` 4 images
- `fpga/basys3.xdc` bitstream (optional)
- `gds/aes_soc.gds` final
- (team state tracking kept private; public numbers live in README/docs)

**Branch:** `feature/aes-pnr-gds-virtuoso`
**Scope:** PNR, signoff, Virtuoso, FPGA demo

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
| 168 cells | 25,902 cells measured (~150x bigger design) |
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
