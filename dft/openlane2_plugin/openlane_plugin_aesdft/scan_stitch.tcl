# scan_stitch.tcl - AesDFT.ScanStitch (DEF in -> DEF out, post detailed placement)
# Architects scan chains and stitches them with wirelength awareness.
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read_pnr_libs
read_lefs
if {[catch {read_def $::env(CURRENT_DEF)} _msg]} {
    # some OL2 io.tcl builds provide a helper instead
    read_current_def
}

set _maxlen $::env(AES_DFT_MAX_LENGTH)
set _mix    $::env(AES_DFT_CLOCK_MIXING)
set_dft_config -max_length $_maxlen -clock_mixing $_mix \
    -scan_enable_name_pattern "scan_enable" \
    -scan_in_name_pattern     "scan_in" \
    -scan_out_name_pattern    "scan_out"
report_dft_config

report_dft_plan -verbose
execute_dft_plan

write_def $::env(SAVE_DEF)
puts "AES_DFT: scan chains stitched; wrote $::env(SAVE_DEF)"
