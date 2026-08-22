# scan_replace.tcl - AesDFT.ScanReplace (netlist in -> netlist out)
# Swaps DFFs for scan-DFFs (sky130_fd_sc_hd dfxtp-class) right after synthesis.
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read_pnr_libs
read_lefs
read_current_netlist

# --- configure DFT -------------------------------------------------------------
set _maxlen $::env(AES_DFT_MAX_LENGTH)
set _mix    $::env(AES_DFT_CLOCK_MIXING)
set_dft_config -max_length $_maxlen -clock_mixing $_mix \
    -scan_enable_name_pattern "scan_enable" \
    -scan_in_name_pattern     "scan_in" \
    -scan_out_name_pattern    "scan_out"
report_dft_config

# --- count FFs before ----------------------------------------------------------
set _ndff 0
foreach _inst [get_cells -hierarchical *] {
    if {[regexp {sky130_fd_sc_hd__df} [get_property $_inst ref_name]]} { incr _ndff }
}
puts "AES_DFT: scan-replace start: DFF-class instances = $_ndff"

# --- replace -------------------------------------------------------------------
scan_replace

# --- count after + sanity ------------------------------------------------------
set _ndff_a 0
set _nscan 0
foreach _inst [get_cells -hierarchical *] {
    set _ref [get_property $_inst ref_name]
    if {[regexp {sky130_fd_sc_hd__df} $_ref]} { incr _ndff_a }
    if {[regexp {(dfxtp|dfrtp|dfstp)} $_ref]} { incr _nscan }
}
puts "AES_DFT: scan-replace done: DFF-class=$_ndff_a scan-class=$_nscan"
if {$_nscan == 0} {
    error "AES_DFT: scan_replace replaced nothing - check liberty has dfxtp cells"
}

write_verilog $::env(SAVE_NETLIST)
puts "AES_DFT: wrote $::env(SAVE_NETLIST)"
