# scan_probe.tcl - Standalone OpenROAD scan-DFT probe on a SYNTHESIZED netlist
# Purpose: prove scan_replace / execute_dft_plan work on the aes_soc gate-level
#          netlist BEFORE wiring anything into an OpenLane 2 flow.
# NO RTL is modified. This operates purely on the Yosys output netlist.
#
# Verified command set (OpenROAD docs, src/dft README):
#   set_dft_config -max_length/-max_chains/-clock_mixing/-scan_in_name_pattern/...
#   report_dft_config
#   scan_replace                (pre-placement: DFF -> scan-DFF, e.g. dfxtp)
#   report_dft_plan [-verbose]  (preview; ideally after global placement)
#   execute_dft_plan            (architect + stitch chains)
# Older OpenROAD builds called these preview_dft / insert_dft - if this script
# errors with "invalid command name", check your build with:  openroad -version
#
# Usage (env vars set by run_scan_probe.sh):
#   DFT_NETLIST   - path to synthesized Verilog netlist (e.g. .../1_synth.v)
#   DFT_LIBS      - space-separated list of .lib files (all corners not needed;
#                   one tt corner is enough for this probe)
#   DFT_OUTDIR    - output directory
#   DFT_MAXLEN    - max chain length (default 800 -> 1 chain for ~742 FFs)

set netlist $::env(DFT_NETLIST)
set libs    $::env(DFT_LIBS)
set outdir  $::env(DFT_OUTDIR)
set maxlen  800
if {[info exists ::env(DFT_MAXLEN)]} { set maxlen $::env(DFT_MAXLEN) }

file mkdir $outdir

# --- 1. Read design -----------------------------------------------------------
foreach lib $libs { read_liberty $lib }
read_verilog $netlist
link_design aes_soc

# --- 2. Count sequential cells BEFORE scan replacement ------------------------
set n_dff 0
set n_sdff 0
foreach inst [get_cells -hierarchical *] {
    set ref [get_property $inst ref_name]
    if {[regexp {sky130_fd_sc_hd__df} $ref]} { incr n_dff }
    if {[regexp {(dfxtp|dfrtp|dfstp)} $ref]} { incr n_sdff }
}
puts "DFT_PROBE: DFF-class instances before scan_replace = $n_dff"
puts "DFT_PROBE: scan-class instances already present    = $n_sdff"

# --- 3. Sanity: does the SCL actually have scan flops? ------------------------
set n_scan_libcells [llength [get_lib_cells sky130_fd_sc_hd__dfxtp*]]
puts "DFT_PROBE: sky130_fd_sc_hd dfxtp* lib cells found = $n_scan_libcells"
if {$n_scan_libcells == 0} {
    puts "DFT_PROBE: ERROR - no dfxtp scan cells in liberty; scan_replace cannot map."
    exit 2
}

# --- 4. Configure + scan-replace ----------------------------------------------
set_dft_config -max_length $maxlen -clock_mixing no_mix \
    -scan_enable_name_pattern "scan_enable" \
    -scan_in_name_pattern     "scan_in" \
    -scan_out_name_pattern    "scan_out"
report_dft_config
scan_replace

set n_dff_after 0
set n_sdff_after 0
foreach inst [get_cells -hierarchical *] {
    set ref [get_property $inst ref_name]
    if {[regexp {sky130_fd_sc_hd__df} $ref]} { incr n_dff_after }
    if {[regexp {(dfxtp|dfrtp|dfstp)} $ref]} { incr n_sdff_after }
}
puts "DFT_PROBE: after scan_replace: DFF-class=$n_dff_after scan-class=$n_sdff_after"

write_verilog $outdir/aes_soc_scanreplaced.v
puts "DFT_PROBE: wrote $outdir/aes_soc_scanreplaced.v"

# --- 5. Preview + attempt stitch (no placement yet) ---------------------------
# On an unplaced netlist chain ORDER will not be wirelength-optimized (docs
# recommend running after global placement); this probe only proves the
# commands converge. Guarded so a failure still leaves the scan-replaced
# netlist from step 4 as the deliverable.
if {[catch { report_dft_plan -verbose } msg]} {
    puts "DFT_PROBE: report_dft_plan failed on unplaced netlist: $msg"
    puts "DFT_PROBE: that is acceptable for the probe - rerun inside flow after GPl."
} else {
    if {[catch { execute_dft_plan } msg2]} {
        puts "DFT_PROBE: execute_dft_plan failed on unplaced netlist: $msg2"
        puts "DFT_PROBE: acceptable for the probe - stitching belongs post-GPL in-flow."
    } else {
        write_verilog $outdir/aes_soc_scanstitched.v
        puts "DFT_PROBE: wrote $outdir/aes_soc_scanstitched.v"
    }
}

puts "DFT_PROBE: DONE"
