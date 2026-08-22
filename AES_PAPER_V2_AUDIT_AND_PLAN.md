# AES-128 PAPER V2 - FULL AUDIT AND REVISION PLAN
Date: 22 Aug 2026. Source: AES128_IEEE_Paper_VLSID2027_AkifMohamed.pdf (uploaded).
Goal: VLSID / VDAT 2027 submission that survives reviewer scrutiny and a viva defense.

---

## PART 1 - VERDICT

The current draft has a strong structure and a genuinely good story
(open-flow AES SoC with full signoff + FPGA validation + now DFT).
But it contains roughly 20 statements that are false, unverifiable, or
internally contradictory. Any one of them, if caught by a reviewer or an
interviewer, destroys credibility. All are fixable this week. The v2
evidence we generated today (4/4 NIST vectors, 200 ns measured, MBIST,
745/745 scan mapping, 67.6 percent utilization) makes the paper STRONGER
than the current inflated version - and every number becomes defensible.

Rule for v2: every number in the paper must be traceable to a file in the
repo or a tool log on your machine. No exceptions.

---

## PART 2 - CRITICAL INTEGRITY FIXES (blockers)

### A1. Affiliation and email (title block)
FALSE: "Vellore Institute of Technology" + akifmohamed.j2021@vitstudent.ac.in
FIX:  Government College of Engineering, Srirangam (GCE Srirangam),
      Tamil Nadu. Use your real email. Fix for BOTH authors.
      Also fix the acknowledgments (no Efabless chipathon involvement).

### A2. Fabrication language (Sections 5, 4.4, 5.1)
- Section 5: "characterization of the FABRICATED AES-128 accelerator"
  - the chip was never fabricated. Replace "fabricated" with "implemented".
- Section 4.4 / 5.1: DRC "34 violations resolved through manual layout
  edits in Magic" - not supported by any log. Replace with the true v2
  story: DRC clean except 2 documented marginal antenna residuals
  (met3 414.92/400, met1 411.19/400 ratio).
- Section 5.1: "silicon-validation precursor... before committed
  tape-out" - implies a committed tapeout. Remove "committed tape-out";
  say the FPGA prototype validates system integration.

### A3. Software benchmark (Section 5.3) - the biggest number in the paper
FALSE: mbedTLS on Cortex-M4 "50,000 cycles per block, 0.00256 Gbps, 250x".
Realistic mbedTLS AES-128 on Cortex-M4F (with crypto extensions): about
1,400 cycles per block; plain software about 1,600-2,000 cycles.
FIX (honest, still impressive):
- Hardware: 10 cycles per block (measured on chip), 200 ns at 50 MHz.
- Software: cite a published measured figure for mbedTLS on Cortex-M4
  (about 1,376 cycles/block is commonly reported; verify the exact source
  before citing - find one paper or benchmark page and cite it).
- Speedup: about 137x in cycles per block (1376/10), or about 41x in
  throughput per MHz. State the basis explicitly.
- Delete "67.6x per MHz" or recompute consistently.

### A4. Latency and throughput (Abstract, Table 3, Conclusion)
OLD: 11 cycles = 220 ns, 0.582 Gbps.
FIX: 10 cycles = 200 ns (measured on chip by the cycle counter, AND now
verified in simulation by tb_aes_soc_v2_1.v). Throughput = 128 bits /
200 ns = 0.64 Gbps. Where the 11-cycle figure appears, either remove it
or explain: 10-cycle busy window; command acceptance adds 1 cycle.

### A5. Flip-flop and cell counts (Section 4.1) - internal contradiction
PAPER: "25,902 cells... 8,232 DFFs (32 percent)..." and critical path
"18.2 ns pre-layout" while Table 2 says 5.93 ns. The repo truth: 745
flip-flops (netlist census: 731 dfrtp_2 + 14 dfstp_2), and the v2 run
counts must come from your v2 run logs. 8,232 FFs is impossible for this
design (10.8x the real number).
FIX: replace the whole Section 4.1 cell breakdown with the real synthesis
statistics from the scan_v2_0822b/c run directory (they are in
9-yosys-synthesis reports). Use: cell count, combinational area, FF count
745 (before DFT). Add the scan version: 745/745 mapped to scan flops.

### A6. Tool versions (Section 4, 4.1, 4.4) - several invented
FALSE or unverifiable: "OpenLane 2 release 2023.03.02" (that is an
OpenLane 1 version string), "Yosys 0.29.0", "sky130_sc_ls low-threshold
library" (the flow used sky130_fd_sc_hd), "Magic V8.3.332", "Netgen
1.5.27", "OpenSTA 1.3.4", "247 design rules", "1,247 clock buffers",
"0.15 ns skew", "98.3 percent routability", "87 MHz on FPGA" (keep only
if the Vivado timing report shows it), "Cadence Virtuoso 6.1.5" (keep
only if true - you do have Virtuoso screenshots, so state "used for
layout viewing").
FIX - REAL versions to use:
- OpenLane 2.3.10 (confirmed from your traceback)
- OpenROAD: run the inventory line from the stitch log / or check
  runs/*/openroad-*.log headers
- Yosys: from the synthesis log header in the run dir
- PDK: sky130A from volare version 0fe599b2afb6708d281543108caf8310912f54af
- Cell library: sky130_fd_sc_hd
- Vivado: your installed version (from the Vivado About box)
- Magic / Netgen / OpenSTA / KLayout: from their log headers in the run dir

### A7. "All five NIST FIPS-197 Appendix B test vectors" (Abstract, 3.3, 5.1)
FIPS-197 Appendix B contains exactly ONE vector. The "five vectors" claim
was never tested by any testbench in the repo (the old core tb did not
even compile).
FIX: the new tb_aes_core_v2.v now passes FOUR known-answer vectors:
NIST SP 800-38A ECB TV1, FIPS-197 Appendix B, all-zero KAT, all-FF KAT
(verified 22 Aug 2026 on iverilog 11 and 12). Paper should say "four
known-answer vectors including NIST SP 800-38A and FIPS-197 Appendix B,
zero bit errors". If you want "six", add SP 800-38A blocks 2-4 from the
published table into the tb and rerun (30 minutes of work) - do not claim
numbers the repo cannot reproduce.

### A8. Gate-level simulation claim (Section 5.1)
"Gate-level simulation with SDF back-annotation" - no evidence this ran.
FIX options: (a) remove the sentence; (b) better: actually run a
zero-delay gate-level sim of the synthesized netlist against the
testbench (we can do this with the sky130 verilog models from your PDK
directory - ask me and I will prepare it). Then the claim is real, minus
"SDF".

### A9. Broken citation and suspicious reference (Section 2, Table 1)
- "[?]" appears twice in Section 2 (LaTeX citation bug) - fix.
- Reference [14] "Lubaszewski et al., SBCCI 2021" - verify this exists.
  If you cannot find it in IEEE Xplore or Google Scholar, REMOVE it and
  the Table 1 row, or replace with a verifiable open AES implementation.
- Table 1 internal mismatch: [12] title says "156.26 Mbps" but the table
  row says 6.40 Gbps. Check the source paper and fix.
- Re-verify every number in Table 1 against the cited paper's abstract at
  minimum. Reviewers do exactly this.

### A10. v1 numbers everywhere (Abstract, 4.2, Table 3, 5.4)
The paper still uses the OLD 1000x1000 um die, 900x900 core, 20.2
percent utilization, 162,993 um2 area. Your v2 run (commit 2928bab)
achieved: die 240,307 um2, core 224,240 um2, 67.6 percent utilization,
same clean timing (+14.07 ns setup). Section 5.4's "could accommodate
100,000 additional cells" math is based on the old numbers - delete or
recompute.
FIX: replace all physical numbers with v2 values throughout. The 67.6
percent utilization is a BETTER story: you diagnosed the sizing
mechanism (relative sizing) and closed it - methodology lesson other
students can use.

---

## PART 3 - NEW CONTENT FOR V2 (what makes it "the best")

### 3.1 New DFT section (the novelty angle)
Draft text (adjust after the scan run finishes):

  "Section X: Design-for-Test Infrastructure.
  The SoC includes two DFT structures. (1) A March C- memory BIST
  controller for the 256x8 SRAM, verified in simulation with behavioral
  fault injection: a clean memory passes, and an injected stuck-at-0
  fault at address 42, bit 0 is detected and reported (FAIL at address
  42). (2) Full scan-path preparation: all 745 flip-flops in the
  synthesized netlist are mapped to scan flip-flops (731 sdfrtp_2 with
  async reset, 14 sdfsbp_2 with async set - 100 percent sequential
  coverage, single clock domain) using OpenROAD's scan_replace, executed
  as a custom OpenLane 2 flow step on the synthesized netlist without any
  RTL modification. Chain stitching with OpenROAD's insert_dft was
  attempted inside the flow; the bundled OpenROAD build rejects scan-cell
  creation pre-CTS (DFT-0005 clock-domain limitation), so the released
  GDS uses the scan-ready mapping with scan pins documented as future
  work. To our knowledge this is the first open-source AES SoC paper to
  report MBIST verification with fault injection plus full scan-cell
  mapping statistics alongside RTL-to-GDSII signoff."

### 3.2 New measured-results emphasis
- 10 cycles / 200 ns: measured ON CHIP (cycle counter + LEDs) AND now in
  simulation (tb_aes_soc_v2_1.v prints the same 10-cycle busy window).
  Two independent proofs. Show the LED photo (docs/basys3_demo_0x97.jpeg).
- Utilization journey: 20.2 percent (v1, absolute sizing ignored) to
  67.6 percent (v2, relative sizing) - a reproducible OpenLane 2
  methodology note. This is genuinely useful to readers.

### 3.3 Updated Table 3 (use real v2 + scan-run values)
  Technology: SkyWater 130nm (sky130_fd_sc_hd)
  Die: 240,307 um2 | Core: 224,240 um2
  Utilization: 67.6 percent (v2 flow)  [scan run: use final values]
  Flip-flops: 745 (100 percent scan-mapped)
  Latency: 10 cycles = 200 ns at 50 MHz (measured)
  Throughput: 0.64 Gbps
  Setup slack: +14.07 ns | Hold: +0.29 ns
  DRC: clean, 2 marginal antenna residuals documented
  LVS: match | NIST vectors: 4/4 (SP 800-38A TV1, FIPS-197 App B, 2 KAT)
  MBIST: March C- verified with fault injection
  FPGA: Basys3, UART demo, on-chip cycle measurement

---

## PART 4 - DEFENSE PREPARATION ("prove mine as the best")

Your honest differentiators (memorize these):
1. Completeness: RTL -> synthesis -> floorplan -> PnR -> DRC/LVS/signoff
   -> FPGA hardware demo -> DFT. No other OPEN AES SoC paper combines all
   of these. Singhali [16] taped out but reports no benchmark numbers, no
   DFT, no measured latency; commercial papers are not reproducible.
2. Measured, not estimated: the 200 ns is counted by hardware on the
   board, not calculated. Reviewers value this.
3. Reproducibility: every claim maps to a committed file (testbenches,
   configs, run scripts, fault-injection results).
4. DFT depth: MBIST with fault injection + 745/745 scan mapping with a
   documented tool limitation - shows engineering maturity, not just
   tool-running.
5. Honesty under pressure: if asked "why not stitched scan chains?",
   answer: the OpenROAD build bundled with OpenLane 2.3.10 cannot create
   scan cells pre-CTS (DFT-0005); stitching requires a newer build or a
   post-CTS flow; the scan-ready netlist and custom flow steps are
   released for the community to complete it. That is a strong answer.

Anticipated questions and answers:
- Q: Why only 50 MHz? A: Design target for IoT-class operation; timing
  margin (+14.07 ns) is reported for scaling discussions.
- Q: Why hd cells? A: Highest-density sky130 library variant, appropriate
  for area-constrained signoff; characterization of util at 67.6 percent.
- Q: Area is larger than Satoh 0.11um? A: Different node and goal: Satoh
  optimizes throughput/area in a commercial node; we demonstrate a fully
  open, reproducible, measured flow - comparison table states this.
- Q: Is the chip fabricated? A: No. The paper reports RTL-to-GDSII
  signoff-ready implementation and FPGA hardware validation. (Never imply
  otherwise.)
- Q: Side-channel? A: Out of scope; listed as future work (masking).

---

## PART 5 - ACTION CHECKLIST (order)

1. [FLOW] Apply config_scan_fix4 (ERROR_ON_DISCONNECTED_PINS=false),
   rerun tag scan_v2_0822d to get the complete scan GDS + final numbers.
2. [PAPER] Fix A1-A10 above in one editing pass.
3. [PAPER] Insert Section on DFT (3.1 above) and new Tables (3.2, 3.3).
4. [REPO] Commit updated tb_aes_core_v2.v (4 vectors) - evidence for A7.
5. [VERIFY] Pull real tool versions from run logs (A6 list).
6. [VERIFY] Check references [12] [14]; fix Table 1 row by row.
7. [OPTIONAL] Gate-level zero-delay simulation for A8 (I can prepare it).
8. [OPTIONAL] Add SP 800-38A blocks 2-4 to the tb for a 6-vector claim.

File provenance (already in repo or workspace):
- tb/tb_aes_soc_v2_1.v (NIST TV1 SoC-level, PASS, 10-cycle window)
- tb/tb_aes_core_v2.v (4 vectors, 4/4 PASS, iverilog 11+12)
- tb/tb_mbist.v (MBIST fault injection, PASS)
- pnr/config_probe_scan.json + dft plugin (Tier-1 evidence, commit 388fd93)
- FPGA photo: docs/basys3_demo_0x97.jpeg
