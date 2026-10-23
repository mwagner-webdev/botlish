# methodfilter.tcl -- deciding method-style calls by kind, in waves
# (METHOD-DECISION-FILTER.md).
#
#   hir::methodfilter::Decide NODES OPTIONS GIVEN HIR SEEDS   => dict
#   hir::methodfilter::NativeMismatch NATIVE RECEIVERTYPE     => {} | {KIND WANTED}
#
# hir::DecideMethodCalls (hir/hir.tcl) decides a method-style call
# `receiver.name(args)` with several visible candidates by the rule of
# METHOD-SUGAR.md -- the call is the candidate whose ordinary call is the only
# valid one -- and learns what each candidate does by whole-program trial
# builds. A build is a pure function of its configuration, so the exact
# decision needs about one build per candidate index per pass of a receiver
# chain (hir::DecideMethodCalls's header), each re-checking the whole program.
#
# This file is the cheaper way to reach the same decisions when it can:
#
#   * A candidate is *excluded* for a call when the receiver's type already
#     makes the ordinary call invalid by kind alone -- a native whose first
#     parameter has another known kind (exactly the TYPE problem
#     hir::MethodCallProblems reports for it, one rule for both:
#     NativeMismatch), or a module function whose declared, trusted or checked
#     first-parameter contract has another known kind -- or, for a receiver
#     of a named struct type, whose declared first parameter is a named
#     struct of another declaration (named structs are nominal: no other
#     struct is ever one's subtype, hir::types::subtype). An exclusion is a
#     proof that the candidate is invalid, never that another is valid: the
#     filter over-approximates validity, so it can neither accept a call that
#     is ambiguous (two valid candidates are both among the survivors) nor
#     skip a candidate that could be valid.
#   * A call whose receiver leaves exactly one survivor is decided to it. The
#     receiver's type is read from the last build, in which the calls not yet
#     decided stand at their first candidate; a decision made from a receiver
#     that a later decision changes is taken back (evicted) when the next
#     build shows it. Decisions are made in waves, one build per wave -- one
#     per link of a receiver chain, where the exact decision tries every
#     candidate index of every pass.
#   * The result is accepted only with a certificate (Decide): every call is
#     decided, the last build was made under exactly the decisions that stand,
#     every survivor set in it is still the decision, and no chosen candidate
#     has a problem of its own. That build is the final program -- the exact
#     decision's own fixed point, reached without trials.
#
# Anything else -- a call with several survivors (an ambiguous receiver, an
# untyped one, a candidate the filter cannot compare), none (no applicable
# method), a problem in a chosen candidate, an eviction left standing, the
# wave limit -- is not the filter's to decide: Decide reports it, and
# hir::DecideMethodCalls makes the exact decision from the start, so every
# rejection, ambiguity and error message is the exact one's. The filter
# changes how many builds a decision takes, never its outcome
# (hir::methodFilterAudit makes the exact decision as well and fails unless
# both agree: tests/method-filter.test, audit/method-filter).

namespace eval hir::methodfilter {
    # The builds (waves) the filter may spend before the exact decision takes
    # over. A chain of n dependent calls needs at most n waves; the limit only
    # bounds the work wasted on a program the filter cannot finish.
    variable maxWaves 8
    # The kinds a non-native candidate's parameter contract and the receiver
    # are compared in. A domain or a refinement is named by another kind
    # (core::type::base), and an integer is admitted by range proofs, so a
    # kind outside this set excludes nothing.
    variable comparableKinds [list int str bool unit UnicodeChar list struct enum mutvec mutarray {*}[core::type::floatTypes]]
    # Candidate -> the kinds of its first parameter's contracts, for the HIR
    # being read (ResetCache clears it with every new build).
    variable paramKinds [dict create]
    # Candidate -> its first parameter's declared type ("" when it has none),
    # for the HIR being read (ResetCache clears it too).
    variable declaredParams [dict create]
    # The expressions of the method-style calls of the HIR Closed reads.
    variable methodExprs [dict create]
    # 1 prints what the filter does, one line per event, on stderr
    # (BOTLISH_METHOD_FILTER_TRACE=1 sets it for a process): the waves, the
    # decisions taken back and why a decision was handed over.
    variable trace 0
    if {[info exists ::env(BOTLISH_METHOD_FILTER_TRACE)] && $::env(BOTLISH_METHOD_FILTER_TRACE) ni {"" 0}} {
        set trace 1
    }
}

proc hir::methodfilter::Trace {args} {
    variable trace
    if {$trace} {
        puts stderr "method-filter: [join $args { }]"
    }
}

proc hir::methodfilter::ResetCache {} {
    variable paramKinds
    variable declaredParams
    set paramKinds [dict create]
    set declaredParams [dict create]
}

# {KIND WANTED} when the receiver of type RECEIVERTYPE is of a statically
# known kind other than the one the first parameter of NATIVE requires --
# the ordinary call is a TYPE error -- else {}. The one statement of this
# rule: hir::MethodCallProblems reports it, Excluded rules a candidate out
# by it.
proc hir::methodfilter::NativeMismatch {native receiverType} {
    if {$receiverType eq "never"} {
        return {}
    }
    set kind [hir::types::kindOf $receiverType]
    if {$kind eq ""} {
        return {}
    }
    set paramTypes [dict get [core::native::metadata $native] paramTypes]
    if {$paramTypes eq ""} {
        return {}
    }
    set wanted [core::type::base [lindex $paramTypes 0]]
    if {$wanted eq "" || $kind eq $wanted} {
        return {}
    }
    return [list $kind $wanted]
}

# The kinds of the contracts on the first parameter of module function CAND
# (display "NS::NAME") in HIR: declared, trusted-inferred and checked-inferred
# (hir/signatures.tcl); {} for anything that is not a module function with
# such a parameter.
proc hir::methodfilter::ParamKinds {hir ns cand} {
    variable paramKinds
    if {[dict exists $paramKinds $cand]} {
        return [dict get $paramKinds $cand]
    }
    set kinds {}
    set v [CandidateBlock $hir $ns $cand]
    if {$v ne ""} {
        foreach field {declaredParamTypes inferredParamTypes checkedParamTypes} {
            if {![dict exists $hir exprs $v $field]} continue
            set t [lindex [dict get $hir exprs $v $field] 0]
            if {$t ne ""} {
                lappend kinds [hir::types::kindOf $t]
            }
        }
    }
    dict set paramKinds $cand $kinds
    return $kinds
}

# The declared type of the first parameter of module function CAND (display
# "NS::NAME") in HIR, "" when it declares none or is no module function. Only
# a declaration: NominalMismatch is stated for declared types, and an
# inferred contract's struct stays the kind rule's (which compares no
# declarations).
proc hir::methodfilter::DeclaredParam {hir ns cand} {
    variable declaredParams
    if {[dict exists $declaredParams $cand]} {
        return [dict get $declaredParams $cand]
    }
    set t ""
    set v [CandidateBlock $hir $ns $cand]
    if {$v ne "" && [dict exists $hir exprs $v declaredParamTypes]} {
        set t [lindex [dict get $hir exprs $v declaredParamTypes] 0]
    }
    dict set declaredParams $cand $t
    return $t
}

# The block of module function CAND (display "NS::NAME") in HIR, or "".
proc hir::methodfilter::CandidateBlock {hir ns cand} {
    if {![dict exists $hir modules $ns]} {
        return ""
    }
    set scope [dict get $hir modules $ns]
    if {![dict exists $hir scopes $scope names $cand]} {
        return ""
    }
    set b [dict get $hir scopes $scope names $cand]
    set d [dict get $hir bindings $b declaredBy]
    if {$d eq "" || ![dict exists $hir exprs $d value]} {
        return ""
    }
    set v [dict get $hir exprs $d value]
    if {[dict get $hir exprs $v kind] ne "block"} {
        return ""
    }
    return $v
}

# 1 if a receiver of type R rules out a first parameter declared DECLARED by
# nominal identity: both are named structs (applications or not) of two
# declarations. Named structs are nominal -- an argument is admitted to a
# struct parameter by hir::types::subtype alone
# (hir::range::ProvesValueAcceptedBy), and no other struct, named or
# anonymous, is ever a named one's subtype -- so the ordinary call is a TYPE
# error whatever the type arguments are. The arguments are never compared:
# a declared parameter's are often imprint variables.
proc hir::methodfilter::NominalMismatch {declared R} {
    expr {[hir::types::IsNamedStruct $declared] && [hir::types::IsNamedStruct $R]
        && [lindex $declared 1] ne [lindex $R 1]}
}

# 1 if candidate CAND (a display of a methodCalls entry) is invalid for a
# receiver of type R by kind alone, or by a named struct's identity
# (NominalMismatch). A bare name is a lexical candidate (a function of the
# file, a parameter, a binding): never excluded.
proc hir::methodfilter::Excluded {hir cand R} {
    variable comparableKinds
    if {$R eq "never"} {
        return 0
    }
    set receiverKind [hir::types::kindOf $R]
    if {$receiverKind eq ""} {
        return 0
    }
    if {![regexp {^(.+)::[^:]+$} $cand -> ns]} {
        return 0
    }
    if {[core::native::isQualifiedNative $cand]} {
        return [expr {[NativeMismatch $cand $R] ne {}}]
    }
    foreach kind [ParamKinds $hir $ns $cand] {
        if {$kind in $comparableKinds && $receiverKind in $comparableKinds && $kind ne $receiverKind} {
            return 1
        }
    }
    return [NominalMismatch [DeclaredParam $hir $ns $cand] $R]
}

# The type binding B was defined with: a parameter's declared type, else the
# type of the value it was bound to (`any` when neither is known).
proc hir::methodfilter::DefinedType {hir b} {
    set binding [dict get $hir bindings $b]
    if {[dict get $binding kind] eq "param"} {
        set scope [dict get $binding scope]
        set owner [dict getdef $hir scopes $scope owner ""]
        if {$owner ne "" && [dict exists $hir exprs $owner params]} {
            set i [lsearch -exact [dict get $hir exprs $owner params] $b]
            if {$i >= 0} {
                set declared [lindex [dict get $hir exprs $owner declaredParamTypes] $i]
                if {$declared ne ""} {
                    return $declared
                }
            }
        }
    }
    return [hir::bindingType $hir $b]
}

# The receiver of method call KEY in HIR: its expression and its type, {} for a
# call without a receiver. With GUESS, a receiver that is a reference to a
# binding is read as the type the binding was defined with (DefinedType) when
# that has a kind: a narrower type of the same kind rules out the same
# candidates, and a receiver that is `never`, or of another kind, is the work of
# the build's default candidates for the calls before it, which narrowed the binding
# (the chain `a.at(0)`, `a.at(1)` on a MutableArray, with `std::list::at` standing
# for both, narrows `a` to nothing for the second). A guess decides a whole
# chain in one wave; it is only a guess -- every decision is read again
# without it, from a build in which the calls before it are decided (Decide),
# and a decision whose receiver is not what the guess said is taken back.
proc hir::methodfilter::Receiver {hir key guess} {
    if {![dict exists $hir methodCalls $key]} {
        return {}
    }
    set args [dict get $hir exprs [dict get $hir methodCalls $key expr] args]
    if {$args eq ""} {
        return {}
    }
    set receiver [lindex $args 0]
    set R [hir::typeOf $hir $receiver]
    if {$guess} {
        set node [dict get $hir exprs $receiver]
        if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""} {
            set defined [DefinedType $hir [dict get $node binding]]
            set definedKind [hir::types::kindOf $defined]
            if {$definedKind ne ""} {
                set R $defined
            }
        }
    }
    return [list $receiver $R]
}

# The candidates of method call KEY (of CALLS) that its receiver in HIR does
# not exclude (Receiver, with GUESS); {} when the call has no receiver. Exactly
# one is a decision.
proc hir::methodfilter::Survivors {hir calls key {guess 0}} {
    set receiver [Receiver $hir $key $guess]
    if {$receiver eq ""} {
        return {}
    }
    set R [lindex $receiver 1]
    return [lmap cand [dict get $calls $key candidates] {
        if {[Excluded $hir $cand $R]} continue
        set cand
    }]
}

# 1 if the type of expression E in HIR is a function of the program text alone,
# whatever the method calls decide: constants, references to parameters with a
# declared type and to bindings bound to such an expression, and calls of
# natives on such arguments. (A call of a function of the program may have its
# result inferred from calls still undecided, and a method-style call is the
# decision's own, whatever candidate it stands at.)
proc hir::methodfilter::Closed {hir e {depth 0}} {
    if {$depth > 20 || ![dict exists $hir exprs $e]} {
        return 0
    }
    if {$depth == 0} {
        variable methodExprs
        set methodExprs [dict create]
        dict for {key info} [dict get $hir methodCalls] {
            dict set methodExprs [dict get $info expr] 1
        }
    }
    variable methodExprs
    if {[dict exists $methodExprs $e]} {
        # A method-style call is the decision's own: its candidate, and so its
        # result, is what is being decided.
        return 0
    }
    set node [dict get $hir exprs $e]
    switch -- [dict get $node kind] {
        const {
            return 1
        }
        ref {
            set b [dict get $node binding]
            if {$b eq ""} {
                return 0
            }
            set binding [dict get $hir bindings $b]
            switch -- [dict get $binding kind] {
                param {
                    set defined [DefinedType $hir $b]
                    return [expr {$defined ne "any" && $defined ne ""}]
                }
                local {
                    set d [dict get $binding declaredBy]
                    if {$d eq "" || ![dict exists $hir exprs $d value]} {
                        return 0
                    }
                    return [Closed $hir [dict get $hir exprs $d value] [expr {$depth + 1}]]
                }
                default {
                    return 0
                }
            }
        }
        call {
            set callee [dict get $hir exprs [dict get $node callee]]
            if {[dict get $callee kind] ne "ref" || [dict get $callee binding] eq ""} {
                return 0
            }
            set binding [dict get $hir bindings [dict get $callee binding]]
            if {[dict get $binding kind] ne "root" || [dict get $binding symbol] eq ""
                    || [dict get $hir symbols [dict get $binding symbol] kind] ne "native"} {
                return 0
            }
            foreach arg [dict get $node args] {
                if {![Closed $hir $arg [expr {$depth + 1}]]} {
                    return 0
                }
            }
            return 1
        }
        default {
            return 0
        }
    }
}

# 1 if method call KEY has a receiver that no decision can change (Closed) and
# that is not `never` (a binding a default candidate narrowed to nothing is
# poisoned, not settled), or none at all: with other than one survivor it is
# not the filter's to decide.
proc hir::methodfilter::Hopeless {hir key} {
    set receiver [Receiver $hir $key 0]
    return [expr {$receiver eq ""
        || ([lindex $receiver 1] ne "never" && [Closed $hir [lindex $receiver 0]])}]
}

# Tries to decide the method-style calls of HIR (the first build of the
# syntax NODES with OPTIONS and GIVEN; SEEDS as for hir::DecideMethodCalls)
# by the waves above. A dict:
#
#   attempted  0 when there was nothing for the filter to decide (every call
#              was seeded or decided by its trait): no build was made
#   certified  1 when the decision is complete and certified
#   hir        the final program, when certified: the last build (or HIR
#              itself, when no wave changed the configuration), with the
#              decisions in its methodChoices and methodDecided
#   builds     the builds the waves made
#
# Leaves the process in the state of the last build it made, which a
# certified result is; hir::DecideMethodCalls activates HIR again before the
# exact decision when it was not.
proc hir::methodfilter::Decide {nodes options given hir seeds} {
    variable maxWaves
    set calls [dict get $hir methodCalls]
    set keys [lmap {key info} $calls {
        if {[string is integer -strict $key]} continue
        set key
    }]
    set decided [dict create]
    dict for {key choice} $seeds {
        if {[dict exists $calls $key] && $choice in [dict get $calls $key candidates]} {
            dict set decided $key $choice
        }
    }
    hir::TraitCallsDecided $hir $calls decided
    set open [lmap key $keys {
        if {[dict exists $decided $key]} continue
        set key
    }]
    if {$open eq ""} {
        return [dict create attempted 0 certified 0 builds 0]
    }
    ResetCache
    set built $hir
    set lastConfig [lmap {key info} $calls {dict get $info chosen}]
    set owned [dict create]
    # The decisions taken back: decided again only from a receiver that is
    # what it is, never from a guess.
    set taken [dict create]
    set builds 0
    for {set wave 0} {$wave < $maxWaves} {incr wave} {
        set newly [dict create]
        foreach key $keys {
            if {[dict exists $decided $key]} continue
            set survivors [Survivors $built $calls $key [expr {![dict exists $taken $key]}]]
            if {[llength $survivors] == 1} {
                dict set newly $key [lindex $survivors 0]
            } elseif {[Hopeless $built $key]} {
                # Not one survivor, and a receiver no decision can change: the
                # exact decision's call, and the others cannot be certified
                # without it.
                Trace handed over: [llength $survivors] survivors for $key, whose receiver is closed
                if {$builds > 0} {
                    dict incr ::hir::buildStats methodFilterAbandoned
                }
                return [dict create attempted 1 certified 0 builds $builds]
            }
        }
        if {[dict size $newly] == 0} break
        dict for {key cand} $newly {
            dict set decided $key $cand
            dict set owned $key 1
        }
        Trace wave $wave decided [dict size $newly] of [llength $open] undecided: [dict keys $newly]
        set config [hir::MethodConfig $calls $decided]
        if {$config eq $lastConfig} {
            # The build in hand is the one these decisions ask for.
            dict incr ::hir::buildStats methodReused
            continue
        }
        # (Built with HALT 0, a build always runs the static checks.)
        set built [hir::BuildOnce $nodes $options $given $decided 0 checked]
        dict incr ::hir::buildStats methodTrials
        incr builds
        set lastConfig $config
        ResetCache
        hir::TraitCallsDecided $built $calls decided
        foreach key [dict keys $owned] {
            if {[Survivors $built $calls $key] ne [list [dict get $decided $key]]} {
                # Decided from a receiver this build does not give it.
                Trace took back $key: its survivors are now [Survivors $built $calls $key]
                dict unset decided $key
                dict unset owned $key
                dict set taken $key 1
                dict incr ::hir::buildStats methodFilterEvicted
            }
        }
    }
    set certified [expr {[dict size $decided] >= [llength $keys]
        && [hir::MethodConfig $calls $decided] eq $lastConfig}]
    if {$certified} {
        foreach key $keys {
            if {![dict exists $decided $key]} {
                set certified 0
                break
            }
        }
    }
    if {$certified} {
        # Every decision stands on the receiver it has in the last build, not
        # on a guess (no build was made after the decisions of the last wave
        # when they were the build's own).
        foreach key [dict keys $owned] {
            if {[Survivors $built $calls $key] ne [list [dict get $decided $key]]} {
                Trace the receiver of $key is not what its decision was made from
                set certified 0
                break
            }
        }
    }
    if {$certified} {
        # A chosen candidate with a problem of its own is the exact
        # decision's to judge (its problems may be shared by every
        # candidate, or make the call inapplicable).
        foreach key [dict keys $owned] {
            if {![dict exists $built methodCalls $key]
                    || [hir::MethodCallProblems $built [dict get $built methodCalls $key expr]] ne ""} {
                Trace the chosen candidate of $key has a problem
                set certified 0
                break
            }
        }
    }
    if {!$certified} {
        Trace handed over after $builds build(s): [expr {[dict size $decided]}] of [llength $keys] decided
        if {$builds > 0} {
            dict incr ::hir::buildStats methodFilterAbandoned
        }
        return [dict create attempted 1 certified 0 builds $builds]
    }
    dict incr ::hir::buildStats methodFiltered
    # The decisions in the order of the calls, where the exact decision's are
    # in the order it made them.
    set ordered [dict create]
    dict for {key info} $calls {
        if {[dict exists $decided $key]} {
            dict set ordered $key [dict get $decided $key]
        }
    }
    set final $built
    dict set final methodChoices $ordered
    dict set final methodDecided $ordered
    return [dict create attempted 1 certified 1 hir $final builds $builds]
}
