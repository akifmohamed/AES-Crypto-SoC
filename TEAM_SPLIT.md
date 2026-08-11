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
