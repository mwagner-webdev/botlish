# kernel.tcl -- times the mid-end-shaped kernel (audit/mid-end-port/README.md,
# "The kernel") in its five versions and checks that they agree:
#
#   tclsh9.0 audit/mid-end-port/tools/kernel.tcl ?-functions 1500? ?-depth 8?
#       ?-repeat 5?
#
#   tcl dict      kernel/ranges.tcl dict    (hir/'s style)
#   tcl list      kernel/ranges.tcl list    (flat lists, pairs returned)
#   tcl tables    kernel/ranges.tcl tables  (flat lists, side tables only)
#   native structs  kernel/ranges-structs.bot as a native executable
#   native tables   kernel/ranges-tables.bot as a native executable
#
# Each is run -repeat times and its best time kept; a native time is the
# whole executable's (its process start is about 2 ms). The executables are
# built with this checkout's main.tcl (the native backend must be built:
# cargo build --release --manifest-path native/Cargo.toml) in a `file
# tempdir` directory removed afterwards. Exits with status 1 unless every
# version computes the same [nodes, rounds, checksum].

set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set checkout [file dirname [file dirname $audit]]
set options [dict create -functions 1500 -depth 8 -repeat 5]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "kernel.tcl: unknown option $option" }
    dict set options $option $value
}
set functions [dict get $options -functions]
set depth [dict get $options -depth]
set repeat [dict get $options -repeat]
set tclsh [info nameofexecutable]
set scratch [file tempdir mid-end-kernel]
set rows {}
try {
    foreach mode {dict list tables} {
        set best ""
        for {set i 0} {$i < $repeat} {incr i} {
            set line [exec $tclsh [file join $audit kernel ranges.tcl] $mode $functions $depth]
            lassign $line - nodes rounds check seconds
            set seconds [string trimright $seconds s]
            if {$best eq "" || $seconds < $best} { set best $seconds }
        }
        lappend rows [list "tcl $mode" $best [list $nodes $rounds $check]]
    }
    foreach variant {structs tables} {
        set source [file join $audit kernel ranges-$variant.bot]
        set channel [open $source]
        set text [read $channel]
        close $channel
        if {![regsub {\nrun\(\d+, \d+\):} $text "\nrun($functions, $depth):" text]} {
            error "kernel.tcl: no run(...) line in $source"
        }
        set copy [file join $scratch ranges-$variant.bot]
        set channel [open $copy w]
        puts -nonewline $channel $text
        close $channel
        exec $tclsh [file join $checkout main.tcl] -warnings off -emit-native-executable $copy
        set executable [file rootname $copy]
        set resultFile [file join $scratch result-$variant.txt]
        set best ""
        for {set i 0} {$i < $repeat} {incr i} {
            set env(BOTLISH_NATIVE_RESULT) $resultFile
            set t0 [clock microseconds]
            exec $executable
            set seconds [format %.3f [expr {([clock microseconds] - $t0) / 1e6}]]
            unset env(BOTLISH_NATIVE_RESULT)
            if {$best eq "" || $seconds < $best} { set best $seconds }
        }
        set channel [open $resultFile]
        set value ""
        foreach line [split [read $channel] \n] {
            if {[lindex $line 0] eq "value"} {
                # value {list {{int N} {int R} {int C}}}
                set value [lmap item [lindex [lindex $line 1] 1] {lindex $item 1}]
            }
        }
        close $channel
        lappend rows [list "native $variant" $best $value]
    }
} finally {
    file delete -force $scratch
}
set reference [lindex $rows 0 2]
set agree 1
puts [format "kernel: %d functions, depth %d, best of %d (nodes %s, rounds %s, checksum %s)" \
    $functions $depth $repeat {*}$reference]
puts [format "%-16s %9s %11s %21s" version seconds "dict / this" "this / native tables"]
set nativeTables [lindex $rows end 1]
set dict [lindex $rows 0 1]
foreach row $rows {
    lassign $row name seconds value
    if {$value ne $reference} {
        set agree 0
        puts "  $name computes $value, not $reference"
    }
    puts [format "%-16s %9.3f %10.1fx %20.1fx" $name $seconds [expr {$dict / $seconds}] [expr {$seconds / $nativeTables}]]
}
exit [expr {!$agree}]
