# lifetime.tcl -- a prototype analysis of foreign-pointer lifetime hazards in
# event-driven Botlish (EVENT-LOOP-EXPLORATION.md, section 8). NOT a compiler
# warning: an audit over the analyzed HIR, to measure what the compiler's
# existing facts can decide.
#
#   tclsh9.0 audit/event-loop/tools/lifetime.tcl FILE.bot ...
#
# The fact it reads is the one a foreign contract has today: an extern's
# pointer result is `independent` (no parameter's alias: owned, or static),
# `alias P`, or -- by default, and for every generated binding -- unknown
# (hir/foreign.tcl's `foreign` side table). A pointer of unknown provenance
# may be a borrow that dies at the next call into its library (SDL_GetError,
# an event's data, a Tcl object's internal rep). Two shapes put such a
# borrow where an event loop would let it dangle:
#
#   deferred  the pointer (or a binding that moved it) is captured by
#             deferred work -- a coroutine construction's thunk, a nested
#             function -- which runs in later turns;
#   suspend   in a function body, the pointer is bound before a statement
#             that may suspend (a call of a yielding function, a yield) and
#             referenced after it: other tasks run in between.
#
# Prints one line per finding ("FILE:LINE:COLUMN: KIND: NAME ...") and exits
# 1 when there is any. A `source`d proc, lifetime::findings, is what
# check.tcl uses.
namespace eval lifetime {}

proc lifetime::UnknownPointerNatives {hir} {
    set out {}
    if {![dict exists $hir foreign]} { return $out }
    dict for {key entry} [dict get $hir foreign] {
        set contract [dict get $entry contract]
        if {[dict get $contract provenance] eq "unknown" && [lindex [dict get $contract result] 0] eq "cptr"} {
            lappend out [dict get $entry native]
        }
    }
    return $out
}

proc lifetime::CalleeName {hir call} {
    set callee [dict get $hir exprs $call callee]
    if {[dict get $hir exprs $callee kind] ne "ref"} { return "" }
    return [dict get $hir exprs $callee name]
}

# Bindings holding an unknown-provenance foreign pointer: bound to such a
# call, or to a reference of such a binding (a move or an alias).
proc lifetime::Tainted {hir} {
    set natives [UnknownPointerNatives $hir]
    set tainted [dict create]
    set changed 1
    while {$changed} {
        set changed 0
        dict for {id x} [dict get $hir exprs] {
            if {[dict get $x kind] ne "bind" || [dict exists $tainted [dict get $x binding]]} continue
            set v [dict get $x value]
            set vx [dict get $hir exprs $v]
            # each tainted binding -> the name of the binding the pointer was
            # first bound to (a construction's argument temporary reports
            # the program's own name)
            if {[dict get $vx kind] eq "call" && [CalleeName $hir $v] in $natives} {
                dict set tainted [dict get $x binding] [dict get $hir bindings [dict get $x binding] name]
                set changed 1
            } elseif {[dict get $vx kind] eq "ref" && [dict exists $vx binding] && [dict exists $tainted [dict get $vx binding]]} {
                dict set tainted [dict get $x binding] [dict get $tainted [dict get $vx binding]]
                set changed 1
            }
        }
    }
    return $tainted
}

proc lifetime::Subtree {hir e} {
    set out [list $e]
    foreach c [hir::children $hir $e] {
        lappend out {*}[Subtree $hir $c]
    }
    return $out
}

# Whether the call E may suspend its coroutine: a yield, or a call of a
# function the coroutine analysis says may yield.
proc lifetime::MaySuspend {hir e} {
    set x [dict get $hir exprs $e]
    if {[dict get $x kind] ne "call"} { return 0 }
    set name [CalleeName $hir $e]
    if {$name eq "coroutine#yield"} { return 1 }
    set callee [dict get $x callee]
    set cx [dict get $hir exprs $callee]
    if {[dict get $cx kind] ne "ref" || ![dict exists $cx binding]} { return 0 }
    set b [dict get $cx binding]
    if {![dict exists $hir bindings $b declaredBy]} { return 0 }
    set decl [dict get $hir bindings $b declaredBy]
    if {$decl eq "" || ![dict exists $hir exprs $decl value]} { return 0 }
    set block [dict get $hir exprs $decl value]
    return [expr {[dict exists $hir coroutines mayYield $block] && [dict get $hir coroutines mayYield $block]}]
}

proc lifetime::Where {hir e} {
    set o [dict get $hir exprs $e origin]
    set file [dict getdef [dict getdef $hir files {}] [dict get $o file] [dict get $o file]]
    return "[file tail $file]:[dict get $o line]:[dict get $o column]"
}

proc lifetime::findings {hir} {
    set tainted [Tainted $hir]
    set out {}
    set thunks [expr {[dict exists $hir coroutines thunks] ? [dict keys [dict get $hir coroutines thunks]] : {}}]
    dict for {id x} [dict get $hir exprs] {
        if {[dict get $x kind] ne "block"} continue
        # deferred: a capture of a tainted binding
        foreach b [dict get $x captures] {
            if {[dict exists $tainted $b]} {
                set what [expr {$id in $thunks ? "a coroutine construction (a task: it runs in later turns)" : "a nested function"}]
                lappend out "[Where $hir $id]: deferred: [dict get $tainted $b] (an unknown-provenance foreign pointer) is captured by $what"
            }
        }
        # suspend: bound before a statement that may suspend, used after it
        set body [dict get $x body]
        set n [llength $body]
        for {set i 0} {$i < $n} {incr i} {
            set s [lindex $body $i]
            set sx [dict get $hir exprs $s]
            if {[dict get $sx kind] ne "bind" || ![dict exists $tainted [dict get $sx binding]]} continue
            set b [dict get $sx binding]
            set suspended ""
            for {set j [expr {$i + 1}]} {$j < $n} {incr j} {
                set later [Subtree $hir [lindex $body $j]]
                set uses [lmap e $later {
                    set ex [dict get $hir exprs $e]
                    expr {[dict get $ex kind] eq "ref" && [dict exists $ex binding] && [dict get $ex binding] eq $b ? $e : [continue]}
                }]
                if {$uses ne "" && $suspended ne ""} {
                    lappend out "[Where $hir [lindex $uses 0]]: suspend: [dict get $hir bindings $b name] (an unknown-provenance foreign pointer) is used after [Where $hir $suspended], which may suspend"
                    break
                }
                foreach e $later {
                    if {[MaySuspend $hir $e]} { set suspended $e; break }
                }
            }
        }
    }
    return [lsort -unique $out]
}

if {[info exists argv0] && [file normalize $argv0] eq [file normalize [info script]]} {
    set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
    set files $argv
    set argv {}
    source [file join $root tests helpers.tcl]
    source [file join $root surface surface.tcl]
    set any 0
    foreach f $files {
        set hir [surface::readProgramFile $f -warnings off]
        foreach line [lifetime::findings $hir] {
            puts $line
            set any 1
        }
    }
    exit $any
}
