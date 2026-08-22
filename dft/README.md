# DFT Kit - AES-128 SoC

Design-for-test tooling for this repository. All steps operate on the
synthesized netlist or the completed flow outputs; no RTL is modified.

## Contents

- `openlane2_plugin/openlane_plugin_aesdft/` - OpenLane 2 plugin registering
  two custom steps: `AesDFT.ScanReplace` (post-synthesis scan-cell
  replacement) and `AesDFT.ScanStitch` (post-placement chain stitching
  attempt; see status below).
- `scan_probe.tcl` + `run_scan_probe.sh` - standalone OpenROAD probe:
  counts flip-flops, verifies the library has scan cells, runs
  `scan_replace` on a synthesized netlist, writes the scan-replaced netlist.
- `dft_report.sh` - extracts all signoff metrics (area, utilization, slack
  per corner, DRC, LVS, antenna, IR drop, wirelength) from any OpenLane run
  directory.
- `power_report.sh` + `power_report.tcl` - post-layout power analysis
  (OpenSTA, three corners, SPEF parasitics; analysis, not silicon
  measurement).

## Usage

```bash
# synthesis + scan replacement (fast probe, minutes):
cd pnr && openlane config_probe_scan.json

# full 79-step DFT flow (~25 min):
export PYTHONPATH=$PWD/../dft/openlane2_plugin:$PYTHONPATH
openlane config_scan.json

# metrics and power from a completed run:
bash ../dft/dft_report.sh runs/<run-tag>
bash ../dft/power_report.sh runs/<run-tag>
```

## Status

- Scan-cell replacement: all 745 flip-flops mapped (731 sdfrtp_2, 14
  sdfsbp_2; 100% sequential coverage, single clock domain).
- Chain stitching: OpenROAD `insert_dft` was invoked at two flow points
  (post-detailed-placement and post-CTS); the bundled OpenROAD build rejects
  scan-cell creation in both cases (DFT-0005), so the released GDS contains
  scan-mapped flops with unconnected scan pins. Stitching requires a newer
  OpenROAD build.
- MBIST (March C-) is in `rtl/` and verified by `tb/tb_mbist.v` with
  behavioral fault injection.
