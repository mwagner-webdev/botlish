#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized equivalence check of `elif` (ELIF.md).
#
#   tclsh9.0 audit/elif/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1? ?-backends LIST?
#
# Each program is generated once as a tree of if chains and printed twice:
#
#   A   with `elif` clauses
#   B   with the explicitly right-nested `else:` / `if` spelling of the same
#       tree
#
# `elif` is surface syntax for exactly that nesting, so on every backend the
# two spellings must produce the identical outcome: value (with runtime
# evidence), error code (error messages, which carry source locations, are
# compared with the locations removed) and the log the program kept of its own
# evaluation order. Within one spelling every backend must also agree with the
# others (the usual interpreter / compile / native-generic / native parity).
#
# The trees are random in:
#
#   chain length       1..6 clauses, with or without a final `else`
#   conditions         Boolean parameters, comparisons on an Int parameter,
#                      not / and / or, constants, the loop counter, and
#                      `probe(...)` calls that record that they were evaluated
#   branch bodies      literals, parameter arithmetic, effect probes, a nested
#                      chain in statement position, a nested chain bound to a
#                      name or returned, `return`, `fail` (handled by the
#                      caller) and, inside a loop, `continue` / `break`
#   nesting            up to three levels, `elif` chains inside branches of
#                      `elif` chains
#   position           statement, `v = chain`, `return chain`
#
# The log is a one-slot MutableArray read as a decimal number: every probe
# appends its own digit, so the number records which conditions and bodies ran
# and in which order -- the only evaluation-order observation the language has
# that every backend (native included) can run.
#
# Every program is seeded individually, so any failure replays with
# `-seed S -n 1 -dump 1`. The run ends with a summary line
# "elif-fuzz programs N values V errors E equivalence-disagreements D
# backend-disagreements B"; the exit status is 1 if D or B is not zero.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 100000

set n 100
set seed0 1
set dump 0
set backends {interp compile cranelift-generic cranelift}
while {[lindex $args 0] in {-n -seed -dump -backends}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -dump { set dump [lindex $args 1] }
        -backends { set backends [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc rnd {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

# ---------------------------------------------------------------------------
# Generator. A program body is a list of statements; a statement is one of
#
#   {text LINE}                       one line of source
#   {chain CHAIN POSITION NAME}       an if chain; POSITION is stmt | bind | return
#
# and a CHAIN is {conds {C...} bodies {BODY...} else BODY|none}.

set ::probeId 0
set ::tempId 0
set ::probes 0

proc nextProbe {} {
    set ::probeId [expr {$::probeId % 9 + 1}]
    incr ::probes
    return $::probeId
}

proc genCond {ctx} {
    set choices {p q r {not p} {p and q} {q or r} {x < 3} {x == 5} {x > 4} true false}
    if {$ctx eq "loop"} {
        lappend choices {i < 2} {i == 1}
    }
    switch -- [rnd 0 4] {
        0 { return "probe(log, [nextProbe], [pick {p q r}])" }
        1 { return "probe(log, [nextProbe], x [pick {< ==  >}] [rnd 2 6])" }
        default { return [pick $choices] }
    }
}

proc genValue {scope} {
    set choices [list [rnd 0 99] [rnd 0 99] "x + [rnd 1 9]"]
    foreach name $scope {
        lappend choices "$name + [rnd 1 9]"
    }
    return [pick $choices]
}

# A branch body: some effect/binding statements, then a final statement.
proc genBody {depth ctx scope} {
    set body {}
    set count [rnd 0 2]
    for {set i 0} {$i < $count} {incr i} {
        switch -- [rnd 0 3] {
            0 { lappend body [list text "probe(log, [nextProbe], true)"] }
            1 {
                if {$depth < 3} {
                    lappend body [list chain [genChain [expr {$depth + 1}] $ctx $scope] stmt ""]
                } else {
                    lappend body [list text "probe(log, [nextProbe], true)"]
                }
            }
            2 {
                set name t[incr ::tempId]
                if {$depth < 3} {
                    lappend body [list chain [genChain [expr {$depth + 1}] $ctx $scope] bind $name]
                } else {
                    lappend body [list text "$name = [genValue $scope]"]
                }
                lappend scope $name
            }
            3 {
                set name t[incr ::tempId]
                lappend body [list text "$name = [genValue $scope]"]
                lappend scope $name
            }
        }
    }
    set final [rnd 0 11]
    if {$final < 5} {
        lappend body [list text [genValue $scope]]
    } elseif {$final < 7} {
        lappend body [list text "return [genValue $scope]"]
    } elseif {$final < 8 && $depth < 3} {
        lappend body [list chain [genChain [expr {$depth + 1}] $ctx $scope] return ""]
    } elseif {$final < 9} {
        lappend body [list text "fail Boom"]
    } elseif {$ctx eq "loop" && $final < 11} {
        lappend body [list text [pick {continue break}]]
    } else {
        lappend body [list text [genValue $scope]]
    }
    return $body
}

proc genChain {depth ctx scope} {
    set clauses [rnd 1 6]
    if {$depth > 1} {
        set clauses [rnd 1 3]
    }
    set conds {}
    set bodies {}
    for {set i 0} {$i < $clauses} {incr i} {
        lappend conds [genCond $ctx]
        lappend bodies [genBody $depth $ctx $scope]
    }
    set else none
    if {[chance 0.7]} {
        set else [genBody $depth $ctx $scope]
    }
    return [dict create conds $conds bodies $bodies else $else]
}

# ---------------------------------------------------------------------------
# Printing, in either spelling.

proc pad {indent} { return [string repeat {    } $indent] }

# Lines of BODY (a list of statements) at INDENT.
proc emitBody {body style indent} {
    set lines {}
    foreach statement $body {
        switch -- [lindex $statement 0] {
            text { lappend lines "[pad $indent][lindex $statement 1]" }
            chain {
                lassign $statement - chain position name
                set prefix [dict get {stmt {} bind "NAME = " return "return "} $position]
                set prefix [string map [list NAME $name] $prefix]
                lappend lines {*}[emitChain $chain $style $indent $prefix]
            }
        }
    }
    return $lines
}

# Lines of CHAIN at INDENT, its first line starting with PREFIX.
proc emitChain {chain style indent prefix} {
    set conds [dict get $chain conds]
    set bodies [dict get $chain bodies]
    set else [dict get $chain else]
    set lines {}
    if {$style eq "elif"} {
        for {set i 0} {$i < [llength $conds]} {incr i} {
            set keyword [expr {$i == 0 ? "${prefix}if" : "elif"}]
            lappend lines "[pad $indent]$keyword [lindex $conds $i]:"
            lappend lines {*}[emitBody [lindex $bodies $i] $style [expr {$indent + 1}]]
        }
        if {$else ne "none"} {
            lappend lines "[pad $indent]else:"
            lappend lines {*}[emitBody $else $style [expr {$indent + 1}]]
        }
        return $lines
    }
    # Right-nested: each further clause is an `if` alone in the previous
    # clause's `else:` suite.
    set level $indent
    for {set i 0} {$i < [llength $conds]} {incr i} {
        set keyword [expr {$i == 0 ? "${prefix}if" : "if"}]
        lappend lines "[pad $level]$keyword [lindex $conds $i]:"
        lappend lines {*}[emitBody [lindex $bodies $i] $style [expr {$level + 1}]]
        if {$i < [llength $conds] - 1 || $else ne "none"} {
            lappend lines "[pad $level]else:"
            incr level
        }
    }
    if {$else ne "none"} {
        lappend lines {*}[emitBody $else $style $level]
    }
    return $lines
}

# The whole program for the generated function bodies, in STYLE.
proc program {kind chain position style} {
    set head {
        error Boom
        fn probe(log, id, result):
            if mutable_array::capacity(log) == 1:
                mutable_array::set(log, 0, mutable_array::at(log, 0) * 10 + id)
            result
    }
    set lines {}
    foreach line [split [string trim $head] \n] {
        lappend lines [regsub {^        } $line {}]
    }
    set prefix [dict get {stmt {} bind "v = " return "return "} $position]
    if {$kind eq "loop"} {
        lappend lines "fn work(log, p, q, r, x) errors Boom:"
        lappend lines "    loop i from 0 to 3:"
        lappend lines {*}[emitChain $chain $style 2 ""]
        lappend lines "    probe(log, 9, true)"
        lappend lines "    x"
    } else {
        lappend lines "fn work(log, p, q, r, x) errors Boom:"
        if {$position eq "bind"} {
            lappend lines {*}[emitChain $chain $style 1 "v = "]
            lappend lines "    v"
        } else {
            lappend lines {*}[emitChain $chain $style 1 $prefix]
        }
    }
    lappend lines {fn driver(p, q, r, x):}
    lappend lines {    log = mutable_array::allocate(1)}
    lappend lines {    mutable_array::set(log, 0, 0)}
    lappend lines {    v = work(log, p, q, r, x):}
    lappend lines {        on Boom:}
    lappend lines {            -7}
    lappend lines {    [v, mutable_array::at(log, 0)]}
    lappend lines {[driver(true, false, true, 3), driver(false, true, false, 7), driver(false, false, true, 5),}
    lappend lines { driver(false, false, false, 1), driver(true, true, true, 9), driver(false, true, true, 4)]}
    return [join $lines \n]
}

# ---------------------------------------------------------------------------
# Running

# Outcome of SOURCE on BACKEND with error locations removed, or a compile-time
# error {error CODE MESSAGE} (static diagnostics are outcomes too: both
# spellings must be rejected for the same reason).
proc outcomeOf {backend source} {
    if {[catch {surface::compile $source t.bot} hir options]} {
        return [list error [dict get $options -errorcode] [stripLocations $hir]]
    }
    set outcome [outcomeUnderHir $backend $hir]
    if {[lindex $outcome 0] eq "error"} {
        lset outcome 2 [stripLocations [lindex $outcome 2]]
    }
    return $outcome
}

proc stripLocations {message} {
    return [regsub -all {t\.bot:[0-9]+:[0-9]+} $message {t.bot:L:C}]
}

set programs 0
set values 0
set errors 0
set equivalenceDisagreements 0
set backendDisagreements 0

for {set k 0} {$k < $n} {incr k} {
    set seed [expr {$seed0 + $k}]
    expr {srand($seed)}
    set ::probeId 0
    set ::tempId 0
    set kind [pick {fn fn fn loop}]
    set position [pick {stmt stmt bind return}]
    set chain [genChain 1 [expr {$kind eq "loop" ? "loop" : "fn"}] {}]
    if {$kind eq "loop"} {
        set position stmt
    }
    set sourceA [program $kind $chain $position elif]
    set sourceB [program $kind $chain $position nested]
    if {$dump} {
        puts "---- seed $seed ($kind, $position)\n$sourceA\n-- nested --\n$sourceB"
    }
    incr programs
    set outcomesA {}
    set outcomesB {}
    foreach backend $backends {
        lappend outcomesA [outcomeOf $backend $sourceA]
        lappend outcomesB [outcomeOf $backend $sourceB]
    }
    if {$outcomesA ne $outcomesB} {
        incr equivalenceDisagreements
        puts "EQUIVALENCE DISAGREEMENT seed $seed ($kind, $position)"
        foreach backend $backends a $outcomesA b $outcomesB {
            if {$a ne $b} {
                puts "  $backend: elif   $a\n  $backend: nested $b"
            }
        }
    }
    if {[llength [lsort -unique $outcomesA]] > 1} {
        incr backendDisagreements
        puts "BACKEND DISAGREEMENT seed $seed ($kind, $position)"
        foreach backend $backends a $outcomesA {
            puts "  $backend: $a"
        }
    }
    if {[lindex $outcomesA 0 0] eq "value"} {
        incr values
    } else {
        incr errors
        puts "note: seed $seed ($kind, $position) is an error outcome on both spellings: [lrange [lindex $outcomesA 0] 0 1]"
    }
}
puts "elif-fuzz programs $programs values $values errors $errors equivalence-disagreements $equivalenceDisagreements backend-disagreements $backendDisagreements"
exit [expr {$equivalenceDisagreements || $backendDisagreements ? 1 : 0}]
