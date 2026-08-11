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
