# warnings.tcl -- compiler warnings: proof-backed diagnostics over analyzed HIR
# (WARNINGS-SAME-RETURN.md).
#
#   hir::warnings::run HIR MODE ?CHANNEL?    HIR with its warnings attached
#   hir::warnings::of HIR                    the warnings run attached
#   hir::warnings::collect HIR               discover every warning (no policy)
#   hir::warnings::render HIR WARNING        diagnostic text
#
# A warning states a *semantic fact the compiler can prove* about a program
# that is perfectly legal -- never a style rule. It has a stable CODE, a
# neutral message, a primary origin and secondary (related) origins, and
# optional structured data. It prescribes no rewrite: what to do about the
# fact is the programmer's call, and a program that keeps the fact on purpose
# is correct.
#
# Four separate concerns, each in one place:
#
#   discovery   a *pass* (SameReturnValue below) reads analyzed HIR and
#               returns warning records. It does not know whether warnings
#               are shown, suppressed or promoted to errors, and never
#               changes HIR.
#   identity    a record's CODE ("SAME-RETURN-VALUE"), stable across
#               releases: for tests, tooling and documentation. There are
#               no per-code switches.
#   policy      ONE global MODE per compilation, passed explicitly (never
#               process-global state), decides what discovery's result means:
#                 default   warnings are collected, attached to the HIR and
#                           emitted as warnings
#                 off       nothing is discovered: no warning pass runs
#                 error     the first warning is raised as a compilation
#                           error carrying the warning's own code
#               Botlish deliberately has no -Wfoo/-Wno-foo/-Werror=foo, no
#               groups (-Wall), no levels and no source suppression: a
#               warning that is not trustworthy enough to be on for everyone
#               does not belong in the compiler.
#   emission    render (text) and emit (a channel, stderr by default); the
#               program's own output channels are never written to.
#
# Warnings are diagnostics over facts the compilation already has. They are
# computed after hir::check, before any backend runs, from the generic
# (source-level) HIR, so every backend sees the same warnings; they are
# attached to HIR as the side table `warnings`, which no analysis, lowering or
# backend reads, and which hir::format does not print.

namespace eval hir::warnings {
    # The static pass registry: CODE -> pass command. A pass is called as
    # `PASS hir` and returns a list of warning records. Adding a warning is
    # one entry here plus its pass; there is no dynamic registration.
    variable passes {
        SAME-RETURN-VALUE hir::warnings::SameReturnValue
    }
    variable modes {default off error}
    # CODE -> number of times its pass has run in this process: test
    # instrumentation that lets a test prove `off` runs no warning pass.
    variable stats [dict create]
}

# ---------------------------------------------------------------------------
# The warning record
#
#   code       stable CODE
#   message    neutral text, without the code or a location
#   primary    origin the warning is anchored at
#   secondary  related origins, in source order
#   data       dict of structured, pass-specific facts

proc hir::warnings::New {code message primary secondary {data {}}} {
    return [dict create code $code message $message primary $primary \
        secondary $secondary data $data]
}

# The warnings a run attached to HIR ({} when warnings were off or none).
proc hir::warnings::of {hir} {
    return [expr {[dict exists $hir warnings] ? [dict get $hir warnings] : {}}]
}

proc hir::warnings::stats {} {
    variable stats
    return $stats
}

proc hir::warnings::resetStats {} {
    variable stats
    set stats [dict create]
}

# ---------------------------------------------------------------------------
# Policy

# The mode a compilation that was not given one runs under: the environment's
# BOTLISH_WARNINGS (default, off or error) -- the host's configuration, read
# fresh by each compilation, never compiler state -- else `default`. An
# explicit per-compilation option always wins. The test suite's harness sets
# it to `off` (tests/helpers.tcl) so that programs which are not the subject
# of a test do not write to stderr; tests of warnings pass their policy
# explicitly.
proc hir::warnings::defaultMode {} {
    if {[info exists ::env(BOTLISH_WARNINGS)] && $::env(BOTLISH_WARNINGS) ne ""} {
        return $::env(BOTLISH_WARNINGS)
    }
    return default
}

# MODE normalized (the one place a mode is validated).
proc hir::warnings::Mode {mode} {
    variable modes
    if {$mode ni $modes} {
        error "unknown warnings mode \"$mode\" (known: [join $modes {, }])"
    }
    return $mode
}

# Applies the global policy MODE to HIR: discovery (collect) happens only
# when warnings are on, and only for a program with no error diagnostics (a
# program the compiler rejects has no trustworthy facts to warn from).
#
#   ""       the environment's default mode (defaultMode)
#   off      HIR unchanged; no warning pass runs
#   default  HIR with `warnings` attached; each warning emitted to CHANNEL
#            (stderr unless given; "" collects without emitting)
#   error    the first warning raised as {CORE SEMANTIC CODE}
proc hir::warnings::run {hir mode {channel stderr}} {
    if {$mode eq ""} {
        set mode [defaultMode]
    }
    if {[Mode $mode] eq "off" || [dict get $hir diagnostics] ne ""} {
        return $hir
    }
    set warnings [collect $hir]
    if {$mode eq "error" && $warnings ne ""} {
        Raise $hir [lindex $warnings 0]
    }
    dict set hir warnings $warnings
    if {$channel ne ""} {
        foreach warning $warnings {
            puts $channel [render $hir $warning]
        }
    }
    return $hir
}

# Every warning of HIR, deterministically ordered, whatever the policy: the
# discovery half. Callers that must honor a policy call `run`.
proc hir::warnings::collect {hir} {
    variable passes
    variable stats
    set warnings {}
    dict for {code pass} $passes {
        dict incr stats $code
        lappend warnings {*}[$pass $hir]
    }
    return [Sort $hir $warnings]
}

# Source order of the primary origin, then code, then message: never the
# order a pass or a dictionary happened to produce them in.
proc hir::warnings::Sort {hir warnings} {
    set keyed [lmap w $warnings {list [OriginKey [dict get $w primary]] $w}]
    return [lmap pair [lsort -command KeyCompare $keyed] {lindex $pair 1}]
}

proc hir::warnings::OriginKey {origin} {
    if {[lindex $origin 0] eq "file"} {
        set fields [lrange $origin 2 end]
        return [list 0 [string range [lindex $origin 1] 1 end] \
            [dict get $fields line] [dict get $fields column] [dict get $fields start]]
    }
    return [list 1 0 0 0 $origin]
}

proc hir::warnings::KeyCompare {a b} {
    lassign $a ka wa
    lassign $b kb wb
    foreach x $ka y $kb {
        if {[string is integer -strict $x] && [string is integer -strict $y]} {
            if {$x != $y} {
                return [expr {$x < $y ? -1 : 1}]
            }
        } else {
            set c [string compare $x $y]
            if {$c} {
                return $c
            }
        }
    }
    foreach field {code message} {
        set c [string compare [dict get $wa $field] [dict get $wb $field]]
        if {$c} {
            return $c
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Emission

# "warning: MESSAGE (CODE)" at the primary location, one "note:" line per
# secondary location -- the shape of main.tcl's own "error: ... (KIND)".
proc hir::warnings::render {hir warning} {
    set lines [list "[hir::originLocation $hir [dict get $warning primary]]: warning: [dict get $warning message] ([dict get $warning code])"]
    set note [expr {[dict exists $warning data note] ? [dict get $warning data note] : "related location"}]
    foreach origin [dict get $warning secondary] {
        lappend lines "[hir::originLocation $hir $origin]: note: $note"
    }
    return [join $lines \n]
}

# Raises WARNING as a compilation error. Its identity is its own code
# ({CORE SEMANTIC SAME-RETURN-VALUE}); the message is the warning's, located
# like any semantic error, with the related locations after it.
proc hir::warnings::Raise {hir warning} {
    set text "[hir::originLocation $hir [dict get $warning primary]]: [dict get $warning message]"
    if {[dict get $warning secondary] ne ""} {
        append text " (also at [join [lmap o [dict get $warning secondary] {hir::originLocation $hir $o}] {, }])"
    }
    core::semanticError [dict get $warning code] $text
}

# ---------------------------------------------------------------------------
# SAME-RETURN-VALUE
#
# Several distinct, reachable exits of one function return one proven value.
#
# Exits of a function (a `block`) are its *terminal completions*:
#   * every reachable `return` whose target is the function, wherever it sits
#     in the body (inside loops, branches and handlers included), and
#   * the function's final-expression value: the body's last expression, or --
#     when that is a written `if`/`elif`/`else` -- the last expression of each
#     reachable branch, recursively. A function that falls off its end
#     completes exactly like one that returned there, so these are exits too.
# An `if` the frontend synthesizes for `a and b`, `a or b`, `not a` and
# `a != b` (both branches carry the one origin of the operator) is a single
# expression, not branches the programmer wrote: it is never opened.
#
# An exit is a *source operation*: reaching it through several control-flow
# predecessors is still one exit. Returns of a nested function belong to that
# function, which is checked on its own.
#
# Two exits return the same value when hir::exact::Identity proves it:
# structurally equal exact values (through immutable aliases), or the same
# alias root binding (any immutable binding, a mutable value's binding
# included). Anything else -- a call (however identical it looks), two
# constructions of a mutable value, a parameter-dependent expression -- has no
# identity and is never grouped.
#
# An exit counts only if it can execute: HIR's structural reachability
# (statically decided branches, code after a completion that cannot finish)
# and then, for a function that would warn, the completion proof's own walk
# (hir::completions::reachedExprs), which also prunes branches its range facts
# prove infeasible. Neither can add an exit; "unknown" keeps it.
#
# Exits are grouped by identity: a value returned from N >= 2 exits yields ONE
# warning anchored at the first exit (source order) with the other exits as
# secondary locations; each repeated value of a function is its own warning.
#
# `unit` is never reported: a procedural function with several unit exits
# collapses no interesting domain information, only noise.
#
# Scope: this reads the generic, source-level HIR once per source function,
# so a function specialized into any number of semantic instances is still
# one warning, and only an equality the source analysis itself proves is
# reported -- never one proven by a single instance.

proc hir::warnings::SameReturnValue {hir} {
    set names [BlockNames $hir]
    set warnings {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "block" || ![dict get $node reachable]} {
            continue
        }
        lappend warnings {*}[SameReturnValueIn $hir $e [expr {[dict exists $names $e] ? [dict get $names $e] : ""}]]
    }
    return $warnings
}

# BlockExprId -> the name it is bound to, where it is bound to one.
proc hir::warnings::BlockNames {hir} {
    set names [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "bind"
                && [dict get $hir exprs [dict get $node value] kind] eq "block"} {
            dict set names [dict get $node value] [dict get $node name]
        }
    }
    return $names
}

proc hir::warnings::SameReturnValueIn {hir block name} {
    set exits [Exits $hir $block]
    # Cheap first: candidate groups from identity alone.
    if {![HasRepeat [Group $hir $exits]]} {
        return {}
    }
    # A repeat exists, so it is worth asking the completion proof which exits
    # can execute at all: an exit under a branch the range facts prove
    # infeasible (which HIR's own structural reachability does not decide) is
    # not an exit. Absent from the walk means proven unreachable; this can
    # only remove exits, never add one.
    set reached [hir::completions::reachedExprs $hir $block]
    set exits [lmap exit $exits {
        if {![dict exists $reached [lindex $exit 0]]} {
            continue
        }
        set exit
    }]
    set warnings {}
    foreach group [Group $hir $exits] {
        lassign $group identity members
        if {[llength $members] >= 2} {
            lappend warnings [GroupWarning $hir $block $name $identity $members]
        }
    }
    return $warnings
}

# EXITS ({SITE VALUE} pairs, source order) grouped by proven identity: a list
# of {IDENTITY MEMBER-EXITS}, in order of first appearance. An exit with no
# proven identity, a value that never completes, or the unit value (policy)
# belongs to no group.
proc hir::warnings::Group {hir exits} {
    set groups {}
    foreach exit $exits {
        lassign $exit site value
        if {[hir::typeOf $hir $value] eq "never" || [hir::types::kindOf [hir::typeOf $hir $value]] eq "unit"} {
            continue
        }
        set identity [hir::exact::Identity $hir $value]
        if {$identity eq "" || ([lindex $identity 0] eq "value" && [core::value::kind [lindex $identity 1]] eq "unit")} {
            continue
        }
        set found 0
        set i 0
        foreach group $groups {
            if {[hir::exact::SameIdentity [lindex $group 0] $identity]} {
                lset groups $i 1 end+1 $exit
                set found 1
                break
            }
            incr i
        }
        if {!$found} {
            lappend groups [list $identity [list $exit]]
        }
    }
    return $groups
}

proc hir::warnings::HasRepeat {groups} {
    foreach group $groups {
        if {[llength [lindex $group 1]] >= 2} {
            return 1
        }
    }
    return 0
}

# The one warning for EXITS ({SITE VALUE} pairs in source order) returning
# IDENTITY.
proc hir::warnings::GroupWarning {hir block name identity exits} {
    set sites [lmap exit $exits {lindex $exit 0}]
    set spellings {}
    foreach exit $exits {
        set node [dict get $hir exprs [lindex $exit 1]]
        if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""
                && [dict get $hir bindings [dict get $node binding] kind] ne "root"} {
            lappend spellings [BindingName $hir [dict get $node binding]]
        }
    }
    set spellings [lsort -unique $spellings]
    if {[lindex $identity 0] eq "value"} {
        set shown "`[Truncate [core::value::show [lindex $identity 1]]]`"
        if {$spellings ne ""} {
            append shown " ([join [lmap s $spellings {string cat ` $s `}] {, }])"
        }
        set subject "value $shown"
    } else {
        set subject "the value of `[BindingName $hir [lindex $identity 1]]`"
    }
    set count [llength $exits]
    set origins [lmap site $sites {hir::get $hir $site origin}]
    return [New SAME-RETURN-VALUE \
        "$subject is returned from $count distinct exits" \
        [lindex $origins 0] [lrange $origins 1 end] \
        [dict create function $block functionName $name exits $count sites $sites \
            identity [lindex $identity 0] spellings $spellings note "also returned here"]]
}

proc hir::warnings::BindingName {hir b} {
    set binding [dict get $hir bindings $b]
    return [expr {[dict exists $binding spelling] ? [dict get $binding spelling] : [dict get $binding name]}]
}

proc hir::warnings::Truncate {text} {
    return [expr {[string length $text] > 40 ? "[string range $text 0 36]..." : $text}]
}

# BLOCK's exits as {SITE VALUE} pairs in source order: SITE is the return or
# the final-expression leaf (where the exit is located), VALUE the expression
# whose value leaves.
proc hir::warnings::Exits {hir block} {
    set exits [dict create]
    foreach e [BodyExprs $hir $block] {
        set node [dict get $hir exprs $e]
        if {[dict get $node kind] eq "return" && [dict get $node reachable]
                && [dict get $node target] eq $block && [dict get $node value] ne ""} {
            dict set exits $e [list $e [dict get $node value]]
        }
    }
    set body [dict get $hir exprs $block body]
    if {$body ne ""} {
        foreach leaf [Leaves $hir [lindex $body end]] {
            dict set exits $leaf [list $leaf $leaf]
        }
    }
    # Source order: the pre-order position of each site in the body.
    return [lmap e [BodyExprs $hir $block] {
        if {![dict exists $exits $e]} {
            continue
        }
        dict get $exits $e
    }]
}

# Every expression of BLOCK's own body in pre-order, never entering a nested
# function (its returns and exits are its own).
proc hir::warnings::BodyExprs {hir block} {
    set result {}
    foreach e [dict get $hir exprs $block body] {
        BodyInto $hir $e result
    }
    return $result
}

proc hir::warnings::BodyInto {hir e resultVar} {
    upvar 1 $resultVar result
    lappend result $e
    if {[dict get $hir exprs $e kind] eq "block"} {
        return
    }
    foreach child [hir::children $hir $e] {
        BodyInto $hir $child result
    }
}

# The expressions whose value is the function's final value when E is the
# last expression of a body: E itself, or the leaves of each reachable
# written branch of an `if`. An expression that cannot complete (a return,
# fail, break, continue, or anything of type never) leaves nothing.
proc hir::warnings::Leaves {hir e} {
    set node [dict get $hir exprs $e]
    if {![dict get $node reachable]} {
        return {}
    }
    switch -- [dict get $node kind] {
        return - fail - break - continue {
            return {}
        }
        if {
            if {![SynthesizedBranch $hir $node]} {
                set leaves {}
                foreach body [list [dict get $node thenBody] [dict get $node elseBody]] {
                    if {$body ne ""} {
                        lappend leaves {*}[Leaves $hir [lindex $body end]]
                    }
                }
                return $leaves
            }
        }
    }
    return [expr {[hir::typeOf $hir $e] eq "never" ? {} : [list $e]}]
}

# 1 if the `if` NODE is one the frontend synthesized for a boolean operator:
# its branches all originate at the operator, while a written `if` has a
# `then` suite and a distinct `else` suite (or end-of-statement) origin.
proc hir::warnings::SynthesizedBranch {hir node} {
    set then [dict get $hir scopes [dict get $node thenScope] origin]
    set else [dict get $hir scopes [dict get $node elseScope] origin]
    return [expr {$then eq $else}]
}
