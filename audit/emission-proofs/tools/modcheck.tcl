# modcheck.tcl -- modular, caller-independent certification of emitters
# (MODULAR-EMISSION-PROOFS-MILESTONE-1.md). An isolated prototype: nothing in
# core/, hir/, surface/, compiler/ or native/ loads it.
#
#   tclsh9.0 audit/emission-proofs/tools/modcheck.tcl PROGRAM.bot ?options?
#   source audit/emission-proofs/tools/modcheck.tcl
#   modcheck::check PATH ?options?   => {claims {CLAIM...} certificates
#                                        {CERT...} invocations {...} stats {...}}
#
# Options:
#   -emits {FN R ...}        claims besides the `#: emits R` directives
#   -compose body|certificate   how a call of a certified emitter is checked:
#                            by its body in the caller's context (body), or
#                            by its certificate's language alone
#                            (certificate, the default)
#   -store FILE              certificates read before and written after:
#                            a claim whose stored certificate is still valid
#                            is reused, not proved again
#   -invocation {CALLER CALLEE R ...}   invocation-level checks: each call
#                            (or coroutine construction) of CALLEE in
#                            CALLER, with the facts CALLER's own body has
#                            there
#   -witness 0|1             search for a concrete counterexample of each
#                            claim that is not proved (default 1)
#   -only {FN...}            check only these claims
#
# The guarantee certified for a function F and a recognizer R (the report's
# section 2): for every argument tuple F's declaration permits, every
# normal completion of a call of F has yielded -- itself and through
# ordinary deep-yielding calls, never through a coroutine it constructs --
# exactly one token of R with nothing unread, and every prefix it yields is
# a viable prefix of R's language.
#
# What makes it modular (section 4): F is entered with its *declared*
# parameter domains (hir::range::TypeFact of each declared type: an `int` is
# every Int, an integer domain its interval), never with what any program
# passes; a helper is analyzed under the facts F's own body establishes at
# the call (a summary keyed by the helper, the recognizer state it is
# entered in and its argument facts); nothing reads hir::range's
# whole-program instances, hir::specialize, or the set of callers. A
# function no program calls is certified or rejected like any other.
#
# Value facts come from intset.tcl (hir::range's transfer functions, lifted
# to unions of intervals), branch conditions (hir::range::Paths), guards
# (non-suspending recognizers), and the table of trusted native facts below
# (each with its origin). Recognizer semantics come from dfasem.tcl (the
# lowering's own table).
#
# Verdicts (section 13): proven (a certificate), disproven (a concrete
# argument tuple whose run completes with an invalid trace, or yields a
# non-viable prefix: tools/concrete.tcl ran it), not proved (the analysis
# lacks the facts; nothing is claimed either way).

if {[info exists ::env(EMISSION_PROOFS_ROOT)]} {
    set modcheckRoot $::env(EMISSION_PROOFS_ROOT)
} else {
    set modcheckRoot [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
}
if {[info commands ::surface::readProgramFile] eq ""} {
    source [file join $modcheckRoot surface surface.tcl]
}
set modcheckHere [file dirname [file normalize [info script]]]
source [file join [file dirname [file normalize [info script]]] intset.tcl]
source [file join [file dirname [file normalize [info script]]] dfasem.tcl]

namespace eval modcheck {
    # The checker's identity: a digest of its own sources (this file, the
    # value domain, the recognizer semantics) and of the front end whose
    # analyses it reads (hir::interchange's fingerprint: core, hir, surface,
    # stdlib's Tcl libraries -- hir::range's transfers among them). A
    # certificate is valid only under the checker that wrote it.
    variable version ""
    variable END -1
    # Trusted native facts: what a native's result is, beyond its
    # registered -result-range, that the prototype relies on. Each is a
    # statement about an implementation, with its origin; a certificate
    # records the ones its proof used.
    variable trusted [dict create \
        std::char::scalar_value [dict create set {{0 55295} {57344 1114111}} \
            origin "core/value.tcl (a UnicodeChar is a Unicode scalar value: isValidScalar); native/src/runtime/value.rs (SURROGATE_LO..SURROGATE_HI never a char)" \
            justification "std::str::char_at and every String operation produce UnicodeChars only through those constructors"]]
    # Budgets: past them a claim is not proved (EMIT-BUDGET), never proved.
    variable maxRounds 60
    variable maxSummaries 40000
    variable maxContexts 12
    variable maxResultChanges 4
    # The analysis.
    variable hir
    variable claims {}
    variable claimsOf [dict create]
    variable guards [dict create]
    variable cache [dict create]
    variable langCache [dict create]
    variable round 0
    variable changed 0
    variable touched {}
    variable computed 0
    variable reused 0
    variable contexts [dict create]
    variable certs [dict create]
    variable compose certificate
    # declared (the guarantee) or observed (the exploratory model, for
    # comparison: what the program's own calls pass).
    variable facts declared
    variable budgetHit 0
    variable trustedUsed [dict create]
    variable registeredUsed [dict create]
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
    variable probe ""
    variable probed {}
    variable observedAll ""
}

# ---------------------------------------------------------------------------
# HIR helpers

proc modcheck::Node {e} {
    variable hir
    return [dict get $hir exprs $e]
}

proc modcheck::Kind {e} {
    variable hir
    return [dict get $hir exprs $e kind]
}

proc modcheck::Location {e} {
    variable hir
    return [hir::originLocation $hir [dict get $hir exprs $e origin]]
}

proc modcheck::NativeName {e} {
    variable hir
    set node [Node $e]
    if {[dict get $node kind] ne "call"} { return "" }
    lassign [dict get $node target] tk t
    if {$tk ne "native"} { return "" }
    return [dict get [hir::symbol $hir $t] name]
}

proc modcheck::RefBinding {e} {
    variable hir
    set node [Node $e]
    if {[dict get $node kind] ne "ref"} { return "" }
    set b [dict get $node binding]
    if {$b eq "" || [dict get [hir::binding $hir $b] kind] ni {local param}} { return "" }
    return $b
}

# 1 if TYPE is an Int type: int, or an integer domain.
proc modcheck::IsInt {type} {
    if {$type eq "int"} { return 1 }
    if {[catch {core::type::integerFacts $type} facts]} { return 0 }
    return [expr {$facts ne {}}]
}

proc modcheck::TypeOf {e} {
    variable hir
    return [hir::typeOf $hir $e]
}

# The abstract value an expression of static type TYPE has with no other
# fact: its type's integer facts, or `*` (not an Int, or not known to be).
proc modcheck::TypeValue {type} {
    if {[IsInt $type]} {
        return [intset::OfType $type]
    }
    return *
}

proc modcheck::Meet {v type} {
    if {$v eq "*"} { return [TypeValue $type] }
    if {[IsInt $type]} {
        return [intset::inter $v [intset::OfType $type]]
    }
    return $v
}

proc modcheck::Join {a b} {
    if {$a eq "*" || $b eq "*"} { return * }
    return [intset::union $a $b]
}

# The declared parameter facts of block B: one value per parameter.
proc modcheck::Declared {b} {
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

# The function name binding B of block E is bound to (qualified for a
# module's), or "".
proc modcheck::FunctionName {b} {
    variable names
    return [dict getdef $names $b ""]
}

# ---------------------------------------------------------------------------
# Fingerprints: what a certificate depends on of a function

# A canonical text of the code of function block B: node kinds, constants,
# natives, the names of the functions and module bindings it refers to
# (with their exact values), its declared types -- never an expression or
# binding id, a scope or an origin, so it is the same text in every
# compilation of the same source, whatever calls it.
proc modcheck::FunctionFingerprint {b} {
    variable fingerprints
    if {[dict exists $fingerprints $b]} {
        return [dict get $fingerprints $b]
    }
    set locals [dict create]
    set text [Canon $b locals 1]
    set fp [dfasem::Digest $text]
    dict set fingerprints $b $fp
    return $fp
}

proc modcheck::Canon {e localsVar {top 0}} {
    upvar 1 $localsVar locals
    variable hir
    set node [Node $e]
    set kind [dict get $node kind]
    set out [list $kind]
    switch -- $kind {
        const { lappend out [dict get $node value] }
        ref { lappend out [CanonBinding [dict get $node binding] locals] }
        block {
            if {!$top && [FunctionName $e] ne ""} {
                return [list fn [FunctionName $e]]
            }
            foreach p [dict get $node params] {
                lappend out [CanonBinding $p locals]
            }
            lappend out [dict get $node declaredParamTypes] [dict get $node declaredResult] \
                [dict get $node declaredErrors] [dict get $node declaredResume]
            lappend out [lmap x [dict get $node body] {Canon $x locals}]
        }
        call {
            lassign [dict get $node target] tk t
            switch -- $tk {
                native { lappend out native [dict get [hir::symbol $hir $t] name] }
                block { lappend out block [Canon $t locals] }
                default { lappend out value [Canon [dict get $node callee] locals] }
            }
            lappend out [lmap x [dict get $node args] {Canon $x locals}]
        }
        default {
            foreach {k v} $node {
                if {[string match *Scope $k] || [string match *Scopes $k]} continue
                if {$k in {id origin scope type reachable sid bodyScope thenScope elseScope written
                        method nameOrigin nameOrigins fieldOrigins resultType inferredResultType
                        inferredParamTypes checkedParamTypes paramRequirements paramNotes known
                        refinements captures staticRefs directContexts requiredContexts}} continue
                lappend out $k [CanonValue $k $v locals]
            }
        }
    }
    return $out
}

proc modcheck::CanonValue {k v localsVar} {
    upvar 1 $localsVar locals
    variable hir
    switch -- $k {
        value - condition - callee - iterable - start - end - call - receiver {
            if {$v eq ""} { return "" }
            return [Canon $v locals]
        }
        body - thenBody - elseBody - args - fields {
            return [lmap x $v {Canon $x locals}]
        }
        handlerBodies {
            return [lmap body $v {lmap x $body {Canon $x locals}}]
        }
        binding - countBinding - elementBinding {
            return [CanonBinding $v locals]
        }
        target {
            if {$v eq ""} { return "" }
            return target
        }
        handlerPayloads {
            return [lmap b $v {CanonBinding $b locals}]
        }
        domains {
            return [lmap d $v {
                set c {}
                foreach {dk dv} $d {
                    lappend c $dk [CanonValue $dk $dv locals]
                }
                set c
            }]
        }
    }
    # Any other field: an expression id is its code, a binding id its
    # identity, a scope or type id nothing (a field the canonical text
    # does not know still changes it when its content does).
    if {[regexp {^[estb]\d+$} $v]} {
        return [CanonId $v locals]
    }
    if {[string is list $v] && [llength $v] > 1} {
        set ids 1
        foreach x $v {
            if {![regexp {^[estb]\d+$} $x]} { set ids 0; break }
        }
        if {$ids} {
            return [lmap x $v {CanonId $x locals}]
        }
    }
    return $v
}

proc modcheck::CanonId {x localsVar} {
    upvar 1 $localsVar locals
    variable hir
    switch -- [string index $x 0] {
        e {
            if {[dict exists $hir exprs $x]} { return [Canon $x locals] }
        }
        b {
            if {[dict exists $hir bindings $x]} { return [CanonBinding $x locals] }
        }
        s - t { return "" }
    }
    return $x
}

proc modcheck::CanonBinding {b localsVar} {
    upvar 1 $localsVar locals
    variable hir
    if {$b eq ""} { return "" }
    if {[dict exists $locals $b]} { return [dict get $locals $b] }
    set binding [hir::binding $hir $b]
    set kind [dict get $binding kind]
    set declaredBy [dict get $binding declaredBy]
    if {$kind in {local param} && ($declaredBy eq "" || ![IsTopLevel $declaredBy])} {
        set id L[dict size $locals]
        dict set locals $b $id
        return $id
    }
    set name [dict get $binding name]
    set exact [hir::exact::BindingIntOf $hir $b]
    return [list global $name $exact]
}

# 1 if bind node E binds a function or value at a module's or the
# program's top level (its name is its identity).
proc modcheck::IsTopLevel {e} {
    variable topLevel
    return [dict exists $topLevel $e]
}

# ---------------------------------------------------------------------------
# Claims, guards

# {LINE NAME RECOGNIZER} of every `#: emits R` directive in PATH.
proc modcheck::Directives {path} {
    set out {}
    set lines [split [core::ReadFile $path] \n]
    for {set i 0} {$i < [llength $lines]} {incr i} {
        if {![regexp {^\s*#:\s*emits\s+(\S+)\s*$} [lindex $lines $i] -> recognizer]} continue
        for {set j [expr {$i + 1}]} {$j < [llength $lines]} {incr j} {
            set line [lindex $lines $j]
            if {[regexp {^\s*#} $line]} continue
            if {[regexp {^\s*(?:private\s+)?(?:nomethod\s+)?fn\s+([A-Za-z_][A-Za-z0-9_?]*)} $line -> name]} {
                lappend out [list [expr {$j + 1}] $name $recognizer]
            }
            break
        }
    }
    return $out
}

proc modcheck::RecognizerKey {name own} {
    if {[string first :: $name] >= 0} {
        set key [list [namespace qualifiers $name] [namespace tail $name]]
    } else {
        set key [list $own $name]
    }
    if {[dfasem::Has $key]} { return $key }
    return ""
}

# ---------------------------------------------------------------------------
# Summaries
#
# A summary is what a call of function B does from one composite state C
# with argument values ARGS: the states its normal completions leave
# (exits), every state it may be in between symbols -- where it may fail --
# (visits), every state it may fail in (fails: at a `fail` or a call that
# may fail -- what a handler around the call starts from), its result
# value, the violations its own yields commit, and the
# summaries it uses (children). Keyed by {B C ARGS}; computed in rounds to a
# fixpoint (Solve), each value only growing (a union with the previous
# round's), so recursion is analyzed; a summary of a converged solve is
# final and reused by every later claim -- across claims, across modules,
# and, through certificates, across compilations.

proc modcheck::Summary {b c args_} {
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
            children {} certUses {} changes 0]
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
            set result [Meet * [dict get [Node $b] declaredResult]]
            if {[dict get [Node $b] declaredResult] eq ""} { set result * }
        }
    }
    if {$exits ne [dict get $rec exits] || $visits ne [dict get $rec visits] || $fails ne [dict get $rec fails]
            || $result ne [dict get $rec result]} {
        set changed 1
    }
    set rec [dict create final 0 round $round exits $exits visits $visits fails $fails result $result \
        violations [dict get $computedRec violations] children [dict get $computedRec children] \
        certUses [dict get $computedRec certUses] changes $changes]
    dict set cache $key $rec
    return $rec
}

# Solves the summary KEY ({B C ARGS}) to a fixpoint: rounds until no
# summary changes; every summary the solve touched is then final.
proc modcheck::Solve {b c args_} {
    variable round
    variable changed
    variable touched
    variable cache
    variable maxRounds
    variable budgetHit
    set touched {}
    set rounds 0
    while 1 {
        incr round
        incr rounds
        incr ::modcheck::roundsTotal
        set changed 0
        set rec [Summary $b $c $args_]
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
proc modcheck::Walk {b c args_} {
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
    set saved [list $block $env $exprVal $returns $retval $breaks $continues $visits $fails $viol $children $certUses]
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
    if {$b eq "program"} {
        # The program's top-level statements (observed facts: Observed).
        set body [hir::roots $::modcheck::hir]
    } else {
        set node [Node $b]
        foreach p [dict get $node params] v $args_ t [dict get $node declaredParamTypes] {
            if {$t ne ""} {
                set v [Meet $v $t]
            }
            dict set env $p $v
        }
        set body [dict get $node body]
    }
    lassign [EvalBody $body [list $c]] out value
    set exits [lsort -unique [concat $out $returns]]
    if {$out ne {}} {
        set result [Join $value $retval]
    } else {
        set result $retval
    }
    set rec [dict create exits $exits visits [lsort -unique $visits] fails [lsort -unique $fails] result $result \
        violations $viol children [lsort -unique $children] certUses [lsort -unique $certUses]]
    lassign $saved block env exprVal returns retval breaks continues visits fails viol children certUses
    return $rec
}

# ---------------------------------------------------------------------------
# The walk: Eval E from states S => {STATES VALUE}

proc modcheck::EvalBody {body s} {
    set value unit
    foreach e $body {
        lassign [Eval $e $s] s value
        if {$s eq {}} {
            return [list {} {}]
        }
    }
    return [list $s $value]
}

proc modcheck::Eval {e s} {
    variable exprVal
    if {$s eq {}} {
        return [list {} {}]
    }
    set node [Node $e]
    if {![dict get $node reachable]} {
        return [list {} {}]
    }
    set r [EvalNode $e $node $s]
    dict set exprVal $e [lindex $r 1]
    return $r
}

proc modcheck::EvalNode {e node s} {
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
                return [list $s [intset::point [core::value::intOf $v]]]
            }
            return [list $s *]
        }
        ref {
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
    return [list $s *]
}

proc modcheck::RefValue {e node} {
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
            return [intset::point $k]
        }
    }
    return [TypeValue $type]
}

# ---------------------------------------------------------------------------
# Calls

proc modcheck::EvalCall {e node s} {
    variable hir
    variable env
    variable guards
    variable probe
    variable probed
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
        Violation EMIT-UNSUPPORTED $e "a trait operation's implementation is chosen after this check: the checker does not follow it" "" {}
        Failing $s
        return [list $s [TypeValue [TypeOf $e]]]
    }
    lassign [dict get $node target] tk t
    if {$tk eq "native"} {
        set name [dict get [hir::symbol $hir $t] name]
        if {$name eq [core::coroutines::yieldNative]} {
            return [Emit $e [lindex [dict get $node args] 0] [lindex $vals 0] $s]
        }
        if {$name eq "coroutine#create"} {
            ProbeThunk [lindex [dict get $node args] 0]
        }
        if {[NativeMayFail $name]} {
            Failing $s
        }
        if {[TypeOf $e] eq "never"} {
            return [list {} {}]
        }
        return [list $s [NativeValue $e $name $vals]]
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
        if {$probe eq "*" || ($probe ne "" && $t eq [lindex $probe 0])} {
            lappend probed [list $t $e $vals]
        }
        if {[dict exists $guards $t]} {
            set b [RefBinding [lindex [dict get $node args] 0]]
            if {$b ne "" && [dict exists $env $b] && [dict get $env $b] ne "*"} {
                dict set env $b [intset::inter [dict get $env $b] [dict get $guards $t]]
            } elseif {$b ne ""} {
                dict set env $b [intset::inter [TypeValue [TypeOf [lindex [dict get $node args] 0]]] [dict get $guards $t]]
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
proc modcheck::Failing {s} {
    variable fails
    lappend fails {*}$s
}

# 1 if native NAME may fail: it declares errors, raises those of a
# callable it is given, or runs a coroutine (whose root may fail).
proc modcheck::NativeMayFail {name} {
    set m [core::native::metadata $name]
    if {[dict get $m errors] ne {} || [dict get $m errorsFrom] ne {}} { return 1 }
    if {[string match coroutine#* $name] && $name ne [core::coroutines::yieldNative]} { return 1 }
    return 0
}

# 1 if a call of function block B may fail: it declares errors, or it
# declares no signature (an undeclared contract is not trusted here).
proc modcheck::BlockMayFail {b} {
    set node [Node $b]
    return [expr {[dict get $node declaredErrors] ne {} || [dict get $node declaredResult] eq ""}]
}

# The value of native NAME's call E with argument values VALS: hir::range's
# transfer for an operator, else the registered -result-range, a trusted
# fact, and the static type.
proc modcheck::NativeValue {e name vals} {
    variable trusted
    variable trustedUsed
    variable registeredUsed
    set type [TypeOf $e]
    if {![IsInt $type]} {
        return *
    }
    if {[llength $vals] == 2 && [lindex $vals 0] ne "*" && [lindex $vals 1] ne "*"} {
        set v [intset::Arith $name {*}$vals]
        if {$v ne ""} {
            return [Meet $v $type]
        }
    }
    set v [intset::OfRange [hir::range::RegisteredRange $name]]
    if {$v ne [intset::universe]} {
        dict set registeredUsed $name [dict get [core::native::metadata $name] resultRange]
    }
    if {[dict exists $trusted $name]} {
        set v [intset::inter $v [dict get $trusted $name set]]
        dict set trustedUsed $name [dict get $trusted $name set]
    }
    return [Meet $v $type]
}

# A summary of block T from composite C with ARGS, as a child of the
# summary being walked.
proc modcheck::Child {t c vals} {
    variable children
    set vals [Contextual $t $vals]
    lappend children [list $t $c $vals]
    return [Summary $t $c $vals]
}

# VALS, or the declared facts when function T has had too many argument
# contexts already (sound: an argument's value is in its declared type).
proc modcheck::Contextual {t vals} {
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
# values VALS: its summary from each state -- or, for a certified emitter
# under -compose certificate, its certificate's language -- and the
# boundary obligation of a helper that claims to emit a token whole.
proc modcheck::Apply {e t s vals} {
    variable visits
    variable compose
    variable claimsOf
    variable certUses
    set out {}
    set result {}
    set certificates [UsableCertificates $t]
    foreach c $s {
        if {$c eq "free"} {
            set rec [Child $t free $vals]
            lappend visits {*}[dict get $rec visits]
            Failing [dict get $rec fails]
            lappend out {*}[dict get $rec exits]
            set result [Join $result [dict get $rec result]]
            continue
        }
        if {$compose eq "certificate" && $certificates ne {}} {
            # Each certificate bounds the helper's trace by its language,
            # so the helper's exits and visits are in the intersection of
            # what each allows, and a symbol violates the caller's grammar
            # only if every certificate admits it.
            set exits ""
            set seen ""
            set failing ""
            set violations ""
            set cert ""
            foreach cert $certificates {
                lappend certUses [CertRef $cert]
                lassign [LangSummary $cert $c] ex vi fa vs
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
            lappend visits {*}$seen
            Failing $failing
            lassign $violations cert vs
            foreach v $vs {
                lassign $v y violation from
                ViolationAt $e $violation $from $y "a token of [dict get $cert recognizer] that [dict get $cert function] may emit (its certificate)"
            }
        } else {
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
proc modcheck::Obligate {t e c x} {
    variable claimsOf
    if {$x eq "done" || $x eq "free"} { return $x }
    foreach key [dict getdef $claimsOf $t {}] {
        set d [dfasem::FrameDepth $x $key]
        if {$d < 0 || [dfasem::FrameDepth $c $key] >= 0} continue
        set o [list $d $key [FunctionName $t] [Location $e]]
        set obligations [lsort -unique [concat [dfasem::Obligations $x] [list $o]]]
        return [list {*}[dfasem::Base $x] $obligations]
    }
    return $x
}

# {EXITS VISITS VIOLATIONS} of a call of the certified emitter CERT from
# composite C, from its recognizer's language (dfasem::LangApply), cached by
# the certificate's statement and C.
proc modcheck::LangSummary {cert c} {
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
    set r [dfasem::LangApply [dict get $cert key] [dict get $cert exits] [dict get $cert visits] [dict get $cert fails] $c]
    Time compose $t0
    dict set langCache $key $r
    return $r
}

# The coroutine construction whose thunk is E: the call it makes, probed
# (invocation-level checks: Invocation).
proc modcheck::ProbeThunk {e} {
    variable probe
    variable probed
    variable hir
    if {$probe eq "" || [Kind $e] ne "block"} return
    set last [lindex [dict get [Node $e] body] end]
    if {$last eq "" || [Kind $last] ne "call"} return
    lassign [dict get [Node $last] target] tk t
    if {$tk ne "block" || ($probe ne "*" && $t ne [lindex $probe 0])} return
    lappend probed [list $t $last [lmap a [dict get [Node $last] args] {PureValue $a}]]
}

# The value of E without walking it: a reference, a constant, or an
# operator of those (a coroutine construction's arguments are bindings of
# the caller).
proc modcheck::PureValue {e} {
    variable hir
    set node [Node $e]
    switch -- [dict get $node kind] {
        const {
            set v [dict get $node value]
            if {[core::value::kind $v] eq "int"} {
                return [intset::point [core::value::intOf $v]]
            }
            return *
        }
        ref { return [RefValue $e $node] }
    }
    return [TypeValue [TypeOf $e]]
}

# ---------------------------------------------------------------------------
# Yields

# 1 if E's value is a character's scalar value (a std::char::scalar_value
# call, or a binding bound to one).
proc modcheck::IsCharacter {e {depth 0}} {
    variable hir
    if {$depth > 20} { return 0 }
    if {[NativeName $e] eq "std::char::scalar_value"} { return 1 }
    set b [RefBinding $e]
    if {$b ne "" && [dict get [hir::binding $hir $b] declaredBy] ne ""} {
        set bind [dict get [hir::binding $hir $b] declaredBy]
        return [IsCharacter [dict get $hir exprs $bind value] [expr {$depth + 1}]]
    }
    return 0
}

# The yield E of the expression ARG, whose value is V, from the states S.
proc modcheck::Emit {e arg v s} {
    variable END
    variable visits
    if {$v eq "*"} {
        set type [TypeOf $arg]
        if {[IsInt $type] || $type in {any}} {
            Violation EMIT-UNKNOWN-VALUE $e "this yield's value is not known to be an Int" "" {}
        } else {
            Violation EMIT-NOT-SYMBOL $e "this yield sends a [hir::types::show $type], not an Int: an emitter's yields are symbols" "" {}
        }
        return [list {} {}]
    }
    if {[intset::inter $v [intset::point $END]] ne {}} {
        Violation EMIT-END-SYMBOL $e "this yield may send -1, which is the end of the input in the recognizer protocol, never a symbol" "" [intset::point $END]
        set v [intset::minus $v [intset::point $END]]
    }
    set character [IsCharacter $arg]
    set out {}
    foreach c $s {
        if {$c eq "free"} {
            lappend out free
            continue
        }
        set key [lindex $c 1]
        if {$character && [dfasem::Get $key alphabet] eq "bytes" && [intset::inter $v {{128 +inf}}] ne {}} {
            Violation EMIT-BYTE-CHARACTER $e "this yield may send the scalar value of a non-ASCII character to a recognizer over bytes: a character is not a byte (send its UTF-8 bytes)" $c {}
        }
        foreach r [dfasem::Step $c $v] {
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
proc modcheck::ViolationAt {e result c y {via ""}} {
    lassign $result - kind key q n
    set prefix ""
    if {$via ne ""} { set prefix "$via: " }
    switch -- $kind {
        reject { Violation EMIT-REJECTED $e "${prefix}this yield may send symbols no transition takes" $c $y }
        beyond { Violation EMIT-BEYOND-TOKEN $e "${prefix}this yield may send a symbol the token ends before (\"accept before\"), which would begin the next token" $c $y }
        after { Violation EMIT-AFTER-TOKEN $e "${prefix}this yield may send a symbol after the token is complete" done $y }
        lookahead { Violation EMIT-REJECTED $e "${prefix}a completion leaves $n symbols unread where its caller can reconsider one" $c $y }
        boundary {
            Violation EMIT-BOUNDARY $e "${prefix}this yield may send a symbol that continues the [dfasem::KeyText $key] token $q emitted (called at $n), which claims to emit that token whole: the token would absorb it" [dfasem::Base $c] $y
        }
    }
}

proc modcheck::Violation {kind e what c y} {
    variable viol
    lappend viol [list $kind $e $what $c $y]
}

# ---------------------------------------------------------------------------
# Conditions

# The environment on the paths where CONDITION has OUTCOME, or "" when no
# path is feasible: each path of hir::range::Paths narrows the bindings its
# comparisons compare (intset::Narrow, from the operands' values this walk
# computed), a statically known comparison (hir::types::KnownOutcome) or an
# empty binding making it infeasible; the environment is the union over the
# feasible paths.
proc modcheck::Facts {condition outcome} {
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
                if {$sv eq "*" || $ov eq "*"} continue
                set cur [dict getdef $penv $b $sv]
                if {$cur eq "*"} { set cur $sv }
                set n [intset::Narrow $mirror $cur $ov]
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

proc modcheck::JoinEnv {a b} {
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

proc modcheck::EvalIf {e node s} {
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

proc modcheck::EvalLoop {e node s} {
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
    if {$s eq {}} {
        return [list {} {}]
    }
    set before $env
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
proc modcheck::ExactCount {induction} {
    if {$induction eq {}} { return "" }
    lassign $induction b startExpr vs ve direction endKind
    if {![intset::isPoint $vs] || ![intset::isPoint $ve]} { return "" }
    set a [lindex $vs 0 0]
    set z [lindex $ve 0 0]
    set n [expr {$direction eq "up" ? $z - $a : $a - $z}]
    if {$endKind ne "exclusive"} { incr n }
    return [expr {$n < 0 ? 0 : $n}]
}

# A counted loop of exactly COUNT iterations (at most a few), each walked
# with its own induction value: no zero-iteration exit when it runs, no
# iteration past the last.
proc modcheck::Unrolled {e node s induction count before} {
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
        set i [expr {$direction eq "up" ? $a + $k : $a - $k}]
        dict set env $b [intset::point $i]
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
proc modcheck::Peel {induction} {
    if {$induction eq {}} {
        return {"" "" "" ""}
    }
    lassign $induction b startExpr vs ve direction endKind
    set rs [hir::range::unknown]
    if {$vs ne "*" && $vs ne {}} { set rs [intset::HullRange $vs] }
    set re [hir::range::unknown]
    if {$ve ne "*" && $ve ne {}} { set re [intset::HullRange $ve] }
    set all [intset::OfRange [hir::range::InductionBinding $rs $re $direction $endKind]]
    if {![intset::isPoint $vs]} {
        return [list $b $all "" ""]
    }
    set k [lindex $vs 0 0]
    set first [intset::inter $all [intset::point $k]]
    if {$direction eq "up"} {
        set later [intset::inter $all [intset::interval [expr {$k + 1}] +inf]]
    } else {
        set later [intset::inter $all [intset::interval -inf [expr {$k - 1}]]]
    }
    return [list $b $all $first $later]
}

# ---------------------------------------------------------------------------
# Handlers

proc modcheck::EvalHandle {e node s} {
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

# The certificates of block T usable here: its proven claims (this run's,
# or stored ones still valid).
proc modcheck::UsableCertificates {t} {
    variable certs
    variable claimsOf
    set out {}
    foreach key [dict getdef $claimsOf $t {}] {
        set name [FunctionName $t]
        if {[dict exists $certs [list $name [dfasem::KeyText $key]]]} {
            lappend out [dict get $certs [list $name [dfasem::KeyText $key]]]
        }
    }
    return $out
}

proc modcheck::CertRef {cert} {
    return [list [dict get $cert function] [dict get $cert recognizer] [dict get $cert statement]]
}

proc modcheck::UseGuard {t} {
    variable guardsUsed
    dict set guardsUsed $t 1
}

# Every summary reachable from KEY, KEY included.
proc modcheck::Reachable {key} {
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
# proof read (section 13 of the report).
proc modcheck::Certificate {claim keyset exits visits fails result} {
    variable cache
    variable version
    variable trustedUsed
    variable registeredUsed
    variable guardsUsed
    set b [dict get $claim block]
    set functions [dict create]
    set certDeps {}
    foreach k $keyset {
        set fb [lindex $k 0]
        dict set functions [FunctionName $fb] [FunctionFingerprint $fb]
        lappend certDeps {*}[dict get $cache $k certUses]
    }
    set recognizers [dict create [dfasem::KeyText [dict get $claim key]] [dfasem::DeepFingerprint [dict get $claim key]]]
    dict for {g -} $guardsUsed {
        set gkey [dict get $::modcheck::guardKeys $g]
        dict set recognizers [dfasem::KeyText $gkey] [dfasem::DeepFingerprint $gkey]
    }
    set node [Node $b]
    set cert [dict create function [FunctionName $b] recognizer [dfasem::KeyText [dict get $claim key]] \
        key [dict get $claim key] \
        domain [dict get $node declaredParamTypes] result $result \
        exits [lsort -unique $exits] \
        visits [lsort -unique [lmap x $visits {dfasem::Base $x}]] \
        fails [lsort -unique [lmap x $fails {dfasem::Base $x}]] \
        follow [dfasem::Follow $exits] \
        depends [dict create checker [Version] \
            functions [lsort -stride 2 -index 0 $functions] \
            certificates [lsort -unique $certDeps] \
            recognizers [lsort -stride 2 -index 0 $recognizers] \
            trusted [lsort -stride 2 -index 0 $trustedUsed] \
            registered [lsort -stride 2 -index 0 $registeredUsed]]]
    dict set cert digest [dfasem::Digest [dict remove $cert digest]]
    dict set cert statement [StatementDigest $cert]
    return $cert
}

# The digest of what certificate CERT states -- the function, its
# recognizer (by fingerprint), its declared domain, its exits and visits
# with their open obligations, its result, its boundary -- without what the
# proof read. A caller composing by the certificate depends on this alone:
# the function's code may change and be proved again without invalidating
# its callers, as long as it states the same.
proc modcheck::StatementDigest {cert} {
    set deps [dict get $cert depends]
    set r [dict get $cert recognizer]
    return [dfasem::Digest [list [dict get $cert function] $r [dict get $deps recognizers $r] \
        [dict get $cert domain] [dict get $cert exits] [dict get $cert visits] [dict get $cert fails] [dict get $cert result] \
        [dict get $cert follow]]]
}

# 1 if stored certificate CERT still holds in this compilation: every input
# its proof read is unchanged (the checker, every function's code, every
# recognizer's table, every trusted and registered native fact, every
# certificate it composed with).
# Adds the microseconds since T0 to the phase PHASE's total (stats).
proc modcheck::Version {} {
    variable version
    if {$version eq ""} {
        set text "modcheck-1"
        foreach f {modcheck.tcl intset.tcl dfasem.tcl} {
            append text \n [core::ReadFile [file join $::modcheckHere $f]]
        }
        set version [list [dfasem::Digest $text] [hir::interchange::fingerprint]]
    }
    return $version
}

proc modcheck::Time {phase t0} {
    variable phases
    dict incr phases $phase [expr {[clock microseconds] - $t0}]
}

proc modcheck::Valid {cert {seen {}}} {
    variable version
    variable byName
    variable trusted
    variable stored
    set deps [dict get $cert depends]
    if {[dict get $deps checker] ne [Version]} { return [list 0 "the checker or the front end changed"] }
    dict for {name fp} [dict get $deps functions] {
        if {![dict exists $byName $name]} { return [list 0 "$name is gone"] }
        if {[FunctionFingerprint [dict get $byName $name]] ne $fp} { return [list 0 "$name changed"] }
    }
    dict for {r fp} [dict get $deps recognizers] {
        set key [list [namespace qualifiers $r] [namespace tail $r]]
        if {![dfasem::Has $key] || [dfasem::DeepFingerprint $key] ne $fp} { return [list 0 "recognizer $r changed"] }
    }
    dict for {n set} [dict get $deps trusted] {
        if {![dict exists $trusted $n] || [dict get $trusted $n set] ne $set} { return [list 0 "the trusted fact of $n changed"] }
    }
    dict for {n range} [dict get $deps registered] {
        if {[catch {dict get [core::native::metadata $n] resultRange} now] || $now ne $range} { return [list 0 "the registered range of $n changed"] }
    }
    foreach ref [dict get $deps certificates] {
        lassign $ref fn r digest
        set id [list $fn $r]
        # The certificate this run holds (proved again, or found valid),
        # else the stored one, which must still be valid itself.
        if {[dict exists $::modcheck::certs $id]} {
            set dep [dict get $::modcheck::certs $id]
        } elseif {[dict exists $stored $id]} {
            set dep [dict get $stored $id]
            if {$id ni $seen} {
                lassign [Valid $dep [concat $seen [list $id]]] ok why
                if {!$ok} { return [list 0 "$fn for $r: $why"] }
            }
        } else {
            return [list 0 "the certificate of $fn for $r is gone"]
        }
        if {[dict get $dep statement] ne $digest} { return [list 0 "what the certificate of $fn for $r states changed"] }
    }
    return [list 1 ""]
}

proc modcheck::ReadStore {path} {
    if {$path eq "" || ![file exists $path]} { return [dict create] }
    set f [open $path r]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    return $text
}

proc modcheck::WriteStore {path store} {
    if {$path eq ""} return
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $store
    close $f
}

# ---------------------------------------------------------------------------
# Diagnostics

proc modcheck::Diagnostics {keyset claim} {
    variable cache
    set entries [dict create]
    foreach k $keyset {
        foreach v [dict get $cache $k violations] {
            lassign $v kind e what c y
            set id [list $kind $e]
            if {![dict exists $entries $id]} {
                dict set entries $id [dict create kind $kind expr $e what $what states [dict create]]
            }
            if {$c ne ""} {
                set old [dict getdef [dict get $entries $id states] $c {}]
                dict set entries $id states $c [intset::union $old $y]
            }
        }
    }
    return [lmap d [dict values $entries] {Message $d $claim}]
}

proc modcheck::Message {d claim} {
    set message [dict get $d what]
    set related {}
    set parts {}
    set byText [dict create]
    dict for {c y} [dict get $d states] {
        if {$c eq "free"} continue
        set text [dfasem::StateText [dfasem::Base $c]]
        dict set byText $text [list [intset::union [lindex [dict getdef $byText $text {{} {}}] 0] $y] $c]
        if {$c ne "done"} {
            lassign $c - key q
            set where [dfasem::StateLocation $key $q]
            set note [list "state $q of [dfasem::KeyText $key]" $where]
            if {$where ne "" && $note ni $related && [llength $related] < 4} {
                lappend related $note
            }
        }
    }
    dict for {text pair} $byText {
        lassign $pair y c
        if {$y ne {}} {
            set alphabet unicode
            if {$c ne "done"} { set alphabet [dfasem::Get [lindex $c 1] alphabet] }
            lappend parts "[dfasem::SetText $y $alphabet] in $text"
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
    set location [Location [dict get $d expr]]
    if {$claim ne "" && [dict get $claim location] ne $location} {
        lappend related [list "checking [dict get $claim name]'s claim to emit [dfasem::KeyText [dict get $claim key]]" [dict get $claim location]]
    }
    return [dict create kind [dict get $d kind] location $location message $message related $related]
}

# The completion: every exit state accepts the end; at the function.
proc modcheck::Finish {exits b key} {
    variable END
    set out {}
    foreach c $exits {
        if {$c eq "done"} continue
        foreach r [dfasem::Step $c [intset::point $END]] {
            lassign $r y result
            if {$result eq "done"} continue
            lassign [dfasem::Expected $c] takes completes
            set needs [intset::union $takes $completes]
            set alphabet [dfasem::Get [lindex $c 1] alphabet]
            if {[lindex $result 1] eq "beyond"} {
                set what "this emitter may complete where [dfasem::KeyText $key]'s token ends before its last symbols (they would not be part of it)"
            } else {
                set what "this emitter may complete with its [dfasem::KeyText $key] token incomplete, where the end of the input is rejected (the state needs one of the symbols shown)"
            }
            lappend out [list EMIT-INCOMPLETE $b $what $c $needs]
        }
    }
    return $out
}

# ---------------------------------------------------------------------------
# The program

proc modcheck::Reset {} {
    foreach v {cache langCache contexts certs claimsOf guards fingerprints names byName topLevel
            trustedUsed registeredUsed guardsUsed guardKeys stored} {
        set ::modcheck::$v [dict create]
    }
    set ::modcheck::claims {}
    set ::modcheck::round 0
    set ::modcheck::computed 0
    set ::modcheck::reused 0
    set ::modcheck::budgetHit 0
    set ::modcheck::probe ""
    set ::modcheck::probed {}
    set ::modcheck::observedAll ""
    set ::modcheck::phases [dict create]
    set ::modcheck::roundsTotal 0
}

# Loads the program at PATH: its HIR, recognizers, function names, guards
# and claims.
proc modcheck::Load {path emits} {
    variable hir
    variable names
    variable byName
    variable topLevel
    variable guards
    variable guardKeys
    variable claims
    variable claimsOf
    set path [file normalize $path]
    set ::modcheck::entryPath $path
    set keys [dfasem::load $path]
    set hir [surface::readProgramFile $path -warnings off]
    hir::activate $hir
    set byLine [dict create]
    set files [dict create]
    dict for {f entry} [dict get $hir files] {
        dict set files $f [file normalize [dict get $entry path]]
    }
    set blockParents [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "bind"} continue
        set v [dict get $node value]
        if {[dict get $hir exprs $v kind] ne "block"} continue
        set binding [hir::binding $hir [dict get $node binding]]
        if {[dict get $binding kind] ne "local"} continue
        set name [dict get $binding name]
        if {[string first # $name] >= 0 && ![string match *#run $name]} {
            # (A hygiene-renamed local function: not a top-level name.)
        }
        dict set names $v $name
        dict set byName $name $v
        dict set topLevel $e 1
        set origin [dict get $node origin]
        if {[lindex $origin 0] eq "file"} {
            set file [dict get $files [lindex $origin 1]]
            dict set byLine [list $file [dict get [lrange $origin 2 end] line]] [list $v $name]
        }
    }
    # Guards: recognizers none of whose transitions suspends, by block; the
    # symbols on which their first step completes, whatever it leaves
    # unread: what a normal completion of a call proves of its argument.
    foreach key $keys {
        set q [dfasem::KeyText $key]
        if {![dict exists $byName $q]} continue
        set b [dict get $byName $q]
        if {[hir::coroutines::MayYield $hir $b]} continue
        set completes {}
        foreach r [dfasem::StepBase [dfasem::Initial $key] [intset::minus [intset::universe] [intset::point -1]]] {
            lassign $r y result
            if {$result eq "done" || ([lindex $result 0] eq "violation" && [lindex $result 1] eq "beyond")} {
                set completes [intset::union $completes $y]
            }
        }
        dict set guards $b $completes
        dict set guardKeys $b $key
    }
    set claims {}
    dict for {ns file} [dfasem::ApplicationFiles $path] {
        foreach d [Directives $file] {
            lassign $d line name recognizer
            set fk [list [file normalize $file] $line]
            if {![dict exists $byLine $fk]} {
                error "modcheck: no function $name at $file:$line"
            }
            lassign [dict get $byLine $fk] b qname
            lappend claims [dict create block $b name $qname recognizer $recognizer \
                key [RecognizerKey $recognizer $ns] location [Location $b]]
        }
    }
    foreach {fn recognizer} $emits {
        if {![dict exists $byName $fn]} { error "modcheck: no function $fn" }
        set b [dict get $byName $fn]
        lappend claims [dict create block $b name $fn recognizer $recognizer \
            key [RecognizerKey $recognizer [namespace qualifiers $fn]] location [Location $b]]
    }
    foreach c $claims {
        if {[dict get $c key] ne ""} {
            dict lappend claimsOf [dict get $c block] [dict get $c key]
        }
    }
}

# Checks claim CLAIM (definition level): its result dict.
proc modcheck::CheckClaim {claim witness} {
    variable cache
    variable certs
    variable stored
    variable trustedUsed
    variable registeredUsed
    variable guardsUsed
    variable budgetHit
    variable computed
    variable reused
    set t0 [clock microseconds]
    set c0 $computed
    set r0 $reused
    set b [dict get $claim block]
    set name [dict get $claim name]
    set result [dict create name $name recognizer [dict get $claim recognizer] location [dict get $claim location]]
    set key [dict get $claim key]
    if {$key eq ""} {
        dict set result verdict not-proved
        dict set result diagnostics [list [dict create kind EMIT-UNKNOWN-RECOGNIZER location [dict get $claim location] \
            message "$name is declared to emit [dict get $claim recognizer], which is no declared recognizer" related {}]]
        return $result
    }
    set id [list $name [dfasem::KeyText $key]]
    # A stored certificate still valid: reused, not proved again.
    if {[dict exists $stored $id]} {
        set tv [clock microseconds]
        lassign [Valid [dict get $stored $id]] ok why
        Time validate $tv
        if {$ok} {
            dict set certs $id [dict get $stored $id]
            dict set result verdict proven
            dict set result reused 1
            dict set result certificate [dict get $stored $id]
            dict set result diagnostics {}
            dict set result follow [dict get $stored $id follow]
            dict set result ms [expr {([clock microseconds] - $t0) / 1000.0}]
            return $result
        }
        dict set result invalidated $why
    }
    set trustedUsed [dict create]
    set registeredUsed [dict create]
    set guardsUsed [dict create]
    set budgetHit 0
    set entry [dfasem::Initial $key]
    set args_ [Declared $b]
    if {$::modcheck::facts eq "observed"} {
        # The exploratory model, for comparison only: the arguments the
        # program's own calls pass, never a property of the declaration.
        set args_ [Observed $b]
        if {$args_ eq "unused"} {
            dict set result verdict not-proved
            dict set result diagnostics [list [dict create kind EMIT-UNUSED location [dict get $claim location] \
                message "$name is not called by the program: observed facts give nothing to check" related {}]]
            return $result
        }
    }
    set rec [Solve $b $entry $args_]
    set keyset [Reachable [list $b $entry $args_]]
    set diags [Diagnostics $keyset $claim]
    set exits [dict get $rec exits]
    foreach v [Finish $exits $b $key] {
        lassign $v kind e what c y
        lappend diags [Message [dict create kind $kind expr $e what $what states [dict create $c $y]] $claim]
    }
    # A claimed emitter whose result is an Int is a symbol source: it must
    # complete with -1, the end.
    set declared [dict get [Node $b] declaredResult]
    set value [dict get $rec result]
    if {$exits ne {} && $declared ne "" && [IsInt $declared] && $value ne [intset::point -1]} {
        lappend diags [dict create kind EMIT-TERMINAL-VALUE location [dict get $claim location] \
            message "$name returns an Int, so it is a symbol source, and its final value may be [ValueText $value], not -1: a consumer reading values after the end would read it as a symbol" related {}]
    }
    if {$budgetHit} {
        lappend diags [dict create kind EMIT-BUDGET location [dict get $claim location] \
            message "the analysis of $name's claim exhausted its budget: not proved" related {}]
    }
    set diags [lsort -command modcheck::ByLocation $diags]
    dict set result diagnostics $diags
    dict set result summaries [llength $keyset]
    dict set result computed [expr {$computed - $c0}]
    dict set result reusedSummaries [expr {$reused - $r0}]
    if {$diags eq {}} {
        set tc [clock microseconds]
        set cert [Certificate $claim $keyset $exits [dict get $rec visits] [dict get $rec fails] $value]
        Time certify $tc
        dict set certs $id $cert
        dict set result verdict proven
        dict set result certificate $cert
        dict set result follow [dict get $cert follow]
    } else {
        dict set result verdict not-proved
        if {$witness} {
            set w [modcheck::Witness $claim]
            if {$w ne ""} {
                dict set result verdict disproven
                dict set result witness $w
            }
        }
    }
    dict set result ms [expr {([clock microseconds] - $t0) / 1000.0}]
    return $result
}

# The argument values every call of block T in the program passes, united
# -- each function walked with what its own callers pass, from the
# program's top-level statements, to a fixpoint (past a few rounds, a
# function's still-changing arguments are its declared ones): the facts
# the exploratory checker read from the program, for the comparison of
# section 3 -- or `unused`.
proc modcheck::Observed {t} {
    variable observedAll
    if {$observedAll eq ""} {
        set observedAll [ObservedAll]
    }
    return [dict getdef $observedAll $t unused]
}

proc modcheck::ObservedAll {} {
    variable probe
    variable probed
    set probe *
    set probed {}
    Walk program free {}
    set obs [dict create]
    set changed [MergeProbed obs $probed]
    for {set round 0} {$round < 8 && $changed ne {}} {incr round} {
        set next {}
        foreach f [dict keys $obs] {
            set probed {}
            Walk $f free [dict get $obs $f]
            lappend next {*}[MergeProbed obs $probed]
        }
        set changed [lsort -unique $next]
    }
    foreach f $changed {
        dict set obs $f [Declared $f]
    }
    set probe ""
    return $obs
}

# Folds the probed calls PROBED ({TARGET EXPR VALUES}...) into OBSVAR's
# arguments: the targets whose arguments grew.
proc modcheck::MergeProbed {obsVar probed} {
    upvar 1 $obsVar obs
    set grew {}
    foreach p $probed {
        lassign $p t e vals
        if {![dict exists $obs $t]} {
            dict set obs $t $vals
            lappend grew $t
            continue
        }
        set old [dict get $obs $t]
        set new [lmap a $old v $vals {Join $a $v}]
        if {$new ne $old} {
            dict set obs $t $new
            lappend grew $t
        }
    }
    return [lsort -unique $grew]
}

# The functions the program's top-level statements reach, through calls
# and coroutine constructions (the exploratory checker's used instances).
proc modcheck::UsedFunctions {} {
    variable hir
    set seen [dict create]
    set out {}
    set stack [hir::roots $hir]
    while {[llength $stack]} {
        set stack [lassign $stack e]
        set node [Node $e]
        if {[dict get $node kind] eq "call"} {
            lassign [dict get $node target] tk t
            if {$tk eq "block" && ![dict exists $seen $t]} {
                dict set seen $t 1
                lappend out $t
                lappend stack {*}[dict get [Node $t] body]
            }
        }
        lappend stack {*}[hir::children $hir $e]
    }
    return $out
}

# Invocation-level: every call (or coroutine construction) of CALLEE in
# CALLER, checked from R's start with the argument facts CALLER's own body
# (entered with its declared parameters) has there.
proc modcheck::Invocation {caller callee recognizer} {
    variable byName
    variable probe
    variable probed
    set cb [dict get $byName $caller]
    set tb [dict get $byName $callee]
    set key [RecognizerKey $recognizer [namespace qualifiers $callee]]
    set probe [list $tb]
    set probed {}
    Walk $cb free [Declared $cb]
    set probe ""
    set sites [dict create]
    foreach p $probed {
        lassign $p - e vals
        if {[dict exists $sites $e]} {
            set old [dict get $sites $e]
            dict set sites $e [lmap a $old v $vals {Join $a $v}]
        } else {
            dict set sites $e $vals
        }
    }
    set out {}
    dict for {e vals} $sites {
        set entry [dfasem::Initial $key]
        set vals [lmap v $vals t [dict get [Node $tb] declaredParamTypes] {
            if {$t ne ""} { Meet $v $t } else { set v }
        }]
        set rec [Solve $tb $entry $vals]
        set keyset [Reachable [list $tb $entry $vals]]
        set claim [dict create name $callee key $key location [Location $e]]
        set diags [Diagnostics $keyset $claim]
        foreach v [Finish [dict get $rec exits] $tb $key] {
            lassign $v kind ve what c y
            lappend diags [Message [dict create kind $kind expr $ve what $what states [dict create $c $y]] $claim]
        }
        lappend out [dict create caller $caller callee $callee recognizer $recognizer site [Location $e] \
            arguments [lmap v $vals {ValueText $v}] \
            verdict [expr {$diags eq {} ? "proven" : "not-proved"}] diagnostics $diags]
    }
    return $out
}

proc modcheck::ValueText {v} {
    if {$v eq "*"} { return "unknown" }
    return [intset::text $v]
}

proc modcheck::ByLocation {a b} {
    set la [split [dict get $a location] :]
    set lb [split [dict get $b location] :]
    set c [string compare [lindex $la 0] [lindex $lb 0]]
    if {$c != 0} { return $c }
    foreach i {1 2} {
        set x [lindex $la $i]
        set y [lindex $lb $i]
        if {![string is integer -strict $x] || ![string is integer -strict $y]} continue
        if {$x != $y} { return [expr {$x < $y ? -1 : 1}] }
    }
    return [string compare [dict get $a kind] [dict get $b kind]]
}

# Checks the program at PATH (the header's options).
proc modcheck::check {path args} {
    variable stored
    variable certs
    variable compose
    variable computed
    variable reused
    set options [dict merge {-emits {} -compose certificate -store "" -invocation {} -witness 1 -only {}
        -facts declared} $args]
    set compose [dict get $options -compose]
    set ::modcheck::facts [dict get $options -facts]
    Reset
    set t0 [clock microseconds]
    Load $path [dict get $options -emits]
    set t1 [clock microseconds]
    set stored [ReadStore [dict get $options -store]]
    if {$::modcheck::facts eq "observed"} {
        # (Observed facts certify nothing reusable: no store.)
        set stored [dict create]
        dict set options -store ""
    }
    set results {}
    # Claims in dependency order: a helper's claim before its callers', so
    # a caller composes with the helper's certificate.
    foreach claim [Ordered] {
        if {[dict get $options -only] ne {} && [dict get $claim name] ni [dict get $options -only]} continue
        lappend results [CheckClaim $claim [dict get $options -witness]]
    }
    set invocations {}
    foreach {caller callee r} [dict get $options -invocation] {
        lappend invocations {*}[Invocation $caller $callee $r]
    }
    set t2 [clock microseconds]
    set store $stored
    dict for {id cert} $certs {
        dict set store $id $cert
    }
    # A stored certificate this run found invalid is dropped.
    foreach r $results {
        if {[dict exists $r invalidated] && [dict get $r verdict] ne "proven"} {
            dict unset store [list [dict get $r name] [dfasem::KeyText [RecognizerKey [dict get $r recognizer] [namespace qualifiers [dict get $r name]]]]]
        }
    }
    WriteStore [dict get $options -store] $store
    set phaseMs [dict create]
    dict for {k v} $::modcheck::phases {
        dict set phaseMs $k [expr {$v / 1000}]
    }
    return [dict create claims $results invocations $invocations certificates $certs \
        stats [dict create frontEndMs [expr {($t1 - $t0) / 1000}] checkMs [expr {($t2 - $t1) / 1000}] \
            summariesComputed $computed summariesReused $reused rounds $::modcheck::roundsTotal phaseMs $phaseMs]]
}

# The claims, callees first: a claim of a function another claimed
# function calls (directly or not) comes before the caller's.
proc modcheck::Ordered {} {
    variable claims
    variable hir
    set calls [dict create]
    foreach c $claims {
        dict set calls [dict get $c block] [Callees [dict get $c block]]
    }
    set out {}
    set placed [dict create]
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
proc modcheck::Callees {b} {
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
                if {$tk eq "block"} {
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

proc modcheck::Format {result} {
    set out {}
    foreach c [dict get $result claims] {
        foreach d [dict get $c diagnostics] {
            append out "[dict get $d location]: [dict get $d message] (EMIT [dict get $d kind])\n"
            foreach r [dict get $d related] {
                append out "    [lindex $r 1]: note: [lindex $r 0]\n"
            }
        }
        set line "claim [dict get $c name] emits [dict get $c recognizer]: [dict get $c verdict]"
        if {[dict exists $c reused]} { append line " (certificate reused)" }
        if {[dict exists $c invalidated]} { append line " (stored certificate invalid: [dict get $c invalidated])" }
        if {[dict exists $c witness]} { append line "; counterexample: [dict get $c witness]" }
        if {[dict get $c verdict] eq "proven"} {
            set f [dict get $c follow]
            if {$f eq "self"} {
                append line "; boundary: completes on its own last symbol"
            } elseif {$f eq {}} {
                append line "; boundary: the end only"
            } else {
                append line "; boundary: the end, or [intset::text $f]"
            }
        }
        append out $line \n
    }
    foreach i [dict get $result invocations] {
        append out "invocation of [dict get $i callee] in [dict get $i caller] at [dict get $i site] ([join [dict get $i arguments] {, }]) emits [dict get $i recognizer]: [dict get $i verdict]\n"
        foreach d [dict get $i diagnostics] {
            append out "    [dict get $d location]: [dict get $d message] (EMIT [dict get $d kind])\n"
        }
    }
    return $out
}

# The counterexample search (tools/concrete.tcl), when loaded; else none.
proc modcheck::Witness {claim} {
    if {[info commands ::concrete::witness] eq ""} {
        return ""
    }
    return [concrete::witness $claim]
}

if {[info exists argv0] && [file normalize $argv0] eq [file normalize [info script]]} {
    set path ""
    set options {}
    set emits {}
    set invocation {}
    for {set i 0} {$i < [llength $argv]} {incr i} {
        set a [lindex $argv $i]
        switch -- $a {
            -emits { lassign [split [lindex $argv [incr i]] =] fn r; lappend emits $fn $r }
            -invocation { lappend invocation {*}[split [lindex $argv [incr i]] ,] }
            -compose - -store - -witness - -only - -facts { lappend options $a [lindex $argv [incr i]] }
            default { set path $a }
        }
    }
    if {$path eq ""} {
        puts stderr "usage: tclsh9.0 audit/emission-proofs/tools/modcheck.tcl PROGRAM.bot ?-emits FN=R? ?-compose body|certificate? ?-store FILE? ?-invocation CALLER,CALLEE,R? ?-witness 0|1?"
        exit 2
    }
    interp recursionlimit {} 100000
    source [file join [file dirname [file normalize [info script]]] concrete.tcl]
    set result [modcheck::check $path -emits $emits -invocation $invocation {*}$options]
    puts -nonewline [modcheck::Format $result]
    set bad 0
    foreach c [dict get $result claims] {
        if {[dict get $c verdict] ne "proven"} { set bad 1 }
    }
    exit $bad
}
