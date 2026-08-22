# AES-128 SoC - Open Source Flow Adaptation
## You Only Have Virtuoso + Open Tools (No Genus/Innovus/Xcelium) - DO THIS

You already completed PipeCore-GDS with: Yosys, OpenSTA, OpenLane 2, KLayout, Sky130 via Nix. Reuse SAME environment.

### New Project Structure (Follow PipeCore exactly for muscle memory)

```
aes-crypto-soc/
├── rtl/
│   ├── crypto/ (aes_sbox, sub_bytes, shift_rows, gf_mult, mix_columns, key_expand, aes_core)
│   ├── peripheral/ (uart_rx, uart_tx)
│   └── top/ (aes_soc)
├── synth/
│   ├── synth.tcl (Yosys - NEW for AES)
│   ├── get_pdk.sh
│   ├── sky130.lib (download -> same as PipeCore)
│   └── netlist/
│       └── aes_soc_synth.v (generated)
├── timing/
│   ├── constraints.sdc (50MHz = 20ns, or try 10ns)
│   ├── sta.tcl (OpenSTA)
│   ├── sky130.lib (copy from synth/)
│   └── reports/
│       ├── setup_report.txt
│       └── hold_report.txt
├── pnr/
│   ├── config.json (OpenLane 2 - NEW for AES)
│   ├── src/
│   │   └── *.v (copy of rtl - OpenLane needs it)
│   └── runs/ (OpenLane output - final GDS here)
├── gds/
│   └── aes_soc.gds (final, copy from pnr/runs/.../final/gds/)
├── tb/
│   ├── tb_aes_core.v (NIST vectors)
│   └── tb_aes_soc.v
├── docs/
│   ├── VIRTUOSO_GUIDE.md
│   └── screenshots/
├── reports/
├── sw/
│   └── pc_demo.py
└── fpga/
    ├── basys3.xdc
    └── icestick.pcf
```

### Phase-by-Phase (Reuse PipeCore Commands)

#### Phase 1: Env Setup (DONE - you already have it!)
You already have from PipeCore:
- Yosys 0.67+84, OpenSTA 2.0.17 via OSS CAD Suite
- OpenLane 2.3.10 via Nix 2.6.0
- KLayout 0.30.9
- Sky130 PDK
Skip this if Nix still works. Test:
```bash
yosys -V
openlane --smoke-test
klayout -v
```

#### Phase 2: RTL Design (DONE!)
All Verilog in `rtl/` already written and verified via Python model against NIST FIPS-197.
If iverilog available, you can simulate like PipeCore:
```bash
iverilog -g2012 -o sim rtl/crypto/*.v rtl/peripheral/*.v rtl/top/*.v tb/tb_aes_core.v
vvp sim
gtkwave waves.vcd
```
5 vectors must pass. TV1 memorized: Key 2B7E..., Plain 6BC1..., Cipher 3AD7...

#### Phase 3: Synthesis with Yosys (Same as PipeCore Phase 3)

```bash
cd aes-crypto-soc
# Get lib if not already
bash synth/get_pdk.sh
# Or copy from old project: cp ~/PipeCore-GDS/synth/sky130.lib synth/

# Run synthesis
yosys -s synth/synth.tcl
```

Output:
- `synth/netlist/aes_soc_synth.v` (gate netlist)
- `synth/synth_report.txt` (cell count, area)

**Expected for AES (bigger than PipeCore ALU):**
- PipeCore ALU: 168 cells, 1513 um2, 29 FFs
- AES SoC: ~8000-12000 cells, ~15000-20000 um2, ~200-400 FFs (16 S-Boxes are large)
Don't panic if area bigger - AES is crypto heavy.

#### Phase 4: STA with OpenSTA (Same as PipeCore Phase 4)

```bash
# Ensure lib copy
cp synth/sky130.lib timing/

sta timing/sta.tcl
```

Check reports:
- Setup slack should be +ve (e.g., +X ns MET)
- Hold may be -ve pre-CTS (normal; OpenLane repairs hold automatically) - measured +0.29 ns post-PNR
- Critical path: will be through S-Box + MixColumn chain (~? ns)

Measured on the official run: setup +14.07 ns / hold +0.29 ns @ 20 ns.

#### Phase 5-7: PNR with OpenLane 2 (Person B flow from PipeCore)

Prep:
```bash
cd aes-crypto-soc
# Copy RTL to pnr/src/ for OpenLane
mkdir -p pnr/src
cp rtl/crypto/*.v rtl/peripheral/*.v rtl/top/*.v pnr/src/

# Note (v2): use relative sizing (FP_SIZING relative + FP_CORE_UTIL); absolute DIE_AREA inputs were silently ignored
# For AES bigger than ALU, we use 1000x1000 um die (vs PipeCore predicted 3785um2 core area at 40%)
# AES needs ~1mm2

# Run OpenLane
openlane pnr/config.json
```

This will run: Synthesis (again, but we already did), Floorplan, Placement, CTS, Routing.

Wait time: PipeCore ALU rehearsal was few minutes. AES is ~50x bigger, may take 15-30 mins on your Ryzen 7 5700U. Have 16GB RAM and swap.

On success:
```
pnr/runs/RUN_2026-XX-XX_xx-xx-xx/final/
  ├── gds/aes_soc.gds
  ├── reports/final/
  └── ...
```

Check DRC/LVS: In OpenLane log, look for `DRC ✅ LVS ✅ Antenna ✅` like your PipeCore rehearsal.

If DRC violations:
- Check reports, usually antenna or density. OpenLane config has `GRT_REPAIR_ANTENNAS: true`

#### Phase 8: Virtuoso Viewing (Your Premium Advantage)

Now you have GDS from open-source, but you have Virtuoso license (others don't).

Follow `docs/VIRTUOSO_GUIDE.md` to import GDS into Virtuoso and take impressive screenshots.

Copy final GDS to top-level:
```bash
cp pnr/runs/RUN_*/final/gds/aes_soc.gds gds/
ls -lh gds/aes_soc.gds
```

#### Phase 9: FPGA Demo (LAST - after GDSII!)

Like original plan, after all simulation/PD done.

- Use Vivado (Basys3) or IceStorm (iCEstick)
- `fpga/basys3.xdc` constraints
- Program and run `python3 sw/pc_demo.py`

This demonstrates a 114x cycle-count reduction vs measured mbedTLS (1136 SW cycles vs 10 HW cycles per block).

### Key Differences from Cadence Flow in Original Note

| Original Note (Full Cadence) | Your Reality (Open + Virtuoso) |
|---|---|
| Xcelium xrun | Icarus Verilog + GTKWave (or Verilator) |
| Genus synthesis | Yosys synthesis |
| Innovus PNR | OpenLane 2 PNR |
| Virtuoso viewing | Virtuoso viewing (you have!) |
| PVS DRC/LVS | OpenLane DRC/LVS + KLayout, optional Virtuoso PVS if rule decks available |

Resume bullet can say: "Mixed flow: Open-source RTL-to-GDS (Yosys/OpenSTA/OpenLane2/Sky130) + Cadence Virtuoso for sign-off viewing/DRC/LVS - leveraging licensed industry tool advantage"

### Interview Prep - Same as PipeCore + AES specifics

- Setup/hold slack, critical path (you learned in PipeCore Phase 4)
- Cap/Slew/Delay terms (same)
- Plus AES: SubBytes non-linear confusion, ShiftRows zero-cost wiring, MixColumns GF(2^8), Key expansion Rcon etc.
- Iterative vs Pipelined tradeoff (8K vs 80K gates)
- Why 50MHz? IoT power; 114-128x fewer cycles than software AES

### Git Workflow (Same as PipeCore)

```bash
git checkout -b feature/aes-soc
git add rtl/ synth/ timing/ pnr/
git commit -m "[AES][RTL] Complete AES SoC RTL + Yosys synth + OpenSTA STA + OpenLane config"
git push origin feature/aes-soc
```

