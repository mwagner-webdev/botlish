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
        METHOD-ELIGIBLE   hir::warnings::MethodEligible
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

# ---------------------------------------------------------------------------
# METHOD-ELIGIBLE (WARNINGS-METHOD-ELIGIBLE.md)
#
# A call written in functional form that is *proven* eligible for method
# syntax: the sugared spelling `R.name(args...)` parses, is unambiguous and
# resolves to the identical callee. The fact is local to one call, so each
# eligible call is its own warning (no grouping, no secondary locations).
#
# The rules are exactly two, and the compiler's own parser and resolver are
# the prover:
#
#   1. method sugar must be syntactically allowed and unambiguous:
#        * the call was *written* `f(x, ...)` (the frontend's `written`
#          provenance; method sugar, list literals and operators are not
#          candidates, and a synthesized call is never eligible),
#        * its first argument -- the receiver -- is, as written, a form the
#          grammar accepts before a ".": a postfix or primary expression
#          (ReceiverForm); an operator expression is not (it would need
#          added parentheses, and HIR does not record parentheses),
#        * the callee is a declared named function (`fn`, a root native, a
#          module function) -- never a function *value* (a parameter, an
#          alias) -- and is not `nomethod`,
#        * the resolver's own candidate gathering for the sugared spelling
#          (hir::resolve::MethodCandidates, the code real method calls use)
#          finds exactly that function and nothing else visible under the
#          name, and no struct field of that name could compete with it
#          (SugarFieldSafe);
#   2. the callee declares at least 2 ordinary parameters (the sugar moves a
#      trailing argument behind the dot; `length(s)` has none to move).
#
# Anything the compiler cannot establish is silence. Calls HIR marks
# structurally unreachable are skipped. The pass reads the generic source HIR
# once, never a semantic instance, and adds no analysis of its own.

proc hir::warnings::MethodEligible {hir} {
    set haveFields 0
    set fields {}
    set view ""
    set warnings {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || ![dict exists $node written]
                || [dict get $node written form] ne "function" || ![dict get $node reachable]
                || [lindex [dict get $node origin] 0] ne "file"} {
            continue
        }
        set callee [NamedCallee $hir $node]
        if {$callee eq "" || [dict get $callee params] < 2
                || [llength [dict get $node args]] < 2} {
            continue
        }
        set receiver [lindex [dict get $node args] 0]
        set form [ReceiverForm $hir $receiver]
        if {$form eq ""} {
            continue
        }
        if {$view eq ""} {
            set view [ResolutionView $hir]
        }
        if {![SugarResolvesTo $view $node $callee]} {
            continue
        }
        if {!$haveFields} {
            set fields [FieldNames $hir]
            set haveFields 1
        }
        if {![SugarFieldSafe $hir $receiver [dict get $callee method] [dict get $node written ns] $fields]} {
            continue
        }
        set shown [dict get $callee shown]
        lappend warnings [New METHOD-ELIGIBLE \
            "call to `$shown` is eligible for method syntax" \
            [dict get $node origin] {} \
            [dict create function [dict get $callee target] functionName $shown call $e \
                receiver $receiver paramCount [dict get $callee params] receiverForm $form]]
    }
    return $warnings
}

# The callee of the call NODE when it is a declared named function, as a dict
# {identity I target T params N method NAME shown TEXT}: IDENTITY in the resolver's own
# spelling (hir::resolve::CandidateIdentity: `binding:B` / `native:NAME`),
# TARGET like a call's `target` ({block ExprId} / {native NAME}), PARAMS its
# ordinary parameter count (flags are a separate category and not counted;
# a variadic native has no fixed count and is not a candidate), METHOD the
# name its method spelling would carry, SHOWN the callee as the diagnostic
# names it. "" for anything else: a call through
# a function value (a parameter, an alias, a call result, a projection) never
# qualifies, because the sugared form's resolution could not be proven
# identical.
proc hir::warnings::NamedCallee {hir node} {
    set callee [dict get $hir exprs [dict get $node callee]]
    if {[dict get $callee kind] ne "ref" || [dict get $callee binding] eq ""} {
        return ""
    }
    set name [dict get $callee name]
    set b [dict get $callee binding]
    set binding [dict get $hir bindings $b]
    switch -- [dict get $binding kind] {
        root {
            set native [dict get $binding name]
            if {[dict get $binding symbol] eq "" || [dict get $hir symbols [dict get $binding symbol] kind] ne "native"
                    || ![core::native::exists $native]} {
                return ""
            }
            set arity [dict get [core::native::metadata $native] arity]
            if {![string is digit -strict $arity]} {
                return ""
            }
            return [dict create identity native:$native target [list native $native] params $arity \
                method [MemberName $native] shown $name]
        }
        local {
            set d [dict get $binding declaredBy]
            if {$d eq "" || ![dict exists $hir exprs $d] || [dict get $hir exprs $d kind] ne "bind"
                    || [dict get $hir exprs $d duplicate]} {
                return ""
            }
            set block [dict get $hir exprs $d value]
            if {[dict get $hir exprs $block kind] ne "block"} {
                return ""
            }
            set params [expr {[llength [dict get $hir exprs $block params]] - [llength [dict get $hir exprs $block flags]]}]
            # A binding hygiene renamed (NAME#N) is looked up under the
            # spelling the programmer wrote, as the method call would.
            set spelling [expr {[dict exists $binding spelling] ? [dict get $binding spelling] : $name}]
            return [dict create identity binding:$b target [list block $block] params $params \
                method [MemberName $spelling] shown [expr {[dict exists $binding spelling] ? $spelling : $name}]]
        }
    }
    return ""
}

# The member of a possibly namespace-qualified NAME ("list::at" -> "at").
proc hir::warnings::MemberName {name} {
    set i [string last :: $name]
    return [expr {$i < 0 ? $name : [string range $name [expr {$i + 2}] end]}]
}

# HIR as name resolution saw it: hygiene (hir/hygiene.tcl) renamed every
# binding of a module's own section scope to its qualified spelling
# ("list::find") after resolution, but the lookup a method call makes (a
# scope's `names`, and an imported namespace's members) works on the names as
# written ("find"). The view differs from HIR in exactly those scopes' name
# tables; nothing else of it is touched or read differently. (The #N renames
# of later, shadowing bindings stay: a later binding is invisible to the call
# anyway, and its renamed key keeps it out of the lookup of the plain name.)
proc hir::warnings::ResolutionView {hir} {
    if {![dict exists $hir modules]} {
        return $hir
    }
    dict for {ns scope} [dict get $hir modules] {
        set prefix "${ns}::"
        set names [dict create]
        dict for {name b} [dict get $hir scopes $scope names] {
            dict set names [expr {[string first $prefix $name] == 0 ? [string range $name [string length $prefix] end] : $name}] $b
        }
        dict set hir scopes $scope names $names
    }
    return $hir
}

# 1 if the sugared spelling of the call NODE to CALLEE resolves to exactly
# CALLEE's function: the resolver's own candidate gathering for
# `receiver.METHOD(args)` from the call's scope and namespace
# (hir::resolve::MethodCandidates -- lexical lookup, the directly imported
# namespaces' members, aliases and arity applied, nomethod functions left out)
# yields one candidate, and it is that function. No second candidate (a
# shadowing local, another namespace's member of the name) and no other
# function: otherwise the real call would be decided by receiver types, be
# ambiguous, or mean something else, and there is nothing to suggest.
proc hir::warnings::SugarResolvesTo {hir node callee} {
    set ctx [dict create namespace [dict get $node written ns]]
    set candidates [hir::resolve::MethodCandidates hir [dict get $node scope] \
        [dict get $callee method] $ctx [llength [dict get $node args]]]
    return [expr {[llength $candidates] == 1
        && [dict get [lindex $candidates 0] identity] eq [dict get $callee identity]}]
}

# The receiver-form class of expression E, the first argument of a call, when
# the grammar accepts it as written before a ".": postfix and primary
# expressions (surface/parser.tcl: postfix = primary { call | "." IDENT [call] },
# primary = literal | name | qualified name | list | struct | "(" expr ")").
# "" for a form that would need parentheses added -- an operator expression,
# which `.` binds tighter than (`-1.f(y)` is `-(1.f(y))`, `a + b.f(y)` is
# `a + (b.f(y))`) -- and for anything the frontend did not write as a call
# argument. HIR records no parentheses, so a receiver written `(a + b)` is
# the same node as `a + b` and is conservatively not eligible either.
proc hir::warnings::ReceiverForm {hir e} {
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        ref     { return [expr {[string first :: [dict get $node name]] >= 0 ? "qualified-name" : "name"}] }
        const   { return literal }
        project { return field }
        struct  { return struct }
        call {
            if {![dict exists $node written]} {
                return ""
            }
            switch -- [dict get $node written form] {
                function { return call }
                method   { return method-call }
                list     { return list }
            }
        }
    }
    return ""
}

# The names of every struct field the program can have: its struct
# declarations' fields (HIR's `sourceTypes`) and the fields of every struct
# construction expression. A struct *type* can only arise from one of them,
# so a name absent here is the name of no field of any value the program can
# make.
proc hir::warnings::FieldNames {hir} {
    set names [dict create]
    foreach entry [dict get $hir sourceTypes] {
        if {[dict exists $entry kind] && [dict get $entry kind] eq "struct"} {
            foreach {field type} [dict get $entry fields] {
                dict set names $field 1
            }
        }
    }
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "struct"} {
            foreach field [dict get $node names] {
                dict set names $field 1
            }
        }
    }
    return $names
}

# 1 if the sugared spelling `RECEIVER.NAME(args)` cannot be the field-value
# call of a struct field NAME instead (hir/structs.tcl's field/function
# ambiguity, which makes the sugared call an error). Provable when no struct
# of the program has a field NAME (FIELDS, FieldNames); otherwise only when the
# receiver's static type is a known one -- not a struct, or a struct whose
# field NAME cannot compete (hir::structs::FieldCompetes). A receiver of
# unknown type (`any`: a generic parameter) may be given such a struct by an
# instance, so it is not provably safe.
proc hir::warnings::SugarFieldSafe {hir receiver name ns fields} {
    if {![dict exists $fields $name]} {
        return 1
    }
    set type [hir::typeOf $hir $receiver]
    if {$type eq "never"} {
        return 0
    }
    if {[hir::types::IsStructLike $type]} {
        return [expr {![hir::structs::FieldCompetes $type $name [dict create ns $ns]]}]
    }
    return [expr {[hir::types::kindOf $type] ni {"" any struct}}]
}
