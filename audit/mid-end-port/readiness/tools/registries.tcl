# registries.tcl -- the size of the process-wide registries a Botlish
# mid-end would have to receive as data
# (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section 14): registered
# natives and the metadata keys they
# carry, registered types, the C target table's rows.
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/registries.tcl
set checkout [file dirname [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]]
source [file join $checkout surface surface.tcl]
source [file join $checkout compiler compiler.tcl]
set scratch [file tempdir registries]
set warm [file join $scratch warm.bot]
set channel [open $warm w]; puts $channel "x = 1\nx"; close $channel
surface::readProgramFile $warm -warnings off -cache ""
set natives [core::native::names]
set keys [dict create]
set qualified 0
foreach n $natives {
    dict for {k v} [core::native::metadata $n] { dict incr keys $k }
    if {[string match std::* $n]} { incr qualified }
}
puts "natives registered after a warm compilation: [llength $natives] (std:: qualified: $qualified)"
puts "distinct metadata keys: [dict size $keys]"
puts "keys (natives carrying each): [lsort -stride 2 -index 1 -integer -decreasing $keys]"
puts "core::type registered names: [llength [core::type::names]]"
puts "C targets: [llength [core::cabi::targetNames]]"
file delete -force $scratch
