# staticdeps.tcl -- which static sites each site's decision depends on
# (STATIC-COMPILE.md, "Decision economics"; hir/static.tcl's batched
# scheduler).
#
#   hir::staticdeps::Deps HIR SITES DECISIONS   => dict
#       sites     key -> the keys of the sites (present as bodies under
#                 DECISIONS) whose form the site's own diagnostics may
#                 depend on, never the site itself
#       channels  the program-wide channels of the build, for the trace
#       consumes  key -> the waiting channels (C:erased, C:budget:B) the
#                 site's diagnostics read (Waiting)
#       contributors  channel -> the keys of the sites (present as bodies)
#                 whose decision may change the channel's value (Waiting;
#                 hir/static.tcl's waiting rule reads both)
#   hir::staticdeps::Explain DEPS Y Z            why site Y depends on site
#                                                Z: a path, as text
#
# The question
# ------------
# A build of the program (hir::BuildFull) is a pure function of the forms of
# its static sites. hir/static.tcl runs the sequential decision order on one
# build for as long as the build answers it: having rejected site Z without
# building again, it must know which other sites' diagnostics may now
# differ. Those are the sites that *depend* on Z: whose own analysis may
# read a fact Z's form can change. Everything else keeps its diagnostics,
# because nothing it reads changed. This file computes that relation for one
# build, conservatively: a dependency it misses would make the batched
# scheduler commit a decision the sequential order would not; a dependency it
# adds only costs a build. It never decides anything itself.
#
# The graph
# ---------
# Nodes are *regions* (R: a function literal, or the program's top-level
# code), *bindings* (B: the facts of one binding as its readers see them),
# *sites* -- twice: Z, what a site's own diagnostics read, and F, the site's
# *form* (whether it is still a body) -- and *channels* (C: a program-wide
# fact). An edge u -> v says u's facts may depend on v's. A site Y depends on
# Z when Z's form, F:Z, is reachable from Z:Y.
#
# The two site nodes are apart because reading a site's form is not reading
# what that site reads: within one run of the batched scheduler a site's form
# changes only when the site itself is rejected, never when something its
# diagnostics read changes (that only makes its status unknown). An edge to
# a site's code -- a region holding it, an expression of it in a subtree --
# goes to its form, which has no successor but the form of the site around
# it (whose rejection takes it away). Once it went to the site's own node:
# whatever read a site's form read everything that site read, and a site
# nested in a function in another site's body reached that site's form (the
# `if true:` that scopes the body) and through it every sibling nested site
# -- one rejection per build (tests/static-economics.test,
# se-builds-nested-siblings).
#
#   Z:site    -> R of the region the site's body stands in (its position: the
#                code before and after it in the same function, which its
#                rejection can make unreachable -- completion and ownership
#                diagnostics are not reported in unreachable code), the forms
#                of the sites nested in its body, and its own contract-
#                boundary checks (below).
#   F:site    -> the form of the site whose body holds it.
#   R:region  -> everything its own code mentions (its own code: the region's
#                expressions, not those of the functions defined in it):
#                every binding referenced (B), every function literal in it
#                (R: its summary -- result, errors, contexts, completion
#                facts), every exact call target (R), every candidate of a
#                method-style call (B: the trial builds try each one) and
#                what those builds judge of the contract boundary (below), the
#                form of every site whose body is in it (F); its parameters and captures
#                (B); the control operands enclosing its literal in the
#                enclosing functions (conditions, loop operands, handled
#                calls); and, for each captured binding, the narrowing
#                mentions of it in the functions between its definition and
#                this one (a capture is seen with the facts its binding has
#                where the function is defined: an `if integer?(v):` or a
#                `v + 1` before the definition narrows it). A function is
#                *not* made to depend on the rest of its enclosing function:
#                a function's body is analyzed from its own entry, whatever
#                the reachability of the point that defines it, and what it
#                sees of the enclosing code is exactly its captures
#                (tests/static-economics.test pins both).
#   B:binding -> its definition (the bound value's subtree; a loop
#                variable's loop operands; a handler payload's handled call),
#                and every narrowing mention of it in its own region: a
#                mention's enclosing call (a native's parameter types, a
#                validator's proof narrow it; a mutation makes it a place no
#                nested function may capture, MUTABLE-PLACE-CAPTURE), or the
#                whole statement when the mention is inside a branch, loop or
#                handler (the narrowing after a join depends on every
#                branch's completion).
#
# Backward and program-wide channels -- facts of a function its *callers* or
# the whole program determine:
#
#   untyped parameter   its contract is inferred from every reachable use,
#                       in the function and every function nested in it
#                       (hir/signatures.tcl): B:p -> R of each.
#   shared binding      an affine or mutable value: a use anywhere (a move,
#                       a capture, a mutation through a place) changes what
#                       the others see: B -> R of every region mentioning it.
#                       A binding holding a callable is none, whatever its
#                       contract mentions (MentionsMutable): a function
#                       value has no place to mutate and is never moved, and
#                       the vector a call of it returns is a new value, owned
#                       by the binding that receives it.
#   yield type          an unconstrained function's yields are typed by the
#                       coroutines that reach it -- `any` once a
#                       struct-protocol one does (hir/coroutines.tcl): R ->
#                       every construction whose root has a struct protocol
#                       and reaches it over the exact call edges.
#   C:erased            the erased-callable contract (hir::completions::
#                       erasedErrorsOf): what every callable passed into an
#                       untyped parameter can raise. Its *contributors*:
#                       C:erased -> each semantic instance's request whose
#                       arguments at its parameters with no declared or
#                       trusted contract could carry errors (CanCarry: a
#                       callable, or a value holding one -- a rejection only
#                       ever turns a type into `never` or adds errors to a
#                       callable's, so nothing else ever carries any), by
#                       those arguments and the call's own place, up the
#                       chain of requests when the request is itself inside
#                       an instance; each position where a callable with an
#                       uncontracted parameter acquires a structural type
#                       whose argument could carry errors (Contravariant);
#                       and each request the budget declined. A request
#                       that erases nothing now (CarriedErrors of its
#                       arguments there empty: none declares an error) never
#                       will -- what a value carries is a function of its
#                       static type, which a rejection only turns into
#                       `never` -- so it is no contributor: rejecting the site
#                       it is written in removes nothing. An argument that is
#                       a function literal, a reference to a binding bound to
#                       one or a native, whose result type carries nothing,
#                       carries exactly its declared errors whatever its body
#                       becomes (FixedCarrier): the edge goes to the sites it
#                       is written in, not into its body. And the contract is
#                       a set: it loses an error only once every contribution
#                       erasing it is gone, so it depends, per error, on one
#                       *witness* contribution -- the one the sequential order
#                       removes last; for a semantic instance, the chain of
#                       requests keeping it that is removed last
#                       (RequestPath) -- and on every declined request
#                       (ErasureWitnesses). The sites holding a contribution
#                       are no edge of the graph: the waiting rule reads them
#                       (Waiting). (They used to be linked to the contract,
#                       Z:site -> C:erased, so that a consumer turned unknown
#                       held the other contributors back and the next build
#                       judged it with them present, as the sequential order
#                       did; the order now judges a failing consumer only
#                       once no failing contributor remains.) Its
#                       *consumers*: R -> C:erased for a region with a call
#                       through an uncontracted value (a callee of type any
#                       or a bare kind, a native calling such an argument),
#                       which has lost both identity precision and contract
#                       precision: the uncontracted erased-callable channel
#                       (VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md). A call
#                       through a verified structural Fn or Coroutine
#                       contract is no consumer (VERIFIED-CALLABLE-CONTRACT-
#                       BOUNDARY.md: the contract bounds it whatever it
#                       holds).
#   C:budget:B          the semantic-instance budget of block B
#                       (hir/semantic.tcl): which call gets one of B's
#                       instances depends on every other call requesting one.
#                       Open only under pressure -- a request declined, or B
#                       holding half its per-block budget -- and then every
#                       call of B is both; every B at once when half of all
#                       instances exist, or a request was made at half the
#                       nesting limits or deeper (hir::semantic's `deep`):
#                       only a first request is declined for nesting, and a
#                       rejection removing the first request for an
#                       instance makes a deep one the first, which a cache
#                       hit before hid (tests/static-economics.test,
#                       se-equal-deep-first-request). What the allocation reads is the
#                       number of distinct instances requested: B's own body,
#                       each call's place, and the facts of its arguments --
#                       of an argument naming a function only its place, since
#                       an instance's key keeps a function's identity and
#                       erases its result (hir::specialize::KeyType): its body
#                       is no part of it (FunctionRef).
#   C:verdict           the ownership analysis's verdict on the whole
#                       program (hir::affine::verify's `accepted`: no
#                       diagnostic of its whole-program analysis anywhere).
#                       Release scopes, and so AFFINE-PATH-RELEASE-
#                       UNSUPPORTED, are computed only under it: a site
#                       whose binding is moved on a break path or in a
#                       handler but still owned when the loop runs out or
#                       the call completes has that diagnostic only while no
#                       other code anywhere has an ownership diagnostic.
#                       Its *consumers* (Ownership): Z:site -> C:verdict for
#                       each site holding such a join -- a counting,
#                       iterating or lockstep loop, or a handled call, whose
#                       body or handlers move an affine binding visible at
#                       it (while the analysis reports an erasure, any
#                       reference to a binding whose type is affine or may
#                       become affine once a rejection narrows an erased
#                       `any`). Its successors, while the analysis reports
#                       something: one *witness* -- the region of the
#                       diagnostic whose site is last in post-order, or of
#                       every one in no site's body -- because the verdict
#                       cannot change while one of its diagnostics stays;
#                       and every site holding one after the first consumer
#                       is linked to it (Z:site -> C:verdict), because the
#                       sequential order judges a consumer while those are
#                       still present: when a consumer's status becomes
#                       unknown, its component holds them back. (Depending
#                       on every one instead would make a consumer unknown
#                       at the first of several rejections that cannot
#                       change it, one build per rejection.) While the
#                       analysis accepts the program, a rejection only kills
#                       paths and narrows types -- an affine value never
#                       flows into a position that is not affine without an
#                       erasure diagnostic -- so a diagnostic can appear
#                       only where a call's argument contract can widen: an
#                       affine argument at an untyped parameter (its
#                       inferred contract, its instance's budget) or of a
#                       callable value (its type's contract); C:verdict ->
#                       R of each region making one.
#   C:plan              the gate of the trait monomorphization's plan
#                       (hir::traits::Plan), which hir::BuildFull runs only on
#                       a checked program with no diagnostic at all -- and
#                       whose diagnostics are a site's (planKinds: TRAIT-IMPL-
#                       ORDER, AFFINE-GENERIC-NESTED-UNSUPPORTED, TRAIT-
#                       INSTANCE-BUDGET, ...). Its *consumers* (PlanGate):
#                       Z:site -> C:plan for each site holding a call the plan
#                       can report at -- a trait operation; a call of a trait-
#                       polymorphic function that a context the plan walks
#                       has no instance for (Unplanned: TRAIT-INSTANCE-BUDGET
#                       is its one diagnostic there, and only for a call that
#                       is not dead -- a dead one becomes the placeholder of
#                       never-executed code, which Unplanned still counts:
#                       sound, if not as tight as it could be); a call
#                       giving an untyped parameter an argument that is or
#                       may become affine
#                       (AFFINE-GENERIC-NESTED-UNSUPPORTED, AFFINE-INSTANCE-
#                       BUDGET; the one diagnostic of a call of a function
#                       requiring a context trait) -- in a program that can
#                       plan at all (trait declarations, or a coroutine
#                       construction). Whether a trait-polymorphic call has
#                       its instance changes with the call's own facts (an
#                       argument's type `never`: a dead call is never
#                       requested), which its site's edges read, or with a
#                       decline: a budget never declines such a request (it
#                       is re-keyed and granted), a top-level function's
#                       environment is recorded at its definition, and a
#                       nesting decline is C:budget's (the pressure of a
#                       deep request); a context a rejection creates walks
#                       the function's body afresh, requesting each call of
#                       it. Its successors, while the build has a
#                       diagnostic the plan does not report (the gate is
#                       closed): one *witness*, the site of the diagnostic last
#                       in post-order (Z and F: the gate cannot open while it
#                       stays), else the region of every one (in no site's
#                       body; at a function literal, the function's own).
#                       No linking is needed, unlike C:verdict: a plan
#                       diagnostic never stands beside another diagnostic, so
#                       a consumer judged once later diagnostics are gone is
#                       rejected with the diagnostic the sequential order
#                       gives it when they are (it accepts it first, and
#                       rejects it in the build where the gate opens -- the
#                       same build of the same forms). While every diagnostic
#                       of the build may be the plan's own (the gate is open):
#                       every site holding one is a consumer, and the plan
#                       depends on each one's form -- one computation over the
#                       whole program, whose stages hide each other's
#                       diagnostics -- so they are decided one per build, as
#                       the sequential order decides them.
#
# The waiting rule (hir/static.tcl, Waits; STATIC-COMPILE.md) reads the
# channels whose contributors' *presence* can cause a consumer's diagnostic --
# C:erased and C:budget:B -- for the definition as well as for the
# economics: a failing site that reads one (`consumes`: its node reaches the
# channel over every edge but a contributor's link and a gate's, and not the
# erased contract when its first diagnostic precedes the completion walk,
# Waiting) waits while a failing site may change it (`contributors`: every
# site holding a contribution, and every site form the channel's node
# reaches). C:verdict and C:plan are gates, the
# opposite shape -- a contributor's presence withholds a consumer's
# diagnostic -- so no site waits on them. An extra edge into a waiting
# channel's part of the graph can therefore change which site the order
# judges first, not only cost a build: a conservative edge makes a consumer
# wait for a contributor that could not have changed its diagnostic, and the
# two are then judged contributor first, whatever their layout.
#
# And one channel that is the site's own, never a summary another region
# reads: the contract-boundary checks at the site's positions
# (hir::completions::Subsume) run only in the diagnosing walk of a body and
# only while the program erases something, analyzing a callable there with
# each uncontracted input standing for what it can hold (Possible). So
# Z:site -> C:erased and -> P:input for the inputs of the callables at its
# positions (and the outward finals of a yield in it: every construction
# reaching it); P:input -> what its calls pass in its position (a parameter
# of a function only ever called), its value (a local), or C:erased. What an
# input may hold is a set too (errors, and whether every value is quiet), so
# P:input depends per part on one witness value whose part is fixed
# (PossibleUnit), and on every other value; every site passing a value of a
# fixed part is linked to it (Z:site -> P:input, possibleLinks).
#
# None of those edges while the site's first diagnostic in this build was
# reported before the completion walk (HIR's beforeCompletions): every report
# is appended after it, so whatever the program erases the site keeps that
# first diagnostic -- all the scheduler reads of a failing site -- for as long
# as its other edges' facts hold. A site that is ok, or whose first diagnostic
# is the completion walk's or a later pass's (or a method-style call's
# rejection, which hir::DecideMethodCalls prepends and which reads its
# trials), keeps them: a report may become its first diagnostic, also once
# the program begins to erase something.
#
# What reads the reports besides the site's own diagnostics is the builds
# that judge a method-style call's candidates, for the call's own checks
# (hir::methods::Problems: the contract boundary at its arguments is one,
# hir::CheckingCall): a candidate's parameter types are the structural
# types the call's own arguments acquire, so their checks may tell the
# candidates apart. R:region -> C:erased and -> P:input (method-trial) for
# every call with several candidates of which an argument has a callable part
# some parameter type could make structural (CallableParts), or a handle whose
# construction is in this body while a candidate is a coroutine operation
# (whose positions the check skips; a handle's check reads no parameter
# type). Every other check inside the call is no check of the call's own,
# which the decision never reads. A region reaches a site's form only
# (F:site), never these edges of the site.
#
# What is not a channel, and why: a demoted trusted contract (hir::check
# keeps the diagnostics of the check before the demotion, so a demotion
# changes no diagnostic); the trait monomorphization's build after its plan
# (it runs only on a program with no diagnostic, and its own diagnostics are
# internal, never a site's); resolution (lexical: a site's own bindings are
# scoped to it, and hir/static.tcl decides every resolution-stage rejection
# in one build).

namespace eval hir::staticdeps {
    # The kinds of the ownership analysis's whole-program diagnostics
    # (hir::affine::Analyze: the consumer rejections, captures, liveness and
    # module bindings), whose presence anywhere withholds the release scopes
    # (C:verdict). tests/static-economics.test checks the list against
    # hir/affine.tcl.
    variable ownershipKinds {
        USE-AFTER-MOVE AFFINE-NOT-DEFINITELY-LIVE AFFINE-CAPTURE-UNSUPPORTED
        AFFINE-ERASURE-UNSUPPORTED AFFINE-EQUALITY-UNSUPPORTED
        AFFINE-LIST-OPERATION-UNSUPPORTED AFFINE-FIELD-MOVE-REQUIRES-DESTRUCTURE
        AFFINE-TEMPORARY-UNSUPPORTED AFFINE-DUPLICATION-UNSUPPORTED
        AFFINE-ELEMENT-COPY-OUT AFFINE-CONTEXT-COPY-OUT
    }
    # The kinds of the diagnostics the trait monomorphization's plan reports
    # (hir::traits::Plan), which it computes only for a program with no other
    # diagnostic (C:plan). TRAIT-NOT-SATISFIED is the checker's too.
    # tests/static-economics.test checks the list against hir/traits.tcl.
    variable planKinds {
        TRAIT-NOT-SATISFIED TRAIT-IMPL-ORDER TRAIT-INSTANCE-BUDGET
        TRAIT-POLYMORPHIC-RECURSION TRAIT-INTERNAL
        AFFINE-GENERIC-NESTED-UNSUPPORTED AFFINE-INSTANCE-BUDGET
    }
    # The edges the waiting rule does not read (Waiting): a contributor's
    # link to what it contributes to (it orders, it reads nothing) and a
    # site's edge to a gate (whose contributors' presence withholds the
    # site's diagnostic rather than causing it).
    variable waitingSkip {
        verdict-contributor possible-contributor path-release plan-site
    }
}

# The dependency analysis of HIR, one build of a program whose static sites
# are SITES (hir::static::Sites, post-order) under DECISIONS (header).
proc hir::staticdeps::Deps {hir sites decisions {methods 0}} {
    set state [Prepare $hir $sites $decisions]
    # With METHODS, the region of every method-style call with several
    # candidates is a root too, and marks what reaches it (M:region).
    set mregions [dict create]
    set mcalls [dict create]
    if {$methods && [dict exists $hir methodCalls]} {
        dict for {key info} [dict get $hir methodCalls] {
            set e [dict get $info expr]
            if {![dict exists $state regionOf $e]} continue
            set q [dict get $state regionOf $e]
            dict set mcalls $key $q
            dict lappend mregions $q $key
        }
    }
    set G [dict create]
    set labels [dict create]
    # Tarjan's strongly connected components over the nodes reachable from
    # the sites, iteratively; the site sets are summed over the condensation
    # in the order the components complete (every successor's first).
    set index [dict create]
    set low [dict create]
    set onStack [dict create]
    set stack {}
    set counter 0
    set sccOf [dict create]
    set sccSites [dict create]
    set sccCount 0
    set roots {}
    foreach key [dict get $state presentKeys] {
        if {[dict exists $state siteHome $key]} {
            lappend roots Z:$key
        }
    }
    foreach q [dict keys $mregions] {
        lappend roots R:$q
    }
    foreach root $roots {
        if {[dict exists $index $root]} continue
        set work [list [list $root 0]]
        while {$work ne {}} {
            lassign [lindex $work end] v i
            if {$i == 0} {
                dict set index $v $counter
                dict set low $v $counter
                incr counter
                lappend stack $v
                dict set onStack $v 1
                if {![dict exists $G $v]} {
                    set succ [Successors $hir state $v]
                    dict set G $v [dict keys $succ]
                    dict set labels $v $succ
                }
            }
            set succs [dict get $G $v]
            set descended 0
            while {$i < [llength $succs]} {
                set w [lindex $succs $i]
                incr i
                if {![dict exists $index $w]} {
                    lset work end [list $v $i]
                    lappend work [list $w 0]
                    set descended 1
                    break
                } elseif {[dict exists $onStack $w]} {
                    if {[dict get $index $w] < [dict get $low $v]} {
                        dict set low $v [dict get $index $w]
                    }
                }
            }
            if {$descended} continue
            # Every successor of V is done.
            lpop work
            if {[dict get $low $v] == [dict get $index $v]} {
                set id $sccCount
                incr sccCount
                set members {}
                while 1 {
                    set w [lpop stack]
                    dict unset onStack $w
                    dict set sccOf $w $id
                    lappend members $w
                    if {$w eq $v} break
                }
                set found [dict create]
                foreach w $members {
                    if {[string match F:* $w]} {
                        dict set found [string range $w 2 end] 1
                    } elseif {[string match R:* $w] && [dict exists $mregions [string range $w 2 end]]} {
                        dict set found M:[string range $w 2 end] 1
                    }
                    foreach x [dict get $G $w] {
                        set sx [dict get $sccOf $x]
                        if {$sx != $id} {
                            foreach k [dict get $sccSites $sx] {
                                dict set found $k 1
                            }
                        }
                    }
                }
                dict set sccSites $id [dict keys $found]
            }
            if {$work ne {}} {
                set parent [lindex [lindex $work end] 0]
                if {[dict get $low $v] < [dict get $low $parent]} {
                    dict set low $parent [dict get $low $v]
                }
            }
        }
    }
    set result [dict create]
    foreach key [dict get $state presentKeys] {
        if {![dict exists $sccOf Z:$key]} {
            dict set result $key {}
            continue
        }
        dict set result $key [lsearch -all -inline -not -glob \
            [lsearch -all -inline -not -exact [dict get $sccSites [dict get $sccOf Z:$key]] $key] M:*]
    }
    lassign [Waiting $state $G $labels $sccOf $sccSites $result] consumes contributors
    # Per method-style call: the sites and the method-call regions its own
    # region reaches (hir/static.tcl's MethodSeeds).
    set methodCones [dict create]
    dict for {key q} $mcalls {
        set markers [dict get $sccSites [dict get $sccOf R:$q]]
        set calls {}
        foreach m [lsearch -all -inline -glob $markers M:*] {
            lappend calls {*}[dict get $mregions [string range $m 2 end]]
        }
        dict set methodCones $key [dict create sites [lsearch -all -inline -not -glob $markers M:*] \
            calls [lsort -unique $calls]]
    }
    # Per site, the smallest expression number in its span: every expression
    # numbered below it is numbered the same whatever the site's form (ids
    # are allocated in one walk of the program, hir::NewId).
    set firstIds [dict create]
    dict for {site exprs} [dict getdef $state siteExprs {}] {
        set min ""
        foreach e $exprs {
            set n [string range $e 1 end]
            if {$min eq "" || $n < $min} {
                set min $n
            }
        }
        dict set firstIds $site $min
    }
    return [dict create sites $result channels [dict get $state channels] \
        labels $labels names [dict get $state names] nodes [dict size $G] methods $methodCones \
        firstIds $firstIds consumes $consumes contributors $contributors]
}

# The waiting rule's reading of the graph (header, "The waiting rule";
# hir/static.tcl's Waits): a list {CONSUMES CONTRIBUTORS}, from STATE
# (Prepare's walk), G and LABELS (Deps' graph: node -> successors, node ->
# {successor label ...}), SCCOF and SCCSITES (its components and the site
# forms each reaches) and SITES (Deps' result, whose keys are the sites
# present as bodies).
#
#   CONSUMES      key -> the waiting channels (C:erased, C:budget:B) the
#                 site's diagnostics read: those its node reaches over every
#                 edge but a link (a contributor's edge to what it
#                 contributes to, which orders but reads nothing) or a
#                 gate's (C:verdict, C:plan: their contributors' presence
#                 withholds a consumer's diagnostic rather than causing it);
#                 not C:erased for a site whose first diagnostic was
#                 reported before the completion walk (STATE's early),
#                 which no erasure can cause or precede
#   CONTRIBUTORS  channel -> the sites whose form its value may depend on:
#                 every site holding a contribution (the erased contract's
#                 every one, not only its witnesses) and every site form the
#                 channel's node reaches. Not closed under what those sites
#                 read: an ok contributor that a later rejection makes fail
#                 holds no consumer back (STATIC-COMPILE.md, "The waiting
#                 rule": a residual case, with cycles), since that closure
#                 made ordinary failing sites a contributor's code reads wait
#                 for each other, one build each (STATIC-DECISION-
#                 ECONOMICS.md, "The waiting rule")
proc hir::staticdeps::Waiting {state G labels sccOf sccSites sites} {
    variable waitingSkip
    # Tarjan over the edges the rule reads, from the sites' own nodes; the
    # waiting channels each component reaches, summed as Deps sums sites.
    set index [dict create]
    set low [dict create]
    set onStack [dict create]
    set stack {}
    set counter 0
    set compOf [dict create]
    set compChannels [dict create]
    set ncomp 0
    set fsucc [dict create]
    set consumes [dict create]
    foreach key [dict get $state presentKeys] {
        set root Z:$key
        if {![dict exists $G $root]} {
            dict set consumes $key {}
            continue
        }
        if {![dict exists $index $root]} {
            set work [list [list $root 0]]
            while {$work ne {}} {
                lassign [lindex $work end] v i
                if {$i == 0} {
                    dict set index $v $counter
                    dict set low $v $counter
                    incr counter
                    lappend stack $v
                    dict set onStack $v 1
                }
                if {![dict exists $fsucc $v]} {
                    dict set fsucc $v [lmap {w label} [dict get $labels $v] {
                        if {$label in $waitingSkip} continue
                        set w
                    }]
                }
                set succs [dict get $fsucc $v]
                set descended 0
                while {$i < [llength $succs]} {
                    set w [lindex $succs $i]
                    incr i
                    if {![dict exists $index $w]} {
                        lset work end [list $v $i]
                        lappend work [list $w 0]
                        set descended 1
                        break
                    } elseif {[dict exists $onStack $w]} {
                        if {[dict get $index $w] < [dict get $low $v]} {
                            dict set low $v [dict get $index $w]
                        }
                    }
                }
                if {$descended} continue
                lpop work
                if {[dict get $low $v] == [dict get $index $v]} {
                    set id $ncomp
                    incr ncomp
                    set members {}
                    while 1 {
                        set w [lpop stack]
                        dict unset onStack $w
                        dict set compOf $w $id
                        lappend members $w
                        if {$w eq $v} break
                    }
                    set found [dict create]
                    foreach w $members {
                        if {$w eq "C:erased" || [string match C:budget:* $w]} {
                            dict set found $w 1
                        }
                        foreach x [dict get $fsucc $w] {
                            set cx [dict get $compOf $x]
                            if {$cx != $id} {
                                foreach c [dict get $compChannels $cx] {
                                    dict set found $c 1
                                }
                            }
                        }
                    }
                    dict set compChannels $id [dict keys $found]
                }
                if {$work ne {}} {
                    set parent [lindex [lindex $work end] 0]
                    if {[dict get $low $v] < [dict get $low $parent]} {
                        dict set low $parent [dict get $low $v]
                    }
                }
            }
        }
        set channels [dict get $compChannels [dict get $compOf $root]]
        if {[dict exists $state early $key]} {
            # Its first diagnostic was reported before the completion walk,
            # and nothing there reads the erased contract (hir/affine.tcl's
            # exit releases read it and report nothing): it stays its first
            # diagnostic whatever the program erases.
            set channels [lsearch -all -inline -not -exact $channels C:erased]
        }
        dict set consumes $key [lsort $channels]
    }
    set contributors [dict create]
    dict for {v _} $G {
        if {$v ne "C:erased" && ![string match C:budget:* $v]} continue
        set base [lsearch -all -inline -not -glob [dict get $sccSites [dict get $sccOf $v]] M:*]
        if {$v eq "C:erased"} {
            lappend base {*}[dict keys [dict get $state erasureSites]]
        }
        set seen [dict create]
        foreach key $base {
            if {[dict exists $sites $key]} {
                dict set seen $key 1
            }
        }
        dict set contributors $v [dict keys $seen]
    }
    return [list $consumes $contributors]
}

# A path of DEPS's graph from site Y's node to site Z's, as text: each step's
# edge label and the node it reaches (Deps' header names the labels).
proc hir::staticdeps::Explain {deps y z} {
    set labels [dict get $deps labels]
    set from [dict create Z:$y ""]
    set queue [list Z:$y]
    set target F:$z
    while {$queue ne {}} {
        set v [lindex $queue 0]
        set queue [lrange $queue 1 end]
        if {$v eq $target} break
        if {![dict exists $labels $v]} continue
        dict for {w label} [dict get $labels $v] {
            if {![dict exists $from $w]} {
                dict set from $w [list $v $label]
                lappend queue $w
            }
        }
    }
    if {![dict exists $from $target]} {
        return "no path"
    }
    set steps {}
    set v $target
    while {[dict get $from $v] ne ""} {
        lassign [dict get $from $v] u label
        set steps [linsert $steps 0 "$label [Name $deps $v]"]
        set v $u
    }
    return [join $steps " -> "]
}

proc hir::staticdeps::Name {deps node} {
    if {[dict exists $deps names $node]} {
        return [dict get $deps names $node]
    }
    return $node
}

# ---------------------------------------------------------------------------
# The walk: what the successors are computed from

# The facts of HIR the graph is built from, as a dict (one walk of the
# program and of every function body).
proc hir::staticdeps::Prepare {hir sites decisions} {
    set present {}
    foreach site $sites {
        set key [dict get $site key]
        if {[dict exists $decisions $key] && [lindex [dict get $decisions $key] 0] eq "rejected"} continue
        lappend present $site
    }
    # Site spans by file, sorted by start; the enclosing present site of each.
    set byFile [dict create]
    foreach site $present {
        set origin [dict get $site origin]
        dict lappend byFile [dict get $origin file] \
            [list [dict get $origin start] [dict get $origin end] [dict get $site key]]
    }
    set spanParent [dict create]
    set spanChildren [dict create]
    dict for {file spans} $byFile {
        set spans [lsort -command hir::staticdeps::SpanOrder $spans]
        dict set byFile $file $spans
        set open {}
        foreach span $spans {
            lassign $span start end key
            while {$open ne {} && [lindex $open end 1] < $start} {
                set open [lrange $open 0 end-1]
            }
            if {$open eq {}} {
                set outer ""
            } else {
                set outer [lindex $open end 2]
            }
            dict set spanParent $key $outer
            if {$outer ne ""} {
                dict lappend spanChildren $outer $key
            }
            lappend open $span
        }
    }
    set state [dict create byFile $byFile spanParent $spanParent spanChildren $spanChildren \
        presentKeys [lmap site $present {dict get $site key}] presentSites $present \
        regionOf {} parentOf {} litRegion {} ownRefs {} ownLits {} ownTargets {} \
        ownSites {} siteHome {} siteDepth {} depth {program 0} \
        subtree {} names {} paramOwner {} channels {}]
    # The walk: every expression's region and parent; per region the
    # bindings, literals, call targets and sites its own code mentions.
    # The lists keyed by a site, region or binding (site -> its expressions,
    # region -> its function literals, binding -> its references, region ->
    # its calls) are built in variables of their own and stored nested once
    # the walk is done: `dict lappend state FIELD KEY VALUE` would append KEY
    # and VALUE to one flat list, of which a lookup by KEY keeps only the last
    # pair -- the analysis once dropped every mention of a binding but the
    # last that way (tests/static-economics.test, se-equal-every-mention).
    set siteExprs [dict create]
    set children [dict create]
    set mentions [dict create]
    set ownCalls [dict create]
    set regionOf [dict create]
    set parentOf [dict create]
    set litRegion [dict create]
    set depth [dict create program 0]
    set siteOf [dict create]
    set stack {}
    foreach r [lreverse [dict get $hir roots]] {
        lappend stack [list $r program ""]
    }
    set exprs [dict get $hir exprs]
    while {$stack ne {}} {
        lassign [lpop stack] e region parent
        if {[dict exists $regionOf $e] || ![dict exists $exprs $e]} continue
        dict set regionOf $e $region
        dict set parentOf $e $parent
        set node [dict get $exprs $e]
        set site [SiteAt $byFile $spanParent [dict get $node origin]]
        if {$site ne ""} {
            dict set siteOf $e $site
            dict lappend siteExprs $site $e
            dict set state ownSites $region $site 1
            set d [dict get $depth $region]
            if {![dict exists $state siteDepth $site] || $d < [dict get $state siteDepth $site]} {
                dict set state siteDepth $site $d
                dict set state siteHome $site $region
            }
        }
        switch -- [dict get $node kind] {
            block {
                dict set litRegion $e $region
                dict set state ownLits $region $e 1
                dict set depth $e [expr {[dict get $depth $region] + 1}]
                dict lappend children $region $e
                set i 0
                foreach p [dict get $node params] {
                    dict set state paramOwner $p [list block $e $i]
                    incr i
                }
                foreach b [lreverse [dict get $node body]] {
                    lappend stack [list $b $e ""]
                }
                continue
            }
            ref {
                set b [dict get $node binding]
                if {$b ne "" && [dict get $hir bindings $b kind] ne "root"} {
                    dict set state ownRefs $region $b 1
                    dict lappend mentions $b $e
                }
            }
            call {
                lassign [dict get $node target] tk tb
                if {$tk eq "block"} {
                    dict set state ownTargets $region $tb 1
                }
                dict lappend ownCalls $region $e
            }
            listloop {
                dict set state paramOwner [dict get $node elementBinding] [list loop $e]
            }
            countloop {
                dict set state paramOwner [dict get $node countBinding] [list loop $e]
            }
            lockloop {
                foreach domain [dict get $node domains] {
                    foreach field {binding elementBinding countBinding} {
                        if {[dict exists $domain $field] && [dict get $domain $field] ne ""} {
                            dict set state paramOwner [dict get $domain $field] [list loop $e]
                        }
                    }
                }
            }
            handle {
                foreach payload [dict get $node handlerPayloads] {
                    foreach b $payload {
                        if {$b ne "" && [dict exists $hir bindings $b]} {
                            dict set state paramOwner $b [list handle $e]
                        }
                    }
                }
            }
        }
        foreach c [lreverse [hir::children $hir $e]] {
            lappend stack [list $c $region $e]
        }
    }
    dict set state siteExprs $siteExprs
    dict set state children $children
    dict set state mentions $mentions
    dict set state ownCalls $ownCalls
    dict set state regionOf $regionOf
    dict set state parentOf $parentOf
    dict set state litRegion $litRegion
    dict set state depth $depth
    dict set state siteOf $siteOf
    # The region of each scope: where the bindings it holds live.
    set scopeRegion [dict create]
    dict for {e region} $regionOf {
        set s [dict get $exprs $e scope]
        if {![dict exists $scopeRegion $s]} {
            dict set scopeRegion $s $region
        }
        if {[dict get $exprs $e kind] eq "block"} {
            dict set scopeRegion [dict get $exprs $e bodyScope] $e
        }
    }
    dict set state scopeRegion $scopeRegion
    # Method-style calls: every candidate of a call with several (the trial
    # builds resolve the call to each in turn).
    set candidates [dict create]
    if {[dict exists $hir methodCalls]} {
        dict for {key info} [dict get $hir methodCalls] {
            set e [dict get $info expr]
            if {![dict exists $regionOf $e]} continue
            foreach display [dict get $info candidates] {
                set b [CandidateBinding $hir $e $display]
                if {$b ne ""} {
                    dict set candidates $e $b 1
                }
            }
        }
    }
    dict set state candidates $candidates
    # What the trial builds of each method-style call judge that reads the
    # contract boundary (R:region's method-trial edges): the checks at the
    # call's own arguments, whose structural type is the candidate's
    # parameter's -- so may differ from one candidate's trial to another's.
    # Every part of an argument that some candidate's parameter could give a
    # structural Fn type (CallableParts) is analyzed there against what the
    # program erases (hir::completions::SubsumedRaises), its captures and
    # parameters standing for what they may hold (P:). A coroutine handle's
    # check reads no parameter type (hir::completions::SubsumeHandle): the
    # same report, at the same expression, for every candidate but a
    # coroutine operation, whose positions the check skips
    # (hir::completions::SubsumeCall), so it tells such a candidate from the
    # others. Checks deeper in the call are no checks of the call's own
    # (hir::methods::Problems never reads them).
    set methodTrial [dict create]
    if {[dict exists $hir methodCalls]} {
        set operations [CoroutineOperations]
        dict for {key info} [dict get $hir methodCalls] {
            set e [dict get $info expr]
            if {![dict exists $regionOf $e]} continue
            set q [dict get $regionOf $e]
            set operation 0
            foreach display [dict get $info candidates] {
                if {$display in $operations} {
                    set operation 1
                }
            }
            foreach arg [dict get $exprs $e args] {
                set type [hir::typeOf $hir $arg]
                if {[hir::types::IsCoroutine $type]} {
                    if {$operation} {
                        set thunk [hir::coroutines::thunkOfHandle $hir $arg]
                    } else {
                        set thunk ""
                    }
                    if {$thunk ne ""} {
                        dict set methodTrial $q C:erased 1
                        foreach c [dict get $exprs $thunk captures] {
                            dict set methodTrial $q P:$c 1
                        }
                    }
                    continue
                }
                foreach part [CallableParts $type] {
                    dict set methodTrial $q C:erased 1
                    if {[hir::types::IsExactBlock $part] && [dict exists $exprs [lindex $part 1]]} {
                        set block [dict get $exprs [lindex $part 1]]
                        foreach b [concat [dict get $block params] [dict get $block captures]] {
                            dict set methodTrial $q P:$b 1
                        }
                    }
                }
            }
        }
    }
    dict set state methodTrial $methodTrial
    # The sites whose first diagnostic in this build was reported before the
    # completion walk (HIR's beforeCompletions): no contract-boundary report
    # can come before it, whatever the program erases (Z:site).
    set early [dict create]
    if {[dict exists $hir beforeCompletions]} {
        lassign [dict get $hir beforeCompletions] from to
        set judged [dict create]
        set i 0
        foreach d [dict get $hir diagnostics] {
            # Its owner as hir::static::Attribute names it.
            set owner [if {[hir::static::Internal $d]} {string cat ""} else {hir::static::Owner $present [hir::static::PrimaryOrigin $hir $d]}]
            if {$owner ne "" && ![dict exists $judged $owner]} {
                dict set judged $owner 1
                if {$i >= $from && $i < $to} {
                    dict set early $owner 1
                }
            }
            incr i
        }
    }
    dict set state early $early
    # Functions used as values (some reference is not a callee): their
    # uncontracted parameters are checked against the erased-callable
    # contract, never against their calls' arguments (hir::completions::
    # PossibleOf).
    set definedBy [dict create]
    set callees [dict create]
    set callsOf [dict create]
    set creates {}
    set yielding [dict create]
    set callEdges [dict create]
    dict for {e region} $regionOf {
        set node [dict get $exprs $e]
        switch -- [dict get $node kind] {
            bind {
                set v [dict get $node value]
                if {$v ne "" && [dict exists $exprs $v] && [dict get $exprs $v kind] eq "block"} {
                    dict set definedBy $v [dict get $node binding]
                }
            }
            call {
                dict set callees [dict get $node callee] 1
                lassign [dict get $node target] tk tb
                if {$tk eq "block"} {
                    dict lappend callsOf $tb $e
                    dict set callEdges $region $tb 1
                }
                switch -- [hir::coroutines::NativeOf $hir $e] {
                    coroutine#create { lappend creates $e }
                    coroutine#yield { dict set yielding $region 1 }
                }
            }
        }
    }
    set escaping [dict create]
    dict for {e region} $regionOf {
        set node [dict get $exprs $e]
        if {[dict get $node kind] eq "ref" && ![dict exists $callees $e] && [dict get $node binding] ne ""} {
            dict set escaping [dict get $node binding] 1
        }
    }
    dict set state definedBy $definedBy
    dict set state escaping $escaping
    dict set state callsOf $callsOf
    # Yields: the coroutine constructions whose root reaches each yielding
    # function over the exact call edges (yieldAll: the outward types a
    # yield's value lands in, hir::completions::YieldFinalsOf), and among
    # them those whose root has a struct protocol, which alone decide the
    # type of an unconstrained function's yields (yieldStruct: `any` once
    # one reaches it, else `unit`; hir/coroutines.tcl's analyze).
    set table [dict getdef $hir coroutines blocks {}]
    set yieldAll [dict create]
    set yieldStruct [dict create]
    foreach c $creates {
        set root [CreateRoot $hir $c]
        set struct 1
        if {$root ne "" && [dict exists $table $root]} {
            set struct [hir::coroutines::IsStructProtocol \
                [hir::coroutines::Resolved [dict get $table $root protocol]]]
        }
        if {$root eq ""} {
            # A construction whose root is unknown: every yield may be
            # reached by it.
            set reached [dict keys $yielding]
        } else {
            set reached {}
            set seen [dict create]
            set work [list $root]
            while {$work ne {}} {
                set b [lpop work]
                if {[dict exists $seen $b]} continue
                dict set seen $b 1
                if {[dict exists $yielding $b]} {
                    lappend reached $b
                }
                if {[dict exists $callEdges $b]} {
                    lappend work {*}[dict keys [dict get $callEdges $b]]
                }
            }
        }
        foreach q $reached {
            dict lappend yieldAll $q $c
            if {$struct && (![dict exists $table $q] || [dict get $table $q protocol] eq "none")} {
                dict lappend yieldStruct $q $c
            }
        }
    }
    dict set state yieldAll $yieldAll
    dict set state creates $creates
    dict set state yieldStruct $yieldStruct
    # The erased-callable contract (hir::completions::erasedErrorsOf): what
    # the program's erasures carry, and the regions that consume it.
    set points {}
    set units {}
    set consumers [dict create]
    dict for {e region} $regionOf {
        set node [dict get $exprs $e]
        if {[dict get $node kind] ne "call"} continue
        lassign [dict get $node target] tk tb
        set args [dict get $node args]
        if {$tk eq "native"} {
            set from [dict get [core::native::metadata [dict get $hir symbols $tb name]] errorsFrom]
            if {$from ne "" && $from < [llength $args]
                    && [hir::completions::Uncontracted [hir::typeOf $hir [lindex $args $from]]]} {
                dict set consumers $region 1
            }
        }
        if {[hir::completions::Uncontracted [hir::typeOf $hir [dict get $node callee]]]} {
            dict set consumers $region 1
        }
    }
    # Its contributors. A semantic instance erases what its arguments at
    # untyped parameters carry: an instance one of whose arguments there could
    # carry errors (a callable, or a value holding one: CanCarry -- a value of
    # any other type never carries any, whatever the sites become) depends on
    # the calls that requested it, and on theirs when the requesting call is
    # itself inside an instance.
    set position [dict create]
    set index 0
    foreach key [dict get $state presentKeys] {
        dict set position $key $index
        incr index
    }
    set paths [dict create]
    if {[dict exists $hir semantic instances]} {
        set requests [dict create]
        dict for {callKey id} [dict get $hir semantic calls] {
            dict lappend requests $id $callKey
        }
        dict for {id inst} [dict get $hir semantic instances] {
            set block [dict get $inst block]
            if {![dict exists $exprs $block]} continue
            set carries 0
            set carried {}
            foreach entry [hir::signatures::entryTypes $hir $block] type [dict get $inst args] {
                if {$entry eq "" && [CanCarry $hir $type]} {
                    set carries 1
                    lappend carried {*}[hir::callables::CarriedErrors $hir $type]
                }
            }
            if {!$carries} continue
            set chain {}
            set work [list $id]
            set seen [dict create]
            while {$work ne {}} {
                set i [lpop work]
                if {[dict exists $seen $i] || ![dict exists $requests $i]} continue
                dict set seen $i 1
                foreach callKey [dict get $requests $i] {
                    lassign $callKey caller call
                    if {[dict exists $regionOf $call]} {
                        # The call's key is its arguments at the parameters
                        # with no declared or trusted contract; the call
                        # itself exists where it is written.
                        lappend points [list key $call]
                        lappend chain $call
                    }
                    if {$caller ne "generic"} {
                        lappend work $caller
                    }
                }
            }
            # What it erases (InstanceErasures). When nothing, it never will
            # (C:erased): no contribution. Else the contribution exists while
            # one chain of requests does -- a request of the instance, of the
            # instance that request is made in, and so on up to the program's
            # own code: its *path* is the chain the sequential order removes
            # last (RequestPath).
            set carried [lsort -unique $carried]
            if {$carried ne {} && $chain ne {}} {
                lassign [RequestPath $requests $regionOf $siteOf $position $id paths] path rank
                if {$path ne {}} {
                    lappend units [list $carried key [lsort -unique $chain] $path $rank]
                }
            }
        }
        # A request the budget declined may be granted once a site is
        # rejected: one that could carry errors is a potential contributor.
        dict for {callKey reason} [dict get $hir semantic declined] {
            set call [lindex $callKey 1]
            if {![dict exists $regionOf $call]} continue
            foreach arg [dict get $exprs $call args] {
                if {[CanCarry $hir [hir::typeOf $hir $arg]]} {
                    lappend points [list key $call]
                    lappend units [list * key [list $call]]
                    break
                }
            }
        }
    }
    # Contravariant erasure: a callable with an uncontracted parameter whose
    # value acquires a structural Fn type there erases what that type's
    # argument carries (hir::completions::Contravariant), at the positions
    # hir::completions::Positions names and at a function's trailing value.
    if {[hir::completions::HasFnTypes $hir]} {
        set finals [hir::completions::YieldFinalsOf $hir]
        dict for {e region} $regionOf {
            set pairs [hir::completions::Positions $hir $e $finals]
            set node [dict get $exprs $e]
            if {[dict get $node kind] eq "block" && [dict get $node body] ne {}} {
                lappend pairs [list [lindex [dict get $node body] end] [hir::completions::ResultFinal $hir $e]]
            }
            foreach pair $pairs {
                lassign $pair value final
                if {$value eq "" || $final eq "" || ![dict exists $exprs $value]} continue
                foreach triple [hir::completions::Align [hir::typeOf $hir $value] $final] {
                    lassign $triple source target
                    set i 0
                    foreach arg [hir::types::FnArgs $target] {
                        if {[hir::completions::ParamUncontracted $hir $source $i] && [CanCarry $hir $arg]} {
                            lappend points [list all $value] [list all $e]
                            set carried [lsort -unique [hir::completions::Contravariant $hir $source $target]]
                            if {$carried ne {}} {
                                lappend units [list $carried all [list $value $e]]
                            }
                            break
                        }
                        incr i
                    }
                }
            }
        }
    }
    dict set state erasurePoints $points
    lassign [ErasureWitnesses $state $units] witnesses holding
    dict set state erasureWitnesses $witnesses
    dict set state erasureSites $holding
    dict set state erasedConsumers $consumers
    # The semantic-instance budget: the blocks under pressure.
    set pressured [dict create]
    set global 0
    if {[dict exists $hir semantic byBlock]} {
        set half [expr {$::hir::semantic::maxPerBlock / 2}]
        set total 0
        dict for {b n} [dict get $hir semantic byBlock] {
            incr total $n
            if {$n >= $half} {
                dict set pressured $b 1
            }
        }
        if {$total >= $::hir::semantic::maxInstances / 2} {
            set global 1
        }
        if {[dict exists $hir semantic deep] && [dict size [dict get $hir semantic deep]] > 0} {
            # A request at half the nesting limits: a rejection removing the
            # request before it can make it the first one, declined for nesting.
            set global 1
        }
        dict for {callKey reason} [dict get $hir semantic declined] {
            if {$reason in {budget-total nesting}} {
                set global 1
            } elseif {$reason eq "budget-block"} {
                set e [lindex $callKey 1]
                if {[dict exists $exprs $e target] && [lindex [dict get $exprs $e target] 0] eq "block"} {
                    dict set pressured [lindex [dict get $exprs $e target] 1] 1
                } else {
                    set global 1
                }
            }
        }
    }
    if {$global} {
        dict for {b _} $callsOf {
            dict set pressured $b 1
        }
    }
    set budgetOf [dict create]
    dict for {b _} $pressured {
        if {![dict exists $callsOf $b]} continue
        foreach call [dict get $callsOf $b] {
            dict set budgetOf [dict get $regionOf $call] $b 1
        }
    }
    dict set state pressured $pressured
    dict set state budgetOf $budgetOf
    # The ownership analysis's verdict (C:verdict).
    lassign [Ownership $hir $state] pathRelease verdict linked diagnosed
    dict set state pathRelease $pathRelease
    dict set state verdict $verdict
    dict set state verdictLinked $linked
    # The sites passing a value with a fixed part to an uncontracted input
    # (PossibleSuccessors): linked to what that input may hold.
    set possibleLinks [dict create]
    dict for {block calls} $callsOf {
        if {![dict exists $exprs $block] || ![dict exists $definedBy $block]
                || [dict exists $escaping [dict get $definedBy $block]]} continue
        set i 0
        foreach p [dict get $exprs $block params] {
            if {[hir::completions::CleanInput $hir $p]} {
                foreach call $calls {
                    set arg [lindex [dict get $exprs $call args] $i]
                    if {$arg eq "" || ![dict exists $siteOf $arg]} continue
                    if {[lindex [PossibleUnit $hir state $arg] 0] eq "fixed"} {
                        dict set possibleLinks [dict get $siteOf $arg] P:$p 1
                    }
                }
            }
            incr i
        }
    }
    dict set state possibleLinks $possibleLinks
    # The gate of the trait monomorphization's plan (C:plan).
    lassign [PlanGate $hir $state] planConsumers plan planOpen
    dict set state planConsumers $planConsumers
    dict set state plan $plan
    dict set state channels [dict create erasurePoints [llength $points] \
        erasedConsumers [dict size $consumers] budgetPressure [dict size $pressured] \
        yieldingFunctions [dict size $yielding] constructions [llength $creates] \
        ownershipDiagnostics $diagnosed pathReleaseSites [dict size $pathRelease] \
        planSites [dict size $planConsumers] planGate [expr {$planOpen ? "open" : "closed"}]]
    return $state
}

# The chain of requests that keeps semantic instance ID requested (a list
# {PATH RANK}): an instance exists while one of its requests does, a request
# while its call does and, made inside an instance, while that instance
# does. PATH is the calls of the chain the sequential order removes last --
# the one whose earliest site (POSITION: site key -> post-order index;
# SITEOF: expression -> its innermost site) is last, a call in no site's
# body counting as last of all -- and RANK that site's position; {{} -1} for
# none. REQUESTS: instance -> its requests {CALLER CALL}; PATHSVAR the
# caller's memo.
proc hir::staticdeps::RequestPath {requests regionOf siteOf position id pathsVar {visiting {}}} {
    upvar 1 $pathsVar paths
    if {[dict exists $paths $id]} {
        return [dict get $paths $id]
    }
    set never [expr {[dict size $position] + 1}]
    set best {}
    set bestRank -1
    if {[dict exists $requests $id]} {
        foreach callKey [dict get $requests $id] {
            lassign $callKey caller call
            if {![dict exists $regionOf $call]} continue
            if {[dict exists $siteOf $call]} {
                set rank [dict get $position [dict get $siteOf $call]]
            } else {
                set rank $never
            }
            set path [list $call]
            if {$caller ne "generic"} {
                if {$caller in $visiting || $caller eq $id} continue
                lassign [RequestPath $requests $regionOf $siteOf $position $caller paths \
                    [concat $visiting [list $id]]] up upRank
                if {$up eq {}} continue
                set rank [expr {min($rank, $upRank)}]
                lappend path {*}$up
            }
            if {$rank > $bestRank} {
                set best $path
                set bestRank $rank
            }
        }
    }
    dict set paths $id [list $best $bestRank]
    return [list $best $bestRank]
}

# The erased-callable contract's witnesses (header, C:erased), from STATE
# (Prepare's walk) and UNITS, the program's contributions, each {ERRORS HOW
# ITEMS}: a semantic instance's (HOW key: ITEMS its requests, up the chain of
# requests -- the contribution exists while all of them do), a contravariant
# erasure's (HOW all: ITEMS the value and its expression), each with the
# errors it erases, or (ERRORS `*`) a declined request's, whose errors are not
# known. A list {WITNESSES HOLDING}, HOLDING the sites (key -> 1) holding a
# contribution of known errors.
#
# The contract is the union of the contributions' errors, and what reads it
# reads that set and nothing else (hir::completions::ErasedErrors: an
# uncontracted call is charged it, Subsume and Possible run while it is not
# empty). An error leaves it only once every contribution erasing it has
# lost it -- so the contract depends, per error, on one *witness*: the
# contribution the sequential order removes last (the one whose earliest site
# is last in post-order; one in no site's body before every other), and on
# every contribution whose errors are not known. Rejecting any other
# contributor's site leaves the set as it is: callable-contracts.bot's 41
# sites, each erasing an error-declaring callable and calling an uncontracted
# one, are no longer decided one per build. The sites holding a contribution
# (HOLDING) are the waiting rule's contributors (Waiting): a failing
# consumer waits for every failing one, witness or not.
proc hir::staticdeps::ErasureWitnesses {state units} {
    set position [dict create]
    set i 0
    foreach key [dict get $state presentKeys] {
        dict set position $key $i
        incr i
    }
    set never [expr {$i + 1}]
    set witnesses {}
    set best [dict create]
    set holding [dict create]
    set index 0
    foreach unit $units {
        lassign $unit errors how items path pathRank
        if {$errors eq "*"} {
            lappend witnesses $index
            incr index
            continue
        }
        set rank $never
        foreach e $items {
            if {[dict exists $state siteOf $e]} {
                set s [dict get $state siteOf $e]
                dict set holding $s 1
                if {[dict get $position $s] < $rank} {
                    set rank [dict get $position $s]
                }
            }
        }
        if {$how eq "key"} {
            # A semantic instance's: removed with the last chain of its
            # requests (RequestPath).
            set rank $pathRank
        }
        foreach error $errors {
            if {![dict exists $best $error] || $rank > [lindex [dict get $best $error] 1]} {
                dict set best $error [list $index $rank]
            }
        }
        incr index
    }
    dict for {error pick} $best {
        lappend witnesses [lindex $pick 0]
    }
    return [list [lmap i [lsort -integer -unique $witnesses] {lindex $units $i}] $holding]
}

# The plan's part of the graph (header, C:plan), from STATE (Prepare's walk):
# a list {CONSUMERS PLAN OPEN} -- CONSUMERS the sites (key -> 1) that may hold
# a diagnostic of the plan, PLAN C:plan's successors (node -> edge label), OPEN
# whether the build's diagnostics may be the plan's own (every one of a kind
# the plan reports: the plan ran and reported them, or -- for kinds the
# checker reports too -- may have).
proc hir::staticdeps::PlanGate {hir state} {
    variable planKinds
    set exprs [dict get $hir exprs]
    set regionOf [dict get $state regionOf]
    set present [dict get $state presentSites]
    # The consumers: the sites holding a call the plan can report at (its
    # diagnostics are anchored at the call, hir::traits::Plan) -- a trait
    # operation (TRAIT-NOT-SATISFIED in a clone's view, TRAIT-IMPL-ORDER); a
    # call of a trait-polymorphic function some context of the plan has no
    # instance for (Unplanned: TRAIT-INSTANCE-BUDGET); a call giving an
    # untyped parameter an argument whose type is affine or may become
    # affine (MayBecomeAffine: a clone's view, or a rejection narrowing an
    # `any`, may make it so: AFFINE-GENERIC-NESTED-UNSUPPORTED -- also a
    # call of a function requiring a context trait, whose other outcomes are
    # no site's diagnostic --, AFFINE-INSTANCE-BUDGET). (A call whose target or trait
    # operation a rejection would first have to make exact is not one: such
    # a site, if any, is predicted ok and the build that reports its plan
    # diagnostic records a misprediction -- the audits fail on it.)
    set consumers [dict create]
    if {![dict exists $hir traits] && [dict get $state creates] eq {}} {
        # Neither a trait nor a coroutine construction: the plan never runs
        # (hir::BuildFull: trait declarations, or a generic function given an
        # affine argument, which only a coroutine handle makes).
        return [list $consumers {} 0]
    }
    set polymorphic [dict create]
    dict for {site list} [dict get $state siteExprs] {
        foreach e $list {
            set node [dict get $exprs $e]
            if {[dict get $node kind] ne "call"} continue
            if {[dict exists $node traitCall]} {
                dict set consumers $site 1
                break
            }
            lassign [dict get $node target] tk tb
            if {$tk ne "block" || ![dict exists $exprs $tb]} continue
            if {![dict exists $polymorphic $tb]} {
                dict set polymorphic $tb [hir::traits::IsPolymorphic $hir $tb]
            }
            if {[dict get $polymorphic $tb]} {
                # Its one diagnostic, TRAIT-INSTANCE-BUDGET, only where a plan
                # context has no instance for it (Unplanned).
                if {[Unplanned $hir $regionOf $e]} {
                    dict set consumers $site 1
                    break
                }
                continue
            }
            set found 0
            foreach arg [dict get $node args] declared [dict get $exprs $tb declaredParamTypes] {
                if {$arg ne "" && $declared eq {}} {
                    if {[MayBecomeAffine [hir::typeOf $hir $arg]]} {
                        set found 1
                        break
                    }
                }
            }
            if {$found} {
                dict set consumers $site 1
                break
            }
        }
    }
    # The build's diagnostics, each {SITE REGION}: a compiler failure is
    # never a site's (hir::static::Internal). The region is the one whose
    # facts the diagnostic is about: a diagnostic at a function literal (its
    # declared result not proven, an error it does not declare) is about the
    # function's own body -- not about the code the literal stands in, which
    # for a top-level function is the whole program's top-level code.
    set diagnosed {}
    set open 1
    foreach d [dict get $hir diagnostics] {
        if {[dict get $d kind] ni $planKinds || ([dict get $d kind] eq "TRAIT-NOT-SATISFIED"
                && [regexp {^(argument for parameter |the function's declared result )} [dict get $d message]])} {
            # Not the plan's: a kind it does not report, or the checker's
            # TRAIT-NOT-SATISFIED (at a call's argument, at a function's
            # exit; the plan's is hir::traits::explain's text alone).
            set open 0
        }
        set e [dict get $d expr]
        if {[dict exists $exprs $e] && [dict get $exprs $e kind] eq "block" && [dict exists $regionOf $e]} {
            set region $e
        } else {
            set region [dict getdef $regionOf $e "program"]
        }
        # Its site as hir/static.tcl attributes it (Attribute).
        set site [if {[hir::static::Internal $d]} {string cat ""} else {hir::static::Owner $present [hir::static::PrimaryOrigin $hir $d]}]
        lappend diagnosed [list $site $region]
    }
    set plan [dict create]
    if {$diagnosed eq {} || [dict size $consumers] == 0 && !$open} {
        # No diagnostic: the plan ran and had none to report (the program is
        # final); or no site can hold one of its diagnostics.
        return [list $consumers $plan 0]
    }
    if {$open} {
        # Every diagnostic may be the plan's: one computation over the whole
        # program, which a rejection anywhere can change -- every site holding
        # one is a consumer, and the plan depends on each.
        foreach item $diagnosed {
            lassign $item site region
            if {$site eq ""} {
                dict set plan R:$region plan-diagnostic
            } else {
                dict set consumers $site 1
                dict set plan F:$site plan-diagnostic
            }
        }
        return [list $consumers $plan 1]
    }
    # Closed: a consumer that has a diagnostic of its own keeps the gate
    # closed itself -- its status changes only once that diagnostic is gone,
    # which is what its own edges say -- so only a consumer without one reads
    # the gate.
    foreach item $diagnosed {
        dict unset consumers [lindex $item 0]
    }
    # The plan does not run while one diagnostic stays. So it depends
    # on one witness: the site of the diagnostic last in post-order (the
    # sequential order rejects it last), what its diagnostics read and its
    # form; else, with no diagnostic in a site's body, the region of each one
    # (no decision removes one but through what that region reads). Any one
    # witness is sound -- the gate cannot open while its diagnostic stays --
    # and one in a site's body is the cheaper: a diagnostic of the program's
    # own at a top-level function would make the top-level code, and so
    # every function, the witness.
    set position [dict create]
    set i 0
    foreach key [dict get $state presentKeys] {
        dict set position $key $i
        incr i
    }
    set last ""
    foreach item $diagnosed {
        lassign $item site region
        if {$site ne "" && ($last eq "" || [dict get $position $site] > [dict get $position $last])} {
            set last $site
        }
    }
    if {$last ne ""} {
        dict set plan Z:$last plan-gate
        dict set plan F:$last plan-gate
    } else {
        foreach item $diagnosed {
            dict set plan R:[lindex $item 1] plan-gate
        }
    }
    return [list $consumers $plan 0]
}

# 1 if call E of a trait-polymorphic function may lack an instance in a
# context hir::traits::Plan walks it in: E is in the generic program (or a
# function requiring only a context trait, analyzed generically) and has no
# generic instance, or E is in a trait-polymorphic function -- top-level only
# (TRAIT-NESTED-POLYMORPHIC) -- some instance of which has none for it.
# (Instances the plan never reaches are counted too, and so is a dead call --
# an argument of type `never` --, at which the plan reports nothing: an
# over-approximation.)
proc hir::staticdeps::Unplanned {hir regionOf e} {
    if {![dict exists $hir semantic calls]} {
        return 1
    }
    set calls [dict get $hir semantic calls]
    set top [dict get $regionOf $e]
    while {$top ne "program" && [dict get $regionOf $top] ne "program"} {
        set top [dict get $regionOf $top]
    }
    if {$top eq "program" || ![hir::traits::IsPolymorphic $hir $top]} {
        return [expr {![dict exists $calls [list generic $e]]}]
    }
    if {![dict exists $hir semantic instsOf $top]} {
        return 0
    }
    foreach id [dict get $hir semantic instsOf $top] {
        if {![dict exists $calls [list $id $e]]} {
            return 1
        }
    }
    return 0
}

# The ownership verdict's part of the graph (header, C:verdict), from STATE
# (Prepare's walk): a list {PATHRELEASE VERDICT LINKED DIAGNOSED} --
# PATHRELEASE the sites (key -> 1) holding a join whose path-release
# diagnostic the verdict withholds, VERDICT C:verdict's successors (node ->
# edge label), LINKED the sites (key -> 1) linked to it as contributors,
# DIAGNOSED the number of the whole-program analysis's diagnostics.
proc hir::staticdeps::Ownership {hir state} {
    variable ownershipKinds
    if {![dict exists $hir affine moveRefs]} {
        # No affine type: no release scope, no verdict.
        return [list {} {} {} 0]
    }
    set exprs [dict get $hir exprs]
    set regionOf [dict get $state regionOf]
    set siteOf [dict get $state siteOf]
    # The diagnostics of the whole-program analysis, each {EXPR REGION SITE}.
    # A semantic instance's diagnostic carried to the call that requested it
    # keeps its ownership kind (hir::semantic::Derived: "call to F with ...
    # is invalid: ...") but is no diagnostic of that analysis.
    set diagnosed {}
    set erasure 0
    foreach d [dict get $hir diagnostics] {
        if {[dict get $d kind] ni $ownershipKinds} continue
        set e [dict get $d expr]
        if {[string match "call to *" [dict get $d message]]
                && [dict exists $hir semantic calls [list generic $e]]} continue
        set region [dict getdef $regionOf $e "program"]
        set site [dict getdef $siteOf $e ""]
        lappend diagnosed [list $e $region $site]
        if {[dict get $d kind] eq "AFFINE-ERASURE-UNSUPPORTED"} {
            set erasure 1
        }
    }
    # The consumers: the sites holding a join one of whose paths may move a
    # binding visible at it -- the moving references of the analysis; while
    # it reports an erasure, also every reference to a binding whose type is
    # affine (its consumer may become a move) or mentions `any` (it may
    # become affine) once a rejection narrows the erased type.
    set refs [dict create]
    foreach r [dict keys [dict get $hir affine moveRefs]] {
        dict set refs $r 1
    }
    if {$erasure} {
        set may [dict create]
        dict for {r region} $regionOf {
            set node [dict get $exprs $r]
            if {[dict get $node kind] ne "ref"} continue
            set b [dict get $node binding]
            if {$b eq "" || ![dict exists $hir bindings $b]} continue
            if {![dict exists $may $b]} {
                set type [hir::bindingType $hir $b]
                dict set may $b [expr {[dict get $hir bindings $b kind] in {local param}
                    && ([hir::types::IsAffine $type] || [MentionsAny $type])}]
            }
            if {[dict get $may $b]} {
                dict set refs $r 1
            }
        }
    }
    set pathRelease [dict create]
    set sees [dict create]
    foreach r [dict keys $refs] {
        if {![dict exists $regionOf $r] || ![dict exists $exprs $r binding]} continue
        set b [dict get $exprs $r binding]
        if {$b eq "" || ![dict exists $hir bindings $b]} continue
        foreach x [PathJoins $hir $state $r $b sees] {
            if {[dict exists $siteOf $x]} {
                dict set pathRelease [dict get $siteOf $x] 1
            }
        }
    }
    set verdict [dict create]
    set linked [dict create]
    if {[dict size $pathRelease] == 0} {
        # No site's diagnostics read the verdict.
        return [list $pathRelease $verdict $linked [llength $diagnosed]]
    }
    set position [dict create]
    set i 0
    foreach key [dict get $state presentKeys] {
        dict set position $key $i
        incr i
    }
    if {$diagnosed ne {}} {
        # The witness: the region of every diagnostic in no site's body (no
        # decision removes one), else of the one whose site is last in
        # post-order (the sequential order removes it last).
        set last ""
        set lastAt -1
        foreach item $diagnosed {
            lassign $item e region site
            if {$site eq ""} {
                dict set verdict R:$region ownership-diagnostic
            } elseif {[dict get $position $site] > $lastAt} {
                set lastAt [dict get $position $site]
                set last $region
            }
        }
        if {[dict size $verdict] == 0} {
            dict set verdict R:$last ownership-diagnostic
        }
        # The contributors after the first consumer, linked.
        set first [tcl::mathfunc::min {*}[lmap key [dict keys $pathRelease] {dict get $position $key}]]
        foreach item $diagnosed {
            set site [lindex $item 2]
            if {$site ne "" && [dict get $position $site] > $first} {
                dict set linked $site 1
            }
        }
    } else {
        # Accepted: the regions where a rejection could make an ownership
        # diagnostic appear -- an affine argument at a parameter whose
        # contract can widen (an untyped parameter's inferred contract, or a
        # callable value's type), never a native's (its ownership roles are
        # fixed) or a declared parameter's.
        dict for {e region} $regionOf {
            set node [dict get $exprs $e]
            if {[dict get $node kind] ne "call" || ![dict get $node reachable]} continue
            lassign [dict get $node target] tk tb
            if {$tk eq "native"} continue
            set declared [if {$tk eq "block" && [dict exists $exprs $tb]} {dict get $exprs $tb declaredParamTypes} else {string cat {}}]
            set index 0
            foreach arg [dict get $node args] {
                if {[lindex $declared $index] eq "" && [hir::types::IsAffine [hir::typeOf $hir $arg]]} {
                    dict set verdict R:$region ownership-contract
                    break
                }
                incr index
            }
        }
    }
    return [list $pathRelease $verdict $linked [llength $diagnosed]]
}

# The joins above reference R to binding B (Ownership) on one of whose paths
# R may move B while B is visible at the join: a handled call R is in a
# handler of, or a counting, iterating or lockstep loop R is in the body of
# (an infinite `loop`'s normal path never completes; an `if`'s branches each
# end in a statement that can hold a release). Walks out of function
# literals; stops where B is no longer visible. SEESVAR caches ScopeSees.
proc hir::staticdeps::PathJoins {hir state r b seesVar} {
    upvar 1 $seesVar sees
    set parentOf [dict get $state parentOf]
    set regionOf [dict get $state regionOf]
    set scope [dict get $hir bindings $b scope]
    set joins {}
    set child $r
    while 1 {
        set x [dict get $parentOf $child]
        if {$x eq ""} {
            # The top of a region: continue outside its function literal.
            set q [dict get $regionOf $child]
            if {$q eq "program" || ![dict exists $parentOf $q]} break
            set child $q
            continue
        }
        set node [dict get $hir exprs $x]
        set at [dict get $node scope]
        if {![dict exists $sees $at $scope]} {
            dict set sees $at $scope [ScopeSees $hir $at $scope]
        }
        if {![dict get $sees $at $scope]} break
        if {[dict get $node reachable]} {
            switch -- [dict get $node kind] {
                handle {
                    if {$child ne [dict get $node call]} {
                        lappend joins $x
                    }
                }
                listloop - countloop - lockloop {
                    if {$child in [dict get $node body]} {
                        lappend joins $x
                    }
                }
            }
        }
        set child $x
    }
    return $joins
}

# 1 if scope S is scope TARGET or nested in it (a binding of TARGET is
# visible in S).
proc hir::staticdeps::ScopeSees {hir s target} {
    while {$s ne "" && [dict exists $hir scopes $s]} {
        if {$s eq $target} {
            return 1
        }
        set s [dict get $hir scopes $s parent]
    }
    return 0
}

# lsort comparison of two spans {START END KEY}: by start, the enclosing one
# (the longer) first.
proc hir::staticdeps::SpanOrder {a b} {
    set d [expr {[lindex $a 0] - [lindex $b 0]}]
    if {$d != 0} {
        return [expr {$d < 0 ? -1 : 1}]
    }
    return [expr {[lindex $b 1] - [lindex $a 1] < 0 ? -1 : ([lindex $b 1] == [lindex $a 1] ? 0 : 1)}]
}

# The key of the innermost present site (BYFILE, SPANPARENT: Prepare) whose
# span holds the start of source ORIGIN, or "".
proc hir::staticdeps::SiteAt {byFile spanParent origin} {
    if {[lindex $origin 0] ne "file"} {
        return ""
    }
    set file [dict get $origin file]
    if {![dict exists $byFile $file]} {
        return ""
    }
    set at [dict get $origin start]
    set spans [dict get $byFile $file]
    # The last span starting at or before AT.
    set lo 0
    set hi [expr {[llength $spans] - 1}]
    set found -1
    while {$lo <= $hi} {
        set mid [expr {($lo + $hi) / 2}]
        if {[lindex $spans $mid 0] <= $at} {
            set found $mid
            set lo [expr {$mid + 1}]
        } else {
            set hi [expr {$mid - 1}]
        }
    }
    if {$found < 0} {
        return ""
    }
    set key [lindex $spans $found 2]
    set end [lindex $spans $found 1]
    while {$key ne ""} {
        if {$at <= $end} {
            return $key
        }
        set key [dict get $spanParent $key]
        if {$key ne ""} {
            set end [lindex [lsearch -inline -index 2 -exact $spans $key] 1]
        }
    }
    return ""
}

# The binding a method-style call E's candidate DISPLAY denotes: a module
# member (NS::NAME) or the lexical binding of NAME visible at E; "" for a
# native.
proc hir::staticdeps::CandidateBinding {hir e display} {
    set idx [string last :: $display]
    if {$idx > 0} {
        set ns [string range $display 0 [expr {$idx - 1}]]
        set name [string range $display [expr {$idx + 2}] end]
        if {[dict exists $hir modules $ns]} {
            set scope [dict get $hir modules $ns]
            if {[dict exists $hir scopes $scope names $name]} {
                set b [dict get $hir scopes $scope names $name]
                if {[dict get $hir bindings $b kind] eq "root"} {
                    return ""
                }
                return $b
            }
        }
        return ""
    }
    set s [dict get $hir exprs $e scope]
    while {$s ne "" && [dict exists $hir scopes $s]} {
        if {[dict exists $hir scopes $s names $display]} {
            set b [dict get $hir scopes $s names $display]
            if {[dict get $hir bindings $b kind] eq "root"} {
                return ""
            }
            return $b
        }
        set s [dict get $hir scopes $s parent]
    }
    return ""
}

# The root function of the coroutine construction CREATE (a call of
# coroutine#create whose argument is the thunk): the exact target of the
# thunk's call, or "".
proc hir::staticdeps::CreateRoot {hir create} {
    set thunk [lindex [dict get $hir exprs $create args] 0]
    if {$thunk eq "" || [dict get $hir exprs $thunk kind] ne "block"} {
        return ""
    }
    foreach e [dict get $hir exprs $thunk body] {
        set stack [list $e]
        while {$stack ne {}} {
            set x [lpop stack]
            set node [dict get $hir exprs $x]
            if {[dict get $node kind] eq "call" && [lindex [dict get $node target] 0] eq "block"} {
                return [lindex [dict get $node target] 1]
            }
            if {[dict get $node kind] ne "block"} {
                lappend stack {*}[hir::children $hir $x]
            }
        }
    }
    return ""
}

# ---------------------------------------------------------------------------
# Successors

# The successors of node V (header): a dict successor -> edge label.
proc hir::staticdeps::Successors {hir stateVar v} {
    upvar 1 $stateVar state
    set succ [dict create]
    switch -glob -- $v {
        F:* {
            # A site's form: whether it is still a body. Nothing decides it
            # but the site's own decision -- and the decision of the site
            # around it, whose rejection takes it away.
            set key [string range $v 2 end]
            dict set state names $v "site [SiteName $hir $key]"
            set outer [dict get $state spanParent $key]
            if {$outer ne ""} {
                dict set succ F:$outer enclosed
            }
        }
        Z:* {
            set key [string range $v 2 end]
            dict set state names $v "the diagnostics of site [SiteName $hir $key]"
            if {[dict exists $state siteHome $key]} {
                dict set succ R:[dict get $state siteHome $key] position
            }
            # The sites nested in its body: their forms are part of it. (Not
            # the site around it: a nested site's own diagnostics read the
            # code around it through its own region, never through the outer
            # site -- an edge to the outer site would make sibling nested
            # sites depend on each other through it.)
            if {[dict exists $state spanChildren $key]} {
                foreach inner [dict get $state spanChildren $key] {
                    dict set succ F:$inner nested
                }
            }
            if {![dict exists $state early $key]} {
                SubsumeSuccessors $hir state $key succ
            }
            if {[dict exists $state pathRelease $key]} {
                dict set succ C:verdict path-release
            } elseif {[dict exists $state verdictLinked $key]} {
                dict set succ C:verdict verdict-contributor
            }
            if {[dict exists $state possibleLinks $key]} {
                foreach node [dict keys [dict get $state possibleLinks $key]] {
                    dict set succ $node possible-contributor
                }
            }
            if {[dict exists $state planConsumers $key] && [dict size [dict get $state plan]] > 0} {
                dict set succ C:plan plan-site
            }
        }
        C:plan {
            dict set state names $v "the gate of the trait monomorphization's plan (no other diagnostic in the program)"
            dict for {node label} [dict get $state plan] {
                dict set succ $node $label
            }
        }
        C:verdict {
            dict set state names $v "the ownership analysis's verdict on the whole program"
            dict for {node label} [dict get $state verdict] {
                dict set succ $node $label
            }
        }
        P:* {
            PossibleSuccessors $hir state [string range $v 2 end] succ
        }
        R:* {
            RegionSuccessors $hir state [string range $v 2 end] succ
        }
        B:* {
            BindingSuccessors $hir state [string range $v 2 end] succ
        }
        C:erased {
            dict set state names $v "the erased-callable contract"
            # What can change it: the witnesses' contributions (Prepare,
            # ErasureWitnesses) -- the sites they are written in (rejecting
            # one removes them), the function a request instantiates (which
            # of its parameters has no contract) and the arguments its key is
            # made of (what their types may become, unless an argument is a
            # function whose type nothing but its own removal changes,
            # FixedCarrier).
            foreach unit [dict get $state erasureWitnesses] {
                lassign $unit errors how items path
                if {$how eq "all"} {
                    foreach e $items {
                        AddSubtree $hir state $e succ erasure
                    }
                    continue
                }
                if {$errors ne "*"} {
                    # A semantic instance's: what keeps it, its path.
                    set items $path
                }
                foreach e $items {
                    if {[dict exists $state siteOf $e]} {
                        dict set succ F:[dict get $state siteOf $e] erasure
                    }
                    lassign [dict get $hir exprs $e target] tk tb
                    set args [dict get $hir exprs $e args]
                    if {$tk ne "block" || ![dict exists $hir exprs $tb]} {
                        set erased $args
                    } else {
                        # (The function vanishes with a site its literal is
                        # in.)
                        dict set succ R:$tb erasure
                        foreach s [SiteChain $state $tb] {
                            dict set succ F:$s erasure
                        }
                        set erased {}
                        foreach entry [hir::signatures::entryTypes $hir $tb] arg $args {
                            if {$entry eq "" && $arg ne ""} {
                                lappend erased $arg
                            }
                        }
                    }
                    foreach arg $erased {
                        if {[FixedCarrier $hir $state $arg]} {
                            foreach s [SiteChain $state $arg] {
                                dict set succ F:$s erasure
                            }
                            continue
                        }
                        AddSubtree $hir state $arg succ erasure
                    }
                }
            }
        }
        C:budget:* {
            set b [string range $v 9 end]
            dict set state names $v "the semantic-instance budget of [BlockName $hir $b]"
            # Which call gets one of B's instances depends on how many
            # distinct instances its calls request: B's own body (which
            # requests more of them), each call (rejecting a site it is in
            # removes it) and the arguments its key is made of -- of an
            # argument naming a function, only its identity is in the key
            # (hir::specialize::KeyType erases its result), which nothing but
            # the argument's own removal changes (FunctionRef).
            dict set succ R:$b budget
            foreach call [dict get $state callsOf $b] {
                foreach s [SiteChain $state $call] {
                    dict set succ F:$s budget
                }
                foreach arg [dict get $hir exprs $call args] {
                    if {$arg eq ""} continue
                    if {[FunctionRef $hir $arg]} {
                        foreach s [SiteChain $state $arg] {
                            dict set succ F:$s budget
                        }
                    } else {
                        AddSubtree $hir state $arg succ budget
                    }
                }
            }
        }
    }
    dict unset succ $v
    return $succ
}

# The sites (present ones) whose body holds expression E: the innermost one
# and every site around it.
proc hir::staticdeps::SiteChain {state e} {
    set chain {}
    if {[dict exists $state siteOf $e]} {
        set s [dict get $state siteOf $e]
        while {$s ne ""} {
            lappend chain $s
            set s [dict get $state spanParent $s]
        }
    }
    return $chain
}

# The contract-boundary checks of site KEY's own code (hir::completions::
# Subsume): at every position where a callable value acquires a structural
# type, its body is analyzed with each uncontracted input standing for what
# it can hold (Possible) -- only while the program's erased-callable
# contract is not empty, and only in the walk that reports the site's own
# diagnostics (never a summary another region reads). So the site depends
# on that contract and on the Possible of those inputs (P:).
proc hir::staticdeps::SubsumeSuccessors {hir stateVar key succVar} {
    upvar 1 $stateVar state $succVar succ
    set exprs {}
    foreach site [concat [list $key] [NestedSites $state $key]] {
        if {[dict exists $state siteExprs $site]} {
            lappend exprs {*}[dict get $state siteExprs $site]
        }
    }
    if {![dict exists $state finals]} {
        dict set state finals [if {[hir::completions::HasFnTypes $hir]} {hir::completions::YieldFinalsOf $hir} else {string cat {}}]
    }
    set finals [dict get $state finals]
    foreach e $exprs {
        set node [dict get $hir exprs $e]
        if {[dict exists $finals $e]} {
            # A yield: the outward type its value lands in is every reaching
            # coroutine's.
            set q [dict get $state regionOf $e]
            if {[dict exists $state yieldAll $q]} {
                foreach c [dict get $state yieldAll $q] {
                    AddSubtree $hir state $c succ yield-final
                }
            }
        }
        set pairs [hir::completions::Positions $hir $e $finals]
        if {[dict get $node kind] eq "block" && [dict get $node body] ne {}} {
            lappend pairs [list [lindex [dict get $node body] end] [hir::completions::ResultFinal $hir $e]]
        }
        foreach pair $pairs {
            set value [lindex $pair 0]
            if {$value eq "" || ![dict exists $hir exprs $value]} continue
            set type [hir::typeOf $hir $value]
            if {[hir::types::IsCoroutine $type]} {
                # SubsumeHandle: the thunk's facts, a capture of an
                # uncontracted type standing for what it can hold (Possible,
                # which reads the contract); every other capture and callee
                # reads it only through its own region (R -> C:erased). No
                # thunk, no check.
                set thunk [hir::coroutines::thunkOfHandle $hir $value]
                if {$thunk ne ""} {
                    foreach c [dict get $hir exprs $thunk captures] {
                        dict set succ P:$c subsume
                        if {[hir::completions::CleanInput $hir $c]} {
                            dict set succ C:erased subsume
                        }
                    }
                }
                continue
            }
            if {[lindex $pair 1] eq ""} continue
            foreach triple [hir::completions::Align $type [lindex $pair 1]] {
                set source [lindex $triple 0]
                dict set succ C:erased subsume
                if {[hir::types::IsExactBlock $source] && [dict exists $hir exprs [lindex $source 1]]} {
                    set block [dict get $hir exprs [lindex $source 1]]
                    foreach b [concat [dict get $block params] [dict get $block captures]] {
                        dict set succ P:$b subsume
                    }
                }
            }
        }
    }
}

# The coroutine operations whose positions the contract-boundary check skips
# (hir::completions::SubsumeCall).
proc hir::staticdeps::CoroutineOperations {} {
    return [list [core::coroutines::createNative] [core::coroutines::startNative] \
        [core::coroutines::resumeNative] [core::coroutines::doneNative] [core::coroutines::releaseNative]]
}

# The callable types in a value of static TYPE that a position of some
# static type could give a structural Fn type (hir::completions::Align, for
# every FINAL at once): the value itself when it is an exact callable or a
# Fn, and what such a callable returns; a List's elements, a set's, a
# vector's or an array's element; an anonymous struct's fields.
proc hir::staticdeps::CallableParts {type {depth 0}} {
    set type [hir::types::Unrefined $type]
    if {$depth > 8 || $type in {never any ""}} {
        return {}
    }
    set deeper [expr {$depth + 1}]
    if {[hir::types::IsExactBlock $type] || [hir::types::IsExactNative $type] || [hir::types::IsFn $type]} {
        set result [list $type]
        set returned [hir::completions::ResultOf $type]
        if {$returned ne ""} {
            lappend result {*}[CallableParts $returned $deeper]
        }
        return $result
    }
    if {[hir::types::IsList $type]} {
        set result {}
        foreach t [concat [list [lindex $type 1]] [hir::types::shapeOf $type]] {
            lappend result {*}[CallableParts $t $deeper]
        }
        return $result
    }
    if {[hir::types::IsSet $type] || [hir::types::IsMutVec $type] || [hir::types::IsMutArray $type]} {
        return [CallableParts [lindex $type 1] $deeper]
    }
    if {[hir::types::IsStruct $type]} {
        set result {}
        dict for {name t} [lindex $type 1] {
            lappend result {*}[CallableParts $t $deeper]
        }
        return $result
    }
    return {}
}

# The sites nested, at any depth, in site KEY's body (present ones).
proc hir::staticdeps::NestedSites {state key} {
    set result {}
    dict for {site parent} [dict get $state spanParent] {
        set p $parent
        while {$p ne ""} {
            if {$p eq $key} {
                lappend result $site
                break
            }
            set p [dict get $state spanParent $p]
        }
    }
    return $result
}

# What an uncontracted input B may hold at the contract boundary
# (hir::completions::PossibleOf): a parameter of a function only ever called,
# what its calls pass in its position; a local, what it is bound to; anything
# else (a parameter of a function used as a value, a loop or handler
# binding), the erased-callable contract. Only a value that may carry errors
# matters (CanCarry); one that is itself an uncontracted input holds that
# input's Possible.
#
# What it holds is a set of errors and whether every value is quiet (calls no
# argument it is given): the union of each value's (hir::completions::
# ValueCarriesStatic), which a rejection only shrinks -- a value's type only
# turns into `never`, a function's body only loses calls (PossibleUnit). So,
# as the erased-callable contract does (ErasureWitnesses), it depends per
# error, and for not being quiet, on one *witness* value -- the one whose
# site is last in post-order, or one in no site's body -- and on every value
# whose part is not fixed; and every site passing a value with a fixed part
# is linked to it (Prepare's possibleLinks).
proc hir::staticdeps::PossibleSuccessors {hir stateVar b succVar} {
    upvar 1 $stateVar state $succVar succ
    dict set state names P:$b "what [dict get $hir bindings $b name] may hold"
    lassign [PossibleValues $hir state $b] status values
    switch -- $status {
        none { return }
        top {
            dict set succ C:erased possible
            return
        }
    }
    set position [SitePositions state]
    set never [expr {[dict size $position] + 1}]
    set best [dict create]
    set units {}
    foreach value $values {
        set unit [PossibleUnit $hir state $value]
        switch -- [lindex $unit 0] {
            nothing { continue }
            fixed {}
            uncontracted {
                # An uncontracted value: the input a reference reads, else the
                # erased-callable contract.
                set node [dict get $hir exprs $value]
                if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""
                        && [dict get $hir bindings [dict get $node binding] kind] ne "root"} {
                    dict set succ P:[dict get $node binding] possible
                } else {
                    dict set succ C:erased possible
                }
                continue
            }
            default {
                # Not fixed: everything its value reads.
                AddSubtree $hir state $value succ possible
                set type [hir::typeOf $hir $value]
                if {[hir::types::IsExactBlock $type] && [dict exists $hir exprs [lindex $type 1]]} {
                    foreach c [dict get $hir exprs [lindex $type 1] captures] {
                        dict set succ P:$c possible
                    }
                }
                continue
            }
        }
        lassign $unit - atoms edges
        set rank $never
        foreach s [SiteChain $state $value] {
            set rank [dict get $position $s]
            break
        }
        set index [llength $units]
        lappend units $edges
        foreach atom $atoms {
            if {![dict exists $best $atom] || $rank > [lindex [dict get $best $atom] 1]} {
                dict set best $atom [list $index $rank]
            }
        }
    }
    foreach index [lsort -integer -unique [lmap {atom pick} $best {lindex $pick 0}]] {
        dict for {node label} [lindex $units $index] {
            if {![dict exists $succ $node]} {
                dict set succ $node $label
            }
        }
    }
}

# What an uncontracted input B may hold is made of (PossibleSuccessors): a
# list {STATUS VALUES} -- STATUS none (B is no uncontracted input), top (it
# holds whatever the program erases) or values (VALUES the expressions it
# holds).
proc hir::staticdeps::PossibleValues {hir stateVar b} {
    upvar 1 $stateVar state
    if {![hir::completions::CleanInput $hir $b]} {
        return {none {}}
    }
    set binding [dict get $hir bindings $b]
    set by [dict get $binding declaredBy]
    set owner [dict getdef $state paramOwner $b ""]
    if {[lindex $owner 0] eq "block"} {
        lassign $owner _ block i
        set definer [dict getdef $state definedBy $block ""]
        if {$definer eq "" || [dict exists $state escaping $definer]} {
            return {top {}}
        }
        set values {}
        if {[dict exists $state callsOf $block]} {
            foreach call [dict get $state callsOf $block] {
                set arg [lindex [dict get $hir exprs $call args] $i]
                if {$arg ne ""} {
                    lappend values $arg
                }
            }
        }
        return [list values $values]
    }
    if {$by ne "" && [dict exists $hir exprs $by] && [dict get $hir exprs $by kind] eq "bind"
            && [dict get $hir exprs $by value] ne ""} {
        return [list values [list [dict get $hir exprs $by value]]]
    }
    return {top {}}
}

# What value VALUE adds to what an uncontracted input holds (hir::completions::
# ValueCarriesStatic): {nothing} (it carries nothing, and a rejection never
# makes it carry anything), {uncontracted} (it holds what another input or
# the erased-callable contract holds), {open} (its part may grow, or is not
# known without the facts it reads: a function capturing inputs, a container
# that may hold callables), or {fixed ATOMS EDGES} -- ATOMS its errors and
# `*calls*` if it may call an argument it is given, each of which a rejection
# can only take away; EDGES what can: its removal (the sites it and its
# function are written in), what its type may become (for a value other than
# one naming a function, FunctionRef), and whether its function calls an
# argument (the function's body, when a parameter of it is uncontracted).
proc hir::staticdeps::PossibleUnit {hir stateVar value} {
    upvar 1 $stateVar state
    set type [hir::typeOf $hir $value]
    if {$type eq "never"} {
        return {nothing}
    }
    set edges [dict create]
    if {[hir::types::IsFn $type] || [hir::types::IsCoroutine $type]} {
        set fact [hir::completions::ContractFact $type]
        set atoms [lindex $fact 1]
        if {[hir::completions::ContractChannel [lindex $fact 2]]} {
            lappend atoms *calls*
        }
        AddSubtree $hir state $value edges possible
    } elseif {[hir::types::IsExactNative $type]} {
        if {[catch {core::native::metadata [lindex $type 1]} meta]} {
            return {nothing}
        }
        set atoms [dict get $meta errors]
        if {[dict get $meta errorsFrom] ne ""} {
            lappend atoms *calls*
        }
        AddSubtree $hir state $value edges possible
    } elseif {[hir::types::IsExactBlock $type]} {
        set block [lindex $type 1]
        if {![dict exists $hir exprs $block]} {
            return {nothing}
        }
        if {[dict get $hir exprs $block captures] ne {}} {
            return {open}
        }
        set atoms [dict get $hir exprs $block declaredErrors]
        set body 0
        foreach p [dict get $hir exprs $block params] {
            set t [hir::bindingType $hir $p]
            if {[hir::types::IsFn $t] || [hir::types::IsCoroutine $t]} {
                lappend atoms *calls*
            } elseif {[hir::completions::CleanInput $hir $p]} {
                # Whether it calls an argument it is given is whether its
                # body is transparent (hir::completions::Transparent), which
                # a rejection only takes away.
                lappend atoms *calls*
                set body 1
            }
        }
        if {[FunctionRef $hir $value]} {
            foreach s [concat [SiteChain $state $value] [SiteChain $state $block]] {
                dict set edges F:$s possible
            }
            if {$body} {
                dict set edges R:$block possible
            }
        } else {
            AddSubtree $hir state $value edges possible
        }
    } elseif {[CanCarry $hir $type]} {
        return {open}
    } elseif {[hir::completions::Uncontracted $type]} {
        return {uncontracted}
    } else {
        return {nothing}
    }
    set atoms [lsort -unique $atoms]
    if {$atoms eq {}} {
        return {nothing}
    }
    return [list fixed $atoms $edges]
}

# Site key -> its position in post-order (the present sites), cached in the
# caller's STATEVAR.
proc hir::staticdeps::SitePositions {stateVar} {
    upvar 1 $stateVar state
    if {![dict exists $state positions]} {
        set position [dict create]
        set i 0
        foreach key [dict get $state presentKeys] {
            dict set position $key $i
            incr i
        }
        dict set state positions $position
    }
    return [dict get $state positions]
}

proc hir::staticdeps::RegionSuccessors {hir stateVar q succVar} {
    upvar 1 $stateVar state $succVar succ
    dict set state names R:$q [expr {$q eq "program" ? "the top-level code" : "function [BlockName $hir $q]"}]
    foreach {field label prefix} {ownRefs mentions B: ownLits defines R: ownTargets calls R: ownSites holds F:} {
        if {[dict exists $state $field $q]} {
            foreach x [dict keys [dict get $state $field $q]] {
                if {![dict exists $succ $prefix$x]} {
                    dict set succ $prefix$x $label
                }
            }
        }
    }
    if {[dict exists $state ownCalls $q]} {
        foreach call [dict get $state ownCalls $q] {
            if {[dict exists $state candidates $call]} {
                foreach b [dict keys [dict get $state candidates $call]] {
                    if {![dict exists $succ B:$b]} {
                        dict set succ B:$b method-candidate
                    }
                }
            }
        }
    }
    if {[dict exists $state erasedConsumers $q]} {
        dict set succ C:erased erased-consumer
    }
    if {[dict exists $state methodTrial $q]} {
        foreach n [dict keys [dict get $state methodTrial $q]] {
            if {![dict exists $succ $n]} {
                dict set succ $n method-trial
            }
        }
    }
    if {[dict exists $state budgetOf $q]} {
        foreach b [dict keys [dict get $state budgetOf $q]] {
            dict set succ C:budget:$b budget
        }
    }
    if {$q eq "program"} {
        return
    }
    set node [dict get $hir exprs $q]
    foreach p [dict get $node params] {
        dict set succ B:$p parameter
    }
    foreach c [dict get $node captures] {
        if {![dict exists $succ B:$c]} {
            dict set succ B:$c capture
        }
    }
    # Where it is defined: the control operands around its literal, in every
    # enclosing function up to the program.
    set literal $q
    while {[dict exists $state litRegion $literal]} {
        set region [dict get $state litRegion $literal]
        set x $literal
        while {[set parent [dict get $state parentOf $x]] ne ""} {
            foreach operand [ControlOperands $hir $parent $x] {
                AddSubtree $hir state $operand succ context
            }
            set x $parent
        }
        if {$region eq "program"} break
        set literal $region
    }
    # The narrowing mentions of each capture in the functions between its
    # binding's region and this one.
    foreach c [dict get $node captures] {
        set home [BindingRegion $hir state $c]
        set region [dict get $state litRegion $q]
        while {$region ne $home && $region ne "program" && $region ne ""} {
            if {[dict exists $state mentions $c]} {
                foreach r [dict get $state mentions $c] {
                    if {[dict get $state regionOf $r] eq $region} {
                        AddNarrowing $hir state $r succ capture-narrowing
                    }
                }
            }
            set region [dict getdef $state litRegion $region ""]
        }
    }
    if {[dict exists $state yieldStruct $q]} {
        foreach c [dict get $state yieldStruct $q] {
            AddSubtree $hir state $c succ yield-type
        }
    }
}

proc hir::staticdeps::BindingSuccessors {hir stateVar b succVar} {
    upvar 1 $stateVar state $succVar succ
    set binding [dict get $hir bindings $b]
    dict set state names B:$b "binding [dict get $binding name]"
    set region [BindingRegion $hir state $b]
    set by [dict get $binding declaredBy]
    set owner [dict getdef $state paramOwner $b ""]
    if {$by ne "" && [dict exists $hir exprs $by]} {
        set node [dict get $hir exprs $by]
        if {[dict get $node kind] eq "bind" && [dict get $node value] ne ""} {
            set value [dict get $node value]
            AddSubtree $hir state $value succ definition
            if {[dict exists $hir exprs $value] && [dict get $hir exprs $value kind] eq "ref"
                    && [dict get $hir exprs $value binding] ne ""} {
                # An alias: a use of either is a use of the one value.
                set c [dict get $hir exprs $value binding]
                if {[dict get $hir bindings $c kind] ne "root"} {
                    dict set succ B:$c alias
                    dict set state aliasOf $c $b 1
                }
            }
        } else {
            AddSubtree $hir state $by succ definition
        }
    } elseif {[lindex $owner 0] eq "block"} {
        lassign $owner _ block i
        if {[lindex [dict get $hir exprs $block declaredParamTypes] $i] eq ""} {
            # An untyped parameter: its contract is inferred from every
            # reachable use, in the function and the functions in it.
            foreach r [Descendants $state $block] {
                dict set succ R:$r untyped-parameter
            }
        }
    } elseif {[lindex $owner 0] eq "loop"} {
        foreach operand [hir::children $hir [lindex $owner 1]] {
            if {[dict get $hir exprs $operand kind] eq "block"} continue
            if {$operand in [LoopBody $hir [lindex $owner 1]]} continue
            AddSubtree $hir state $operand succ definition
        }
    } elseif {[lindex $owner 0] eq "handle"} {
        AddSubtree $hir state [dict get $hir exprs [lindex $owner 1] call] succ definition
    } elseif {$region ne ""} {
        dict set succ R:$region binding
    }
    if {[dict exists $state aliasOf $b]} {
        foreach a [dict keys [dict get $state aliasOf $b]] {
            dict set succ B:$a alias
        }
    }
    if {![dict exists $state mentions $b]} {
        return
    }
    set type [hir::bindingType $hir $b]
    set shared [expr {[hir::types::IsAffine $type] || [MentionsMutable $type]}]
    foreach r [dict get $state mentions $b] {
        set at [dict get $state regionOf $r]
        if {$at eq $region} {
            AddNarrowing $hir state $r succ narrowing
        } elseif {$shared} {
            dict set succ R:$at shared
        }
    }
}

# The region (Prepare) binding B lives in: the region of its declaration, of
# the function whose parameter it is, of the loop or handler that binds it,
# else of its scope; "" if none is known.
proc hir::staticdeps::BindingRegion {hir stateVar b} {
    upvar 1 $stateVar state
    if {[dict exists $state bindingRegion $b]} {
        return [dict get $state bindingRegion $b]
    }
    set binding [dict get $hir bindings $b]
    set by [dict get $binding declaredBy]
    set region ""
    if {$by ne "" && [dict exists $state regionOf $by]} {
        set region [dict get $state regionOf $by]
    } elseif {[dict exists $state paramOwner $b]} {
        set owner [dict get $state paramOwner $b]
        if {[lindex $owner 0] eq "block"} {
            set region [lindex $owner 1]
        } elseif {[dict exists $state regionOf [lindex $owner 1]]} {
            set region [dict get $state regionOf [lindex $owner 1]]
        }
    } elseif {[dict exists $state scopeRegion [dict get $binding scope]]} {
        set region [dict get $state scopeRegion [dict get $binding scope]]
    }
    dict set state bindingRegion $b $region
    return $region
}

# Region Q and every function literal nested in it, at any depth.
proc hir::staticdeps::Descendants {state q} {
    set result {}
    set work [list $q]
    while {$work ne {}} {
        set r [lpop work]
        lappend result $r
        if {[dict exists $state children $r]} {
            lappend work {*}[dict get $state children $r]
        }
    }
    return $result
}

# The body expressions of loop expression E.
proc hir::staticdeps::LoopBody {hir e} {
    return [dict get $hir exprs $e body]
}

# The operands of control expression PARENT that decide whether, or how
# often, its child CHILD runs, when CHILD is in one of its branches or
# bodies: an `if`'s condition, a loop's operands, a handled call.
proc hir::staticdeps::ControlOperands {hir parent child} {
    set node [dict get $hir exprs $parent]
    switch -- [dict get $node kind] {
        if {
            set condition [dict get $node condition]
            if {$child eq $condition} {
                return {}
            }
            return [list $condition]
        }
        listloop {
            set iterable [dict get $node iterable]
            if {$child eq $iterable} {
                return {}
            }
            return [list $iterable]
        }
        countloop {
            if {$child in [list [dict get $node start] [dict get $node end]]} {
                return {}
            }
            return [list [dict get $node start] [dict get $node end]]
        }
        lockloop {
            set operands [hir::loopOperands $node]
            if {$child in $operands} {
                return {}
            }
            return $operands
        }
        handle {
            set call [dict get $node call]
            if {$child eq $call} {
                return {}
            }
            return [list $call]
        }
    }
    return {}
}

# Adds to the caller's SUCCVAR what a mention R of a binding narrows it by
# (header, B:binding): its enclosing call or projection, or, when the mention
# is inside a branch, loop or handler of its function, the whole statement.
proc hir::staticdeps::AddNarrowing {hir stateVar r succVar label} {
    upvar 1 $stateVar state $succVar succ
    set parentOf [dict get $state parentOf]
    set x $r
    set controlled 0
    while {[set parent [dict get $parentOf $x]] ne ""} {
        if {[dict get $hir exprs $parent kind] in {if loop listloop countloop lockloop handle}} {
            set controlled 1
        }
        set x $parent
    }
    if {$controlled} {
        AddSubtree $hir state $x succ $label
        return
    }
    set parent [dict get $parentOf $r]
    if {$parent eq "" || [dict get $hir exprs $parent kind] eq "bind"} {
        # A statement of its own, or an alias's value (the alias edge).
        if {[dict exists $state siteOf $r]} {
            dict set succ F:[dict get $state siteOf $r] $label
        }
        return
    }
    AddSubtree $hir state $parent succ $label
}

# Adds to the caller's SUCCVAR every node expression E's subtree depends on
# (not entering the bodies of the functions it defines: their literals are
# their summaries): the bindings it references, its function literals, its
# exact call targets, the candidates of its method-style calls, the sites
# its expressions belong to.
proc hir::staticdeps::AddSubtree {hir stateVar e succVar label} {
    upvar 1 $stateVar state $succVar succ
    if {![dict exists $state subtree $e]} {
        set nodes [dict create]
        set stack [list $e]
        while {$stack ne {}} {
            set x [lpop stack]
            if {![dict exists $hir exprs $x]} continue
            set node [dict get $hir exprs $x]
            if {[dict exists $state siteOf $x]} {
                dict set nodes F:[dict get $state siteOf $x] 1
            }
            switch -- [dict get $node kind] {
                block {
                    dict set nodes R:$x 1
                    continue
                }
                ref {
                    set b [dict get $node binding]
                    if {$b ne "" && [dict get $hir bindings $b kind] ne "root"} {
                        dict set nodes B:$b 1
                    }
                }
                call {
                    lassign [dict get $node target] tk tb
                    if {$tk eq "block"} {
                        dict set nodes R:$tb 1
                    }
                    if {[dict exists $state candidates $x]} {
                        foreach b [dict keys [dict get $state candidates $x]] {
                            dict set nodes B:$b 1
                        }
                    }
                }
            }
            lappend stack {*}[hir::children $hir $x]
        }
        dict set state subtree $e [dict keys $nodes]
    }
    foreach n [dict get $state subtree $e] {
        if {![dict exists $succ $n]} {
            dict set succ $n $label
        }
    }
}

# 1 if a value of static TYPE could carry declared errors to where it is
# erased (hir::callables::CarriedErrors), for this type or the type it has
# once some site is rejected (a rejected body only ever turns a type into
# `never` or adds errors to a callable's): a callable, or a List, set,
# vector, array or struct that may hold one.
proc hir::staticdeps::CanCarry {hir type {seen {}}} {
    set type [hir::types::Unrefined $type]
    if {[hir::types::IsExactBlock $type] || [hir::types::IsExactNative $type]
            || [hir::types::IsFn $type] || [hir::types::IsCoroutine $type]} {
        return 1
    }
    if {[hir::types::IsMutArray $type] || [hir::types::IsSet $type] || [hir::types::IsMutVec $type]} {
        return [CanCarry $hir [lindex $type 1] $seen]
    }
    if {[hir::types::IsList $type]} {
        foreach t [concat [list [lindex $type 1]] [hir::types::shapeOf $type]] {
            if {[CanCarry $hir $t $seen]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            if {[CanCarry $hir $t $seen]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsNamedStruct $type]} {
        # (An application's fields, its slots replaced by the arguments:
        # TRAIT-CONSTRAINED-IMPRINTED-TYPES.md.)
        if {$type in $seen} {
            return 0
        }
        lappend seen $type
        foreach {name t} [hir::structs::AppliedFieldTypes $type] {
            if {[CanCarry $hir $t $seen]} {
                return 1
            }
        }
    }
    return 0
}

# 1 if a value of static TYPE holds a mutable value (a MutableVector or a
# MutableArray: the value itself, an element, a field, at any depth): a value
# whose places another use can change (BindingSuccessors' shared binding).
#
# A callable -- an exact function or native, a structural Fn, a coroutine
# handle -- holds none, whatever its contract mentions: a function value has
# no place (no field or element a mutation could reach: a call's result is a
# temporary, and what the function captures is a binding of its own, a node
# of the graph mentioned by the function's region), the vector its call
# returns is a new value owned by whatever receives it, and the vector a
# parameter takes is the caller's argument (a logical copy). So a function
# `empty_queue() -> MutableVector[...]` is no shared binding -- the bindings
# holding what it returns are. Nor is a callable ever moved by a use: a
# function value is unrestricted, and a coroutine handle is affine on its
# own account (hir::types::IsAffine, which BindingSuccessors asks first).
proc hir::staticdeps::MentionsMutable {type} {
    if {$type in {mutvec mutarray}} {
        return 1
    }
    if {[llength $type] < 2} {
        return 0
    }
    switch -- [lindex $type 0] {
        mutvec - mutarray {
            return 1
        }
        block - native - fn - coroutine {
            if {[hir::types::IsExactBlock $type] || [hir::types::IsExactNative $type]
                    || [hir::types::IsFn $type] || [hir::types::IsCoroutine $type]} {
                return 0
            }
        }
        struct {
            if {[hir::types::IsStruct $type]} {
                # Its fields' types (the field names are no types).
                foreach {name t} [lindex $type 1] {
                    if {[MentionsMutable $t]} {
                        return 1
                    }
                }
                return 0
            }
        }
        list {
            if {[hir::types::IsList $type]} {
                # Its element type and, when it has one, each element of
                # its positional shape.
                foreach t [concat [list [lindex $type 1]] [hir::types::shapeOf $type]] {
                    if {[MentionsMutable $t]} {
                        return 1
                    }
                }
                return 0
            }
        }
    }
    foreach part [lrange $type 1 end] {
        if {[MentionsMutable $part]} {
            return 1
        }
    }
    return 0
}

# 1 if static TYPE mentions `any` at any depth: a type an erased affine value
# may have (a join or element type collapsed to `any`), which a rejection that
# narrows it could make affine.
proc hir::staticdeps::MentionsAny {type} {
    if {$type eq "any"} {
        return 1
    }
    if {[llength $type] < 2} {
        return 0
    }
    foreach part [lrange $type 1 end] {
        if {[MentionsAny $part]} {
            return 1
        }
    }
    return 0
}

# 1 if argument expression ARG names a function whose static type -- and so
# what it carries (hir::callables::CarriedErrors: the function's declared
# errors, and what its result type carries) -- nothing but the removal of
# the expression itself can change: a native, a function literal, or a
# reference to a binding bound to one, whose result type carries nothing
# (CanCarry: no rejection ever makes it carry anything). Its body's facts
# are no part of what it carries.
proc hir::staticdeps::FixedCarrier {hir state arg} {
    if {![FunctionRef $hir $arg]} {
        return 0
    }
    set type [hir::typeOf $hir $arg]
    return [expr {[hir::types::IsExactNative $type] || ![CanCarry $hir [lindex $type 3]]}]
}

# 1 if expression ARG names one function whatever any site becomes: a
# native, a function literal, or a reference to a binding bound to one -- its
# static type is that exact function's (only its result type may change).
proc hir::staticdeps::FunctionRef {hir arg} {
    set node [dict get $hir exprs $arg]
    set type [hir::typeOf $hir $arg]
    switch -- [dict get $node kind] {
        block {
            set literal $arg
        }
        ref {
            set b [dict get $node binding]
            if {$b eq "" || ![dict exists $hir bindings $b]} {
                return 0
            }
            if {[dict get $hir bindings $b kind] eq "root"} {
                return [hir::types::IsExactNative $type]
            }
            set by [dict get $hir bindings $b declaredBy]
            if {$by eq "" || ![dict exists $hir exprs $by] || [dict get $hir exprs $by kind] ne "bind"} {
                return 0
            }
            set literal [dict get $hir exprs $by value]
        }
        default {
            return 0
        }
    }
    return [expr {$literal ne "" && [dict exists $hir exprs $literal]
        && [dict get $hir exprs $literal kind] eq "block"
        && [hir::types::IsExactBlock $type] && [lindex $type 1] eq $literal}]
}

# 1 if a value of static TYPE is affine, or may be once a clone's view or a
# rejection makes its type more precise: it is or holds an `any` (an erased
# join or element). A callable -- an exact function or native, a structural
# Fn -- never is, whatever its result (a function value is unrestricted:
# hir::types::IsAffine); a coroutine handle is affine on its own account.
proc hir::staticdeps::MayBecomeAffine {type} {
    if {[hir::types::IsAffine $type]} {
        return 1
    }
    if {$type eq "any"} {
        return 1
    }
    if {[hir::types::IsExactBlock $type] || [hir::types::IsExactNative $type] || [hir::types::IsFn $type]} {
        return 0
    }
    if {[llength $type] < 2} {
        return 0
    }
    foreach part [lrange $type 1 end] {
        if {[MayBecomeAffine $part]} {
            return 1
        }
    }
    return 0
}

proc hir::staticdeps::BlockName {hir b} {
    if {[catch {hir::contexts::BlockName $hir $b} name]} {
        return $b
    }
    return $name
}

proc hir::staticdeps::SiteName {hir key} {
    return $key
}