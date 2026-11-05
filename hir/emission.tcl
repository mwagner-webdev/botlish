# emission.tcl -- emission claims: `fn F(...) emits R:` certified from F's
# declaration and implementation alone (EMISSION-CLAIMS-MILESTONE-1.md;
# MODULAR-EMISSION-PROOFS-MILESTONE-1.md's checker, integrated).
#
#   hir::emission::verify HIRVAR       certify or reject every claim of HIR
#   hir::emission::claims HIR          the claims' records (the `emissions`
#                                      side table), for tooling
#   hir::emission::reverify HIRVAR     verify again a HIR this process did not
#                                      build (hir::interchange::decode)
#
# The guarantee. A function F is certified to emit R when, for every argument
# tuple F's declaration permits:
#
#   1. every invocation of F that completes normally has an outward yield
#      trace that is exactly one token of R, with nothing unread; and
#   2. every finite outward yield trace of an invocation -- before
#      completion, at a failure, or when its consumer stops resuming -- is a
#      viable prefix of R's language.
#
# The outward yield trace is the symbols yielded by F and by the functions it
# calls by an ordinary call (deep yields); a coroutine F constructs yields to
# F, not through it. A result is no symbol. "Every argument tuple the
# declaration permits" is the values of the declared parameter types -- every
# Int for `int`, a declared integer domain's interval -- never what some
# program's callers pass. The claim is no runtime operation: nothing here
# changes how F runs, and no backend reads it.
#
# The analysis (the milestone's sections 6-12). F's HIR is walked over sets
# of composite recognizer states (hir/emitdfa.tcl, core/dfa.tcl's outcome
# model) with an environment of value facts (hir/intset.tcl over
# hir::range's transfers), F entered with its declared parameter facts only.
# A helper F calls is analyzed in the states and with the argument facts F's
# own code establishes at the call (a summary, keyed by function, entry state
# and argument facts, shared by every claim of the compilation); recursion
# and loops by monotone fixpoints whose convergence is checked; a failure
# point records its states, where a handler starts; a guard (a call of a
# recognizer that never suspends) narrows its binding argument on its normal
# path; a helper with its own certificate is composed through the
# certificate's statement (its language restricted to its exit, visit and
# failure states, with its open boundary obligations), never its body.
# Anything the walk does not model -- a trait operation, a context-trait
# implementation, an unknown HIR form, a budget exhausted -- is EMIT-
# UNSUPPORTED or EMIT-BUDGET: not proved, never proved.
#
# Verdicts. proven (a certificate); rejected (a violation the analysis
# found: EMIT-REJECTED, -BEYOND-TOKEN, -AFTER-TOKEN, -INCOMPLETE,
# -END-SYMBOL, -BOUNDARY, -BYTE-CHARACTER: "may", because
# the facts over-approximate -- a concrete counterexample is the witness
# tool's, audit/emission-claims/tools/witness.tcl, which runs the program);
# not proved (EMIT-UNKNOWN-VALUE, -NOT-SYMBOL, -UNSUPPORTED, -BUDGET: the
# analysis lacks the facts); dependent (the claim's code holds a diagnostic
# of its own, poison or a syntax hole: nothing more is said, nothing
# certified). Every verdict but proven is a diagnostic of the claim: an
# explicit claim is certified or the compilation is rejected.
#
# Certificates and trust. A proven claim's certificate states what a caller
# composes with -- its recognizer (by deep fingerprint), declared domain,
# exit, visit and failure states, open obligations, result and boundary --
# and records what its proof read (every function body by canonical
# fingerprint, every certificate it composed with by statement, every
# recognizer, every registered native result set). The `emissions` side
# table carries them. Only a certificate this process produced is a proof:
# the in-process memo (`memo`) reuses one in a later compilation exactly when
# every dependency still holds; a HIR read from text (interchange, the
# front-end cache) is verified again (reverify), never believed.

namespace eval hir::emission {
    variable END -1
    # Budgets: past them a claim is not proved (EMIT-BUDGET), never proved.
    variable maxRounds 60
    variable maxSummaries 40000
    variable maxContexts 12
    variable maxResultChanges 4
    variable maxProduct 20000
    # The in-process trusted memo: {FUNCTION RECOGNIZER} -> a certificate
    # this process proved (CheckClaim reuses one only when Valid).
    variable memo [dict create]
    # 0 disables the memo (tests, measurements).
    variable useMemo 1
    # Statistics of the last verify (bench/emission-claims.tcl).
    variable stats [dict create]
    # The analysis of one verify.
    variable hir
    variable names [dict create]
    variable byName [dict create]
    variable claimsOf [dict create]
    variable guards [dict create]
    variable guardKeys [dict create]
    variable cache [dict create]
    variable langCache [dict create]
    variable contexts [dict create]
    variable certs [dict create]
    variable fingerprints [dict create]
    variable diagnosed [dict create]
    variable round 0
    variable changed 0
    variable touched {}
    variable computed 0
    variable reused 0
    variable roundsTotal 0
    variable budgetHit 0
    variable registeredUsed [dict create]
    variable guardsUsed [dict create]
    # The walk of one summary.
    variable block ""
    variable env [dict create]
    variable exprVal [dict create]
    variable returns {}
    variable retval {}
    variable breaks [dict create]
    variable continues [dict create]
    variable visits {}
    variable fails {}
    variable viol {}
    variable children {}
    variable certUses {}
    variable tainted 0
}

# ---------------------------------------------------------------------------
# Entry points

# Certifies or rejects every emission claim of HIRVAR's HIR: its diagnostics
# appended, its `emissions` side table set (absent when it has no claim).
# Nothing at all happens to a program without claims.
proc hir::emission::verify {hirVar} {
    upvar 1 $hirVar hir
    set claimBlocks {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "block" && [dict exists $node emits]} {
            lappend claimBlocks $e
        }
    }
    dict unset hir emissions
    if {$claimBlocks eq {}} {
        return
    }
    set t0 [clock microseconds]
    Reset $hir
    dict set ::hir::emission::stats reusedClaims {}
    set records [Check $claimBlocks]
    set hir $::hir::emission::hir
    dict set hir emissions $records
    dict set ::hir::emission::stats checkMicroseconds [expr {[clock microseconds] - $t0}]
    dict set ::hir::emission::stats summariesComputed $::hir::emission::computed
    dict set ::hir::emission::stats summariesReused $::hir::emission::reused
    dict set ::hir::emission::stats rounds $::hir::emission::roundsTotal
    set ::hir::emission::hir ""
}

# The claims' records of HIR (verify's `emissions`): one per claim, {block E
# function NAME recognizer TEXT origin ORIGIN verdict proven|rejected|
# not-proved|dependent ?certificate CERT?} -- a function of the program
# alone (whether this process reused a certificate is in `stats`, never
# here).
proc hir::emission::claims {hir} {
    return [dict getdef $hir emissions {}]
}

# HIRVAR's HIR, read from text another process (or this one, earlier) wrote,
# verified again: its emission diagnostics and records are what this
# process's checker derives from the HIR, or the text is refused ({HIR
# INTERCHANGE EMISSION}). A certificate in text is a claim of a proof, never
# a proof (EMISSION-CLAIMS-MILESTONE-1.md, "Trust").
proc hir::emission::reverify {hirVar} {
    upvar 1 $hirVar hir
    set given [dict getdef $hir emissions {}]
    set hasClaims 0
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "block" && [dict exists $node emits]} {
            set hasClaims 1
            break
        }
    }
    if {!$hasClaims && $given eq {}} {
        return
    }
    set copy $hir
    dict set copy diagnostics [lmap d [dict get $hir diagnostics] {
        if {[string match EMIT-* [dict get $d kind]] && [dict exists $d emission]} continue
        set d
    }]
    verify copy
    if {[dict getdef $copy emissions {}] ne $given || [dict get $copy diagnostics] ne [dict get $hir diagnostics]} {
        throw {HIR INTERCHANGE EMISSION} "HIR interchange text whose emission claims are not what this compiler's checker establishes for its HIR: a certificate in text is never a proof"
    }
    # What the text states is what this process derived: the HIR is kept as
    # read (the same value a build made).
}

# ---------------------------------------------------------------------------
# Setup

proc hir::emission::Reset {h} {
    variable hir
    foreach v {names byName claimsOf guards guardKeys cache langCache contexts certs fingerprints
            diagnosed registeredUsed guardsUsed} {
        set ::hir::emission::$v [dict create]
    }
    set hir $h
    set ::hir::emission::round 0
    set ::hir::emission::computed 0
    set ::hir::emission::reused 0
    set ::hir::emission::roundsTotal 0
    set ::hir::emission::budgetHit 0
    set ::hir::emission::stats [dict create]
    LoadRecognizers $hir
    # Function names: the binding each function block is declared by.
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "bind"} continue
        set v [dict get $node value]
        if {$v eq "" || ![dict exists $hir exprs $v] || [dict get $hir exprs $v kind] ne "block"} continue
        set b [dict get $node binding]
        if {$b eq "" || ![dict exists $hir bindings $b]} continue
        set name [dict get $hir bindings $b name]
        dict set ::hir::emission::names $v $name
        if {![dict exists $::hir::emission::byName $name]} {
            dict set ::hir::emission::byName $name $v
        }
    }
    # Guards: recognizers none of whose transitions suspends -- an ordinary
    # function of one symbol -- by function block.
    dict for {key r} $::hir::emission::recognizers {
        if {[dict get $r suspends] || ![Complete? $key]} continue
        dict set ::hir::emission::guards [dict get $r block] [GuardSet $key]
        dict set ::hir::emission::guardKeys [dict get $r block] $key
    }
    # Expressions the program's own diagnostics are about: a claim whose
    # code holds one is dependent.
    foreach d [dict get $hir diagnostics] {
        set e [dict getdef $d expr ""]
        if {$e ne ""} {
            dict set ::hir::emission::diagnosed $e 1
        }
    }
}

# The claims of CLAIMBLOCKS checked, callees first: their records.
proc hir::emission::Check {claimBlocks} {
    variable hir
    variable claimsOf
    set claims {}
    foreach b $claimBlocks {
        set seen [dict create]
        foreach entry [dict get $hir exprs $b emits] {
            set claim [Claim $b $entry]
            if {$claim eq ""} continue
            if {[dict exists $claim key]} {
                if {[dict exists $seen [dict get $claim key]]} {
                    Report [dict create kind EMIT-RECOGNIZER expr $b origin [dict get $entry origin] \
                        message "[FunctionText $b] claims to emit [KeyText [dict get $claim key]] twice: a claim is stated once"]
                    continue
                }
                dict set seen [dict get $claim key] 1
                dict lappend claimsOf $b [dict get $claim key]
            }
            lappend claims $claim
        }
    }
    set records {}
    foreach claim [Ordered $claims] {
        lappend records [CheckClaim $claim]
    }
    return $records
}

# The claim of block B's emission entry ENTRY ({name origin binding}): {block
# B name TEXT key KEY origin ORIGIN}, or {block B ... verdict V} when it
# names no recognizer the checker can read (reported here), or "" when the
# entry is unresolved (resolution reported it) or dependent.
proc hir::emission::Claim {b entry} {
    variable hir
    variable recognizerOf
    set origin [dict get $entry origin]
    set binding [dict get $entry binding]
    set claim [dict create block $b name [dict get $entry name] origin $origin]
    if {$binding eq "" || [dict getdef $entry dependent 0]} {
        return ""
    }
    set target ""
    if {[dict exists $hir bindings $binding]} {
        set declaredBy [dict get $hir bindings $binding declaredBy]
        if {$declaredBy ne "" && [dict exists $hir exprs $declaredBy]
                && [dict get $hir exprs $declaredBy kind] eq "bind"} {
            set target [dict get $hir exprs $declaredBy value]
        }
    }
    if {$target ne "" && [dict exists $recognizerOf $target]} {
        set key [dict get $recognizerOf $target]
        if {![Complete? $key]} {
            Report [dict create kind EMIT-UNSUPPORTED expr $b origin $origin \
                message "the claim \"emits [dict get $entry name]\" cannot be checked: the table of a recognizer it calls is not part of this HIR (a HIR read from text carries no recognizer tables)"]
            return [dict merge $claim [dict create verdict not-proved]]
        }
        return [dict merge $claim [dict create key $key]]
    }
    if {$target ne "" && [dict exists $hir exprs $target] && [dict get $hir exprs $target kind] eq "block"
            && [StubBlock $target]} {
        # A recognizer declaration rejected with diagnostics of its own
        # (surface/dfa.tcl's Stub): the claim says nothing more.
        return ""
    }
    if {$target ne "" && [dict exists $hir exprs $target] && [dict get $hir exprs $target kind] eq "block"
            && [dict exists $hir exprs $target recognizer] == 0 && [lindex [dict get $hir exprs $target origin] 0] ne "file"} {
        # HIR text: no recognizer tables.
        Report [dict create kind EMIT-UNSUPPORTED expr $b origin $origin \
            message "the claim \"emits [dict get $entry name]\" cannot be checked: the recognizer's table is not part of this HIR (a HIR read from text carries no recognizer tables)"]
        return [dict merge $claim [dict create verdict not-proved]]
    }
    Report [dict create kind EMIT-RECOGNIZER expr $b origin $origin \
        message "the claim \"emits [dict get $entry name]\" names [Described $binding], not a recognizer: a claim names a recognizer declared with \"dfa NAME over ALPHABET:\""]
    return [dict merge $claim [dict create verdict not-proved]]
}

# 1 if function block E is a rejected recognizer's stub: its body holes.
proc hir::emission::StubBlock {e} {
    variable hir
    set body [dict get $hir exprs $e body]
    if {$body eq {}} { return 0 }
    foreach x $body {
        set node [dict get $hir exprs $x]
        if {[dict get $node kind] ne "ref" || [dict get $node name] ne "syntax#hole"} {
            return 0
        }
    }
    return 1
}

# What binding B is, for a message.
proc hir::emission::Described {b} {
    variable hir
    set name [hir::semantic::SourceName $hir $b]
    set declaredBy [dict get $hir bindings $b declaredBy]
    if {$declaredBy ne "" && [dict exists $hir exprs $declaredBy] && [dict get $hir exprs $declaredBy kind] eq "bind"
            && [dict get $hir exprs [dict get $hir exprs $declaredBy value] kind] eq "block"} {
        return "the function $name"
    }
    return "the value $name"
}

# The name of function block B, for a message ("a function" for one without
# one).
proc hir::emission::FunctionText {b} {
    variable hir
    set name [hir::semantic::CallableName $hir $b]
    if {$name eq ""} { return "a function" }
    return $name
}

# The function name binding of block B (its declaring bind's), or "".
proc hir::emission::FunctionName {b} {
    variable names
    return [dict getdef $names $b ""]
}

# ---------------------------------------------------------------------------
# HIR helpers

proc hir::emission::Node {e} {
    variable hir
    return [dict get $hir exprs $e]
}

proc hir::emission::Kind {e} {
    variable hir
    return [dict get $hir exprs $e kind]
}

proc hir::emission::NativeName {e} {
    variable hir
    set node [Node $e]
    if {[dict get $node kind] ne "call"} { return "" }
    lassign [dict get $node target] tk t
    if {$tk ne "native"} { return "" }
    return [dict get [hir::symbol $hir $t] name]
}

proc hir::emission::RefBinding {e} {
    variable hir
    set node [Node $e]
    if {[dict get $node kind] ne "ref"} { return "" }
    set b [dict get $node binding]
    if {$b eq "" || [dict get [hir::binding $hir $b] kind] ni {local param}} { return "" }
    return $b
}

# 1 if TYPE is an Int type: int, or an integer domain.
proc hir::emission::IsInt {type} {
    if {$type eq "int"} { return 1 }
    if {[catch {core::type::integerFacts $type} facts]} { return 0 }
    return [expr {$facts ne {}}]
}

proc hir::emission::TypeOf {e} {
    variable hir
    return [hir::typeOf $hir $e]
}

# The abstract value an expression of static type TYPE has with no other
# fact: its type's integer facts, or `*` (not an Int, or not known to be).
proc hir::emission::TypeValue {type} {
    if {[IsInt $type]} {
        return [hir::intset::OfType $type]
    }
    return *
}

proc hir::emission::Meet {v type} {
    if {$v eq "*"} { return [TypeValue $type] }
    if {[IsInt $type]} {
        return [hir::intset::inter $v [hir::intset::OfType $type]]
    }
    return $v
}

proc hir::emission::Join {a b} {
    if {$a eq "*" || $b eq "*"} { return * }
    return [hir::intset::union $a $b]
}

# The declared parameter facts of block B: one value per parameter (an
# undeclared parameter's: unknown -- its inferred contract is derived from
# the body, a weaker statement than a declaration).
proc hir::emission::Declared {b} {
    set node [Node $b]
    set out {}
    foreach p [dict get $node params] t [dict get $node declaredParamTypes] {
        if {$t eq ""} {
            lappend out *
        } else {
            lappend out [TypeValue $t]
        }
    }
    return $out
}

proc hir::emission::ValueText {v} {
    if {$v eq "*"} { return "unknown" }
    return [hir::intset::text $v]
}

# ---------------------------------------------------------------------------
# Fingerprints: what a certificate depends on of a function

# A canonical text of the code of function block B: node kinds, constants,
# natives, the names of the bindings it refers to outside itself (with their
# exact values and the facts their types give), every expression's type fact
# (never, an integer type's facts, or `*`) and reachability, its declared
# types -- never an expression, binding, scope or type id or an origin, so
# it is the same text in every compilation of the same code: what a proof
# read of the function, and nothing else.
proc hir::emission::FunctionFingerprint {b} {
    variable fingerprints
    if {[dict exists $fingerprints $b]} {
        return [dict get $fingerprints $b]
    }
    set locals [dict create]
    set fp [Digest [Canon $b locals 1 [dict get [Node $b] bodyScope]]]
    dict set fingerprints $b $fp
    return $fp
}

proc hir::emission::Canon {e localsVar top inside} {
    upvar 1 $localsVar locals
    variable hir
    set node [Node $e]
    set kind [dict get $node kind]
    set out [list $kind [dict get $node reachable] [TypeFact $e]]
    switch -- $kind {
        const { lappend out [dict get $node value] }
        ref { lappend out [CanonBinding [dict get $node binding] locals $inside] }
        block {
            if {!$top && [FunctionName $e] ne ""} {
                return [list fn [FunctionName $e]]
            }
            foreach p [dict get $node params] {
                lappend out [CanonBinding $p locals $inside]
            }
            lappend out [dict get $node declaredParamTypes] [dict get $node declaredResult] \
                [dict get $node declaredErrors] [dict get $node declaredResume]
            foreach field {traitClone contextClone traitResult} {
                if {[dict exists $node $field]} {
                    lappend out $field
                }
            }
            lappend out [lmap x [dict get $node body] {Canon $x locals 0 $inside}]
        }
        call {
            lassign [dict get $node target] tk t
            switch -- $tk {
                native { lappend out native [dict get [hir::symbol $hir $t] name] }
                block { lappend out block [Canon $t locals 0 $inside] }
                default { lappend out value [Canon [dict get $node callee] locals 0 $inside] }
            }
            if {[dict exists $node traitCall]} {
                lappend out traitCall
            }
            lappend out [lmap x [dict get $node args] {Canon $x locals 0 $inside}]
        }
        default {
            foreach {k v} $node {
                if {[string match *Scope $k] || [string match *Scopes $k]} continue
                if {$k in {id origin scope type reachable sid bodyScope thenScope elseScope written
                        method nameOrigin nameOrigins fieldOrigins resultType inferredResultType
                        inferredParamTypes checkedParamTypes paramRequirements paramNotes known
                        refinements captures staticRefs directContexts requiredContexts}} continue
                lappend out $k [CanonValue $k $v locals $inside]
            }
        }
    }
    return $out
}

# The fact of expression E's static type the walk reads: never, an integer
# type's facts, or `*`.
proc hir::emission::TypeFact {e} {
    set type [TypeOf $e]
    if {$type eq "never"} { return never }
    return [TypeValue $type]
}

proc hir::emission::CanonValue {k v localsVar inside} {
    upvar 1 $localsVar locals
    switch -- $k {
        value - condition - callee - iterable - start - end - call - receiver - foldInitial {
            if {$v eq ""} { return "" }
            return [Canon $v locals 0 $inside]
        }
        body - thenBody - elseBody - args - fields {
            return [lmap x $v {Canon $x locals 0 $inside}]
        }
        handlerBodies {
            return [lmap body $v {lmap x $body {Canon $x locals 0 $inside}}]
        }
        binding - countBinding - elementBinding - foldBinding {
            return [CanonBinding $v locals $inside]
        }
        target {
            if {$v eq ""} { return "" }
            return target
        }
        handlerPayloads {
            return [lmap b $v {CanonBinding $b locals $inside}]
        }
        domains {
            return [lmap d $v {
                set c {}
                foreach {dk dv} $d {
                    if {$dk eq "origin"} continue
                    lappend c $dk [CanonValue $dk $dv locals $inside]
                }
                set c
            }]
        }
    }
    # Any other field: an expression id is its code, a binding id its
    # identity, a scope or type id nothing (a field the canonical text does
    # not know still changes it when its content does).
    if {[regexp {^[estb]\d+$} $v]} {
        return [CanonId $v locals $inside]
    }
    if {[string is list $v] && [llength $v] > 1} {
        set ids 1
        foreach x $v {
            if {![regexp {^[estb]\d+$} $x]} { set ids 0; break }
        }
        if {$ids} {
            return [lmap x $v {CanonId $x locals $inside}]
        }
    }
    return $v
}

proc hir::emission::CanonId {x localsVar inside} {
    upvar 1 $localsVar locals
    variable hir
    switch -- [string index $x 0] {
        e {
            if {[dict exists $hir exprs $x]} { return [Canon $x locals 0 $inside] }
        }
        b {
            if {[dict exists $hir bindings $x]} { return [CanonBinding $x locals $inside] }
        }
        s - t { return "" }
    }
    return $x
}

# Binding B in the canonical text of the function whose body scope is
# INSIDE: a binding of the function's own (declared in a scope within it) by
# its order of first mention; any other by its name, exact Int value and the
# facts its type gives -- what the function reads of it.
proc hir::emission::CanonBinding {b localsVar inside} {
    upvar 1 $localsVar locals
    variable hir
    if {$b eq ""} { return "" }
    if {[dict exists $locals $b]} { return [dict get $locals $b] }
    set binding [hir::binding $hir $b]
    if {[dict get $binding kind] in {local param} && [Within [dict get $binding scope] $inside]} {
        set id L[dict size $locals]
        dict set locals $b $id
        return $id
    }
    set exact [hir::exact::BindingIntOf $hir $b]
    set type [hir::bindingType $hir $b]
    set fact [if {$type eq "never"} {string cat never} else {TypeValue $type}]
    return [list outer [dict get $binding name] $exact $fact]
}

# 1 if scope S is TARGET or nested in it.
proc hir::emission::Within {s target} {
    variable hir
    while {$s ne ""} {
        if {$s eq $target} { return 1 }
        set s [dict get $hir scopes $s parent]
    }
    return 0
}

# ---------------------------------------------------------------------------
# Summaries
#
# A summary is what a call of function B does from one composite state C
# with argument values ARGS: the states its normal completions leave
# (exits), every state it is in between symbols (visits), every state it may
# fail in (fails: at a `fail` or a call that may fail -- where a handler
# around the call starts), its result value, the violations its own yields
# commit, the summaries it uses (children), the certificates it composed
# with, and whether its code holds what the program's own diagnostics are
# about (tainted). Keyed by {B C ARGS}; computed in rounds to a fixpoint
# (Solve), each value only growing, so recursion is analyzed; a summary of a
# converged solve is final and reused by every later claim of the
# compilation.

proc hir::emission::Summary {b c args_} {
    variable cache
    variable round
    variable changed
    variable touched
    variable computed
    variable reused
    variable maxSummaries
    variable budgetHit
    variable maxResultChanges
    set key [list $b $c $args_]
    if {[dict exists $cache $key]} {
        set rec [dict get $cache $key]
        if {[dict get $rec final]} {
            incr reused
            return $rec
        }
        if {[dict get $rec round] == $round} {
            return $rec
        }
    } else {
        set rec [dict create final 0 round 0 exits {} visits {} fails {} result {} violations {} \
            children {} certUses {} changes 0 tainted 0]
    }
    if {$computed >= $maxSummaries} {
        set budgetHit 1
        return [dict merge $rec [dict create exits {} visits [list $c] fails [list $c] result *]]
    }
    incr computed
    dict set rec round $round
    dict set cache $key $rec
    lappend touched $key
    set computedRec [Walk $b $c $args_]
    # Values only grow: the union with the previous round's.
    set exits [lsort -unique [concat [dict get $rec exits] [dict get $computedRec exits]]]
    set visits [lsort -unique [concat [dict get $rec visits] [dict get $computedRec visits]]]
    set fails [lsort -unique [concat [dict get $rec fails] [dict get $computedRec fails]]]
    set result [Join [dict get $rec result] [dict get $computedRec result]]
    if {[dict get $rec result] eq {} && [dict get $rec exits] eq {} && [dict get $rec changes] == 0} {
        set result [dict get $computedRec result]
    }
    set changes [dict get $rec changes]
    if {$result ne [dict get $rec result]} {
        incr changes
        if {$changes > $maxResultChanges && $result ne "*"} {
            # Widening: the declared result type's facts.
            set declared [dict get [Node $b] declaredResult]
            if {$declared eq ""} {
                set result *
            } else {
                set result [Meet * $declared]
            }
        }
    }
    if {$exits ne [dict get $rec exits] || $visits ne [dict get $rec visits] || $fails ne [dict get $rec fails]
            || $result ne [dict get $rec result]} {
        set changed 1
    }
    set rec [dict create final 0 round $round exits $exits visits $visits fails $fails result $result \
        violations [dict get $computedRec violations] children [dict get $computedRec children] \
        certUses [dict get $computedRec certUses] changes $changes \
        tainted [expr {[dict get $rec tainted] || [dict get $computedRec tainted]}]]
    dict set cache $key $rec
    return $rec
}

# Solves the summary {B C ARGS} to a fixpoint: rounds until no summary
# changes; every summary the solve touched is then final (unless a budget
# was exhausted: then nothing is).
proc hir::emission::Solve {b c args_} {
    variable round
    variable changed
    variable touched
    variable cache
    variable maxRounds
    variable budgetHit
    variable roundsTotal
    set touched {}
    set rounds 0
    while 1 {
        incr round
        incr rounds
        incr roundsTotal
        set changed 0
        Summary $b $c $args_
        if {!$changed} break
        if {$rounds >= $maxRounds} {
            set budgetHit 1
            break
        }
    }
    if {!$budgetHit} {
        foreach key [lsort -unique $touched] {
            dict set cache $key final 1
        }
    }
    return [dict get $cache [list $b $c $args_]]
}

# The summary record of block B from C with ARGS, walked once (the walk
# context saved and restored around it).
proc hir::emission::Walk {b c args_} {
    variable block
    variable env
    variable exprVal
    variable returns
    variable retval
    variable breaks
    variable continues
    variable visits
    variable fails
    variable viol
    variable children
    variable certUses
    variable tainted
    set saved [list $block $env $exprVal $returns $retval $breaks $continues $visits $fails $viol $children $certUses $tainted]
    set block $b
    set env [dict create]
    set exprVal [dict create]
    set returns {}
    set retval {}
    set breaks [dict create]
    set continues [dict create]
    set visits [list $c]
    set fails {}
    set viol {}
    set children {}
    set certUses {}
    set tainted 0
    set node [Node $b]
    foreach field {traitClone contextClone} {
        if {[dict exists $node $field]} {
            Violation EMIT-UNSUPPORTED $b "[FunctionText $b] is a specialization of a trait-polymorphic or context-trait function: the implementations it calls were selected for the program it is in, so the checker does not follow them" "" {}
            set fails [list $c]
            set rec [dict create exits {} visits [list $c] fails [list $c] result * violations $viol \
                children {} certUses {} tainted 0]
            lassign $saved block env exprVal returns retval breaks continues visits fails viol children certUses tainted
            return $rec
        }
    }
    foreach p [dict get $node params] v $args_ t [dict get $node declaredParamTypes] {
        if {$t ne ""} {
            set v [Meet $v $t]
        }
        dict set env $p $v
    }
    lassign [EvalBody [dict get $node body] [list $c]] out value
    set exits [lsort -unique [concat $out $returns]]
    if {$out ne {}} {
        set result [Join $value $retval]
    } else {
        set result $retval
    }
    set rec [dict create exits $exits visits [lsort -unique $visits] fails [lsort -unique $fails] result $result \
        violations $viol children [lsort -unique $children] certUses [lsort -unique $certUses] tainted $tainted]
    lassign $saved block env exprVal returns retval breaks continues visits fails viol children certUses tainted
    return $rec
}

# ---------------------------------------------------------------------------
# The walk: Eval E from states S => {STATES VALUE}

proc hir::emission::EvalBody {body s} {
    variable hir
    set value unit
    foreach e $body {
        set before $s
        lassign [Eval $e $s] s value
        if {$s eq {}} {
            if {$before ne {} && [hir::static::reifiedStatement $hir $body $e]} {
                # A rejected static block as a statement (STATIC-COMPILE.md,
                # "Completions"): a failure point (Failing recorded it), and
                # the walk goes on as if the block completed, from the states
                # before it -- the code after it is checked as written.
                set s $before
                set value unit
                continue
            }
            return [list {} {}]
        }
    }
    return [list $s $value]
}

proc hir::emission::Eval {e s} {
    variable exprVal
    variable hir
    variable diagnosed
    variable tainted
    if {$s eq {}} {
        return [list {} {}]
    }
    set node [Node $e]
    if {[dict exists $hir poisoned $e] || [dict exists $hir syntaxDependent $e] || [dict exists $diagnosed $e]} {
        # What the program's own diagnostics are about: the claim is
        # dependent (verify).
        set tainted 1
    }
    if {![dict get $node reachable]} {
        return [list {} {}]
    }
    set r [EvalNode $e $node $s]
    dict set exprVal $e [lindex $r 1]
    return $r
}

proc hir::emission::EvalNode {e node s} {
    variable hir
    variable env
    variable returns
    variable retval
    variable breaks
    variable continues
    variable block
    switch -- [dict get $node kind] {
        const {
            set v [dict get $node value]
            if {[core::value::kind $v] eq "int"} {
                return [list $s [hir::intset::point [core::value::intOf $v]]]
            }
            return [list $s *]
        }
        ref {
            if {[dict get $node name] eq "syntax#hole"} {
                variable tainted
                set tainted 1
            }
            return [list $s [RefValue $e $node]]
        }
        block {
            return [list $s *]
        }
        bind {
            lassign [Eval [dict get $node value] $s] s v
            set b [dict get $node binding]
            if {$s ne {}} {
                dict set env $b $v
            }
            return [list $s $v]
        }
        return {
            lassign [Eval [dict get $node value] $s] s v
            if {$s ne {} && [dict get $node target] eq $block} {
                lappend returns {*}$s
                set retval [Join $retval $v]
            }
            return [list {} {}]
        }
        break {
            if {[dict get $node value] ne ""} {
                lassign [Eval [dict get $node value] $s] s v
            }
            dict lappend breaks [dict get $node target] {*}$s
            return [list {} {}]
        }
        continue {
            dict lappend continues [dict get $node target] {*}$s
            return [list {} {}]
        }
        fail {
            if {[dict exists $node value] && [dict get $node value] ne ""} {
                lassign [Eval [dict get $node value] $s] s -
            }
            # A failure point.
            Failing $s
            return [list {} {}]
        }
        struct {
            foreach f [dict get $node fields] {
                lassign [Eval $f $s] s -
            }
            return [list $s *]
        }
        project {
            lassign [Eval [dict get $node receiver] $s] s -
            return [list $s [TypeValue [TypeOf $e]]]
        }
        ok - error {
            lassign [Eval [dict get $node value] $s] s -
            return [list $s *]
        }
        call {
            return [EvalCall $e $node $s]
        }
        if {
            return [EvalIf $e $node $s]
        }
        loop - listloop - countloop - lockloop {
            return [EvalLoop $e $node $s]
        }
        handle {
            return [EvalHandle $e $node $s]
        }
    }
    Violation EMIT-UNSUPPORTED $e "the checker does not model a [dict get $node kind] expression" "" {}
    Failing $s
    return [list $s *]
}

proc hir::emission::RefValue {e node} {
    variable hir
    variable env
    set b [dict get $node binding]
    set type [TypeOf $e]
    if {$b ne "" && [dict exists $env $b]} {
        return [Meet [dict get $env $b] $type]
    }
    if {$b ne ""} {
        set k [hir::exact::BindingIntOf $hir $b]
        if {$k ne ""} {
            return [hir::intset::point $k]
        }
    }
    return [TypeValue $type]
}

# ---------------------------------------------------------------------------
# Calls

proc hir::emission::EvalCall {e node s} {
    variable hir
    variable env
    variable guards
    set callee [dict get $node callee]
    if {[Kind $callee] ne "ref"} {
        lassign [Eval $callee $s] s -
    }
    set vals {}
    foreach a [dict get $node args] {
        lassign [Eval $a $s] s v
        lappend vals $v
    }
    if {$s eq {}} {
        return [list {} {}]
    }
    if {[dict exists $node traitCall]} {
        Violation EMIT-UNSUPPORTED $e "a trait operation's implementation is chosen for the program it is in: the checker does not follow it" "" {}
        Failing $s
        return [list $s [TypeValue [TypeOf $e]]]
    }
    lassign [dict get $node target] tk t
    if {$tk eq "native"} {
        set name [dict get [hir::symbol $hir $t] name]
        if {$name eq [core::coroutines::yieldNative]} {
            return [Emit $e [lindex [dict get $node args] 0] [lindex $vals 0] $s]
        }
        if {[NativeMayFail $name]} {
            Failing $s
        }
        if {[TypeOf $e] eq "never"} {
            return [list {} {}]
        }
        return [list $s [NativeValue $e $name $vals]]
    }
    if {$tk eq "block" && ![dict exists $hir exprs $t]} {
        set tk ""
    }
    if {[TypeOf $e] eq "never"} {
        # A call that never completes normally (it may still yield first).
        if {$tk eq "block" && [hir::coroutines::MayYield $hir $t]} {
            Apply $e $t $s $vals
        } else {
            Failing $s
        }
        return [list {} {}]
    }
    if {$tk eq "block"} {
        if {[dict exists $guards $t]} {
            set b [RefBinding [lindex [dict get $node args] 0]]
            if {$b ne "" && [dict exists $env $b] && [dict get $env $b] ne "*"} {
                dict set env $b [hir::intset::inter [dict get $env $b] [dict get $guards $t]]
            } elseif {$b ne ""} {
                dict set env $b [hir::intset::inter [TypeValue [TypeOf [lindex [dict get $node args] 0]]] [dict get $guards $t]]
            }
            UseGuard $t
            # (A guard fails where its argument is no symbol it takes:
            # before the facts above hold.)
            Failing $s
            return [list $s [TypeValue [TypeOf $e]]]
        }
        if {[hir::coroutines::MayYield $hir $t]} {
            return [Apply $e $t $s $vals]
        }
        # A function that cannot yield: its result only.
        if {[BlockMayFail $t]} {
            Failing $s
        }
        set rec [Child $t free $vals]
        return [list $s [Meet [dict get $rec result] [TypeOf $e]]]
    }
    # A call through a function value: a function that may yield never
    # becomes a value (COROUTINES.md), so it yields nothing; it may fail.
    Failing $s
    return [list $s [TypeValue [TypeOf $e]]]
}

# Records the states S as failure points: a handler of an enclosing
# `handle` (or the caller's) may start there.
proc hir::emission::Failing {s} {
    variable fails
    lappend fails {*}$s
}

# 1 if native NAME may fail: it declares errors, raises those of a
# callable it is given, or runs a coroutine (whose root may fail).
proc hir::emission::NativeMayFail {name} {
    set m [core::native::metadata $name]
    if {[dict get $m errors] ne {} || [dict get $m errorsFrom] ne {}} { return 1 }
    if {[string match coroutine#* $name] && $name ne [core::coroutines::yieldNative]} { return 1 }
    return 0
}

# 1 if a call of function block B may fail: it declares errors, or it
# declares no signature (an undeclared contract is not trusted here).
proc hir::emission::BlockMayFail {b} {
    set node [Node $b]
    return [expr {[dict get $node declaredErrors] ne {} || [dict get $node declaredResult] eq ""}]
}

# The value of native NAME's call E with argument values VALS: hir::range's
# transfer for an operator, else the registered result set
# (-result-range), and the static type.
proc hir::emission::NativeValue {e name vals} {
    variable registeredUsed
    set type [TypeOf $e]
    if {![IsInt $type]} {
        return *
    }
    if {[llength $vals] == 2 && [lindex $vals 0] ne "*" && [lindex $vals 1] ne "*"} {
        set v [hir::intset::Arith $name {*}$vals]
        if {$v ne ""} {
            return [Meet $v $type]
        }
    }
    set v [hir::intset::OfRegistered $name]
    if {$v ne [hir::intset::universe]} {
        dict set registeredUsed $name [dict get [core::native::metadata $name] resultRange]
    }
    return [Meet $v $type]
}

# A summary of block T from composite C with VALS, as a child of the
# summary being walked.
proc hir::emission::Child {t c vals} {
    variable children
    set vals [Contextual $t $vals]
    lappend children [list $t $c $vals]
    return [Summary $t $c $vals]
}

# VALS, or the declared facts when function T has had too many argument
# contexts already (sound: an argument's value is in its declared type).
proc hir::emission::Contextual {t vals} {
    variable contexts
    variable maxContexts
    set seen [dict getdef $contexts $t {}]
    if {[dict exists $seen $vals]} {
        return $vals
    }
    if {[dict size $seen] >= $maxContexts} {
        set vals [Declared $t]
    }
    dict set seen $vals 1
    dict set contexts $t $seen
    return $vals
}

# A call E of block T that may yield, from the states S, with argument
# values VALS: its summary from each state -- or, for a certified emitter,
# its certificates' language -- and the boundary obligation of a helper that
# claims to emit a token whole.
proc hir::emission::Apply {e t s vals} {
    variable visits
    variable certUses
    set out {}
    set result {}
    set certificates [UsableCertificates $t]
    foreach c $s {
        set composed 0
        if {$certificates ne {}} {
            # Each certificate bounds the helper's trace by its language,
            # so the helper's exits and visits are in the intersection of
            # what each allows, and a symbol violates the caller's grammar
            # only if every certificate admits it.
            set exits ""
            set seen ""
            set failing ""
            set violations ""
            set ok 1
            foreach cert $certificates {
                lassign [LangSummary $cert $c] ex vi fa vs complete
                if {!$complete} {
                    set ok 0
                    break
                }
                lappend certUses [CertRef $cert]
                if {$exits eq ""} {
                    set exits $ex
                    set seen $vi
                    set failing $fa
                    set violations [list $cert $vs]
                } else {
                    set exits [lmap x $exits {if {$x ni $ex} continue; set x}]
                    set seen [lmap x $seen {if {$x ni $vi} continue; set x}]
                    set failing [lmap x $failing {if {$x ni $fa} continue; set x}]
                    if {$vs eq {}} { set violations [list $cert {}] }
                }
                set result [Join $result [dict get $cert result]]
            }
            if {$ok} {
                set composed 1
                lappend visits {*}$seen
                Failing $failing
                lassign $violations cert vs
                foreach v $vs {
                    lassign $v y violation from
                    ViolationAt $e $violation $from $y "a token of [dict get $cert recognizer] that [dict get $cert display] may emit (its certificate)"
                }
            }
        }
        if {!$composed} {
            set rec [Child $t $c $vals]
            lappend visits {*}[dict get $rec visits]
            Failing [dict get $rec fails]
            set exits [dict get $rec exits]
            set result [Join $result [dict get $rec result]]
        }
        foreach x $exits {
            lappend out [Obligate $t $e $c $x]
        }
    }
    return [list [lsort -unique $out] [Meet $result [TypeOf $e]]]
}

# Exit state X of a call E of T entered in C, with the boundary obligation
# of each recognizer K that T claims to emit whole: the frame of K that T
# entered (none was open when T was called) and left open holds T's token,
# so it must end at the next symbol. A frame of K already open at the call
# is the caller's own token, which the caller's claim governs.
proc hir::emission::Obligate {t e c x} {
    variable claimsOf
    if {$x eq "done"} { return $x }
    foreach key [dict getdef $claimsOf $t {}] {
        set d [FrameDepth $x $key]
        if {$d < 0 || [FrameDepth $c $key] >= 0} continue
        set o [list $d $key [FunctionText $t] $e]
        set obligations [lsort -unique [concat [Obligations $x] [list $o]]]
        return [list {*}[Base $x] $obligations]
    }
    return $x
}

# {EXITS VISITS FAILS VIOLATIONS COMPLETE} of a call of the certified emitter
# CERT from composite C, from its recognizer's language (LangApply), cached by
# the certificate's statement and C.
proc hir::emission::LangSummary {cert c} {
    variable langCache
    variable reused
    variable computed
    set key [list [dict get $cert key] [dict get $cert exits] [dict get $cert visits] [dict get $cert fails] $c]
    if {[dict exists $langCache $key]} {
        incr reused
        return [dict get $langCache $key]
    }
    incr computed
    set t0 [clock microseconds]
    set r [LangApply [dict get $cert key] [dict get $cert exits] [dict get $cert visits] [dict get $cert fails] $c]
    dict incr ::hir::emission::stats composeMicroseconds [expr {[clock microseconds] - $t0}]
    dict set langCache $key $r
    return $r
}

# ---------------------------------------------------------------------------
# Yields

# 1 if E's value is a character's scalar value (a std::char::scalar_value
# call, or a binding bound to one).
proc hir::emission::IsCharacter {e {depth 0}} {
    variable hir
    if {$depth > 20} { return 0 }
    if {[NativeName $e] eq "std::char::scalar_value"} { return 1 }
    set b [RefBinding $e]
    if {$b ne "" && [dict get [hir::binding $hir $b] declaredBy] ne ""} {
        set bind [dict get [hir::binding $hir $b] declaredBy]
        if {[dict get $hir exprs $bind kind] ne "bind"} { return 0 }
        return [IsCharacter [dict get $hir exprs $bind value] [expr {$depth + 1}]]
    }
    return 0
}

# The yield E of the expression ARG, whose value is V, from the states S.
proc hir::emission::Emit {e arg v s} {
    variable END
    variable visits
    if {$v eq "*"} {
        set type [TypeOf $arg]
        if {[IsInt $type] || $type in {any never}} {
            Violation EMIT-UNKNOWN-VALUE $e "this yield's value is not known to be an Int" "" {}
        } else {
            Violation EMIT-NOT-SYMBOL $e "this yield sends a [hir::semantic::ShowType $::hir::emission::hir $type], not an Int: an emitter's yields are symbols" "" {}
        }
        return [list {} {}]
    }
    if {[hir::intset::inter $v [hir::intset::point $END]] ne {}} {
        Violation EMIT-END-SYMBOL $e "this yield may send -1, which is the end of the input in the recognizer protocol, never a symbol" "" [hir::intset::point $END]
        set v [hir::intset::minus $v [hir::intset::point $END]]
    }
    set character [IsCharacter $arg]
    set out {}
    foreach c $s {
        set key [lindex $c 1]
        if {$c ne "done" && $character && [Rec $key alphabet] eq "bytes" && [hir::intset::inter $v {{128 +inf}}] ne {}} {
            Violation EMIT-BYTE-CHARACTER $e "this yield may send the scalar value of a non-ASCII character to a recognizer over bytes: a character is not a byte (send its encoded bytes)" $c {}
        }
        foreach r [Step $c $v] {
            lassign $r y result
            if {$result ne "done" && [lindex $result 0] eq "violation"} {
                ViolationAt $e $result $c $y ""
                continue
            }
            lappend out $result
        }
    }
    set out [lsort -unique $out]
    lappend visits {*}$out
    return [list $out unit]
}

# Records the violation RESULT ({violation KIND KEY STATE N}) of symbols Y
# from composite C at expression E.
proc hir::emission::ViolationAt {e result c y {via ""}} {
    lassign $result - kind key q n
    set prefix ""
    if {$via ne ""} { set prefix "$via: " }
    switch -- $kind {
        reject { Violation EMIT-REJECTED $e "${prefix}this yield may send symbols no transition takes" $c $y }
        beyond { Violation EMIT-BEYOND-TOKEN $e "${prefix}this yield may send a symbol the token ends before (\"accept before\"), which would begin the next token" $c $y }
        after { Violation EMIT-AFTER-TOKEN $e "${prefix}this yield may send a symbol after the token is complete" done $y }
        lookahead { Violation EMIT-REJECTED $e "${prefix}a completion leaves $n symbols unread where its caller can reconsider one" $c $y }
        boundary {
            Violation EMIT-BOUNDARY $e "${prefix}this yield may send a symbol that continues the [KeyText $key] token $q emitted, which claims to emit that token whole: the token would absorb it" [Base $c] $y [list $n]
        }
    }
}

proc hir::emission::Violation {kind e what c y {related {}}} {
    variable viol
    lappend viol [list $kind $e $what $c $y $related]
}

# ---------------------------------------------------------------------------
# Conditions

# The environment on the paths where CONDITION has OUTCOME, or "" when no
# path is feasible: each path of hir::range::Paths narrows the bindings its
# comparisons compare (hir::intset::Narrow, from the operands' values this
# walk computed), a statically known comparison (hir::types::KnownOutcome)
# or an empty binding making it infeasible; the environment is the union
# over the feasible paths.
proc hir::emission::Facts {condition outcome} {
    variable hir
    variable env
    variable exprVal
    set result ""
    foreach path [hir::range::Paths $hir $condition $outcome] {
        set penv $env
        set feasible 1
        foreach pair $path {
            lassign $pair c o
            set known [hir::types::KnownOutcome $hir $c]
            if {$known ne {} && $known != $o} {
                set feasible 0
                break
            }
            set op [NativeName $c]
            if {$op ni {< <= > >= ==}} continue
            set args [dict get [Node $c] args]
            if {[llength $args] != 2} continue
            if {!$o} {
                set op [dict get {< >= <= > > <= >= < == !=} $op]
            }
            lassign $args xa xb
            set va [dict getdef $exprVal $xa *]
            set vb [dict getdef $exprVal $xb *]
            foreach {side self other mirror} [list $xa va vb $op $xb vb va [dict get {< > <= >= > < >= <= == == != !=} $op]] {
                set b [RefBinding $side]
                if {$b eq ""} continue
                set sv [set $self]
                set ov [set $other]
                if {$mirror in {< <= > >=}} {
                    # An order comparison admits only Ints (its native's
                    # parameters; a value of any other kind fails the
                    # call): where it completed, both operands are Ints,
                    # whatever their static types said.
                    if {$sv eq "*"} { set sv [hir::intset::universe] }
                    if {$ov eq "*"} { set ov [hir::intset::universe] }
                }
                if {$sv eq "*" || $ov eq "*"} continue
                set cur [dict getdef $penv $b $sv]
                if {$cur eq "*"} { set cur $sv }
                set n [hir::intset::Narrow $mirror $cur $ov]
                dict set penv $b $n
                if {$n eq {}} {
                    set feasible 0
                }
            }
            if {!$feasible} break
        }
        if {!$feasible} continue
        if {$result eq ""} {
            set result $penv
        } else {
            set result [JoinEnv $result $penv]
        }
    }
    return $result
}

proc hir::emission::JoinEnv {a b} {
    set out [dict create]
    dict for {k v} $a {
        if {[dict exists $b $k]} {
            dict set out $k [Join $v [dict get $b $k]]
        } else {
            dict set out $k $v
        }
    }
    dict for {k v} $b {
        if {![dict exists $a $k]} {
            dict set out $k $v
        }
    }
    return $out
}

proc hir::emission::EvalIf {e node s} {
    variable env
    lassign [Eval [dict get $node condition] $s] s -
    if {$s eq {}} {
        return [list {} {}]
    }
    set cond [dict get $node condition]
    set before $env
    set outs {}
    set envs {}
    set value {}
    set any 0
    foreach outcome {1 0} body [list [dict get $node thenBody] [dict get $node elseBody]] {
        set facts [Facts $cond $outcome]
        if {$facts eq ""} continue
        set env $facts
        lassign [EvalBody $body $s] out v
        if {$out ne {}} {
            lappend outs {*}$out
            lappend envs $env
            if {$body eq {}} { set v unit }
            if {$any} {
                set value [Join $value $v]
            } else {
                set value $v
                set any 1
            }
        }
        set env $before
    }
    if {$envs ne {}} {
        set env [lindex $envs 0]
        foreach other [lrange $envs 1 end] {
            set env [JoinEnv $env $other]
        }
    }
    if {!$any} {
        return [list {} {}]
    }
    if {$value eq "unit"} { set value * }
    return [list [lsort -unique $outs] $value]
}

# ---------------------------------------------------------------------------
# Loops

proc hir::emission::EvalLoop {e node s} {
    variable env
    variable breaks
    variable continues
    variable hir
    set kind [dict get $node kind]
    set induction {}
    switch -- $kind {
        listloop {
            lassign [Eval [dict get $node iterable] $s] s -
        }
        countloop {
            lassign [Eval [dict get $node start] $s] s vs
            lassign [Eval [dict get $node end] $s] s ve
            set induction [list [dict get $node countBinding] [dict get $node start] $vs $ve \
                [dict get $node direction] [dict get $node endKind]]
        }
        lockloop {
            foreach d [dict get $node domains] {
                if {[dict get $d kind] eq "list"} {
                    lassign [Eval [dict get $d iterable] $s] s -
                } else {
                    lassign [Eval [dict get $d start] $s] s vs
                    lassign [Eval [dict get $d end] $s] s ve
                    if {$induction eq {}} {
                        set induction [list [dict get $d binding] [dict get $d start] $vs $ve \
                            [dict get $d direction] [dict get $d endKind]]
                    }
                }
            }
        }
    }
    # A fold's initial value (FOLD-LOOPS-MILESTONE-1.md): evaluated once,
    # after the loop's own operands; the intermediate is a value of its
    # type in every iteration.
    if {[dict exists $node foldInitial]} {
        lassign [Eval [dict get $node foldInitial] $s] s -
    }
    if {$s eq {}} {
        return [list {} {}]
    }
    set before $env
    if {[dict exists $node foldBinding]} {
        set fb [dict get $node foldBinding]
        dict set before $fb [TypeValue [hir::bindingType $hir $fb]]
        set env $before
    }
    set count [ExactCount $induction]
    if {$count ne "" && $count <= 8} {
        return [Unrolled $e $node $s $induction $count $before]
    }
    lassign [Peel $induction] counter all first later
    if {$counter ne ""} {
        dict set env $counter $all
    }
    dict set breaks $e {}
    dict set continues $e {}
    set out {}
    set head $s
    set loopEnv $env
    if {$counter ne "" && $first ne ""} {
        # The first iteration of a counting domain with an exact start is
        # its own (the `if i > 0:` separator idiom); every later one is past
        # the start.
        dict set env $counter $first
        lassign [EvalBody [dict get $node body] $s] after -
        set head [lsort -unique [concat $after [dict get $continues $e]]]
        lappend out {*}[dict get $breaks $e]
        lappend out {*}$s
        set loopEnv [dict replace $loopEnv $counter $later]
        set env $loopEnv
    }
    if {$head ne {}} {
        while 1 {
            dict set continues $e {}
            set env $loopEnv
            lassign [EvalBody [dict get $node body] $head] after -
            set next [lsort -unique [concat $head $after [dict get $continues $e]]]
            if {$next eq $head} break
            set head $next
        }
    }
    set env $before
    lappend out {*}[dict get $breaks $e]
    if {$kind ne "loop"} {
        lappend out {*}$head
    }
    return [list [lsort -unique $out] *]
}

# The exact iteration count of counting domain INDUCTION when its start
# and end are each one exact Int, else "".
proc hir::emission::ExactCount {induction} {
    if {$induction eq {}} { return "" }
    lassign $induction b startExpr vs ve direction endKind
    if {$vs eq "*" || $ve eq "*" || ![hir::intset::isPoint $vs] || ![hir::intset::isPoint $ve]} { return "" }
    set a [lindex $vs 0 0]
    set z [lindex $ve 0 0]
    if {$direction eq "up"} {
        set n [expr {$z - $a}]
    } else {
        set n [expr {$a - $z}]
    }
    if {$endKind ne "exclusive"} { set n [expr {$n + 1}] }
    if {$n < 0} { return 0 }
    return $n
}

# A counted loop of exactly COUNT iterations (at most a few), each walked
# with its own induction value: no zero-iteration exit when it runs, no
# iteration past the last.
proc hir::emission::Unrolled {e node s induction count before} {
    variable env
    variable breaks
    variable continues
    lassign $induction b startExpr vs ve direction
    set a [lindex $vs 0 0]
    dict set breaks $e {}
    set head $s
    for {set k 0} {$k < $count && $head ne {}} {incr k} {
        dict set continues $e {}
        set env $before
        if {$direction eq "up"} {
            set i [expr {$a + $k}]
        } else {
            set i [expr {$a - $k}]
        }
        dict set env $b [hir::intset::point $i]
        lassign [EvalBody [dict get $node body] $head] after -
        set head [lsort -unique [concat $after [dict get $continues $e]]]
    }
    set env $before
    set out [concat [dict get $breaks $e] $head]
    return [list [lsort -unique $out] *]
}

# {COUNTER ALL FIRST LATER} for a counting domain INDUCTION ({BINDING
# STARTEXPR STARTVALUE ENDVALUE DIRECTION ENDKIND}): the induction binding,
# its values in every iteration (hir::range::InductionBinding), and, when
# the start is one exact Int, in the first iteration and in every later one.
proc hir::emission::Peel {induction} {
    if {$induction eq {}} {
        return {"" "" "" ""}
    }
    lassign $induction b startExpr vs ve direction endKind
    set rs [hir::range::unknown]
    if {$vs ne "*" && $vs ne {}} { set rs [hir::intset::HullRange $vs] }
    set re [hir::range::unknown]
    if {$ve ne "*" && $ve ne {}} { set re [hir::intset::HullRange $ve] }
    set all [hir::intset::OfRange [hir::range::InductionBinding $rs $re $direction $endKind]]
    if {$vs eq "*" || ![hir::intset::isPoint $vs]} {
        return [list $b $all "" ""]
    }
    set k [lindex $vs 0 0]
    set first [hir::intset::inter $all [hir::intset::point $k]]
    if {$direction eq "up"} {
        set later [hir::intset::inter $all [hir::intset::interval [expr {$k + 1}] +inf]]
    } else {
        set later [hir::intset::inter $all [hir::intset::interval -inf [expr {$k - 1}]]]
    }
    return [list $b $all $first $later]
}

# ---------------------------------------------------------------------------
# Handlers

proc hir::emission::EvalHandle {e node s} {
    variable fails
    variable env
    set before $env
    set saved $fails
    set fails {}
    lassign [Eval [dict get $node call] $s] after v
    # The handlers start where the call may fail; a failure no handler
    # catches goes on to the caller from the same states.
    set inside [lsort -unique $fails]
    set fails [concat $saved $inside]
    set envs {}
    if {$after ne {}} {
        lappend envs $env
    }
    set out $after
    set value {}
    if {$after ne {}} { set value $v }
    foreach body [dict get $node handlerBodies] {
        # A handler runs where the call failed: none of the call's own
        # facts (a guard's) hold there.
        set env $before
        lassign [EvalBody $body $inside] h hv
        if {$h ne {}} {
            lappend out {*}$h
            lappend envs $env
            set value [Join $value $hv]
        }
    }
    set env $before
    if {$envs ne {}} {
        set env [lindex $envs 0]
        foreach other [lrange $envs 1 end] {
            set env [JoinEnv $env $other]
        }
    }
    if {$out eq {}} {
        return [list {} {}]
    }
    return [list [lsort -unique $out] $value]
}

# ---------------------------------------------------------------------------
# Certificates

# The certificates of block T usable here: its proven claims (this
# compilation's, or reused from the memo after validation).
proc hir::emission::UsableCertificates {t} {
    variable certs
    variable claimsOf
    set out {}
    foreach key [dict getdef $claimsOf $t {}] {
        set id [list [FunctionName $t] [KeyText $key]]
        if {[dict exists $certs $id]} {
            lappend out [dict get $certs $id]
        }
    }
    return $out
}

proc hir::emission::CertRef {cert} {
    return [list [dict get $cert function] [dict get $cert recognizer] [dict get $cert statement]]
}

proc hir::emission::UseGuard {t} {
    variable guardsUsed
    dict set guardsUsed $t 1
}

# Every summary reachable from KEY, KEY included.
proc hir::emission::Reachable {key} {
    variable cache
    set seen [dict create]
    set work [list $key]
    while {[llength $work]} {
        set work [lassign $work k]
        if {[dict exists $seen $k] || ![dict exists $cache $k]} continue
        dict set seen $k 1
        lappend work {*}[dict get $cache $k children]
    }
    return [dict keys $seen]
}

# The certificate of a proven claim: what a caller, a later compilation or
# a reader needs -- the statement, the boundary summary, and every input the
# proof read.
proc hir::emission::Certificate {claim keyset exits visits fails result} {
    variable cache
    variable registeredUsed
    variable guardsUsed
    variable guardKeys
    variable hir
    set b [dict get $claim block]
    set functions [dict create]
    set certDeps {}
    foreach k $keyset {
        set fb [lindex $k 0]
        dict set functions [FunctionName $fb] [FunctionFingerprint $fb]
        lappend certDeps {*}[dict get $cache $k certUses]
    }
    # The claimed function itself, whatever the summaries were keyed by.
    dict set functions [FunctionName $b] [FunctionFingerprint $b]
    set key [dict get $claim key]
    set recognizers [dict create [KeyText $key] [DeepFingerprint $key]]
    dict for {g -} $guardsUsed {
        set gkey [dict get $guardKeys $g]
        dict set recognizers [KeyText $gkey] [DeepFingerprint $gkey]
    }
    set node [Node $b]
    set cert [dict create function [FunctionName $b] display [FunctionText $b] recognizer [KeyText $key] \
        key $key alphabet [Rec $key alphabet] domain [lmap t [dict get $node declaredParamTypes] {
            if {$t eq ""} { string cat undeclared } else { hir::types::show $t }
        }] result $result \
        exits [lsort -unique $exits] \
        visits [lsort -unique [lmap x $visits {Base $x}]] \
        fails [lsort -unique [lmap x $fails {Base $x}]] \
        follow [Follow $exits] \
        depends [dict create checker [hir::interchange::fingerprint] \
            functions [lsort -stride 2 -index 0 $functions] \
            certificates [lsort -unique $certDeps] \
            recognizers [lsort -stride 2 -index 0 $recognizers] \
            registered [lsort -stride 2 -index 0 $registeredUsed]]]
    dict set cert digest [Digest [dict remove $cert digest]]
    dict set cert statement [StatementDigest $cert]
    return $cert
}

# The digest of what certificate CERT states -- the function, its
# recognizer (by fingerprint), its declared domain, its exits and visits
# with their open obligations, its failure states, its result, its boundary
# -- without what the proof read. A caller composing by the certificate
# depends on this alone: the function's code may change and be proved again
# without invalidating its callers, as long as it states the same.
proc hir::emission::StatementDigest {cert} {
    set deps [dict get $cert depends]
    set r [dict get $cert recognizer]
    return [Digest [list [dict get $cert function] $r [dict get $deps recognizers $r] \
        [dict get $cert domain] [Statable [dict get $cert exits]] [dict get $cert visits] [dict get $cert fails] \
        [dict get $cert result] [dict get $cert follow]]]
}

# EXITS with each obligation's call expression left out: an id, which is
# no statement (the obligation's recognizer and depth are).
proc hir::emission::Statable {exits} {
    return [lmap x $exits {
        if {$x eq "done" || [llength $x] < 4} { set x } else {
            list {*}[lrange $x 0 2] [lmap o [lindex $x 3] {lrange $o 0 2}]
        }
    }]
}

# {1 ""} if certificate CERT (the memo's: this process proved it) still
# holds in this compilation -- every input its proof read is unchanged: the
# front end, every function's code, every recognizer's table, every
# registered native result set, every certificate it composed with -- else
# {0 WHY}.
proc hir::emission::Valid {cert} {
    variable byName
    variable certs
    set deps [dict get $cert depends]
    if {[dict get $deps checker] ne [hir::interchange::fingerprint]} {
        return [list 0 "the checker or the front end changed"]
    }
    dict for {name fp} [dict get $deps functions] {
        if {![dict exists $byName $name]} { return [list 0 "$name is gone"] }
        if {[FunctionFingerprint [dict get $byName $name]] ne $fp} { return [list 0 "$name changed"] }
    }
    variable byQualified
    dict for {r fp} [dict get $deps recognizers] {
        if {![dict exists $byQualified $r] || [DeepFingerprint [dict get $byQualified $r]] ne $fp} {
            return [list 0 "recognizer $r changed"]
        }
    }
    dict for {n range} [dict get $deps registered] {
        if {[catch {dict get [core::native::metadata $n] resultRange} now] || $now ne $range} {
            return [list 0 "the registered result set of $n changed"]
        }
    }
    foreach ref [dict get $deps certificates] {
        lassign $ref fn r digest
        set id [list $fn $r]
        if {![dict exists $certs $id]} {
            return [list 0 "the certificate of $fn for $r is gone"]
        }
        if {[dict get $certs $id statement] ne $digest} {
            return [list 0 "what the certificate of $fn for $r states changed"]
        }
    }
    return [list 1 ""]
}

# ---------------------------------------------------------------------------
# Diagnostics

# Records DIAGNOSTIC (a dict: kind, expr, origin, message, ?related?,
# ?notes?) in the HIR, marked as the emission checker's.
proc hir::emission::Report {diagnostic} {
    variable hir
    dict set diagnostic emission 1
    dict lappend hir diagnostics $diagnostic
}

# The diagnostics of claim CLAIM from the violations of the summaries
# KEYSET: one per kind and expression, its states and symbols merged.
proc hir::emission::Diagnostics {keyset claim} {
    variable cache
    set entries [dict create]
    foreach k $keyset {
        foreach v [dict get $cache $k violations] {
            lassign $v kind e what c y related
            set id [list $kind $e]
            if {![dict exists $entries $id]} {
                dict set entries $id [dict create kind $kind expr $e what $what states [dict create] related $related]
            }
            if {$c ne ""} {
                set old [dict getdef [dict get $entries $id states] $c {}]
                dict set entries $id states $c [hir::intset::union $old $y]
            }
        }
    }
    return [lmap d [dict values $entries] {Message $d $claim}]
}

# The HIR diagnostic of violation entry D of CLAIM: located at the
# violation's expression (a yield, a call, possibly in a helper), anchored
# at the claimed function (its unit), naming the claim, the states and the
# symbols, the states' declarations as notes, the claim as a related
# location.
proc hir::emission::Message {d claim} {
    variable hir
    set message "[ClaimPrefix $claim]: [dict get $d what]"
    set notes {}
    set parts {}
    set byText [dict create]
    dict for {c y} [dict get $d states] {
        set text [StateText [Base $c]]
        dict set byText $text [list [hir::intset::union [lindex [dict getdef $byText $text {{} {}}] 0] $y] $c]
        if {$c ne "done"} {
            lassign $c - key q
            set where [StateOrigin $key $q]
            if {$where ne "" && [llength $notes] < 4} {
                set note [dict create message "state $q of [KeyText $key] is declared here" origin $where]
                if {$note ni $notes} {
                    lappend notes $note
                }
            }
        }
    }
    dict for {text pair} $byText {
        lassign $pair y c
        if {$y ne {}} {
            set alphabet unicode
            if {$c ne "done"} { set alphabet [Rec [lindex $c 1] alphabet] }
            lappend parts "[SetText $y $alphabet] in $text"
        } else {
            lappend parts $text
        }
    }
    if {$parts ne {}} {
        if {[llength $parts] > 4} {
            set parts [list {*}[lrange $parts 0 3] "and [expr {[llength $parts] - 4}] more states"]
        }
        append message ": [join $parts {; }]"
    }
    set e [dict get $d expr]
    set related [list [dict get $claim origin]]
    foreach call [dict getdef $d related {}] {
        if {$call ne "" && [dict exists $hir exprs $call]} {
            lappend related [dict get $hir exprs $call origin]
        }
    }
    if {[dict exists $d at]} {
        set origin [dict get $d at]
    } else {
        set origin [dict get $hir exprs $e origin]
    }
    return [dict create kind [dict get $d kind] expr [dict get $claim block] \
        origin $origin message $message related $related notes $notes]
}

# "F's claim to emit R", for a message.
proc hir::emission::ClaimPrefix {claim} {
    return "[FunctionText [dict get $claim block]]'s claim to emit [KeyText [dict get $claim key]]"
}

# The completion: every exit state accepts the end; at the function.
proc hir::emission::Finish {exits claim} {
    variable END
    set b [dict get $claim block]
    set key [dict get $claim key]
    set out {}
    foreach c $exits {
        if {$c eq "done"} continue
        foreach r [Step $c [hir::intset::point $END]] {
            lassign $r y result
            if {$result eq "done"} continue
            lassign [Expected $c] takes completes
            set needs [hir::intset::union $takes $completes]
            if {[lindex $result 1] eq "beyond"} {
                set what "[FunctionText $b] may complete where [KeyText $key]'s token ends before its last symbols (they would not be part of it)"
            } else {
                set what "[FunctionText $b] may complete with its [KeyText $key] token incomplete, where the end of the input is rejected (the state needs one of the symbols shown)"
            }
            lappend out [dict create kind EMIT-INCOMPLETE expr $b what $what states [dict create $c $needs] \
                at [dict get $claim origin]]
        }
    }
    return $out
}

# ---------------------------------------------------------------------------
# Claims

# Checks CLAIM (definition level): its record, its diagnostics reported.
proc hir::emission::CheckClaim {claim} {
    variable cache
    variable certs
    variable memo
    variable useMemo
    variable registeredUsed
    variable guardsUsed
    variable budgetHit
    variable computed
    variable reused
    variable hir
    set b [dict get $claim block]
    set record [dict create block $b function [FunctionText $b] recognizer [dict get $claim name] \
        origin [dict get $claim origin]]
    if {[dict exists $claim verdict]} {
        dict set record verdict [dict get $claim verdict]
        return $record
    }
    set key [dict get $claim key]
    dict set record recognizer [KeyText $key]
    set id [list [FunctionName $b] [KeyText $key]]
    # A certificate this process proved in an earlier compilation, still
    # valid here: reused, not proved again.
    if {$useMemo && [dict exists $memo $id]} {
        set t0 [clock microseconds]
        lassign [Valid [dict get $memo $id]] ok why
        dict incr ::hir::emission::stats validateMicroseconds [expr {[clock microseconds] - $t0}]
        if {$ok} {
            # (Reuse is process history, never part of the HIR: only the
            # statistics say it happened.)
            set cert [dict get $memo $id]
            dict set certs $id $cert
            dict set record verdict proven
            dict set record certificate $cert
            dict lappend ::hir::emission::stats reusedClaims $id
            return $record
        }
    }
    foreach field {traitClone contextClone} {
        if {[dict exists [Node $b] $field]} {
            # A specialization of a trait-polymorphic or context-trait
            # function: the implementations it calls were selected for the
            # program it is in -- no property of the declaration.
            Report [dict create kind EMIT-UNSUPPORTED expr $b origin [dict get $claim origin] \
                message "[ClaimPrefix $claim]: [FunctionText $b] is a specialization of a trait-polymorphic or context-trait function, for the implementations this program selects; the checker does not follow them (a claim holds for every caller, never for one program's selection)" \
                related {} notes {}]
            dict set record verdict not-proved
            return $record
        }
    }
    set registeredUsed [dict create]
    set guardsUsed [dict create]
    set budgetHit 0
    set entry [Initial $key]
    set args_ [Declared $b]
    set rec [Solve $b $entry $args_]
    set keyset [Reachable [list $b $entry $args_]]
    set dependent 0
    foreach k $keyset {
        if {[dict get $cache $k tainted]} {
            set dependent 1
            break
        }
    }
    if {$dependent} {
        # The claim's code holds what the program's own diagnostics are
        # about (or poison, or a syntax hole): nothing more is said of it,
        # and nothing is certified.
        dict set record verdict dependent
        return $record
    }
    set diags [Diagnostics $keyset $claim]
    set exits [dict get $rec exits]
    foreach v [Finish $exits $claim] {
        lappend diags [Message [dict replace $v expr $b] $claim]
    }
    # The function's result is no symbol, whatever its type: the claim is
    # about the yield trace alone. A coroutine root's final value -- a
    # count, a status, the -1 a source protocol may use for its end -- is
    # the consumer's to tell from a symbol (std::coroutine::done?), and
    # what it is belongs to that protocol, not to the claim
    # (CSV-EMISSION-VALIDATION-MILESTONE-1.md, section 18).
    set value [dict get $rec result]
    if {$budgetHit} {
        # An analysis that did not converge: what it found is no finding
        # (its facts are a round's, not the fixpoint's) -- only the budget
        # is reported.
        set diags [list [dict create kind EMIT-BUDGET expr $b origin [dict get $claim origin] \
            message "[ClaimPrefix $claim]: the analysis exhausted its budget (rounds, summaries or a product of recognizers): not proved" \
            related {} notes {}]]
    }
    if {$diags eq {}} {
        set t0 [clock microseconds]
        set cert [Certificate $claim $keyset $exits [dict get $rec visits] [dict get $rec fails] $value]
        dict incr ::hir::emission::stats certifyMicroseconds [expr {[clock microseconds] - $t0}]
        dict set certs $id $cert
        if {$useMemo} {
            dict set memo $id $cert
        }
        dict set record verdict proven
        dict set record certificate $cert
        return $record
    }
    set kinds [lsort -unique [lmap d $diags {dict get $d kind}]]
    if {[llength [lmap k $kinds {if {$k in {EMIT-UNKNOWN-VALUE EMIT-NOT-SYMBOL EMIT-UNSUPPORTED EMIT-BUDGET}} continue; set k}]]} {
        dict set record verdict rejected
    } else {
        dict set record verdict not-proved
    }
    foreach d [lsort -command hir::emission::ByOrigin $diags] {
        Report $d
    }
    return $record
}

proc hir::emission::ByOrigin {a b} {
    set oa [dict get $a origin]
    set ob [dict get $b origin]
    foreach field {line column} {
        set x [dict getdef [lrange $oa 2 end] $field 0]
        set y [dict getdef [lrange $ob 2 end] $field 0]
        if {[string is integer -strict $x] && [string is integer -strict $y] && $x != $y} {
            return [expr {$x < $y ? -1 : 1}]
        }
    }
    return [string compare [dict get $a kind] [dict get $b kind]]
}

# The claims, callees first: a claim of a function another claimed function
# calls (directly or not) comes before the caller's, so the caller composes
# with the helper's certificate.
proc hir::emission::Ordered {claims} {
    set calls [dict create]
    foreach c $claims {
        if {![dict exists $calls [dict get $c block]]} {
            dict set calls [dict get $c block] [Callees [dict get $c block]]
        }
    }
    set out {}
    set remaining $claims
    while {[llength $remaining]} {
        set next {}
        set progress 0
        foreach c $remaining {
            set b [dict get $c block]
            set ready 1
            foreach other $remaining {
                set ob [dict get $other block]
                if {$ob ne $b && $ob in [dict get $calls $b] && $b ni [dict get $calls $ob]} {
                    set ready 0
                    break
                }
            }
            if {$ready} {
                lappend out $c
                set progress 1
            } else {
                lappend next $c
            }
        }
        if {!$progress} {
            lappend out {*}$next
            break
        }
        set remaining $next
    }
    return $out
}

# The blocks B calls, directly or not.
proc hir::emission::Callees {b} {
    variable hir
    set seen [dict create]
    set work [list $b]
    while {[llength $work]} {
        set work [lassign $work x]
        if {[dict exists $seen $x]} continue
        dict set seen $x 1
        set stack [dict get [Node $x] body]
        while {[llength $stack]} {
            set stack [lassign $stack e]
            set node [Node $e]
            if {[dict get $node kind] eq "call"} {
                lassign [dict get $node target] tk t
                if {$tk eq "block" && [dict exists $hir exprs $t]} {
                    lappend work $t
                }
            }
            if {[dict get $node kind] ne "block"} {
                lappend stack {*}[hir::children $hir $e]
            }
        }
    }
    dict unset seen $b
    return [dict keys $seen]
}

# ---------------------------------------------------------------------------
# Text, for tooling

# The guarantee certificate CERT states, as text (the compiler service's
# hover).
proc hir::emission::GuaranteeText {cert} {
    set f [dict get $cert follow]
    if {$f eq "self"} {
        set boundary "its token completes on its own last symbol"
    } elseif {$f eq {}} {
        set boundary "its token ends only at the end of the input"
    } else {
        set boundary "its token ends at the end of the input or before [SetText $f [dict get $cert alphabet]]"
    }
    return "certified to emit [dict get $cert recognizer]: every normal completion has yielded exactly one token, every prefix it yields is viable; $boundary"
}

# A line of text for claim record RECORD (claims), for a hover: the
# guarantee its certificate states, or why it has none.
proc hir::emission::ClaimText {record} {
    switch -- [dict get $record verdict] {
        proven { return "emits [dict get $record recognizer]: [GuaranteeText [dict get $record certificate]]" }
        rejected { return "emits [dict get $record recognizer]: rejected -- the analysis found a trace the recognizer does not accept (see its diagnostics)" }
        not-proved { return "emits [dict get $record recognizer]: not proved -- the analysis lacks the facts (see its diagnostics)" }
        dependent { return "emits [dict get $record recognizer]: not checked -- its code holds another diagnostic" }
    }
    return "emits [dict get $record recognizer]: [dict get $record verdict]"
}
