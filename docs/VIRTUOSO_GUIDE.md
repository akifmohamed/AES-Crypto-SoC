<<<<<<< HEAD
# Cadence Virtuoso Signoff & Layout Import Guide (Licensed Advantage)

Having access to **Cadence Virtuoso** gives our team a strong competitive advantage in VLSI Physical Design interviews. Most student projects rely solely on open-source viewers like KLayout. By importing our final OpenLane GDSII layout into Virtuoso, we demonstrate industry-standard signoff verification and mixed open/licensed EDA workflows.

---

## 1. Why Virtuoso Matters in VLSI Interviews
- **Industry-Standard Physical Signoff:** In commercial chip design (Intel, TSMC, NVIDIA, Qualcomm), open-source or digital PNR tools (Innovus/OpenLane) export a GDSII stream that is imported into full-custom layout environments like Cadence Virtuoso for final DRC/LVS/Antenna signoff, padframe integration, and analog/mixed-signal verification.
- **Proof of Licensed Tool Experience:** Displaying Virtuoso screenshots with the title bar showing your university/lab license proves you are familiar with commercial layout environments.

---

## 2. GDSII Stream Import Commands
1. Open your terminal in the university Cadence environment and launch Virtuoso:
   ```bash
   virtuoso &
   ```
2. In the Command Interpreter Window (CIW), select:
   **File → Import → Stream...**
3. In the Stream In window, set:
   - **Stream File:** `/home/user/aes-crypto-soc/gds/aes_soc.gds` (or copy from your OpenLane run directory).
   - **Top Cell:** `aes_soc`
   - **Library:** Create a new library named `AES_CRYPTO_SKY130` attached to the Sky130 PDK technology library.
   - **Layer Map:** Select the Sky130 GDS layer map file (`sky130A.layermap`).
4. Click **Translate** to stream in the layout.

---

## 3. Required Signoff Screenshots (Save to `virtuoso/screenshots/`)
1. `full_chip.png`: Full 1000 µm × 1000 µm die area showing core ring, I/O pins, and density.
2. `std_cells.png`: Zoomed-in view of the standard cell rows showing `sub_bytes` (S-Box) LUT placements and power rails (VDD/VSS).
3. `metal_routing.png`: Highlighting metal layers (Met1 to Met5) and via matrices.
4. `power_grid.png`: Highlighted power distribution network (PDN) rings and straps.
=======
# Virtuoso Guide - Using Your Licensed Advantage
## You have Virtuoso (most students don't!) - Here's how to use it with open-source GDS

You have:
- **Open tools** for RTL->GDS: Yosys, OpenSTA, OpenLane 2, KLayout (from PipeCore-GDS Nix)
- **Licensed tool** for Viewing/Signoff: Cadence Virtuoso

This is your BIG resume differentiator.

### Flow Completed in Open Source
```
RTL (Verilog) -> Yosys synth -> OpenSTA STA -> OpenLane 2 PNR -> GDS
```

Files:
- `synth/netlist/aes_soc_synth.v` - gate netlist
- `pnr/runs/.../final/gds/aes_soc.gds` - final GDS from OpenLane
- Then import to Virtuoso

### Import GDS into Virtuoso (Step-by-Step)

1. **Open Virtuoso**
   ```bash
   virtuoso &
   ```

2. **Create Library**
   - Library Manager -> File -> New -> Library
   - Name: `aes_soc`
   - Technology: Attach to `sky130` PDK tech file if you have it, or create blank
   - If you have Sky130 PDK in Virtuoso, use that. If not, use generic.

3. **Import Stream (GDS)**
   - In CIW: File -> Import -> Stream
   - Input file: `/path/to/aes-crypto-soc/pnr/runs/RUN_xxx/final/gds/aes_soc.gds`
   - Top cell: `aes_soc`
   - Library: `aes_soc`
   - View: `layout`
   - Options:
     - Layer Map: If you have `sky130.map` file, use it. Else let Virtuoso auto-map
     - Units: 0.001 (from OpenLane GDS)

4. **Open Layout**
   - Library Manager -> aes_soc -> aes_soc -> layout -> Open

5. **Virtuoso Layout Viewing Tricks (For Video/Screenshots)**
   - `F` - Fit to window (see full chip 1000x1000um)
   - `Shift+F` - Fit all
   - `Ctrl+Scroll` - Zoom in/out
   - Left panel: Click metal layers to highlight
     - Turn on/off Metal1-Metal4 to see routing
     - Show VPWR/VGND power grid (thick rings)
   - `E` - Descend into hierarchy (see standard cells inside AES core)
   - `K` - Ruler to measure (measure die size)
   - `:` - Go to coordinate
   - `Shift+E` - Return to top level

6. **What to Screenshot for Resume/LinkedIn**
   - Full chip view zoomed out (shows die area ~1mm2, 45% util)
   - Zoomed in standard cell rows (shows ~8k gates placed)
   - Metal layers routing (show wires connecting S-Boxes)
   - Power rings around core (M4/M3)
   - Clock tree (if visible, buffers)
   - With Virtuoso title bar visible (proof you used licensed tool!)

### DRC/LVS with Virtuoso (if you have PVS or Calibre + Sky130 PDK rules)

If your Virtuoso install includes PVS/Assura and Sky130 DRC/LVS rule decks:

**DRC:**
```bash
pvs -drc -cell aes_soc -layout aes_soc.gds -rules /path/to/sky130/drc_rules.rul -log drc.log
```
Or inside Virtuoso:
- Tools -> PVS -> DRC...

**LVS:**
```bash
pvs -lvs -cell aes_soc -layout aes_soc.gds -schematic synth/netlist/aes_soc_synth.v -rules /path/to/sky130/lvs_rules.rul
```

**Expected clean results (like PipeCore):**
- DRC 0 violations ✅
- LVS MATCH ✅

If you don't have Sky130 PDK in Virtuoso, you can still view GDS (geometry only) - DRC/LVS is optional. OpenLane already ran DRC/LVS (check `pnr/runs/.../reports/final/` ).

### How to Talk About This in Interview

> "I used full open-source flow Yosys/OpenSTA/OpenLane 2 for RTL-to-GDS like my previous PipeCore-GDS project, but I also have access to Cadence Virtuoso - which most students don't have - so I imported my final GDS into Virtuoso for sign-off viewing, measurements, and DRC/LVS verification. This gave me both open-source expertise and industry tool experience."

This shows:
- You know open-source (valuable for startups)
- You know Cadence industry tools (valuable for big companies Intel/TSMC/NVIDIA)
- You understand both worlds

### Bonus: Generate Layout Screenshot with KLayout Also (Fallback)

Since you already have KLayout 0.30.9 from PipeCore:
```bash
klayout gds/aes_soc.gds &
```
- Use same viewing tricks, colored layers
- Take screenshot for README

But Virtuoso screenshot is more impressive for resume.

### GitHub Repo Structure to Show Virtuoso Usage

Add folder:
```
virtuoso/
  ├── screenshots/
  │   ├── virtuoso_full_chip.png
  │   ├── virtuoso_std_cells.png
  │   ├── virtuoso_metal_routing.png
  │   └── virtuoso_power_grid.png
  └── README.md (how you imported)
```

### Questions You Might Get

Q: "Why OpenLane if you have Virtuoso?"
A: "Virtuoso license I have is for layout viewing/custom design only, not full digital flow (Innovus/Genus). So I used open-source for synthesis and PnR which I already mastered in PipeCore-GDS, and Virtuoso for final signoff and viewing - this is also common in industry where teams use mixed flows."

Q: "What tech node?"
A: "Sky130 130nm from Google/SkyWater PDK - same as previous project, so I could reuse my Nix environment. Die 1000x1000um ~1mm2, 45% utilization, ~8.2K gates."

>>>>>>> 8a7d0f170172da4de0ed845c06b98da844d9d5b2
