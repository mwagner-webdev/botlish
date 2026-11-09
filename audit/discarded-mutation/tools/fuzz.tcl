# fuzz.tcl -- generated programs against an independent model of the
# DISCARDED-MUTATION warning (WARNINGS-DISCARDED-MUTATION-MILESTONE-1.md,
# section 16).
#
#   tclsh9.0 audit/discarded-mutation/tools/fuzz.tcl \
#       ?-seed N? ?-count N? ?-backends LIST? ?-verbose 0|1?
#
# Each program is one function over a few MutableVector locals, built from a
# small grammar whose statements state their own relations: a mutation of a
# local (a push in both call spellings, a handled pop whose element is
# dropped or bound, a call of a confined place helper `grow`, a call of a
# place helper `logged` that also changes an installed context), a read of
# a local, an `if` on a parameter of its own (no two conditions share one,
# so every path is feasible), an early `return` reading some locals, and a
# fold over [1, 2, 3] whose body mutates its intermediate or the locals,
# exits with `continue` or `break` under such an `if`, and completes with
# the intermediate or with a fresh vector. The function's value reads a
# subset of the locals.
#
# The model is this file's own and reads the statement tree it generated,
# never the compiler: a backward liveness over the tree for the dead
# mutations -- a mutation is dead when its local is not live after it on any
# path; a local is live at a fold body's end (the next iteration), after a
# `continue` of the fold, and through a `break` into what follows the fold;
# an intermediate is live at the body's end only when the body completes
# with it, and dead after an exit; a `return` reads only its own operands --
# and a forward must-analysis of each fold body for the fold exits (the
# mutations of the intermediate every path to a `continue` or `break` ran;
# a handled pop's own mutation never counts, its handler having run instead
# on some path). A dead mutation is reported when its value is dropped and
# its callee is no `logged`; a mutation an exit reports is not reported
# again.
#
# For every program: the warnings (reason, line, column) equal the model's;
# `-warnings off` attaches none and builds the same HIR (but the side
# table); `-warnings error` rejects exactly the programs with a warning, with
# the first one's code; and every backend runs the program to the same value
# with warnings on and off. Exits 1 on any difference.

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
set options [dict create -seed 1 -count 200 -backends {interp compile} -verbose 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
unset -nocomplain env(BOTLISH_HIR_CACHE)
unset -nocomplain env(BOTLISH_WARNINGS)
source [file join $checkout examples stdlib corpus.tcl]
interp recursionlimit {} 1000000

namespace eval fz {
    variable seed 1
    variable params 24
}

# A deterministic generator (a linear congruential sequence of its own:
# the same seed gives the same programs on every host and Tcl).
proc fz::Rand {n} {
    variable seed
    set seed [expr {($seed * 1103515245 + 12345) % 2147483648}]
    return [expr {($seed / 65536) % $n}]
}

proc fz::Pick {list} {
    return [lindex $list [Rand [llength $list]]]
}

# ---------------------------------------------------------------------------
# The statement tree
#
#   {mut ID VAR FORM}       FORM push | fpush | grow | logged | pop
#   {readpop ID VAR NAME}   NAME = VAR.pop() handled: a mutation whose value is used
#   {read VAR NAME}         NAME = VAR.length()
#   {if PARAM THEN ELSE}    ELSE {} for none
#   {return VARS}           return the sum of VARS' lengths
#   {fold ID NAME BODY COMPLETION}   COMPLETION acc | fresh; NAME the fold's local
#   {exit ID KIND}          KIND continue | break (only in a fold body)
#
# Inside a fold body the intermediate is the variable `acc`.

proc fz::Statements {vars depth inFold budgetVar} {
    upvar 1 $budgetVar budget
    set result {}
    set n [expr {1 + [Rand 4]}]
    for {set i 0} {$i < $n && $budget > 0} {incr i} {
        incr budget -1
        lappend result [Statement $vars $depth $inFold budget]
        if {[lindex $result end 0] in {return exit}} break
    }
    return $result
}

proc fz::Statement {vars depth inFold budgetVar} {
    upvar 1 $budgetVar budget
    variable nextId
    variable nextParam
    variable nextName
    variable params
    set targets $vars
    if {$inFold} {
        lappend targets acc acc acc
    }
    if {!$inFold && $depth == 0 && [Rand 4] == 0} {
        set body [Statements $vars 1 1 budget]
        return [list fold [incr nextId] w[incr nextName] $body [Pick {acc acc fresh}]]
    }
    set roll [Rand 100]
    if {$roll < 40} {
        set form [Pick {push push fpush grow logged pop}]
        return [list mut [incr nextId] [Pick $targets] $form]
    }
    if {$roll < 48} {
        return [list readpop [incr nextId] [Pick $targets] x[incr nextName]]
    }
    if {$roll < 60} {
        return [list read [Pick $targets] r[incr nextName]]
    }
    if {$roll < 82 && $depth < 3 && $nextParam < $params} {
        set p [incr nextParam]
        set then [Statements $vars [expr {$depth + 1}] $inFold budget]
        set else {}
        if {[Rand 3] == 0} {
            set else [Statements $vars [expr {$depth + 1}] $inFold budget]
            if {[lindex $then end 0] in {return exit} && [lindex $else end 0] in {return exit}} {
                # (Keep the code after the if reachable.)
                set else [lrange $else 0 end-1]
            }
        }
        if {$then eq {}} {
            set then [list [list read [Pick $targets] r[incr nextName]]]
        }
        return [list if $p $then $else]
    }
    if {$roll < 88 && $depth > 0} {
        if {$inFold && ($depth == 1 || [Rand 2])} {
            # (A return at a fold body's top level would end the function
            # in the first of the fold's three iterations, which the
            # compiler knows: what follows the fold could not run.)
            return [list exit [incr nextId] [Pick {continue break}]]
        }
        set read {}
        foreach v $vars {
            if {[Rand 2]} { lappend read $v }
        }
        return [list return $read]
    }
    if {$roll < 96 && !$inFold && $depth == 0} {
        set body [Statements $vars 1 1 budget]
        return [list fold [incr nextId] w[incr nextName] $body [Pick {acc acc fresh}]]
    }
    return [list read [Pick $targets] r[incr nextName]]
}

# ---------------------------------------------------------------------------
# Rendering: the source text and each node's line and column

proc fz::Render {tree vars finalVars} {
    variable lines
    variable at
    set lines {}
    set at [dict create]
    variable params
    lappend lines "import std::mutable_vector" \
        "" \
        "opaque context struct Log:" \
        "    lines: MutableVector\[int\]" \
        "" \
        "fn ints() -> MutableVector\[int\]:" \
        "    std::mutable_vector::from_list(\[0\])" \
        "" \
        "fn grow(place v: MutableVector\[int\], n: int):" \
        "    v.push(n)" \
        "" \
        "fn logged(place v: MutableVector\[int\], n: int, context log: Log):" \
        "    v.push(n)" \
        "    log.lines.push(n)" \
        ""
    set ps [lmap i [lrange [Range 1 $params] 0 end] {string cat "p$i: int"}]
    lappend lines "fn f([join $ps {, }], context log: Log) -> int:"
    foreach v $vars {
        lappend lines "    $v = ints()"
    }
    Block $tree 1
    lappend lines "    [Sum $finalVars]"
    lappend lines "" "with context Log {lines: ints()}"
    set args [lmap i [Range 1 $params] {expr {$i % 3}}]
    lappend lines "f([join $args {, }])"
    return [join $lines \n]
}

proc fz::Range {a b} {
    set r {}
    for {set i $a} {$i <= $b} {incr i} { lappend r $i }
    return $r
}

proc fz::Sum {vars} {
    if {$vars eq {}} {
        return 0
    }
    return [join [lmap v $vars {string cat $v ".length()"}] " + "]
}

proc fz::Line {indent text} {
    variable lines
    lappend lines "[string repeat {    } $indent]$text"
    return [list [llength $lines] [expr {4 * $indent + 1}]]
}

proc fz::Block {statements indent} {
    variable at
    foreach s $statements {
        switch -- [lindex $s 0] {
            mut {
                lassign $s - id v form
                switch -- $form {
                    push { dict set at $id [Line $indent "$v.push($id)"] }
                    fpush { dict set at $id [Line $indent "std::mutable_vector::push($v, $id)"] }
                    grow { dict set at $id [Line $indent "grow($v, $id)"] }
                    logged { dict set at $id [Line $indent "logged($v, $id)"] }
                    pop {
                        dict set at $id [Line $indent "$v.pop():"]
                        Line [expr {$indent + 1}] "on IndexNotFound:"
                        Line [expr {$indent + 2}] "-1"
                    }
                }
            }
            readpop {
                lassign $s - id v name
                Line $indent "$name = $v.pop():"
                Line [expr {$indent + 1}] "on IndexNotFound:"
                Line [expr {$indent + 2}] "-1"
            }
            read {
                lassign $s - v name
                Line $indent "$name = $v.length()"
            }
            if {
                lassign $s - p then else
                Line $indent "if p$p > 0:"
                Block $then [expr {$indent + 1}]
                if {$else ne {}} {
                    Line $indent "else:"
                    Block $else [expr {$indent + 1}]
                }
            }
            return {
                Line $indent "return [Sum [lindex $s 1]]"
            }
            exit {
                lassign $s - id kind
                dict set at $id [Line $indent $kind]
            }
            fold {
                lassign $s - id name body completion
                Line $indent "$name = fold x in \[1, 2, 3\] with intermediate acc ints():"
                Block $body [expr {$indent + 1}]
                if {$completion eq "acc"} {
                    Line [expr {$indent + 1}] "acc"
                } else {
                    Line [expr {$indent + 1}] "ints()"
                }
            }
        }
    }
}

# ---------------------------------------------------------------------------
# The model
#
# Live: the backward liveness of a statement list. LIVEOUT the set of
# variables live after it (a dict); CTX the fold context, {} outside a fold,
# else {cont SET brk SET}: what is live after a continue (every local:
# the next iteration) and after a break (what is live after the fold; never the
# intermediate). Records each mutation's deadness in the `dead` array.
# Returns the set live before the list, or "never" when no path completes
# it normally (a return or an exit on every path).

# The locals statement list STATEMENTS refers to, anywhere in it.
proc fz::Refs {statements} {
    set r [dict create]
    foreach s $statements {
        switch -- [lindex $s 0] {
            mut - readpop { dict set r [lindex $s 2] 1 }
            read { dict set r [lindex $s 1] 1 }
            return { foreach v [lindex $s 1] { dict set r $v 1 } }
            if { set r [Union $r [Refs [lindex $s 2]] [Refs [lindex $s 3]]] }
        }
    }
    return $r
}

proc fz::Union {args} {
    set r [dict create]
    foreach s $args {
        if {$s eq "never"} continue
        dict for {k -} $s { dict set r $k 1 }
    }
    return $r
}

proc fz::Live {statements liveOut ctx} {
    variable dead
    set live $liveOut
    foreach s [lreverse $statements] {
        switch -- [lindex $s 0] {
            mut {
                lassign $s - id v
                set dead($id) [expr {![dict exists $live $v]}]
                dict set live $v 1
            }
            readpop {
                lassign $s - id v
                dict set live $v 1
            }
            read {
                dict set live [lindex $s 1] 1
            }
            return {
                set live [dict create]
                foreach v [lindex $s 1] { dict set live $v 1 }
            }
            exit {
                lassign $s - id kind
                if {$kind eq "continue"} {
                    set live [dict get $ctx cont]
                } else {
                    set live [dict get $ctx brk]
                }
            }
            if {
                lassign $s - p then else
                set t [Live $then $live $ctx]
                set e [Live $else $live $ctx]
                set live [Union $t $e]
            }
            fold {
                lassign $s - id name body completion
                # What follows the fold, as the body's break sees it.
                set after [dict remove $live $name]
                set all [dict create]
                foreach v $::fz::vars { dict set all $v 1 }
                set end $all
                if {$completion eq "acc"} {
                    dict set end acc 1
                }
                set inner [Live $body $end [dict create cont $all brk $after]]
                # (A break goes on after the fold, where the locals are
                # live as they are there; a continue, and the body's end,
                # with the next iteration, which may read any local.)
                # Before the fold, a local is live when the fold refers to
                # it (any reference in the body, whatever path reaches it)
                # or it is live after the fold.
                set live [Union [Refs $body] $after]
                dict unset live acc
                dict unset live $name
            }
        }
    }
    return $live
}

# The fold-exit facts of a fold body: the must-set of the intermediate's
# mutations at each exit (the `exits` array: exit id -> mutation ids).
proc fz::Must {statements state} {
    variable exits
    foreach s $statements {
        if {$state eq "top"} {
            return top
        }
        switch -- [lindex $s 0] {
            mut {
                lassign $s - id v form
                if {$v eq "acc" && $form ne "pop"} {
                    # (A handled pop's own mutation: its handler ran
                    # instead on some path.)
                    dict set state $id 1
                }
            }
            return {
                return top
            }
            exit {
                lassign $s - id
                if {[dict size $state] > 0} {
                    set exits($id) [lsort -integer [dict keys $state]]
                }
                return top
            }
            if {
                lassign $s - p then else
                set t [Must $then $state]
                set e [Must $else $state]
                set state [Meet $t $e]
            }
        }
    }
    return $state
}

proc fz::Meet {a b} {
    if {$a eq "top"} { return $b }
    if {$b eq "top"} { return $a }
    set r [dict create]
    dict for {k -} $a {
        if {[dict exists $b $k]} { dict set r $k 1 }
    }
    return $r
}

# The model's warnings of TREE: {REASON LINE:COL} sorted.
proc fz::Predict {tree finalVars} {
    variable dead
    variable exits
    variable at
    array unset dead
    array unset exits
    set out [dict create]
    foreach v $finalVars { dict set out $v 1 }
    Live $tree $out {}
    set result {}
    set reported [dict create]
    foreach s [Folds $tree] {
        lassign $s - id name body
        Must $body [dict create]
    }
    foreach x [array names exits] {
        lassign [dict get $at $x] line col
        lappend result [list fold-exit $line:$col]
        foreach m $exits($x) { dict set reported $m 1 }
    }
    foreach s [Mutations $tree] {
        lassign $s - id v form
        if {$form eq "logged" || [dict exists $reported $id] || !$dead($id)} continue
        lassign [dict get $at $id] line col
        lappend result [list dead $line:$col]
    }
    return [lsort $result]
}

proc fz::Folds {tree} {
    set r {}
    foreach s $tree {
        switch -- [lindex $s 0] {
            fold { lappend r $s }
            if { lappend r {*}[Folds [lindex $s 2]] {*}[Folds [lindex $s 3]] }
        }
    }
    return $r
}

proc fz::Mutations {tree} {
    set r {}
    foreach s $tree {
        switch -- [lindex $s 0] {
            mut { lappend r $s }
            if { lappend r {*}[Mutations [lindex $s 2]] {*}[Mutations [lindex $s 3]] }
            fold { lappend r {*}[Mutations [lindex $s 3]] }
        }
    }
    return $r
}

# ---------------------------------------------------------------------------
# One program

proc fz::Compile {text mode} {
    return [surface::compile $text fuzz.bot -warnings $mode -warning-channel ""]
}

proc fz::Observed {hir} {
    set r {}
    foreach w [hir::warnings::of $hir] {
        if {[dict get $w code] ne "DISCARDED-MUTATION"} continue
        regexp {:(\d+):(\d+)$} [hir::originLocation $hir [dict get $w primary]] -> line col
        lappend r [list [dict get $w data reason] $line:$col]
    }
    return [lsort $r]
}

proc fz::Outcome {backend hir} {
    if {[catch {corpus::run $backend $hir} value options]} {
        return [list error [dict get $options -errorcode]]
    }
    return [list value [core::value::show $value 1]]
}

proc fz::One {i backends} {
    variable nextId 0
    variable nextParam 0
    variable nextName 0
    variable vars {v1 v2 v3}
    set budget 18
    set tree [Statements $vars 0 0 budget]
    if {[lindex $tree end 0] eq "return"} {
        set tree [lrange $tree 0 end-1]
    }
    set finalVars {}
    foreach v $vars {
        if {[Rand 2]} { lappend finalVars $v }
    }
    set text [Render $tree $vars $finalVars]
    set predicted [Predict $tree $finalVars]
    set problems {}
    if {[catch {Compile $text default} on options]} {
        return [list [list compile [dict get $options -errorcode] [string range $on 0 300]] $text $predicted]
    }
    set observed [Observed $on]
    if {$observed ne $predicted} {
        lappend problems [list warnings observed $observed predicted $predicted]
    }
    set off [Compile $text off]
    if {[hir::warnings::of $off] ne ""} {
        lappend problems "off attached warnings"
    }
    if {[dict remove $on warnings] ne [dict remove $off warnings]} {
        lappend problems "the HIR differs between off and default"
    }
    set rejected [catch {Compile $text error} - options]
    set any [expr {[hir::warnings::of $on] ne ""}]
    if {$rejected != $any} {
        lappend problems "error mode rejected $rejected, warnings $any"
    } elseif {$rejected} {
        set first [lindex [hir::warnings::of $on] 0]
        if {[dict get $options -errorcode] ne [list CORE SEMANTIC [dict get $first code]]} {
            lappend problems "error mode raised [dict get $options -errorcode]"
        }
    }
    set outcomes {}
    foreach b $backends {
        lappend outcomes [Outcome $b $on] [Outcome $b $off]
    }
    if {[llength [lsort -unique $outcomes]] != 1} {
        lappend problems [list outcomes $outcomes]
    }
    return [list $problems $text $predicted]
}

set fz::seed [dict get $options -seed]
set failures 0
set warned 0
set reasons [dict create]
for {set i 1} {$i <= [dict get $options -count]} {incr i} {
    lassign [fz::One $i [dict get $options -backends]] problems text predicted
    foreach p $predicted {
        dict incr reasons [lindex $p 0]
    }
    if {$predicted ne {}} {
        incr warned
    }
    if {$problems ne {}} {
        incr failures
        puts "program $i (seed [dict get $options -seed]): $problems"
        puts $text
        puts ""
    } elseif {[dict get $options -verbose]} {
        puts "program $i: $predicted"
    }
}
puts "seed [dict get $options -seed]: [dict get $options -count] programs, $warned with warnings ([join [lmap {k v} $reasons {string cat $k " " $v}] {, }]), $failures failing"
exit [expr {$failures > 0}]
