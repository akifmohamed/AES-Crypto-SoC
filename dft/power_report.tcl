# power_report.tcl v2 - OpenSTA post-layout power analysis for aes_soc
# Analysis, not silicon measurement. Corners defined before use.

define_corners tt ss ff
read_liberty -corner tt $::env(PLIB_TT)
read_liberty -corner ss $::env(PLIB_SS)
read_liberty -corner ff $::env(PLIB_FF)
read_lef $::env(PTEF)
read_lef $::env(PLEF1)
read_lef $::env(PLEF2)
read_def $::env(PDEF)
read_spef $::env(PSPEF)

create_clock -name clk -period 20 [get_ports clk]

if {[catch {set_power_activity -global -activity 0.10 -duty 0.50} m1]} {
    if {[catch {set_power_activity -global -input_activity {0.10 0.50}} m2]} {
        puts "NOTE: set_power_activity not supported, using OpenSTA defaults"
    }
}

puts "================ POWER REPORT tt ================"
catch { report_power -corner tt } ptt
puts $ptt
puts "================ POWER REPORT ss ================"
catch { report_power -corner ss } pss
puts $pss
puts "================ POWER REPORT ff ================"
catch { report_power -corner ff } pff
puts $pff
puts "================ DONE ================"
