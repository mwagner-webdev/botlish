# corpus.tcl -- what FOLD-VIRTUAL-STRUCT-STATE-MILESTONE-1.md changes over a
# corpus of programs: for each program and each lowering configuration, the
# NIR's digest, the struct census's classes, the fold slots and the native
# run's Struct allocations.
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/corpus.tcl ?-root DIR?
#       ?-configs {NAME OPTIONS ...}? ?-run 0|1? FILE.bot ...
#
# -root DIR measures another checkout's compiler (the tree before the
# milestone: its lowering has no fold slots); the program files are read
# where they are named. Each program is compiled once and lowered under
# every configuration (default: {default {}}); -run 1 also runs it natively
# (no GC stress) for its Struct allocations. One line per program and
# configuration:
#
#   FILE CONFIG nir=CRC32-LENGTH census=CLASS:N,... slots=V/D structs=N
#
# The NIR is digested with the program's path mapped to PROGRAM and the
# checkout's directory to ROOT (a diagnostic a program embeds names files). A program
# that does not compile or lower prints its error instead.
# Comparing two outputs line by line (same FILE and CONFIG) shows which
# programs' NIR changed and how their representation changed.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set configs {default {}}
set run 0
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -root { set root [file normalize [lindex $argv [incr i]]] }
        -configs { set configs [lindex $argv [incr i]] }
        -run { set run [lindex $argv [incr i]] }
        default { lappend files [file normalize $arg] }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
unset -nocomplain env(BOTLISH_HIR_CACHE) env(BOTLISH_NATIVE_GC_STRESS)
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
core::useProgramRecursionLimit

foreach path $files {
    set name [file tail [file dirname $path]]/[file tail $path]
    if {[catch {surface::readProgramFile $path -warnings off} hir]} {
        puts "$name - error: [lindex [split $hir \n] 0]"
        continue
    }
    foreach {config options} $configs {
        if {[catch {native::lowered $hir {*}$options} lowered]} {
            puts "$name $config error: [lindex [split $lowered \n] 0]"
            continue
        }
        # The program's path and the checkout's directory appear in
        # diagnostics a program embeds as strings (its own and the standard
        # library's files): mapped out, so two checkouts' NIR compare by
        # what they compile, not where.
        set bytes [encoding convertto utf-8 [string map [list $path PROGRAM $root ROOT] [dict get $lowered text]]]
        set digest [format %08x-%d [zlib crc32 $bytes] [string length $bytes]]
        set classes [dict create]
        foreach rec [dict get $lowered structCensus] {
            set what [dict get $rec class]
            if {$what eq "materialized"} {
                append what ([string map {{ } -} [dict get $rec reason]])
            }
            dict incr classes $what
        }
        set census [join [lmap {k v} [lsort -stride 2 $classes] {string cat $k:$v}] ,]
        set virtual 0
        set dropped 0
        foreach rec [dict getdef $lowered foldSlots {}] {
            if {[dict get $rec status] eq "virtual"} { incr virtual } else { incr dropped }
        }
        set structs -
        if {$run} {
            if {[catch {dict get [native::allocationReport $hir summary 1 {*}$options] byKind Struct allocations} structs]} {
                set structs "run-error"
            }
        }
        puts "$name $config nir=$digest census=[expr {$census eq "" ? "-" : $census}] slots=$virtual/$dropped structs=$structs"
    }
}
