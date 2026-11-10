# nested-frontend.tcl -- what compiling a deeply nested program costs
# (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md).
#
#   tclsh9.0 bench/nested-frontend.tcl ?-kinds KIND,...? ?-depths N,...?
#       ?-root DIR? ?-limit L? ?-out FILE?
#
# For each specimen kind (audit/depth-safe-nesting/tools/specimens.tcl) at
# each depth, a fresh process compiles the program at Tcl's recursion limit
# L (1000, the default) and reports, per phase -- the front end (parse,
# lowering, the whole-program build and checks), core IR, the Tcl
# compiler's unit, native lowering -- its wall time, then the process's
# peak memory and structural counts: tokens, HIR expressions, segments
# made and drivers started (core/deep.tcl). The last column is each total's
# ratio to the previous depth's: about 2 where the work is linear in the
# nesting (the depths double). -root measures another checkout (the
# revision before the milestone needs -limit 100000 to get anywhere, and
# has no segment counters: shown as -).

set options [dict create -kinds paren,rbin,flat,list,struct,call,method,not,elif,handler,mixed \
    -depths 64,128,256,512,1000,2000 -root "" -limit 1000 -out "" -child ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        error "unknown option $option"
    }
    dict set options $option $value
}
set here [file dirname [file normalize [info script]]]
set checkout [file dirname $here]
set root [expr {[dict get $options -root] eq "" ? $checkout : [file normalize [dict get $options -root]]}]

if {[dict get $options -child] ne ""} {
    lassign [dict get $options -child] kind depth
    set ::dsnArgs [list $kind $depth $root [dict get $options -limit]]
    source [file join $root native native.tcl]
    source [file join $root surface surface.tcl]
    source [file join $checkout audit depth-safe-nesting tools specimens.tcl]
    lassign $::dsnArgs kind depth root limit
    set source [dict get [dsn::specimen $kind $depth] source]
    interp recursionlimit {} $limit
    set result [dict create tokens [llength [dict get [surface::lexer::tokenize $source <input>] tokens]]]
    foreach {phase script} {
        front {set hir [surface::compile $source -warnings off]}
        coreir {hir::lower $hir}
        tcl {core::compiler::compileHir $hir}
        native {native::lowered $hir}
    } {
        set started [clock microseconds]
        if {[catch $script message info]} {
            dict set result failed "$phase: [lrange [dict get $info -errorcode] 0 2]"
            break
        }
        dict set result $phase [expr {([clock microseconds] - $started) / 1000}]
    }
    if {[info exists hir]} {
        dict set result exprs [dict size [dict get $hir exprs]]
    }
    if {[info commands core::deep::stats] ne ""} {
        dict set result segments [dict get [core::deep::stats] segments]
        dict set result drivers [dict get [core::deep::stats] drivers]
    }
    set f [open /proc/self/status r]
    regexp {VmHWM:\s+(\d+)} [read $f] -> peak
    close $f
    dict set result peak [expr {$peak / 1024}]
    puts $result
    exit 0
}

set out [expr {[dict get $options -out] eq "" ? "stdout" : [open [dict get $options -out] w]}]
puts $out [format "%-8s %6s %7s %7s %8s %6s %6s %8s %8s %6s %6s %8s %6s" \
    kind depth tokens exprs front coreir tcl native total peakMB segs drivers ratio]
foreach kind [split [dict get $options -kinds] ,] {
    set previous ""
    foreach depth [split [dict get $options -depths] ,] {
        set started [clock milliseconds]
        if {[catch {exec [info nameofexecutable] [info script] -child [list $kind $depth] \
                -root $root -limit [dict get $options -limit] 2>@1} result]} {
            puts $out "$kind $depth: [string range $result 0 200]"
            continue
        }
        set result [lindex [split [string trim $result] \n] end]
        if {[dict exists $result failed]} {
            puts $out [format "%-8s %6s  %s" $kind $depth "failed in [dict get $result failed]"]
            set previous ""
            continue
        }
        set total [expr {[dict get $result front] + [dict get $result coreir] + [dict get $result tcl] + [dict get $result native]}]
        set ratio [expr {$previous eq "" ? "" : [format %.2f [expr {double($total) / max($previous, 1)}]]}]
        puts $out [format "%-8s %6d %7d %7d %8d %6d %6d %8d %8d %6d %6s %8s %6s" \
            $kind $depth [dict get $result tokens] [dict get $result exprs] \
            [dict get $result front] [dict get $result coreir] [dict get $result tcl] [dict get $result native] \
            $total [dict get $result peak] [dict getdef $result segments -] [dict getdef $result drivers -] $ratio]
        flush $out
        set previous $total
    }
}
if {$out ne "stdout"} {
    close $out
}
