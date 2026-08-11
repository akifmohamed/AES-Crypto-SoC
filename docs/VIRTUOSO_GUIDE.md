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
