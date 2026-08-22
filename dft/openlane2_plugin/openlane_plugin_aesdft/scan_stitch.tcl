# scan_stitch.tcl - AesDFT.ScanStitch (DEF in -> DEF out, post detailed placement)
# v3 (22 Aug 2026): this OpenROAD build has no report_dft_plan/execute_dft_plan.
# Print the DFT command inventory, try each known stitch command, and if none
# works, pass the DEF through so the flow still completes.
source $::env(SCRIPTS_DIR)/openroad/common/io.tcl
read_pnr_libs
read_lefs
if {[catch {read_def $::env(CURRENT_DEF)} _msg]} {
    read_current_def
}

set_dft_config -max_length $::env(AES_DFT_MAX_LENGTH) -clock_mixing $::env(AES_DFT_CLOCK_MIXING)

puts "AES_DFT_INVENTORY: [lsort [info commands *dft*]]"

set _stitched 0
foreach _cmd {execute_dft_plan insert_dft connect_dft} {
    if {[llength [info commands $_cmd]] == 0} { continue }
    puts "AES_DFT: trying stitch command: $_cmd"
    if {[catch {$_cmd} _smsg]} {
        puts "AES_DFT: $_cmd failed: $_smsg"
    } else {
        set _stitched 1
        puts "AES_DFT: STITCH OK via $_cmd"
        break
    }
}

if {$_stitched == 0} {
    puts "AES_DFT: WARNING - no stitch command worked. Continuing with unstitched DEF."
    puts "AES_DFT: Design still contains the scan flops from AesDFT.ScanReplace."
}

write_def $::env(SAVE_DEF)
write_verilog [file join [file dirname $::env(SAVE_DEF)] aes_soc_postdft.nl.v]
puts "AES_DFT: wrote $::env(SAVE_DEF)"
