#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized differential check of the raw Int ABI
# (RAW-INT-ABI.md). Generates programs of closed Int helpers (one to three
# parameters, nested arithmetic, branches, exact calls of earlier helpers,
# decreasing self recursion, small and huge literals, negative values, and a
# runtime-dependent error from `mod`) and compares the interpreter, the Tcl
# compile backend and native with the ABI off and on, with leaf inlining off
# and on. Any disagreement is printed with its program.
#
#   tclsh9.0 audit/raw-int-abi/tools/fuzz.tcl ?-n N? ?-seed S?
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 100000
set n 100
set seed0 1
while {[lindex $args 0] in {-n -seed}} {
    if {[lindex $args 0] eq "-n"} { set n [lindex $args 1] } else { set seed0 [lindex $args 1] }
    set args [lrange $args 2 end]
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }

# A literal expression: small, negative, near the small-Int limit, or beyond it.
proc literal {} {
    set v [pick {0 1 2 3 5 7 11 100 1000 4611686018427387903 4611686018427387904 -1 -9 -4611686018427387904}]
    return [expr {$v < 0 ? "(0 - [expr {-$v}])" : $v}]
}

proc term {vars} {
    if {$vars ne "" && rand() < 0.55} { return [pick $vars] }
    return [literal]
}

proc expression {vars depth} {
    if {$depth == 0} { return [term $vars] }
    set op [pick {+ - * + -}]
    return "([expression $vars [expr {$depth - 1}]] $op [expression $vars [expr {$depth - 1}]])"
}

# Like `expression` without multiplication: a recursive helper feeds its
# non-measure arguments back into itself, and a product there makes the value
# grow exponentially with the recursion depth (seed 100262 of the older
# generator computed an Int of ~10^20 digits, seed 200167 one of 28 million:
# correct but not terminating in any backend -- audit/raw-int-abi/out/fuzz-hangs).
proc linexpression {vars depth} {
    if {$depth == 0} { return [term $vars] }
    set op [pick {+ - + -}]
    return "([linexpression $vars [expr {$depth - 1}]] $op [linexpression $vars [expr {$depth - 1}]])"
}

proc program {} {
    set lines {}
    set nfun [expr {2 + int(rand() * 4)}]
    array unset ::arity
    array unset ::recursive
    for {set i 1} {$i <= $nfun} {incr i} {
        set arity [expr {1 + int(rand() * 3)}]
        set vars [lrange {a b c} 0 [expr {$arity - 1}]]
        set kind [pick {plain plain plain branch recursive modular}]
        set body [expression $vars 2]
        if {$i > 1 && rand() < 0.7} {
            set callee [expr {1 + int(rand() * ($i - 1))}]
            set cargs [lmap _ [lrange {a b c} 0 [expr {$::arity($callee) - 1}]] {expression $vars 1}]
            if {[info exists ::recursive($callee)]} {
                # a bounded measure: calls of a recursive helper recurse a few levels only
                set cargs [lreplace $cargs 0 0 "mod([lindex $cargs 0], 9)"]
            }
            set body "$body + f${i}x[expr {$callee}]([join $cargs {, }])"
            set body [string map [list "f${i}x$callee" "f$callee"] $body]
        }
        switch $kind {
            branch {
                set body "if [pick $vars] < [term {}]:\n        $body\n    else:\n        [expression $vars 1]"
            }
            recursive {
                set k [pick {1 2 3}]
                set step [pick {1 1 2}]
                set measure [lindex $vars 0]
                set rest [lrange $vars 1 end]
                set recArgs [join [concat [list "$measure - $step"] [lmap v $rest {linexpression $vars 1}]] {, }]
                set body "if $measure < $k:\n        [expression $vars 1]\n    else:\n        f${i}($recArgs) + $body"
                set ::recursive($i) 1
            }
            modular {
                set body "mod(100, [pick $vars] - [pick {0 1 2 3 5}]) + $body"
            }
        }
        set ::arity($i) $arity
        lappend lines "fn f${i}([join $vars {, }]):\n    $body\n"
    }
    set calls {}
    for {set i 1} {$i <= $nfun} {incr i} {
        foreach base {5 0 -3 100 7} {
            set cargs [lmap _ [lrange {a b c} 0 [expr {$::arity($i) - 1}]] {
                set v [pick [list $base [expr {$base + 2}] [expr {$base * 7}] 1 2]]
                expr {$v < 0 ? "(0 - [expr {-$v}])" : $v}
            }]
            lappend calls "f${i}([join $cargs {, }])"
        }
    }
    # the last call alone, so an erroring helper is isolated
    return "[join $lines \n]\n[pick $calls]\n"
}

proc outcome {kind hir args} {
    if {[catch {
        switch $kind {
            interp  { core::useBackend interp;  set r [core::evalProgram [hir::lower $hir]] }
            compile { core::useBackend compile; set r [core::evalProgram [hir::lower $hir]] }
            native  { set r [native::evalHir $hir {*}$args] }
        }
    } msg opts]} {
        return [list error [dict get $opts -errorcode]]
    }
    return [list value [core::value::show $r 1]]
}

set bad 0
set kinds [dict create]
for {set s $seed0} {$s < $seed0 + $n} {incr s} {
    expr {srand($s)}
    set text [program]
    set dir [file join [pwd] .fuzz-raw-int-abi]
    file mkdir $dir
    set path [file join $dir p$s.bot]
    set ch [open $path w]; puts $ch $text; close $ch
    if {[catch {set hir [surface::readProgramFile $path]} err]} {
        file delete $path
        continue
    }
    file delete $path
    set outcomes [list [outcome interp $hir] [outcome compile $hir]]
    set prepared [native::prepareHir $hir]
    # Tagged ABI, eligibility-only RawInt, RawInt + demand suppression.
    foreach {abi demand} {0 1 1 0 1 1} {
        foreach inline {0 1} {
            lappend outcomes [outcome native $prepared -raw-int-abi-opt $abi -raw-demand-opt $demand -tiny-leaf-inline-opt $inline]
        }
    }
    dict incr kinds [lindex [lindex $outcomes 0] 0]
    set nir [native::nir $prepared -raw-int-abi-opt 1 -tiny-leaf-inline-opt 0]
    if {[regexp {rawparams=|rawresult=1} $nir]} { dict incr kinds uses-raw-abi }
    if {[regexp {rawparams=\S* rawresult=1} $nir] || [regexp {rawresult=1} $nir]} { dict incr kinds raw-result }
    if {[llength [lsort -unique $outcomes]] != 1} {
        incr bad
        puts "DISAGREEMENT seed $s:\n$text\n[join $outcomes \n]"
    }
}
file delete -force [file join [pwd] .fuzz-raw-int-abi]
puts "programs [expr {$n}] (value/error: $kinds); disagreements $bad"
exit [expr {$bad ? 1 : 0}]
