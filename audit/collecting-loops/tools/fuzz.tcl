#!/usr/bin/env tclsh9.0
# fuzz.tcl -- bounded randomized differential check of the collecting loops
# (COLLECTING-LOOPS.md): the four numeric forms and lockstep iteration.
#
#   tclsh9.0 audit/collecting-loops/tools/fuzz.tcl ?-n N? ?-seed S? ?-dump 1?
#
# Four generators, each seeded per program so any failure replays from its
# seed (`-seed S -n 1 -dump 1`):
#
#   numeric    one numeric loop (optionally with a nested one) over random
#              start/end values -- negative, equal, reversed, adjacent, and
#              far beyond i64 -- in each of `from..to`, `from..through`,
#              `down from..to`, `down from..through`, with random
#              continue/break/return in the body. The program's value is
#              compared against an independent Tcl model of the semantics
#              (explicit enumeration of the domain, never the interpreter's
#              own code path) AND across every backend: the reference
#              interpreter, the Tcl compiler, native (specialized) and native
#              generic.
#
#   lockstep   LEGAL lockstep loops built so that every clause provably has
#              the same cardinality (the same N spelled through list_length,
#              a parameter, a constant or a collecting loop, in different
#              numeric forms and offsets); the compiler must accept them, and
#              the result must match the zip model on every backend.
#
#   unequal    the same constructions with one clause's cardinality moved by
#              a nonzero offset: the compiler must REJECT every one at
#              compile time (never run it, never fall back to a runtime
#              check).
#
#   sound      SOUNDNESS: random pairs of numeric/list clauses over two free
#              parameters with arbitrary offsets and forms. Whenever the
#              compiler accepts one, it is run on a grid of parameter values
#              (negative, zero, positive) on the interpreter -- which
#              cross-checks the equal-cardinality proof it was handed and
#              reports an internal error on any mismatch -- and across all
#              backends on a few of them. An accepted program that ever has
#              unequal runtime counts is an unsound proof rule.
#
# The generators are bounded (domains have at most a few dozen elements, one
# level of nesting), so every program finishes quickly.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 100000
set n 200
set seed0 1
set dump 0
set only {}
while {[lindex $args 0] in {-n -seed -dump -only}} {
    switch -- [lindex $args 0] {
        -n { set n [lindex $args 1] }
        -seed { set seed0 [lindex $args 1] }
        -dump { set dump [lindex $args 1] }
        -only { set only [lindex $args 1] }
    }
    set args [lrange $args 2 end]
}

proc pick {list} { return [lindex $list [expr {int(rand() * [llength $list])}]] }
proc chance {p} { return [expr {rand() < $p}] }
proc rnd {lo hi} { return [expr {$lo + int(rand() * ($hi - $lo + 1))}] }

# ---------------------------------------------------------------------------
# Running

proc outcome {kind hir args} {
    if {[catch {
        switch $kind {
            interp  { core::useBackend interp;  set r [core::evalProgram [hir::lower $hir]] }
            compile { core::useBackend compile; set r [core::evalProgram [hir::lower $hir]] }
            native  { set r [native::evalHir $hir {*}$args] }
        }
    } msg opts]} {
        return [list error [dict get $opts -errorcode] $msg]
    }
    return [list value [core::value::show $r 1]]
}

# The outcomes of HIR on every backend.
proc allOutcomes {hir} {
    set prepared [native::prepareHir $hir]
    return [list [outcome interp $hir] [outcome compile $hir] \
        [outcome native $prepared] [outcome native $prepared -specialize 0]]
}

# {ok HIR} or {rejected KIND MESSAGE} for strict compilation of TEXT.
proc compileStrict {text} {
    if {[catch {surface::compile $text fuzz.bot} message options]} {
        set code [dict get $options -errorcode]
        return [list rejected [lindex $code end] $message]
    }
    return [list ok $message]
}

# ---------------------------------------------------------------------------
# Model: the semantics of a numeric domain, by explicit enumeration. This is
# deliberately a second, independent implementation (no shared code with
# core/evaluator.tcl): `through`/`down` are spelled out as the loops a reader
# would write by hand.

proc modelDomain {dir kind start end} {
    set out {}
    set i $start
    if {$dir eq "up"} {
        while {$kind eq "to" ? $i < $end : $i <= $end} {
            lappend out $i
            set i [expr {$i + 1}]
        }
    } else {
        while {$kind eq "to" ? $i > $end : $i >= $end} {
            lappend out $i
            set i [expr {$i - 1}]
        }
    }
    return $out
}

proc formText {dir kind} {
    return [expr {$dir eq "up" ? "from" : "down from"}]
}

# ---------------------------------------------------------------------------
# numeric generator
#
# A numeric program is  fn f(a, b): <loop>  called as f(A, B). A loop spec is
#   {dir kind startSpec endSpec body}
# where a bound spec is {lit N}, {param a|b}, {expr a|b OFFSET} or (inner
# loops only) {outer OFFSET}, and body is {guards value inner} -- guards a
# list of {continue|break|return C}, value {M K} meaning i*M + K, inner an
# optional nested loop whose result is the iteration's value.

proc bigPool {} {
    set big 9223372036854775807
    return [list [expr {$big - 2}] [expr {$big - 1}] $big [expr {$big + 1}] [expr {$big + 2}] \
        [expr {-$big - 1}] [expr {-$big}] [expr {-$big + 1}] [expr {-$big - 2}] \
        4611686018427387902 4611686018427387903 4611686018427387904 4611686018427387905]
}

proc literalValue {} {
    if {[chance 0.12]} { return [pick [bigPool]] }
    return [rnd -4 5]
}

proc boundSpec {outerVar} {
    set r rand()
    set choice [expr {$r}]
    if {$outerVar ne "" && [chance 0.5]} {
        return [list outer [rnd -2 3]]
    }
    switch [rnd 0 2] {
        0 { return [list lit [literalValue]] }
        1 { return [list param [pick {a b}]] }
        2 { return [list expr [pick {a b}] [rnd -2 2]] }
    }
}

proc boundText {spec outerVar} {
    switch [lindex $spec 0] {
        lit { set v [lindex $spec 1]; return [expr {$v < 0 ? "($v)" : $v}] }
        param { return [lindex $spec 1] }
        expr {
            set off [lindex $spec 2]
            return "([lindex $spec 1] [expr {$off < 0 ? "-" : "+"}] [expr {abs($off)}])"
        }
        outer {
            set off [lindex $spec 1]
            return "($outerVar [expr {$off < 0 ? "-" : "+"}] [expr {abs($off)}])"
        }
    }
}

proc boundValue {spec env outer} {
    switch [lindex $spec 0] {
        lit { return [lindex $spec 1] }
        param { return [dict get $env [lindex $spec 1]] }
        expr { return [expr {[dict get $env [lindex $spec 1]] + [lindex $spec 2]}] }
        outer { return [expr {$outer + [lindex $spec 1]}] }
    }
}

proc genLoop {depth} {
    set outerVar [expr {$depth == 0 ? "" : "i"}]
    set dir [pick {up down}]
    set kind [pick {to through}]
    set guards {}
    foreach g {continue break return} p {0.3 0.2 0.08} {
        if {[chance $p]} { lappend guards [list $g [rnd -2 4]] }
    }
    set inner ""
    if {$depth == 0 && [chance 0.3]} {
        set inner [genLoop 1]
    }
    return [list $dir $kind [boundSpec $outerVar] [boundSpec $outerVar] \
        [list $guards [list [pick {1 1 2 -1 3}] [rnd -3 3]] $inner]]
}

proc emitLoop {loop depth outerVar} {
    lassign $loop dir kind startSpec endSpec body
    lassign $body guards value inner
    set var [expr {$depth == 0 ? "i" : "j"}]
    set pad [string repeat "    " [expr {$depth + 1}]]
    set lines {}
    lappend lines "${pad}loop $var [formText $dir $kind] [boundText $startSpec $outerVar] $kind\
        [boundText $endSpec $outerVar]:" 
    foreach g $guards {
        lassign $g what c
        lappend lines "${pad}    if $var == $c:"
        lappend lines "${pad}        [expr {$what eq "return" ? "return $var * 100" : $what}]"
    }
    if {$inner ne ""} {
        lappend lines [emitLoop $inner 1 $var]
    } else {
        lassign $value m k
        lappend lines "${pad}    $var * $m + $k"
    }
    return [join $lines \n]
}

# {RETURNED VALUE} or {LIST ITEMS}: runs LOOP in env ENV (a, b), OUTER the
# enclosing induction value.
proc modelLoop {loop env outer} {
    lassign $loop dir kind startSpec endSpec body
    lassign $body guards value inner
    set start [boundValue $startSpec $env $outer]
    set end [boundValue $endSpec $env $outer]
    set results {}
    foreach i [modelDomain $dir $kind $start $end] {
        set skip 0
        foreach g $guards {
            lassign $g what c
            if {$i != $c} continue
            switch $what {
                continue { set skip 1 }
                break { return [list list $results] }
                return { return [list returned [expr {$i * 100}]] }
            }
            break
        }
        if {$skip} continue
        if {$inner ne ""} {
            set innerResult [modelLoop $inner $env $i]
            if {[lindex $innerResult 0] eq "returned"} { return $innerResult }
            lappend results [list L [lindex $innerResult 1]]
        } else {
            lassign $value m k
            lappend results [expr {$i * $m + $k}]
        }
    }
    return [list list $results]
}

proc showModel {result} {
    if {[lindex $result 0] eq "returned"} {
        return [lindex $result 1]
    }
    return [showList [lindex $result 1]]
}

# Items are integers, `{L ITEMS}` (a nested List) or, for lockstep rows,
# plain Tcl lists of integers.
proc showList {items} {
    return "\[[join [lmap item $items {
        if {[lindex $item 0] eq "L" && [llength $item] == 2} {
            showList [lindex $item 1]
        } elseif {[llength $item] > 1 || $item eq {}} {
            showList $item
        } else {
            set item
        }
    }] {, }]\]"
}

proc genNumeric {} {
    set loop [genLoop 0]
    set a [literalValue]
    set b [literalValue]
    if {[chance 0.7]} {
        # most programs keep both parameters small so loops are nonempty
        set a [rnd -4 5]
        set b [rnd -4 5]
    }
    set text "fn f(a, b):\n[emitLoop $loop 0 {}]\n"
    # A function whose loop may `return` has an int result on that path;
    # keep the program well-typed by returning the loop value otherwise.
    append text "f([expr {$a < 0 ? "($a)" : $a}], [expr {$b < 0 ? "($b)" : $b}])\n"
    set model [showModel [modelLoop $loop [dict create a $a b $b] 0]]
    return [list $text $model]
}

# ---------------------------------------------------------------------------
# lockstep generators
#
# A cardinality NSPEC is {const K}, {param n|m}, {len xs} or {built}; a
# clause for it is chosen from the families that PROVABLY give exactly N
# elements, and (for the `unequal` generator) one clause is shifted by DELTA.

proc nText {nspec} {
    switch [lindex $nspec 0] {
        const { return [lindex $nspec 1] }
        param { return [lindex $nspec 1] }
        len { return "list_length([lindex $nspec 1])" }
    }
}

proc nValue {nspec env} {
    switch [lindex $nspec 0] {
        const { return [lindex $nspec 1] }
        param { return [dict get $env [lindex $nspec 1]] }
        len { return [llength [dict get $env [lindex $nspec 1]]] }
    }
}

# {TEXT ELEMENTS-GIVEN-N-AS-NUMBER VARNAME} of a numeric clause with exactly
# N + DELTA elements for the cardinality text NT.
proc numericClause {var nt delta} {
    set s [rnd -3 4]
    set sText [expr {$s < 0 ? "($s)" : $s}]
    set d $delta
    switch [rnd 0 3] {
        0 {
            # from s to s + N (+DELTA)
            set end "$sText + $nt[offsetText $d]"
            return [list "$var from $sText to $end" up to $s 0 $d]
        }
        1 {
            # from s through s + N - 1 (+DELTA)
            set end "$sText + $nt[offsetText [expr {$d - 1}]]"
            return [list "$var from $sText through $end" up through $s 0 $d]
        }
        2 {
            # down from s + N (+DELTA) to s
            set high "$sText + $nt[offsetText $d]"
            return [list "$var down from $high to $sText" down to $s 0 $d]
        }
        3 {
            # down from s + N - 1 (+DELTA) through s
            set high "$sText + $nt[offsetText [expr {$d - 1}]]"
            return [list "$var down from $high through $sText" down through $s 0 $d]
        }
    }
}

proc offsetText {d} {
    if {$d == 0} { return "" }
    return [expr {$d < 0 ? " - [expr {-$d}]" : " + $d"}]
}

# The elements of numeric clause CLAUSE (from numericClause) when N = NVAL.
proc numericElements {clause nval} {
    lassign $clause text dir kind s unused d
    set count [expr {max($nval + $d, 0)}]
    set out {}
    for {set k 0} {$k < $count} {incr k} {
        lappend out [expr {$dir eq "up" ? $s + $k : $s + $nval + $d - ($kind eq "through" ? 1 : 0) - $k}]
    }
    # the descending forms start at the HIGH end, which numericClause spells
    # as s + N + d (to) or s + N + d - 1 (through)
    return $out
}

# Builds a lockstep program for cardinality NSPEC with CLAUSES clauses. SHIFT
# is {} (legal) or {INDEX DELTA}: clause INDEX is moved by DELTA elements.
# Returns {TEXT MODEL} (MODEL "" when no value is expected).
proc genLockstep {shift} {
    set kinds {const param len built}
    set kind [pick $kinds]
    set env [dict create]
    set setup {}
    set params {}
    set args {}
    switch $kind {
        const { set nspec [list const [rnd 0 5]] }
        param { set nspec [list param n]; set nv [rnd -3 5]; dict set env n $nv; lappend params n; lappend args [expr {$nv < 0 ? "($nv)" : $nv}] }
        len - built {
            set items [lmap k [lrange {10 20 30 40 50 60} 0 [rnd 0 4]] {set k}]
            set nspec [list len xs]
            dict set env xs $items
            lappend params xs
            lappend args "\[[join $items {, }]\]"
            if {$kind eq "built"} {
                lappend setup "    ys = loop x in xs:\n        x + 1"
            }
        }
    }
    set nt [nText $nspec]
    set nval [nValue $nspec $env]
    set count [rnd 2 3]
    set clauses {}
    set elements {}
    set vars {}
    for {set c 0} {$c < $count} {incr c} {
        set var [lindex {p q r} $c]
        set delta 0
        if {$shift ne "" && [lindex $shift 0] == $c} { set delta [lindex $shift 1] }
        set options {numeric numeric}
        if {$kind in {len built}} { lappend options list }
        if {$kind eq "built"} { lappend options built }
        if {$kind eq "const"} { lappend options literal }
        switch [pick $options] {
            numeric {
                set clause [numericClause $var $nt $delta]
                lappend clauses [lindex $clause 0]
                lappend elements [numericElements $clause $nval]
            }
            list {
                # a list clause over xs has exactly length(xs) elements; a
                # shift is expressed by dropping/adding an element via a
                # numeric clause instead (a list cannot be shifted in place)
                if {$delta != 0} {
                    set clause [numericClause $var $nt $delta]
                    lappend clauses [lindex $clause 0]
                    lappend elements [numericElements $clause $nval]
                } else {
                    lappend clauses "$var in xs"
                    lappend elements [dict get $env xs]
                }
            }
            built {
                if {$delta != 0} {
                    set clause [numericClause $var $nt $delta]
                    lappend clauses [lindex $clause 0]
                    lappend elements [numericElements $clause $nval]
                } else {
                    lappend clauses "$var in ys"
                    lappend elements [lmap x [dict get $env xs] {expr {$x + 1}}]
                }
            }
            literal {
                set k [lindex $nspec 1]
                set lit [lmap q [lrange {7 8 9 10 11 12} 0 [expr {$k + $delta - 1}]] {set q}]
                if {$k + $delta < 0} { set lit {} }
                lappend clauses "$var in \[[join $lit {, }]\]"
                lappend elements $lit
            }
        }
        lappend vars $var
    }
    set guard ""
    set skipValue ""
    if {[chance 0.3]} {
        set skipValue [rnd 0 3]
        set guard "        if [lindex $vars 0] == $skipValue:\n            continue\n"
    }
    set tuple "\[[join $vars {, }]\]"
    set text "fn f([join $params {, }]):\n[join $setup \n]"
    if {$setup ne ""} { append text "\n" }
    append text "    loop [join $clauses { and }]:\n$guard        $tuple\nf([join $args {, }])\n"
    # model
    set total [llength [lindex $elements 0]]
    set rows {}
    for {set k 0} {$k < $total} {incr k} {
        set row [lmap e $elements {lindex $e $k}]
        if {$skipValue ne "" && [lindex $row 0] == $skipValue} continue
        lappend rows $row
    }
    return [list $text [showList $rows] $elements]
}

# ---------------------------------------------------------------------------
# soundness generator: two free parameters, arbitrary clauses

proc genSound {} {
    set specs {n m}
    set clauses {}
    set count [rnd 2 3]
    for {set c 0} {$c < $count} {incr c} {
        set var [lindex {p q r} $c]
        set nt [pick {n m n m 3 4}]
        set delta [pick {0 0 0 1 -1 2}]
        if {[chance 0.2]} {
            lappend clauses "$var in xs"
            continue
        }
        set clause [numericClause $var $nt $delta]
        lappend clauses [lindex $clause 0]
    }
    return "fn f(n, m, xs):\n    loop [join $clauses { and }]:\n        p\n"
}

# ---------------------------------------------------------------------------
# Driver

set failures 0
set stats [dict create]
proc bump {key} { dict incr ::stats $key }
proc failure {seed what text details} {
    incr ::failures
    puts "FAILURE seed $seed ($what):\n$text\n$details"
}

proc checkAgree {seed what text outcomes expected} {
    set norm [lmap o $outcomes {lrange $o 0 1}]
    if {[llength [lsort -unique $norm]] != 1} {
        failure $seed "$what: backends disagree" $text [join $outcomes \n]
        return 0
    }
    set first [lindex $outcomes 0]
    if {$expected ne "" && ([lindex $first 0] ne "value" || [lindex $first 1] ne $expected)} {
        failure $seed "$what: model mismatch" $text "expected $expected\n[join $outcomes \n]"
        return 0
    }
    return 1
}

for {set s $seed0} {$s < $seed0 + $n} {incr s} {
    expr {srand($s)}
    switch [expr {$s % 4}] {
        0 { set mode numeric }
        1 { set mode lockstep }
        2 { set mode unequal }
        3 { set mode sound }
    }
    if {$only ne "" && $mode ne $only} continue
    switch $mode {
        numeric {
            lassign [genNumeric] text model
            if {$dump} { puts "--- seed $s numeric\n${text}(expected $model)" }
            lassign [compileStrict $text] status hir
            if {$status ne "ok"} {
                failure $s "numeric: unexpectedly rejected" $text $hir
                continue
            }
            # a body that can `return` is int-typed on that path only; the
            # model already handles it
            set outcomes [allOutcomes $hir]
            if {[checkAgree $s numeric $text $outcomes $model]} { bump numeric-ok }
        }
        lockstep {
            lassign [genLockstep {}] text model
            if {$dump} { puts "--- seed $s lockstep\n${text}(expected $model)" }
            lassign [compileStrict $text] status hir message
            if {$status ne "ok"} {
                failure $s "lockstep: a provably equal loop was rejected" $text "$hir: $message"
                continue
            }
            set outcomes [allOutcomes $hir]
            if {[checkAgree $s lockstep $text $outcomes $model]} { bump lockstep-ok }
        }
        unequal {
            set delta [pick {-2 -1 1 2}]
            lassign [genLockstep [list [rnd 1 1] $delta]] text model elements
            if {$dump} { puts "--- seed $s unequal\n$text" }
            # A shift below zero of an already-empty domain changes nothing
            # (counts clamp at zero): that program is genuinely legal, so it
            # is no test of rejection.
            if {[llength [lsort -unique [lmap e $elements {llength $e}]]] == 1} {
                bump unequal-degenerate-skipped
                continue
            }
            lassign [compileStrict $text] status hir message
            if {$status eq "ok"} {
                failure $s "unequal: an unequal lockstep loop was ACCEPTED" $text ""
                continue
            }
            if {$hir ni {LOCKSTEP-UNEQUAL LOCKSTEP-UNPROVEN}} {
                failure $s "unequal: rejected for the wrong reason" $text "$hir: $message"
                continue
            }
            bump "unequal-rejected-[string tolower $hir]"
        }
        sound {
            set text [genSound]
            if {$dump} { puts "--- seed $s sound\n$text" }
            lassign [compileStrict $text] status hir message
            if {$status ne "ok"} {
                bump sound-rejected
                continue
            }
            bump sound-accepted
            set bad 0
            foreach nv {-3 -1 0 1 2 5} {
                foreach mv {-2 0 1 3 5} {
                    set call "f($nv, $mv, \[1, 2, 3\])"
                    set full "$text$call\n"
                    set callHir [surface::compile [string map {"f(" "f("} $full] fuzz.bot -strict 0]
                    set outcome [outcome interp $callHir]
                    if {[lindex $outcome 0] eq "error" && [string match "*proof was wrong*" [lindex $outcome 2]]} {
                        failure $s "sound: an ACCEPTED lockstep loop has unequal runtime counts at n=$nv m=$mv" $text [lindex $outcome 2]
                        set bad 1
                        break
                    }
                }
                if {$bad} break
            }
            if {!$bad} {
                # a few assignments across all backends
                foreach {nv mv} {2 2 0 0 3 1} {
                    set callHir [surface::compile "${text}f($nv, $mv, \[1, 2, 3\])\n" fuzz.bot -strict 0]
                    if {[hir::diagnostics $callHir] ne ""} continue
                    checkAgree $s sound $text [allOutcomes $callHir] ""
                }
            }
        }
    }
}
puts "programs $n seeds $seed0..[expr {$seed0 + $n - 1}]; stats: $stats; failures $failures"
exit [expr {$failures ? 1 : 0}]
