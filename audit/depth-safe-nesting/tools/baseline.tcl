# baseline.tcl -- how deep each specimen compiles at a recursion limit
# (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md, section 2).
#
#   tclsh9.0 audit/depth-safe-nesting/tools/baseline.tcl ?-root DIR?
#       ?-kinds KIND,...? ?-limit L? ?-max N? ?-memory KB?
#
# For each specimen kind (specimens.tcl, this checkout's), bisects the
# largest depth up to -max (1024) at which the compiler of checkout -root
# (this one by default; the revision before the milestone to measure where
# it stopped) compiles the program -- the front end, core IR, the Tcl
# compiler's unit and native lowering -- at Tcl's recursion limit -limit
# (1000, the default). Each attempt is a child process capped at -memory KB
# (3000000) of virtual memory. Prints, per kind, the largest depth that
# compiled and the first that did not, with how: the error code and the
# procedure repeated most in its stack, or the child's death (the cap).

set options [dict create -root "" -kinds "" -limit 1000 -max 1024 -memory 3000000 -child ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "unknown option $option"
    }
    dict set options $option $value
}
set here [file dirname [file normalize [info script]]]
set root [dict get $options -root]
if {$root eq ""} {
    set root [file dirname [file dirname [file dirname $here]]]
}
set root [file normalize $root]

if {[dict get $options -child] ne ""} {
    set ::dsnArgs [list [dict get $options -child] $root [dict get $options -limit]]
    source [file join $root native native.tcl]
    source [file join $root surface surface.tcl]
    source [file join $here specimens.tcl]
    lassign $::dsnArgs child root limit
    lassign $child kind n
    set source [dict get [dsn::specimen $kind $n] source]
    interp recursionlimit {} $limit
    set code [catch {
        set hir [surface::compile $source -warnings off]
        hir::lower $hir
        core::compiler::compileHir $hir
        native::lowered $hir
    } result info]
    interp recursionlimit {} 1000000
    if {!$code} {
        puts ok
        exit 0
    }
    set names {}
    foreach line [split [dict get $info -errorinfo] \n] {
        if {[regexp {\(procedure "([^"]+)"} $line -> name]} {
            dict incr names $name
        }
    }
    puts [list [lrange [dict get $info -errorcode] 0 2] [lindex [lsort -stride 2 -index 1 -integer -decreasing $names] 0]]
    exit 0
}

proc Attempt {kind n} {
    global options root
    set code [catch {
        exec sh -c {ulimit -v "$0"; exec "$@"} [dict get $options -memory] \
            [info nameofexecutable] [info script] -root $root -limit [dict get $options -limit] \
            -child [list $kind $n] 2>@1
    } out]
    set out [string trim $out]
    if {$code} {
        return [list killed [string range [lindex [split $out \n] end] 0 80]]
    }
    return $out
}

source [file join $here specimens.tcl]
set kinds [expr {[dict get $options -kinds] eq "" ? [dsn::kinds] : [split [dict get $options -kinds] ,]}]
set max [dict get $options -max]
foreach kind $kinds {
    if {[Attempt $kind $max] eq "ok"} {
        puts "$kind: compiles $max deep"
        flush stdout
        continue
    }
    set lo 0
    set hi $max
    while {$hi - $lo > 1} {
        set mid [expr {($lo + $hi) / 2}]
        if {[Attempt $kind $mid] eq "ok"} {
            set lo $mid
        } else {
            set hi $mid
        }
    }
    puts "$kind: largest passing $lo, first failing $hi: [Attempt $kind $hi]"
    flush stdout
}
