# AES-128 v2 — Netlist Scan DFT Plan (Step 2)

**Status:** planned + scripts ready · 22 Aug 2026
**Approach:** scan insertion on the **synthesized netlist** via OpenROAD's `dft`
module, injected into the OpenLane 2 flow as custom steps. **No RTL edits.**
(This is the replacement for the abandoned hand-written MUX-D RTL attempt.)

## Verified facts this plan is built on (checked 22 Aug 2026)

1. OpenROAD's current DFT command set is `set_dft_config` / `report_dft_config`
   / `scan_replace` / `report_dft_plan` / `execute_dft_plan`
   (https://openroad.readthedocs.io/en/latest/main/src/dft/README.html).
   The names `insert_dft` / `preview_dft` in earlier notes are the OLD names
   from the tool's first prototype (OpenROAD discussion #2784). There is **no
   `connect_dft`** command — stitching is done by `execute_dft_plan` with
   `-scan_in/_out/_enable_name_pattern` for pin creation.
2. `scan_replace` swaps DFFs for scan-DFFs from the liberty (sky130_fd_sc_hd
   has the `dfxtp` scan-flop class). It should run **before placement**.
   `execute_dft_plan` architects + stitches chains and should run **after
   placement** (docs: wirelength-aware ordering).
3. OpenLane 2 (current docs, step-config-vars registry) ships **no built-in
   DFT/scan step or variable** — verified by exhaustive grep of the full
   variable registry (0 hits for dft/scan). So scan insertion must be a
   **custom step** (officially supported: `OpenROADStep` subclass +
   `get_script_path()`, registered from an `openlane_plugin_*` module).
4. Custom steps slot into the Classic flow declaratively via
   `meta.substituting_steps` with `StepID+` = "insert after"
   (config grammar docs). Env contract for Tcl steps: `_PNR_LIBS` (liberty
   list), `CURRENT_NETLIST`/`SAVE_NETLIST`, `CURRENT_DEF`/`SAVE_DEF`,
   `SCRIPTS_DIR` — all verified in `openlane/steps/{tclstep,openroad}.py` and
   `scripts/openroad/floorplan.tcl` on OL2 main.

## Tier 1 — standalone probe (do FIRST; ~30 min incl. reading logs)

Goal: prove `scan_replace`+stitching converge on the aes_soc netlist before
touching any flow config.

```
cd AES-Crypto-SoC
# inside your OL2 env (openroad + PDK_ROOT available):
chmod +x dft/run_scan_probe.sh
./dft/run_scan_probe.sh
```

Expected evidence if it works:
- `DFT_PROBE: DFF-class instances before scan_replace = ~742` (matches the
  742-FF figure from the abandoned RTL attempt — cross-check!)
- `dfxtp* lib cells found > 0`
- `after scan_replace: scan-class=~742, DFF-class reduced`
- `dft/probe_out/aes_soc_scanreplaced.v` (+ possibly `..._scanstitched.v`)

If `execute_dft_plan` refuses to run on an unplaced netlist: that's fine —
Tier 2 handles stitching in-flow; the scan-replaced netlist alone already
demonstrates "scan-ready" mapping.

## Tier 2 — OL2 plugin + full scan PnR (1–2 evenings, ~30 min per run)

1. `export PYTHONPATH=$PWD/dft/openlane2_plugin:$PYTHONPATH`
2. Sanity: `python3 -c "import openlane_plugin_aesdft"` (import errors =
   OL2 API drift — compare against your installed OL2 2.3.10 sources in
   `openlane/steps/openroad.py` and adjust the plugin).
3. Run: `openlane pnr/config_scan.json --run-tag scan_v2_$(date +%m%d)`
   (config_scan.json = your verified v2 config + `meta.substituting_steps`
   inserting `AesDFT.ScanReplace` after synthesis and `AesDFT.ScanStitch`
   after detailed placement).
4. Grep the run dir logs for `AES_DFT:` lines; collect:
   - FF count before/after scan_replace
   - `report_dft_plan` chain summary (chains, length, cells)
   - final GDS with scan cells; DRC/LVS/antenna results vs the documented
     2 marginal antenna residuals
   - new utilization (scan flops are slightly larger → util will rise from
     67.6%; record honestly)

## Tier 3 — evidence for the paper (evening)

Gate-level scan shift simulation of `aes_soc_scanreplaced.v` (or stitched):
- Simulate with iverilog against sky130 behavioral models
  (`$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog/` + `sky130_fd_sc_hd.v`
   + `primitives.v`), `scan_enable=1`, clock a known pattern through
   `scan_in`, verify it appears at `scan_out` exactly chain-length clocks
   later; one capture cycle (`scan_enable=0`, 1 clk) then shift out.
- This replaces the old hand-written `tb_scan.v` with a NETLIST-level test.

## Honest fallback (already agreed)

If Tiers 1–2 don't converge in the timebox: paper states —
*"Scan-ready architecture: full-FF inventory (742 FFs) analyzed for scan
insertion with OpenROAD's dft module; MBIST (March C−) implemented and
verified with fault injection; full scan insertion and ATPG = future work."*
Everything else in the paper (67.6% util, 200 ns measured, NIST TV1) stands
on its own evidence.

## Notes / risks

- The plugin step classes are written against the OL2 **main-branch** API;
  your installed 2.3.10 may differ slightly. Tier 1 first, then adjust.
- `no_mix` clock mode is correct here (single clock `clk`, posedge, no
  generated clocks inside the core).
- Scan pins (`scan_in/scan_out/scan_enable`) become new top-level BTerms —
  the FPGA wrapper and BASYS3 demo are NOT affected (ASIC netlist only).
- After a successful scan run, re-check: antenna diode insertion interacts
  with new scan routing; keep `GPL_CELL_PADDING: 4` as-is unless DRC says
  otherwise (previous decision: keep, 2 residuals documented).
