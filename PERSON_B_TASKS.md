<<<<<<< HEAD
# Person B Tasks — Akif (PNR, Virtuoso Signoff & FPGA Demo)

## Overview
As **Person B**, Akif owns the digital back-end and physical signoff flow: floorplanning, placement, clock tree synthesis (CTS), routing, DRC/LVS verification in OpenLane 2, Cadence Virtuoso layout import/screenshots, and live FPGA UART demonstration.

---

## Task Checklist

### Phase 1: Environment Setup (Reuse PipeCore)
- [x] Verify OpenLane 2.3.10 and KLayout 0.30.9 are working in Nix environment (`openlane --smoke-test`).
- [x] Verify Cadence Virtuoso university/lab license is working (`virtuoso &`).

### Phase 5: Floorplanning & PNR Rehearsal Run (Current/Parallel Step)
- [x] Create OpenLane configuration `pnr/config.json`:
  - Die area: `0 0 1000 1000 µm` (`1 mm²` total area).
  - Core area: `50 50 950 950 µm`.
  - Utilization: `45%` (`0.45`).
  - Clock period: `20.0 ns` (`50 MHz`).
- [x] Copy RTL source files into `pnr/src/` for OpenLane access.
- [ ] Run OpenLane rehearsal build (can run now in parallel with Nandikha's synthesis):
  ```bash
  openlane pnr/config.json
  ```
- [ ] Check runtime (`~20–40 mins`, larger than ALU due to 8.2K gates).
- [ ] Verify clean antenna rules, 0 DRC violations, and clean LVS match.

### Phase 6–7: Placement, CTS, Routing & GDS Export
- [ ] Perform official OpenLane run once Nandikha pushes final SDC constraints.
- [ ] Verify CTS clock skew meets `<145 ps` target.
- [ ] Export final GDS-II layout stream to `gds/aes_soc.gds`.
- [ ] View GDS in KLayout (`klayout gds/aes_soc.gds`).

### Phase 8: Cadence Virtuoso Layout Signoff (Licensed Advantage!)
- [ ] Launch Virtuoso: `virtuoso &`
- [ ] Stream in `/home/user/aes-crypto-soc/gds/aes_soc.gds` (Top Cell: `aes_soc`, Layer map: `sky130A.layermap`).
- [ ] Capture 4 signoff screenshots in `virtuoso/screenshots/`:
  1. `full_chip.png`: Complete 1mm² die with I/O padframe and power rings.
  2. `std_cells.png`: Zoomed-in standard cell rows showing SubBytes S-Box placements.
  3. `metal_routing.png`: Highlighted Met1–Met5 routing layers.
  4. `power_grid.png`: VDD/VSS power distribution straps.

### Phase 9: FPGA Live Demo & Verification
- [ ] Program Basys3 / iCEstick FPGA board with RTL using Vivado / IceStorm.
- [ ] Execute Python demo script: `python3 sw/pc_demo.py`
- [ ] Verify hardware execution time (`220 ns` / 11 cycles @ 50 MHz) vs software (`50,000 ns`), confirming **227× speedup**.
- [ ] Check FPGA LEDs display `0x97` (matching last byte of NIST TV1 ciphertext).
- [ ] Commit progress to `feature/aes-pnr-gds-virtuoso`:
  ```bash
  git commit -m "[AES][PNR][B] OpenLane run DRC LVS clean + Virtuoso screenshots"
  ```
=======
# PERSON B TASKS - AES Crypto SoC
## PNR, GDS, Virtuoso Viewing, FPGA Demo - Same as PipeCore Person B

You are Person B. You mastered PipeCore Phases 5-7 with Nix + OpenLane 2.3.10 + KLayout. Now same for AES but bigger design + Virtuoso premium advantage.

### Your Skills from PipeCore (Reuse!)
- Nix install, bind-mount to /home
- OpenLane 2 config.json
- KLayout 0.30.9 viewing
- DRC/LVS clean checks
- Swapfile for heavy runs

### Environment - Already DONE (from PipeCore)

You already have:
- Nix 2.6.0, OpenLane 2.3.10
- KLayout 0.30.9
- Sky130 PDK
- /nix bind-mounted to /home/nix-store to avoid filling root
- 8GB swapfile active

Test (like PipeCore):
```bash
openlane --smoke-test
klayout -v
```

If not working, re-follow PipeCore Phase 1 steps.

### Phase 5: Floorplan - YOUR FIRST TASK (Can start NOW!)

**Goal:** Define die area 1000x1000um = 1mm2, 45% util, power grid - same as PipeCore but bigger die.

**Step 1: Prep - same as PipeCore**
```bash
cd aes-crypto-soc
# Ensure RTL copy for OpenLane (like pnr/src/alu_pipeline.v in PipeCore)
ls pnr/src/ | wc -l  # should be 15 files (already copied)
# If not:
mkdir -p pnr/src
cp rtl/crypto/*.v rtl/peripheral/*.v rtl/top/*.v pnr/src/
```

**Step 2: Check config.json (we created)**
```json
{
  "DESIGN_NAME": "aes_soc",
  "VERILOG_FILES": "dir::src/*.v",
  "CLOCK_PORT": "clk",
  "CLOCK_PERIOD": 20,
  "FP_SIZING": "absolute",
  "DIE_AREA": "0 0 1000 1000",  // vs PipeCore which was smaller ~ maybe 100x100?
  "CORE_AREA": "50 50 950 950",
  "CORE_UTILIZATION": 45,  // vs 40% in PipeCore
  ...
}
```
- DIE 1000x1000um = 1mm2 (PipeCore predicted ~3785um2 core @40% util, AES needs bigger)
- CLOCK_PERIOD 20 = 50MHz (PipeCore used 10ns)
- PNR_SDC_FILE points to ../timing/constraints.sdc (real SDC from Person A)

**Step 3: Rehearsal Run (like PipeCore Phase 5 rehearsal that was DRC LVS clean)**

You did rehearsal in PipeCore with fallback SDC and got DRC ✅ LVS ✅. Do same now:

```bash
cd aes-crypto-soc
openlane pnr/config.json
# Takes 20-40 mins for AES (vs few mins for ALU) - AES is ~50x bigger!
# Monitor RAM with htop - ensure swapfile active
```

**Expected output (same as PipeCore rehearsal):**
```
OpenLane run .../RUN_2026-07-28_xx-xx-xx
...
Final Summary:
DRC: 0 violations? Check logs
LVS: MATCH?
Antenna: clean?
```

If fails, check errors you solved in PipeCore:

| PipeCore Error | Fix |
|---|---|
| `PermissionError: not located any path readable` | Use `VERILOG_FILES: "dir::src/*.v"` not direct file path |
| `DIODE_INSERTION_STRATEGY deprecated` | Use `GRT_REPAIR_ANTENNAS: true` (already in config) |
| Nix /nix not writable | `sudo chown -R $USER /nix` |
| Root partition full | Bind Nix to /home (you already did) |

**Step 4: Find GDS**
```bash
ls pnr/runs/
ls pnr/runs/RUN_*/final/gds/
# Should have aes_soc.gds
ls -lh pnr/runs/RUN_*/final/gds/aes_soc.gds
```

**Step 5: Copy to top-level gds/ (like PipeCore)**
```bash
mkdir -p gds
cp pnr/runs/RUN_*/final/gds/aes_soc.gds gds/
```

### Phase 6 & 7: Placement, CTS, Routing - Inside same OpenLane run

OpenLane does Floorplan -> Placement -> CTS -> Routing in one go.

**Check reports (like PipeCore):**
```bash
cat pnr/runs/RUN_*/reports/final/synthesys/reports/*.rpt | head
cat pnr/runs/RUN_*/final/logs/final.log | grep -E "DRC|LVS|Antenna|WNS|TNS"
```

**Numbers to fill in PROJECT_STATE.md:**
- Die area: 1000x1000um
- Utilization: 45%
- Clock skew: Look for CTS report, target 145ps (original spec)
- Final area, power

### Phase 8: Virtuoso Viewing - YOUR PREMIUM TASK (Only you have licensed tool!)

This is what makes you stand out vs other students (like master note says: "BIG ADVANTAGE").

**Step 1: Open Virtuoso (licensed)**
```bash
virtuoso &
```

**Step 2: Import GDS (follow docs/VIRTUOSO_GUIDE.md)**

- CIW: File -> Import -> Stream
- Input: `/home/.../aes-crypto-soc/gds/aes_soc.gds`
- Top cell: `aes_soc`
- Library: create new `aes_soc` library, attach to Sky130 tech if you have, else blank

**Step 3: Take 4 screenshots (for GitHub README + LinkedIn + Interview)**

1. **Full chip view** - Press F (fit), shows die 1000x1000um, 45% util, power rings
2. **Standard cell rows** - Zoom in, press E to descend, shows ~8K gates placed
3. **Metal routing** - Toggle Metal1-Metal4 layers visible, shows wires between S-Boxes
4. **Power grid** - Turn on only Metal3/Metal4 + VPWR/VGND, shows rings + stripes

Save to:
```
virtuoso/screenshots/virtuoso_full_chip.png
virtuoso/screenshots/virtuoso_std_cells.png
...
```

**If you also have KLayout (you do - 0.30.9):** Take fallback screenshots too:
```bash
klayout gds/aes_soc.gds &
```

### Phase 9: FPGA Demo - LAST! (After GDSII - per master note)

**Goal:** Show live encryption + 227x speedup story

**Step 1: Vivado project for Basys3 (Xilinx)**
- Create new project, add rtl/*.v, top aes_soc.v, set top
- Add constraints `fpga/basys3.xdc` (clock W5 100MHz, UART A18/B18, LEDs U16/E19/U19)
- **Important:** Basys3 clock is 100MHz, our design wants 50MHz. You need clock divider or MMCM:
  ```verilog
  // Add in top wrapper: clk_50M = clk_100M /2
  reg clk_div = 0;
  always @(posedge clk_100M) clk_div <= ~clk_div;
  assign clk_50M = clk_div;
  ```
- Generate bitstream

**Alternative iCEstick (Lattice):**
- Use `fpga/icestick.pcf`, clock 12MHz -> BAUD_DIV 104 not 434, update uart params to 12M
- Use IceStorm: `yosys`, `nextpnr-ice40`, `icepack`

**Step 2: Program FPGA**
- Basys3 via USB, iCEstick via USB

**Step 3: Run Python demo**
```bash
pip install pyserial pycryptodome
python3 sw/pc_demo.py
# Select port /dev/ttyUSB0 or COM3
```

**Expected output:**
```
Key: 2B7E...
Plain: 6BC1...
SW Time: 50000 ns
HW Core Time: 220 ns
Speedup: 227x ✅ NIST MATCH!
LED last byte: 97 (matches expected last byte of cipher)
```

### Your Interview Talking Points (Person B focus)

- How you defined die area 1000x1000um, why 45% util (like PipeCore 40%)
- Power grid: addRing, addStripe, VDD/VSS - same concept as OpenLane PDN
- Placement density, CTS clock skew target 145ps
- Routing layers: Met1-4, DRC clean, antenna fix
- How you imported GDS into Virtuoso (licensed tool advantage)
- How you measured die size with K ruler in Virtuoso
- FPGA demo: UART protocol 0xAE/0x55, baud div calculation, why 227x faster (HW 11 cycles vs SW 50k ns)

### Checklist Before Saying "GDS Done"

- [ ] pnr/src/ has 15 verilog files
- [ ] pnr/config.json DIE 0 0 1000 1000, CORE_UTIL 45, CLOCK_PERIOD 20
- [ ] Nix env + OpenLane --smoke-test passed
- [ ] OpenLane run completed, log shows DRC ✅ LVS ✅ (or at least GDS produced)
- [ ] gds/aes_soc.gds exists and > few KB
- [ ] Virtuoso import succeeded, 4 screenshots taken into virtuoso/screenshots/
- [ ] KLayout viewing also done (fallback)
- [ ] FPGA bitstream generated (optional for now, but xdc ready)
- [ ] Files pushed to feature/aes-pnr-gds-virtuoso branch
- [ ] PROJECT_STATE.md updated with Phase 5-8 numbers

### Git Workflow (Same as PipeCore)

```bash
git checkout -b feature/aes-pnr-gds-virtuoso
# After OpenLane run:
git add pnr/config.json gds/ virtuoso/screenshots/ docs/
git commit -m "[AES][PNR][B] OpenLane run DRC LVS clean + Virtuoso screenshots"
git push origin feature/aes-pnr-gds-virtuoso

# To get Person A's SDC (you did this in PipeCore):
git fetch origin
git checkout origin/feature/aes-rtl-synth-timing -- timing/constraints.sdc
# Copy into pnr/ for readable-paths if needed
```

### Common Errors (You solved these in PipeCore + New AES specific)

| Error | Fix |
|-------|-----|
| OpenLane permission error | Use dir::src/*.v |
| DIODE_INSERTION deprecated | Use GRT_REPAIR_ANTENNAS |
| Run killed / OOM | AES bigger than ALU - ensure 16GB RAM + 8GB swapfile active, close Chrome |
| GDS too big for Virtuoso | Try KLayout first, then Virtuoso with proper layer map |
| FPGA clock mismatch 100MHz vs 50MHz | Divide clock by 2 in wrapper |

You already did full clean RTL->GDS for ALU in rehearsal on 2026-07-23. Now do same for AES SoC - bigger but same steps!
>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
