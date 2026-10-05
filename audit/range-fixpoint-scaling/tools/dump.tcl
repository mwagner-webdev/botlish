# dump.tcl -- RANGE-FIXPOINT-SCALING.md: records every range analysis and
# every NIR lowering a run performs, so two compiler trees can be compared
# output for output (compare.tcl).
#
# Not loaded by anything in the tree. To use it, append to a scratch
# worktree's hir/hir.tcl
#
#   if {[info exists ::env(BOTLISH_DUMP_DIR)]} { source PATH/dump.tcl; ::dump::wrapRange }
#
# and to its native/native.tcl
#
#   if {[info exists ::env(BOTLISH_DUMP_DIR)]} { source PATH/dump.tcl; ::dump::wrapNative }
#
# then run anything (tests/all.tcl, tests/native-coverage.tcl,
# bench/corpus.tcl, ...) with BOTLISH_DUMP_DIR set: every test file runs in
# its own process, and each process inherits the variable. Every
# hir::range::analyze and native::lower::program call appends
# "KIND INPUT-KEY OUTPUT-KEY" to DIR/PID.log (KIND range or nir; a key is the
# CRC-32, Adler-32 and byte length of the UTF-8 text of the call's arguments
# or of its result -- the analysis dict, or the NIR text) and stores the
# output text as DIR/out/OUTPUT-KEY.
namespace eval ::dump {
    variable dir $::env(BOTLISH_DUMP_DIR)
    file mkdir [file join $dir out]
}

proc ::dump::key {text} {
    set bytes [encoding convertto utf-8 $text]
    return [format %08x%08x-%d [zlib crc32 $bytes] [zlib adler32 $bytes] [string length $bytes]]
}

proc ::dump::record {kind in out} {
    variable dir
    set inKey [key $in]
    set outKey [key $out]
    set path [file join $dir out $outKey]
    if {![file exists $path]} {
        set channel [open $path w]
        fconfigure $channel -encoding utf-8 -translation lf
        puts -nonewline $channel $out
        close $channel
    }
    set channel [open [file join $dir [pid].log] a]
    puts $channel [list $kind $inKey $outKey]
    close $channel
}

proc ::dump::wrapRange {} {
    if {[info commands ::hir::range::analyze__dumped] ne ""} return
    rename ::hir::range::analyze ::hir::range::analyze__dumped
    proc ::hir::range::analyze args {
        set analysis [::hir::range::analyze__dumped {*}$args]
        ::dump::record range $args $analysis
        return $analysis
    }
}

proc ::dump::wrapNative {} {
    if {[info commands ::native::lower::program__dumped] ne ""} return
    rename ::native::lower::program ::native::lower::program__dumped
    proc ::native::lower::program args {
        set lowered [::native::lower::program__dumped {*}$args]
        ::dump::record nir $args [dict get $lowered text]
        return $lowered
    }
}
