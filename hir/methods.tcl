# methods.tcl -- the decision of method-style calls (METHOD-SUGAR.md,
# METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md).
#
#   hir::methods::Decide NODES OPTIONS GIVEN HIR SEEDS   => the decided HIR
#   hir::methods::Problems HIR KEY                       => a call's own problems
#   hir::methods::NativeMismatch NATIVE RECEIVERTYPE     => {} | {KIND WANTED}
#   hir::methods::Excluded HIR CANDIDATE RECEIVERTYPE    => 0 | 1
#
# `receiver.name(args)` is the ordinary call `name(receiver, args)` of the one
# visible function `name` whose ordinary call is valid (METHOD-SUGAR.md).
# Resolution records every such call with several distinct visible
# candidates (hir/resolve.tcl's MethodCandidates and MethodChoice, the
# `methodCalls` table) and resolves it to the candidate a build is told
# (`methodChoices`), else to its first; this file decides which candidate
# that is. Nothing below decides by a candidate's name, position or
# namespace: those only make the procedure deterministic.
#
# The rule
# --------
#
# * A call's own problems in a build (Problems): the diagnostics whose
#   `subject` is the call -- reported by a check of the call against the
#   callee the build resolved it to (hir::CheckingCall: its arguments'
#   admission by the callee's parameters, its flags and imprints, the
#   validity of the callee's semantic instance for it, its places and the
#   ownership roles of its arguments) -- minus the obligations a valid call
#   may still carry (an error nobody handled, a missing context, ...), plus
#   the kind mismatch of a native's first parameter (NativeMismatch), which
#   is the native's run-time TYPE error and is not diagnosed. Nothing else:
#   not a diagnostic merely located in the call (an outer call's check of
#   this call's result is reported at this call's node, METHOD-SUGAR.md
#   "Source locations"), not the problems of a call nested in its arguments
#   (that call's own), not a diagnostic another construct's check reports.
# * Configurations. A configuration gives every call one of its candidates.
#   Candidate K of call C is *applicable* relative to configuration S when
#   C has no own problem in the build of S with C at K -- S itself if S
#   puts C at K, else the single deviation S[C:=K].
# * The decision is a configuration S in which every call C's applicable
#   candidates relative to S are exactly {S(C)}: each call is the one
#   candidate whose ordinary call is valid, given the others. A call with
#   several applicable candidates is AMBIGUOUS-METHOD-CALL, with none
#   NO-APPLICABLE-METHOD (it stands at its first applicable candidate, else
#   at the one it stood at, so the program keeps a call that types).
#
# The procedure (Decide)
# ----------------------
#
# 1. Kind waves (search). A candidate the receiver's kind rules out
#    (Excluded: a native whose first parameter has another known kind, a
#    module function whose first-parameter contract has another plain kind
#    or whose declared first parameter is a named struct of another
#    declaration) cannot be applicable: its build would report exactly
#    that. A call with one survivor stands at it; a receiver that is a
#    reference to a binding is read as the binding's defined type, a guess
#    that settles a receiver chain in one build (the default candidates of
#    the calls before it may have narrowed the binding to nothing). One
#    build per wave, until no stand-in moves.
# 2. Certification. In the build of the current configuration S, with no
#    guess: a call whose stand-in its receiver rules out moves to its first
#    survivor (and S is built again). Then every call with several
#    survivors is judged: each other survivor K by the single deviation
#    S[C:=K], built (or read from a record of the same configuration). A
#    call whose applicable set is not {S(C)} moves to its unique applicable
#    candidate, or to its first when it has several and S(C) is not one;
#    if any call moved, S is built again and judged again. When nothing
#    moves, S is the decision: every verdict was computed relative to S
#    itself. Bounded rounds; a call still moving at the bound depends on
#    its own decision (an oscillation) and is AMBIGUOUS-METHOD-CALL between
#    the candidates it moved between.
# 3. The final program is the build of S: the last build made when it is
#    S's (its process state is then the final one), else built again. The
#    rejected calls' diagnostics are prepended, with every candidate's
#    reason (its first own problem, from its own build).
#
# Why the outcome is the rule's, and is independent of the search: every
# verdict that decides is computed relative to the final configuration
# itself -- in its build, in a single deviation of it, or by a kind proof of
# its build's receiver -- and owned problems are the call's own checks, so
# no other call's check or choice is read as this call's verdict. The waves,
# the stand-ins and the order calls are judged in only choose the
# configuration the certification starts from. For a program whose calls'
# arguments do not depend on the calls' own decisions (a receiver chain, a
# call in another call's argument, a call on a function's result: every
# acyclic program), the decision is unique -- by induction over the calls
# in dataflow order, each call's arguments are fixed once the calls they
# depend on are, and so is its applicable set -- so any configuration the
# certification accepts is it. A dependency cycle through a recursive
# function's inferred result may admit more than one; then the decision is
# the one reached from the stand-ins (METHOD-RESOLUTION-CORRECTNESS-
# MILESTONE-1.md, "Remaining limitations").
#
# The reference rule and its audit
# --------------------------------
#
# hir::methodKindProofs 0 judges every candidate by its own build, never by
# a kind proof (the kind waves still choose stand-ins: a stand-in decides
# nothing); hir::methodReferenceAudit 1 decides every program by both rules
# and fails unless both decide alike and give the same HIR. A kind proof
# saves builds: the audit checks that each rules out what the build would.

namespace eval hir::methods {
    # The builds the kind waves may spend before certification starts. A
    # chain of n dependent calls needs at most n waves.
    variable maxWaves 8
    # The kinds a non-native candidate's parameter contract and the receiver
    # are compared in. A domain or a refinement is named by another kind
    # (core::type::base), and an integer is admitted by range proofs, so a
    # kind outside this set excludes nothing.
    variable comparableKinds [list int str bool unit UnicodeChar list struct enum mutvec mutarray {*}[core::type::floatTypes]]
    # Candidate -> the kinds of its first parameter's contracts, and its
    # first parameter's declared type, for the HIR being read (ResetCache
    # clears both for every build read).
    variable paramKinds [dict create]
    variable declaredParams [dict create]
    # 1 prints what the decision does, one line per event, on stderr
    # (BOTLISH_METHOD_TRACE=1 sets it for a process).
    variable trace 0
    if {[info exists ::env(BOTLISH_METHOD_TRACE)] && $::env(BOTLISH_METHOD_TRACE) ni {"" 0}} {
        set trace 1
    }
}

proc hir::methods::Trace {args} {
    variable trace
    if {$trace} {
        puts stderr "method-decision: [join $args { }]"
    }
}

proc hir::methods::ResetCache {} {
    variable paramKinds
    variable declaredParams
    set paramKinds [dict create]
    set declaredParams [dict create]
}

# ---------------------------------------------------------------------------
# A call's own problems

# Diagnostic kinds that say a call is unfit for its callee the way no other
# candidate is: everything except the obligations a *fit* call may still
# carry (an error it declares that nobody handled yet, or that provably
# always fails) and the ambiguity checks themselves.
proc hir::methods::ObligationKinds {} {
    # MISSING-CONTEXT: a context the selected function needs is an obligation
    # of the call (CONTEXTS.md), never evidence that the candidate does not
    # fit -- exactly like a declared error nobody handled yet.
    # DIRECT likewise: the selected function's module is direct, which the
    # calling function must mediate (DIRECT-MODULES.md) -- an obligation of
    # the call, never a reason another candidate fits better.
    return {UNHANDLED-ERROR KNOWN-ERROR UNDECLARED-ERROR AMBIGUOUS-METHOD-CALL MISSING-CONTEXT DIRECT}
}

# The own problems (header) of method call KEY in HIR (a typed build), as
# a sorted unique list of {kind message expr}; {} when HIR has no such call.
# Empty: the ordinary call with the candidate HIR resolved it to is valid.
proc hir::methods::Problems {hir key} {
    if {![dict exists $hir methodCalls $key]} {
        return {}
    }
    set e [dict get $hir methodCalls $key expr]
    return [CallProblems $hir $e [OwnedBySubject $hir]]
}

# The diagnostics of HIR that a call's own check reported, by the call: a
# dict call ExprId -> {kind message expr} list (the obligation kinds left
# out).
proc hir::methods::OwnedBySubject {hir} {
    set owned [dict create]
    set obligations [ObligationKinds]
    foreach d [dict get $hir diagnostics] {
        if {![dict exists $d subject] || [dict get $d kind] in $obligations} continue
        dict lappend owned [dict get $d subject] [list [dict get $d kind] [dict get $d message] [dict get $d expr]]
    }
    return $owned
}

# The own problems of call E of HIR, OWNED its OwnedBySubject.
proc hir::methods::CallProblems {hir e owned} {
    set problems [dict getdef $owned $e {}]
    # A native called with a first argument of a statically known other kind
    # is not diagnosed at compile time (it is the native's run-time TYPE
    # error, as for any call), but it is plainly not the function the
    # method-style call means when another candidate accepts the receiver.
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] eq "call" && [dict get $node args] ne ""} {
        set callee [dict get $hir exprs [dict get $node callee]]
        if {[dict get $callee kind] eq "ref" && [dict get $callee binding] ne ""} {
            set binding [dict get $hir bindings [dict get $callee binding]]
            if {[dict get $binding kind] eq "root" && [dict get $binding symbol] ne ""
                    && [dict get $hir symbols [dict get $binding symbol] kind] eq "native"} {
                set native [dict get $binding name]
                set receiver [lindex [dict get $node args] 0]
                # (The one statement of this rule, which the kind proofs,
                # Excluded, rule candidates out by.)
                set mismatch [NativeMismatch $native [hir::typeOf $hir $receiver]]
                if {$mismatch ne {}} {
                    lassign $mismatch kind wanted
                    lappend problems [list TYPE \
                        "the receiver is a $kind, but argument 1 of native $native requires $wanted" $receiver]
                }
            }
        }
    }
    return [lsort -unique $problems]
}

# ---------------------------------------------------------------------------
# Kind proofs

# {KIND WANTED} when the receiver of type RECEIVERTYPE is of a statically
# known kind other than the one the first parameter of NATIVE requires --
# the ordinary call is a TYPE error -- else {}. The one statement of this
# rule: CallProblems reports it, Excluded rules a candidate out by it.
proc hir::methods::NativeMismatch {native receiverType} {
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
proc hir::methods::ParamKinds {hir ns cand} {
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
proc hir::methods::DeclaredParam {hir ns cand} {
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
proc hir::methods::CandidateBlock {hir ns cand} {
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
proc hir::methods::NominalMismatch {declared R} {
    expr {[hir::types::IsNamedStruct $declared] && [hir::types::IsNamedStruct $R]
        && [lindex $declared 1] ne [lindex $R 1]}
}

# 1 if candidate CAND (a display of a methodCalls entry) is not applicable to
# a receiver of type R by kind alone, or by a named struct's identity
# (NominalMismatch): its build would report exactly that problem. A bare
# name is a lexical candidate (a function of the file, a parameter, a
# binding): never excluded.
proc hir::methods::Excluded {hir cand R} {
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
proc hir::methods::DefinedType {hir b} {
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

# The candidates of method call KEY (of CALLS) that the receiver of type R
# (receiver expression RECEIVER) in HIR does not rule out -- every candidate
# under the reference rule (hir::methodKindProofs 0). With GUESS, a receiver
# that is a reference to a binding is read as the type the binding was
# defined with (DefinedType) when that has a kind: a narrower type of the
# same kind rules out the same candidates, and a receiver that is `never`, or
# of another kind, is the work of the default candidates of the calls before
# it, which narrowed the binding. A guess only chooses stand-ins (the waves,
# under either rule: a stand-in decides nothing); certification never reads
# one.
proc hir::methods::Survivors {hir calls key receiver R guess} {
    variable ::hir::methodKindProofs
    set candidates [dict get $calls $key candidates]
    if {!$methodKindProofs && !$guess} {
        return $candidates
    }
    if {$guess} {
        set node [dict get $hir exprs $receiver]
        if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""} {
            set defined [DefinedType $hir [dict get $node binding]]
            if {[hir::types::kindOf $defined] ne ""} {
                set R $defined
            }
        }
    }
    return [lmap cand $candidates {
        if {[Excluded $hir $cand $R]} continue
        set cand
    }]
}

# ---------------------------------------------------------------------------
# Records of builds

# The configuration of a build given the method-call choices CHOICES (key ->
# candidate display): the candidate it resolves each multi-candidate method
# call of CALLS (a typed build's `methodCalls`) to, in CALLS' order -- as
# hir::resolve::MethodChoice picks it: the call's choice when that is one of
# its candidates, else its first, which is also the candidate of a call with
# no source identity (keyed by its expression, which no choice names). Builds
# of one configuration are one build: hir::BuildOnce is a pure function of
# its inputs, and the choices are the only one that differs between the
# builds of one decision.
proc hir::methods::Config {calls choices} {
    set config {}
    dict for {key info} $calls {
        set candidates [dict get $info candidates]
        set want [lindex $candidates 0]
        if {$key ne [dict get $info expr] && [dict exists $choices $key] && [dict get $choices $key] in $candidates} {
            set want [dict get $choices $key]
        }
        lappend config $want
    }
    return $config
}

# What the decision reads of HIR, one build of the program (CHECKED: whether
# its static checks ran), for the decidable calls KEYS of CALLS: a dict
#
#   checked  CHECKED
#   calls    KEY -> {problems P receiver R poisoned 0|1 survivors S guessed G}
#            for each of KEYS the build has: the call's own problems with
#            the candidate the build resolved it to (CallProblems), its
#            receiver's type and whether that is poison, and its candidates
#            the receiver does not rule out, without and with the guess
#            (Survivors); a call without arguments has no entry
#   traits   KEY -> the candidate the call stood in with, for every call of
#            CALLS the build types as a trait operation (TraitCallsDecided)
#
# A record is all the decision reads of a build, so a build of the same
# configuration is read from its record (hir::methodBuildAudit compares the
# two).
proc hir::methods::Record {hir calls keys checked} {
    set record [dict create checked $checked calls [dict create] traits [dict create]]
    if {!$checked} {
        return $record
    }
    ResetCache
    set owned [OwnedBySubject $hir]
    foreach key $keys {
        if {![dict exists $hir methodCalls $key]} continue
        set e [dict get $hir methodCalls $key expr]
        set args [dict get $hir exprs $e args]
        if {$args eq ""} continue
        set receiver [lindex $args 0]
        set R [hir::typeOf $hir $receiver]
        dict set record calls $key [dict create \
            problems [CallProblems $hir $e $owned] receiver $R \
            poisoned [hir::types::Poisoned $hir $receiver] \
            survivors [Survivors $hir $calls $key $receiver $R 0] \
            guessed [Survivors $hir $calls $key $receiver $R 1]]
    }
    set decided [dict create]
    TraitCallsDecided $hir $calls decided
    dict set record traits $decided
    return $record
}

# Marks, in the caller's DECIDEDVAR, every multi-candidate method call of
# CALLS (a methodCalls table) that HIR (a typed build) types as a trait
# operation: such a call is decided by its receiver's trait, never by the
# candidates (TRAITS.md), so it keeps the candidate its build stood in with.
proc hir::methods::TraitCallsDecided {hir calls decidedVar} {
    upvar 1 $decidedVar decided
    if {![dict exists $hir methodCalls]} {
        return
    }
    dict for {key info} $calls {
        if {[dict exists $decided $key] || ![dict exists $hir methodCalls $key]} continue
        set e [dict get $hir methodCalls $key expr]
        if {[dict exists $hir exprs $e traitCall]} {
            dict set decided $key [dict get $hir methodCalls $key chosen]
        }
    }
}

# The record of the build of CHOICES (state STATEVAR: the decision's inputs,
# records and last build), built unless a build of its configuration was
# already recorded. WHAT counts the build: wave, trial, deviation or round.
proc hir::methods::Build {stateVar choices what} {
    upvar 1 $stateVar state
    variable ::hir::methodBuildReuse
    variable ::hir::methodBuildAudit
    set calls [dict get $state calls]
    set config [Config $calls $choices]
    if {$methodBuildReuse && [dict exists $state records $config]} {
        dict incr ::hir::buildStats methodReused
        set record [dict get $state records $config]
        if {$methodBuildAudit} {
            set fresh [BuildRecord state $choices $config]
            if {$fresh ne $record} {
                error "hir::methods: the reused build of $what differs from building it again (choices: $choices)"
            }
        }
        return $record
    }
    dict incr ::hir::buildStats methodTrials
    if {$what eq "deviation"} {
        dict incr ::hir::buildStats methodDeviations
    }
    return [BuildRecord state $choices $config]
}

proc hir::methods::BuildRecord {stateVar choices config} {
    upvar 1 $stateVar state
    lassign [dict get $state inputs] nodes options given
    set hir [hir::BuildOnce $nodes $options $given $choices 0 checked]
    set record [Record $hir [dict get $state calls] [dict get $state keys] $checked]
    dict set state records $config $record
    dict set state last [list $config $hir]
    return $record
}

# ---------------------------------------------------------------------------
# The decision

# Decides the method-style calls of HIR (the first build of the syntax NODES
# with OPTIONS and GIVEN) by the rule of the header and returns the decided
# program: the build of the decision, with `methodChoices` (every call's
# candidate) and `methodDecided` (the calls decided: SEEDS, the trait
# operations and the certified decisions -- not the rejected calls' stand-
# ins), the rejected calls' diagnostics first. SEEDS (key -> candidate) are
# calls an earlier round decided that nothing since can have changed
# (hir/static.tcl's MethodSeeds): decided as they are.
proc hir::methods::Decide {nodes options given hir seeds} {
    variable maxWaves
    set calls [dict get $hir methodCalls]
    # Calls with a source identity (keyed by file and node); a call keyed by
    # its expression is not decidable (no choice names it).
    set keys [lmap {key info} $calls {
        if {$key eq [dict get $info expr]} continue
        set key
    }]
    set fixed [dict create]
    dict for {key choice} $seeds {
        if {[dict exists $calls $key] && $choice in [dict get $calls $key candidates]} {
            dict set fixed $key $choice
        }
    }
    set state [dict create inputs [list $nodes $options $given] calls $calls keys $keys \
        records [dict create]]
    set config [lmap {key info} $calls {dict get $info chosen}]
    set record [Record $hir $calls $keys 1]
    dict set state records $config $record
    dict set state initial $config
    dict set state last [list $config $hir]
    set fixed [dict merge [dict get $record traits] $fixed]
    set choices $fixed
    foreach key $keys {
        if {![dict exists $choices $key]} {
            dict set choices $key [dict get $calls $key chosen]
        }
    }
    set open [Open $keys $fixed]
    if {$open eq ""} {
        dict set hir methodChoices [Ordered $calls $choices]
        dict set hir methodDecided [Ordered $calls $fixed]
        return $hir
    }
    Trace decide [llength $open] call(s), [dict size $fixed] fixed
    # 1. Kind waves: stand-ins by the receivers' kinds (with the guess).
    for {set wave 0} {$wave < $maxWaves} {incr wave} {
        set moved 0
        foreach key $open {
            if {![dict exists $record calls $key]} continue
            set guessed [dict get $record calls $key guessed]
            if {[llength $guessed] == 1 && [dict get $choices $key] ne [lindex $guessed 0]} {
                dict set choices $key [lindex $guessed 0]
                set moved 1
            }
        }
        if {!$moved} break
        set record [Build state $choices wave]
        Trace wave $wave
        lassign [Fix $record $fixed $choices $open] fixed choices open
    }
    # 2. Trial rounds (search). Every call with several survivors is tried at
    # each of them, all at once (Proposal), and moves to the candidate the
    # trials found applicable -- a proposal, never a decision: the trials
    # vary every such call together, so a call's verdict in one is not
    # relative to any one configuration.
    for {set round 0} {$round < [llength $open] + 2} {incr round} {
        lassign [Fix $record $fixed $choices $open] fixed choices open
        set proposal [Proposal state $record $choices $open]
        if {$proposal eq $choices} break
        Trace trial round $round moved [lmap {k v} $proposal {if {$v eq [dict get $choices $k]} continue; set k}]
        set choices $proposal
        set record [Build state $choices round]
    }
    # 3. Certification. A call moves to its canonical stand-in: its unique
    # applicable candidate, the first of several (it is then ambiguous), its
    # first candidate when none is applicable or its receiver is poison (it
    # decides nothing) -- in candidate order, which only picks the
    # placeholder a rejected call keeps. STEPS bounds the builds of new
    # configurations: a call still moving then is one whose decision changes
    # its own arguments (a cycle through an inferred result), rejected as
    # ambiguous between the candidates it moved between; it keeps the one it
    # stands at.
    set limit [expr {4 * [llength $open] + 8}]
    set steps 0
    set unstable [dict create]
    while 1 {
        incr steps
        lassign [Fix $record $fixed $choices $open] fixed choices open
        set verdicts [Verdicts state $record $choices $open]
        set next $choices
        dict for {key verdict} $verdicts {
            set applicable [dict get $verdict applicable]
            if {$applicable ne {}} {
                dict set next $key [lindex $applicable 0]
            } else {
                dict set next $key [lindex [dict get $calls $key candidates] 0]
            }
        }
        if {$next eq $choices} break
        if {$steps > $limit} {
            dict for {key choice} $next {
                if {$choice ne [dict get $choices $key]} {
                    dict set unstable $key [list [dict get $choices $key] $choice]
                }
            }
            break
        }
        Trace step $steps moved [lmap {k v} $next {if {$v eq [dict get $choices $k]} continue; set k}]
        set choices $next
        set record [Build state $choices round]
    }
    # The reasons of the calls no candidate fits: every candidate's own
    # problems, from its own build (made before the final program, whose
    # process state must be the last).
    dict for {key verdict} $verdicts {
        if {[dict get $verdict poisoned] || [dict get $verdict applicable] ne {} || [dict exists $unstable $key]} continue
        set problems [dict get $verdict problems]
        foreach cand [dict get $calls $key candidates] {
            if {[dict exists $problems $cand]} continue
            set deviation [Build state [dict merge $choices [list $key $cand]] deviation]
            if {[dict exists $deviation calls $key]} {
                dict set problems $cand [dict get $deviation calls $key problems]
            } else {
                dict set problems $cand {}
            }
        }
        dict set verdicts $key problems $problems
    }
    # 4. The final program.
    set final [Final state $choices]
    set decided $fixed
    dict for {key verdict} $verdicts {
        if {[dict exists $unstable $key] || [dict get $verdict poisoned]} continue
        set applicable [dict get $verdict applicable]
        if {[llength $applicable] == 1} {
            dict set decided $key [lindex $applicable 0]
        }
    }
    foreach key $keys {
        if {[dict exists $decided $key] || ![dict exists $verdicts $key]} continue
        Reject final $key [dict get $verdicts $key] [dict getdef $unstable $key {}]
    }
    # Every call's candidate, and the decided calls (not the rejected ones'
    # stand-ins), for a later build of a changed program that can reuse them
    # (hir/static.tcl). Bookkeeping of the decision, never read by an
    # analysis.
    dict set final methodChoices [Ordered $calls $choices]
    dict set final methodDecided [Ordered $calls $decided]
    return $final
}

# The keys of KEYS not in FIXED.
proc hir::methods::Open {keys fixed} {
    lmap key $keys {
        if {[dict exists $fixed $key]} continue
        set key
    }
}

# FIXED, CHOICES and OPEN with the trait operations RECORD's build types
# added to FIXED (a call that is a trait operation is the trait's, whatever
# its candidates).
proc hir::methods::Fix {record fixed choices open} {
    dict for {key chosen} [dict get $record traits] {
        if {![dict exists $fixed $key]} {
            dict set fixed $key $chosen
            dict set choices $key $chosen
        }
    }
    return [list $fixed $choices [Open $open $fixed]]
}

# DECIDED (key -> candidate) in the order of CALLS.
proc hir::methods::Ordered {calls decided} {
    set ordered [dict create]
    dict for {key info} $calls {
        if {[dict exists $decided $key]} {
            dict set ordered $key [dict get $decided $key]
        }
    }
    return $ordered
}

# The configuration the trial round from CHOICES (whose build RECORD is)
# proposes for the calls OPEN: a call whose stand-in its receiver rules out
# moves to its first survivor; every call with several survivors is tried at
# each of its other survivors, all of them at once (trial T puts each at its
# T-th other survivor, or leaves it standing when it has fewer), and moves to
# its canonical candidate by what the trials found (the first whose own
# problems were empty, else its first candidate) -- only when its receiver
# had one type in every trial: a receiver another varied call changes says
# nothing about this call (certification judges it once that call stands).
# The trials are records like any build: a later single deviation of the same
# configuration reads its record.
proc hir::methods::Proposal {stateVar record choices open} {
    upvar 1 $stateVar state
    set calls [dict get $state calls]
    set next $choices
    set orders [dict create]
    foreach key $open {
        if {![dict exists $record calls $key]} continue
        set entry [dict get $record calls $key]
        set survivors [dict get $entry survivors]
        set standing [dict get $choices $key]
        if {[dict get $entry poisoned] || $survivors eq {}} continue
        if {[llength $survivors] == 1} {
            dict set next $key [lindex $survivors 0]
            continue
        }
        set at [lsearch -exact $survivors $standing]
        if {$at < 0} {
            dict set orders $key $survivors
        } else {
            dict set orders $key [concat [lrange $survivors $at+1 end] [lrange $survivors 0 $at-1]]
        }
    }
    if {[dict size $orders] == 0} {
        return $next
    }
    set rounds 0
    dict for {key order} $orders {
        set rounds [expr {max($rounds, [llength $order])}]
    }
    set problems [dict create]
    set receivers [dict create]
    dict for {key order} $orders {
        set standing [dict get $choices $key]
        if {$standing in [dict get $record calls $key survivors]} {
            dict set problems $key $standing [dict get $record calls $key problems]
        }
        dict set receivers $key [list [dict get $record calls $key receiver]]
    }
    for {set t 0} {$t < $rounds} {incr t} {
        set trial $next
        dict for {key order} $orders {
            if {$t < [llength $order]} {
                dict set trial $key [lindex $order $t]
            }
        }
        set built [Build state $trial trial]
        dict for {key order} $orders {
            if {![dict exists $built calls $key]} continue
            dict lappend receivers $key [dict get $built calls $key receiver]
            if {$t < [llength $order]} {
                dict set problems $key [lindex $order $t] [dict get $built calls $key problems]
            }
        }
    }
    set moves [dict create]
    set stable [dict create]
    dict for {key order} $orders {
        set survivors [dict get $record calls $key survivors]
        set applicable [lmap cand $survivors {
            if {![dict exists $problems $key $cand] || [dict get $problems $key $cand] ne {}} continue
            set cand
        }]
        if {$applicable ne {}} {
            set want [lindex $applicable 0]
        } else {
            set want [lindex [dict get $calls $key candidates] 0]
        }
        if {$want ne [dict get $next $key]} {
            dict set moves $key $want
            if {[llength [lsort -unique [dict get $receivers $key]]] == 1} {
                dict set stable $key 1
            }
        }
    }
    dict for {key want} $moves {
        if {[dict exists $stable $key]} {
            dict set next $key $want
        }
    }
    return $next
}

# The verdicts of the calls OPEN relative to CHOICES, whose build RECORD is:
# key -> {poisoned 0|1 survivors S problems {CANDIDATE -> P} applicable A}.
# A call's standing candidate is judged by RECORD, every other survivor by
# its single deviation; a call with a poisoned receiver (hir/types.tcl,
# "Poison") is judged by nothing: it fits every candidate and decides
# nothing, and the diagnostic that poisoned it is the cause.
proc hir::methods::Verdicts {stateVar record choices open} {
    upvar 1 $stateVar state
    set verdicts [dict create]
    foreach key $open {
        if {![dict exists $record calls $key]} continue
        set entry [dict get $record calls $key]
        if {[dict get $entry poisoned]} {
            dict set verdicts $key [dict create poisoned 1 survivors {} problems {} applicable {}]
            continue
        }
        set standing [dict get $choices $key]
        set survivors [dict get $entry survivors]
        set problems [dict create]
        if {$standing in $survivors} {
            dict set problems $standing [dict get $entry problems]
        }
        foreach cand $survivors {
            if {$cand eq $standing} continue
            set deviation [Build state [dict merge $choices [list $key $cand]] deviation]
            if {[dict exists $deviation calls $key]} {
                dict set problems $cand [dict get $deviation calls $key problems]
            }
        }
        set applicable [lmap cand $survivors {
            if {![dict exists $problems $cand] || [dict get $problems $cand] ne {}} continue
            set cand
        }]
        dict set verdicts $key [dict create poisoned 0 survivors $survivors problems $problems applicable $applicable]
    }
    return $verdicts
}

# The final program: the build of CHOICES -- the last build made when it is
# that configuration's (the process state it left behind is then the final
# build's), else built again. (An older build of the configuration is not
# reused: a later build's state would be left behind it, and what runs after
# the decision -- BuildFull's elaborations, hir/static.tcl's attribution and
# dependency analysis, the warnings -- is not audited for reading it.)
proc hir::methods::Final {stateVar choices} {
    upvar 1 $stateVar state
    variable ::hir::methodBuildReuse
    variable ::hir::methodBuildAudit
    set config [Config [dict get $state calls] $choices]
    lassign [dict get $state last] lastConfig lastHir
    lassign [dict get $state inputs] nodes options given
    if {$methodBuildReuse && $config eq $lastConfig} {
        dict incr ::hir::buildStats methodReused
        if {$methodBuildAudit} {
            set fresh [hir::BuildOnce $nodes $options $given $choices 0 checked]
            if {[list $fresh] ne [list $lastHir]} {
                error "hir::methods: the reused final build differs from building it again (choices: $choices)"
            }
            return $fresh
        }
        return $lastHir
    }
    dict incr ::hir::buildStats methodFinals
    return [hir::BuildOnce $nodes $options $given $choices 0 checked]
}

# Prepends to FINAL (a caller variable: the decided program) the rejection
# of call KEY, whose VERDICT (Verdicts) has no single applicable candidate:
# AMBIGUOUS-METHOD-CALL when several are applicable (or UNSTABLE, the two
# candidates a call moved between at the round bound), NO-APPLICABLE-METHOD,
# with every candidate's reason, when none is.
proc hir::methods::Reject {finalVar key verdict unstable} {
    upvar 1 $finalVar final
    if {![dict exists $final methodCalls $key]} {
        return
    }
    set info [dict get $final methodCalls $key]
    set e [dict get $info expr]
    set callArgs [dict get $final exprs $e args]
    if {$callArgs ne "" && [hir::types::Poisoned $final [lindex $callArgs 0]]} {
        # A poisoned receiver (hir/types.tcl, "Poison") fits every
        # candidate and decides nothing: the diagnostic that rejected it is
        # the cause, already reported (DIAGNOSTIC-RECOVERY.md).
        return
    }
    if {$callArgs ne "" && [UnknownTraitOperation $final [lindex $callArgs 0]]} {
        # A receiver computed by an operation its trait does not declare
        # (TRAIT-UNKNOWN-OPERATION) is what fails every candidate: that
        # diagnostic is the cause and is already reported.
        return
    }
    set name [dict get $info name]
    set origin [dict get $final exprs $e method nameOrigin]
    set candidates [dict get $info candidates]
    if {$unstable ne {}} {
        set valid [lmap c $candidates {if {$c ni $unstable} continue; set c}]
    } else {
        set valid [dict get $verdict applicable]
    }
    if {[llength $valid] > 1} {
        set message [::format {method-style call "%s" is ambiguous: more than one visible function accepts the receiver (%s); there is no precedence between them: call the one you mean explicitly, e.g. %s(receiver, ...)} \
            $name [join $valid {, }] [lindex $valid 0]]
        set kind AMBIGUOUS-METHOD-CALL
    } else {
        set reasons {}
        set problems [dict get $verdict problems]
        foreach candidate $candidates {
            set own [dict getdef $problems $candidate {}]
            if {$own eq ""} {
                set reason "no problem found"
            } else {
                set reason [lindex [lindex $own 0] 1]
            }
            lappend reasons "$candidate: $reason"
        }
        set message [::format {method-style call "%s": none of the visible functions of that name accepts the receiver (%s)} \
            $name [join $reasons {; }]]
        set kind NO-APPLICABLE-METHOD
    }
    set diagnostics [dict get $final diagnostics]
    hir::DiagnoseAt final $kind $message $e $origin
    set added [lindex [dict get $final diagnostics] end]
    dict set final diagnostics [concat [list $added] $diagnostics]
    if {[dict exists $final beforeCompletions]} {
        # Not one of them: what each candidate's own build reported decided
        # it.
        lassign [dict get $final beforeCompletions] from to
        dict set final beforeCompletions [list [expr {$from + 1}] [expr {$to + 1}]]
    }
}

# 1 if expression E of HIR is a call diagnosed TRAIT-UNKNOWN-OPERATION.
proc hir::methods::UnknownTraitOperation {hir e} {
    foreach d [dict get $hir diagnostics] {
        if {[dict get $d kind] eq "TRAIT-UNKNOWN-OPERATION" && [dict get $d expr] eq $e} {
            return 1
        }
    }
    return 0
}
