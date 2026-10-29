# coroutines.tcl -- static coroutine semantics (COROUTINES.md).
#
# A coroutine is an eagerly started, affine resumable computation. `yield`
# may occur arbitrarily deep in its synchronous call stack; construction runs
# immediately to the first outward boundary (a yield, the normal return, or
# an unhandled fail), and each later call of the handle resumes to the next.
# The resume channel is statically fixed to no message or one structured
# message. Handles are movable but never implicitly copied or aliased.
#
# Source forms and the HIR they are (surface/lower.tcl, hir/resolve.tcl): all
# coroutine operations are calls of internal root natives (core/coroutines.tcl;
# `#` cannot be spelled by source), so every analysis that does not care sees
# an ordinary opaque native call:
#
#   yield V                     call ^coroutine#yield V
#   coroutine {step, first} = worker(a)
#                               bind coroutine#N#arg1 a
#                               bind step (call ^coroutine#create THUNK)
#                               bind first (call ^coroutine#start (ref step))
#                               THUNK = (block {} (call worker (ref ...#arg1)))
#   step(m)                      call ^coroutine#resume (ref step) m
#   std::coroutine::done?(step)  call ^std::coroutine::done? (ref step)
#
# A THUNK is the *coroutine boundary*: the one call in its body (the
# construction's call) is the root of a coroutine's execution, and its yield
# effect stops there. Everything else is ordinary code.
#
# What this file decides
# ----------------------
# analyze (before type inference; hir::check, once for both checks of a demotion):
#
#   call graph    the exact, syntactic call edges of every function region
#                 (hir::contexts::Callee: a block literal, a binding denoting
#                 one, a module function), excluding the thunks' boundary
#                 calls. A call through a function value is no edge: a
#                 function that may yield never becomes a value (below).
#                 A trait operation (TRAITS.md, CONTEXT-TRAITS.md) is an
#                 edge to the implementation the program binds it to -- the
#                 selected installed context's, or its receiver's
#                 witness's -- and to nothing else: the visible function of
#                 its name that method syntax may have stood it in with is
#                 no part of it (not an edge, not a coroutine's root, not a
#                 use-site constraint). The typing decides which calls are
#                 trait operations, and what implements them, after this
#                 analysis, so hir::check tells it (Feedback: Target,
#                 TraitOperations, CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-
#                 MILESTONE-1.md; Implementations, TRAIT-IMPLEMENTATION-
#                 YIELD-INFERENCE-MILESTONE-1.md). A witness's
#                 implementation differs per witness, so a trait-
#                 polymorphic function has, besides its own node per block
#                 (the function as written: an operation on a parameter's
#                 view binds nothing there), a node per specialization the
#                 monomorphization's plan makes of it, {K BLOCK}, whose
#                 operations and calls are bound as the plan binds them in
#                 that clone; a call passing concrete witnesses is an edge to
#                 its specialization. Every analysis below runs over these
#                 nodes.
#   protocol      the resume protocol of every function that may yield,
#                 bottom-up over the call graph, a least fixed point over
#                   none   no constraint: every yield's value is discarded and
#                          every yielding callee is unconstrained too
#                   unit   the zero-message protocol
#                   T      one named struct type: one message of T
#                   conflict
#                 Constraints: a declared `resume T`; a use of a yield's
#                 value as the argument of an exact call whose parameter is
#                 declared with a struct type T (use-site inference); every
#                 yielding callee's own protocol. Two different constraints
#                 are COROUTINE-RESUME-CONFLICT (never a widening, never a
#                 union). A function left unconstrained whose yield's value
#                 is used is zero-message (unit) -- unless that value is used
#                 as a struct (a field projection), which needs a declared
#                 protocol (COROUTINE-RESUME-UNDERCONSTRAINED) -- and that
#                 default reaches its callers like any other constraint.
#   yield type    a yield evaluates to its function's protocol: T, or unit.
#                 An unconstrained function's yields are all discarded; they
#                 are typed unit when every coroutine that can reach them is
#                 zero-message, and any (the message is ignored) when some
#                 struct-protocol coroutine reaches them too.
#
# type inference (hir/types.tcl's ShapeResult, from the tables analyze left):
#
#   coroutine#yield(V)          the yield's type (above)
#   coroutine#create(THUNK)     {coroutine R Y E}: R the root's protocol (none
#                               resolves to unit), E its declared errors, Y
#                               its outward type -- its declared result, else
#                               the join of what it returns and of every value
#                               a yield its coroutine can reach sends
#   coroutine#start/#resume(H)  H's outward type Y; the call's declared
#                               errors are E (hir/types.tcl's Call), so
#                               handlers and `errors` clauses work unchanged
#
# verify (after type inference; hir::CheckOnce), over *reachable* code only:
#
#   may yield     a function has a reachable yield, or a reachable exact call
#                 of a function that may yield: the transitive yield effect
#   YIELD-OUTSIDE-FUNCTION   a yield in top-level code
#   UNWRAPPED-YIELD          a yielding call graph entered without a
#                            coroutine boundary: a call from top-level code,
#                            or a function that may yield used as a value
#                            (with the shortest deterministic call chain)
#   COROUTINE-RHS-NOT-YIELDING  a construction whose call is not an exact call
#                            of a function that may yield
#   COROUTINE-RESULT-MISMATCH   a root whose yields and return have no one
#                            common outward type (its declared result, else
#                            one of them all the others are subtypes of)
#   COROUTINE-RESUME-ARITY   a resume call with other than 0 (zero-message)
#                            or 1 (struct protocol) message arguments
#   TYPE                     a resume message not of the protocol's type
#   the affine discipline (Affine, below): USE-AFTER-MOVE,
#   AFFINE-NOT-DEFINITELY-LIVE, COROUTINE-STORAGE-UNSUPPORTED,
#   COROUTINE-NOT-FUNCTION
#
# Recursion: a self-recursive yielding function is an ordinary edge to itself
# and converges like any other. Mutual recursion needs bindings visible before
# their definition, which the language does not have yet (MUTUAL-RECURSION.md):
# not a coroutine limitation. Protocols are inferred over every syntactic edge
# (reachable or not, since inference runs before reachability is known); the
# yield effect and every rejection above use reachable code only.
#
# What HIR keeps (dict `coroutines`): blocks (yielding function -> protocol
# and yield type), thunks (thunk -> its create call and root node),
# boundaries (a thunk's boundary call -> the thunk), yields (yield call -> its
# function), edges (node -> its call edges), direct (block -> its yields),
# operations (the method-style calls set aside as trait operations) and
# consulted (the method-style calls whose written callee the analysis read);
# when trait operations have edges, graph (the trait-operation edges:
# Implementations), specialized (yielding clone node -> protocol and yield
# type), cloneThunks ({K THUNK} -> the root it has in specialization K),
# cloneOf (a semantic instance's specialization) and cloneNodes; and, after
# verify, mayYield (the nodes that may yield), next (each one's next step),
# moves (move bind -> moved binding), releases (a statement -> the handle
# bindings whose coroutines are released after it), exits (an exit statement
# -> the bindings released when it leaves) and errorExits (a call or handle
# -> NAME -> the bindings released when it propagates declared error NAME):
# "Release at the last use, and on every early exit" below.

namespace eval hir::coroutines {}

# ---------------------------------------------------------------------------
# Native identity

# The coroutine native call E calls (its callee is a reference to that root
# binding), or "".
proc hir::coroutines::NativeOf {hir e} {
    if {![dict exists $hir exprs $e] || [dict get $hir exprs $e kind] ne "call"} {
        return ""
    }
    set callee [dict get $hir exprs [dict get $hir exprs $e callee]]
    if {[dict get $callee kind] ne "ref" || [dict get $callee binding] eq ""} {
        return ""
    }
    set binding [dict get $hir bindings [dict get $callee binding]]
    if {[dict get $binding kind] ne "root"} {
        return ""
    }
    set name [dict get $binding name]
    if {$name in [core::coroutines::natives]} {
        return $name
    }
    return ""
}

# 1 if HIR refers to any coroutine operation at all: a program without one
# pays nothing for this file.
proc hir::coroutines::Used {hir} {
    set natives [core::coroutines::natives]
    dict for {y symbol} [dict get $hir symbols] {
        if {[dict get $symbol kind] eq "native" && [dict get $symbol name] in $natives} {
            return 1
        }
    }
    return 0
}

# The display name of call-graph node E: a block's
# (hir::contexts::BlockName's convention), or a specialization's, "NAME (for
# WITNESSES)" -- the block as the monomorphized program's clone has it.
proc hir::coroutines::Name {hir e} {
    if {[llength $e] == 2} {
        lassign $e k b
        return "[hir::contexts::BlockName $hir $b] (for [dict get $hir coroutines graph clones $k witnesses])"
    }
    return [hir::contexts::BlockName $hir $e]
}

# ", the implementation of TRAIT's operation OP for WITNESS," when the edge of
# call C in context CTX (a block's own "", or a specialization) is a trait
# operation's (Implementations' `via`), else "": what a chain says about a
# call that names no function.
proc hir::coroutines::Via {hir ctx c} {
    set key [list $ctx $c]
    if {![dict exists $hir coroutines graph via $key]} {
        return ""
    }
    set via [dict get $hir coroutines graph via $key]
    return ", the implementation of [dict get $via trait]'s operation [dict get $via operation] for [dict get $via witness],"
}

proc hir::coroutines::Where {hir e} {
    return [hir::originLocation $hir [dict get $hir exprs $e origin]]
}

# 1 if TYPE is a named struct type: what a resume protocol may be.
proc hir::coroutines::IsStructProtocol {type} {
    return [expr {[lindex $type 0] eq "nstruct" && [llength $type] == 2}]
}

proc hir::coroutines::ShowProtocol {p} {
    switch -- $p {
        none { return "no message" }
        unit { return "no message (zero-message)" }
    }
    return "resume [hir::types::show $p]"
}

# ---------------------------------------------------------------------------
# analyze: thunks, call graph, protocols (before type inference)

proc hir::coroutines::analyze {hirVar {feedback {}}} {
    upvar 1 $hirVar hir
    if {![Used $hir]} {
        dict set hir coroutines [dict create]
        return
    }
    # The method-style calls a typing of this HIR made trait operations
    # (hir::check): no call of their written callee (Target).
    set excluded [dict create]
    foreach c [dict getdef $feedback operations {}] {
        dict set excluded $c 1
    }
    # The implementation each trait operation calls and the specialization
    # each call of a trait-polymorphic function calls, as a typing of this
    # HIR found them (hir::check, Implementations): the call graph's edges
    # through trait operations.
    set graph [dict getdef $feedback graph {}]
    dict set hir coroutines [dict create graph $graph]
    set walk [hir::contexts::Walk $hir]
    lassign $walk owner parent rootOf calls blocks
    set built [Build $hir $walk $excluded $graph]
    set nodes [dict get $built nodes]
    set thunks [dict get $built thunks]
    set cloneThunks [dict get $built cloneThunks]
    set yields [dict get $built yields]
    set direct [dict get $built direct]
    set edges [dict get $built edges]
    set capable [dict get $built capable]
    set res [dict get $built res]
    # The method-style calls whose written callee this analysis read
    # (Consulted): what hir::check asks the typing about -- a coroutine's
    # root, an edge into a yield-capable function, a use-site constraint.
    set consulted [dict create]
    foreach c [dict get $built rootReads] {
        Consulted $hir $c consulted
    }
    # An edge reaches the protocols only through a yield-capable callee.
    foreach {c target} [dict get $built reads] {
        if {[dict exists $capable $target]} {
            Consulted $hir $c consulted
        }
    }
    # Local constraints: declared protocols and use-site inference. A
    # specialization's yields are its function's; their uses may reach other
    # implementations (Resolve in its context).
    set local [dict create]
    set used [dict create]
    set needsStruct [dict create]
    foreach n [dict keys $capable] {
        set b [BlockOf $n]
        set ctx [ContextOf $n]
        set constraints {}
        set declared [DeclaredResume $hir $b]
        if {$declared ne ""} {
            lappend constraints [list $declared [list declared $b]]
        }
        foreach y [dict get $direct $b] {
            lassign [YieldUses $hir $parent $y $res $ctx] isUsed types projections
            if {$isUsed} {
                dict set used $n 1
            }
            foreach {type at} $types {
                lappend constraints [list $type [list use $y $at]]
                if {[lindex $at 2] eq "exact"} {
                    Consulted $hir [lindex $at 0] consulted
                }
            }
            if {$projections ne {} && $ctx eq ""} {
                # (A function's own projections need its own protocol: a
                # specialization's is never less constrained.)
                dict lappend needsStruct $b [list $y [lindex $projections 0]]
            }
        }
        dict set local $n $constraints
    }
    # The protocol fixed point, then the zero-message default, then again.
    set protocols [dict create]
    set conflicts [dict create]
    foreach n [dict keys $capable] {
        dict set protocols $n [dict create protocol none reason {}]
    }
    Solve $hir $capable $local $edges protocols conflicts
    foreach n [dict keys $capable] {
        if {[dict get $protocols $n protocol] eq "none" && [dict exists $used $n]} {
            dict set local $n [concat [dict get $local $n] [list [list unit [list default [BlockOf $n]]]]]
        }
    }
    Solve $hir $capable $local $edges protocols conflicts
    # Diagnostics of the protocols themselves: a function's own, then a
    # specialization's where its function has none (a specialization reaches
    # every constraint its function does, and the implementations of its
    # witnesses besides).
    foreach n [concat [lsort -dictionary [lmap n [dict keys $conflicts] {if {[ContextOf $n] eq ""} {set n} else continue}]] \
            [lsort -dictionary [lmap n [dict keys $conflicts] {if {[ContextOf $n] ne ""} {set n} else continue}]]] {
        if {[ContextOf $n] ne "" && [dict exists $conflicts [BlockOf $n]]} continue
        lassign [dict get $conflicts $n] p1 r1 p2 r2
        hir::Diagnose hir COROUTINE-RESUME-CONFLICT \
            [::format "%s needs two different resume protocols, and one coroutine has exactly one (no union is inferred: declare a struct with the fields both need, or split the coroutine):\n    %s: %s\n    %s: %s" \
                [Name $hir $n] [ShowProtocol $p1] [ExplainReason $hir $r1 $protocols] \
                [ShowProtocol $p2] [ExplainReason $hir $r2 $protocols]] [BlockOf $n]
    }
    dict for {b list} $needsStruct {
        set p [dict get $protocols $b protocol]
        if {[IsStructProtocol $p] || $p eq "conflict"} continue
        foreach entry $list {
            lassign $entry y projection
            hir::Diagnose hir COROUTINE-RESUME-UNDERCONSTRAINED \
                [::format {the value of this yield is used as a struct (".%s" at %s), but nothing determines the resume message type of %s: declare it with "resume TYPE" as the last entry of its parameter list} \
                    [dict get $hir exprs $projection name] [Where $hir $projection] [Name $hir $b]] $y
        }
    }
    # Roots, their resolved protocols, and the yield type of each function.
    set roots [dict create]
    foreach root [concat [lmap {t info} $thunks {dict get $info root}] [dict values $cloneThunks]] {
        if {$root ne "" && [dict exists $protocols $root]} {
            dict set roots $root [Resolved [dict get $protocols $root protocol]]
        }
    }
    set reachedByStruct [dict create]
    dict for {root protocol} $roots {
        if {![IsStructProtocol $protocol]} continue
        foreach n [Closure $root $edges $capable] {
            dict set reachedByStruct $n 1
        }
    }
    set table [dict create]
    set specialized [dict create]
    foreach n [dict keys $capable] {
        set p [dict get $protocols $n protocol]
        switch -- $p {
            none {
                set yieldType [expr {[dict exists $reachedByStruct $n] ? "any" : "unit"}]
            }
            unit { set yieldType unit }
            conflict { set yieldType any }
            default { set yieldType $p }
        }
        set entry [dict create protocol $p yieldType $yieldType reason [dict get $protocols $n reason]]
        if {[ContextOf $n] eq ""} {
            dict set table $n $entry
        } else {
            dict set specialized $n $entry
        }
    }
    set boundaries [dict create]
    dict for {t info} $thunks {
        if {[dict get $info call] ne ""} {
            dict set boundaries [dict get $info call] $t
        }
    }
    dict set hir coroutines [dict create blocks $table thunks $thunks yields $yields \
        edges $edges direct $direct boundaries $boundaries \
        operations [lsort [dict keys $excluded]] consulted [lsort [dict keys $consulted]]]
    if {$graph ne {}} {
        # The specializations (TRAIT-IMPLEMENTATION-YIELD-INFERENCE-
        # MILESTONE-1.md): their yield-capable nodes, the roots of the
        # coroutines constructed in them, and which specialization a
        # semantic instance of a trait-polymorphic function is
        # (SpecializedNode).
        set cloneOf [dict create]
        dict for {k info} [dict get $graph clones] {
            dict set cloneOf [list [dict get $info function] [dict get $info params] [dict get $info binding]] $k
        }
        dict set hir coroutines graph $graph
        dict set hir coroutines specialized $specialized
        dict set hir coroutines cloneThunks $cloneThunks
        dict set hir coroutines cloneOf $cloneOf
        dict set hir coroutines cloneNodes [lrange $nodes [llength $blocks] end]
    }
}

# The coroutine call graph of HIR: WALK is hir::contexts::Walk's result,
# EXCLUDED the method-style calls set aside as trait operations (Target),
# GRAPH the trait-operation edges (Implementations). Returns {nodes N thunks
# T cloneThunks C rootReads R yields Y direct D edges E reads X capable P
# res S}:
#
#   nodes      the functions: every block (its own, generic node), then for
#              each specialization K of GRAPH every block of its function's
#              region, {K BLOCK} (a clone node: the block as the
#              monomorphized program's clone K has it)
#   thunks     thunk -> {create CALL root NODE call ROOTCALL}: a coroutine
#              boundary and its root, the node its call calls (never a trait
#              operation: a root is a direct call of a function)
#   cloneThunks  {K THUNK} -> the root the thunk has in specialization K
#   rootReads  the root calls whose root is their written callee
#   yields, direct  as before: yield -> its function; block -> its yields
#   edges      node -> {{CALL NODE} ...}: the call edges of each node
#   reads      {CALL NODE ...}: the edges that are a call's written callee
#   capable    the syntactically yield-capable nodes
#   res        what Resolve reads
proc hir::coroutines::Build {hir walk excluded graph} {
    lassign $walk owner parent rootOf calls blocks
    # The region of each block: the outermost block it is in (a top-level
    # function's own for its nested functions), its own when it is in none.
    set regionRoot [dict create]
    foreach b $blocks {
        set o [dict get $owner $b]
        if {$o eq ""} {
            dict set regionRoot $b $b
        } else {
            dict set regionRoot $b [dict get $regionRoot $o]
        }
    }
    set clones [dict getdef $graph clones {}]
    set res [dict create excluded $excluded graph $graph regionRoot $regionRoot clones $clones]
    set nodes $blocks
    set cloneBlocks [dict create]
    foreach k [lsort [dict keys $clones]] {
        set h [dict get $clones $k function]
        foreach b $blocks {
            if {[dict get $regionRoot $b] eq $h} {
                dict lappend cloneBlocks $k $b
                lappend nodes [list $k $b]
            }
        }
    }
    # Thunks: the block literal argument of every create call.
    set thunks [dict create]
    set rootReads {}
    dict for {o list} $calls {
        foreach c $list {
            if {[NativeOf $hir $c] ne [core::coroutines::createNative]} continue
            set arg [lindex [dict get $hir exprs $c args] 0]
            if {$arg eq "" || [dict get $hir exprs $arg kind] ne "block"} continue
            set body [dict get $hir exprs $arg body]
            set inner [if {[llength $body] == 1 && [dict get $hir exprs [lindex $body 0] kind] eq "call"} {lindex $body 0} else {string cat ""}]
            set root ""
            if {$inner ne ""} {
                lassign [Root $hir $res "" $inner] root read
                if {$read} {
                    lappend rootReads $inner
                }
            }
            dict set thunks $arg [dict create create $c root $root call $inner]
        }
    }
    set cloneThunks [dict create]
    dict for {k list} $cloneBlocks {
        foreach t $list {
            if {![dict exists $thunks $t] || [dict get $thunks $t call] eq ""} continue
            lassign [Root $hir $res $k [dict get $thunks $t call]] root read
            if {$read} {
                lappend rootReads [dict get $thunks $t call]
            }
            dict set cloneThunks [list $k $t] $root
        }
    }
    # Per function: direct yields and call edges.
    set yields [dict create]
    set direct [dict create]
    foreach b $blocks {
        dict set direct $b {}
    }
    dict for {o list} $calls {
        foreach c $list {
            if {[NativeOf $hir $c] eq [core::coroutines::yieldNative]} {
                dict set yields $c $o
                if {$o ne ""} {
                    dict lappend direct $o $c
                }
            }
        }
    }
    set edges [dict create]
    set reads {}
    foreach n $nodes {
        dict set edges $n {}
        set b [BlockOf $n]
        if {[dict exists $thunks $b] || ![dict exists $calls $b]} continue
        set ctx [ContextOf $n]
        foreach c [dict get $calls $b] {
            if {[NativeOf $hir $c] ne ""} continue
            lassign [Resolve $hir $res $ctx $c] kind targets
            foreach target $targets {
                set t [lindex $target 0]
                if {[dict exists $thunks [BlockOf $t]]} continue
                dict lappend edges $n [list $c $t]
                if {$kind eq "exact"} {
                    lappend reads $c $t
                }
            }
        }
    }
    # The syntactically yield-capable nodes (protocol inference's domain).
    set capable [dict create]
    foreach n $nodes {
        if {[dict get $direct [BlockOf $n]] ne {}} {
            dict set capable $n 1
        }
    }
    set changed 1
    while {$changed} {
        set changed 0
        foreach n $nodes {
            if {[dict exists $capable $n]} continue
            foreach edge [dict get $edges $n] {
                if {[dict exists $capable [lindex $edge 1]]} {
                    dict set capable $n 1
                    set changed 1
                    break
                }
            }
        }
    }
    return [dict create nodes $nodes thunks $thunks cloneThunks $cloneThunks rootReads $rootReads \
        yields $yields direct $direct edges $edges reads $reads capable $capable res $res]
}

# The block of call-graph node N (a block, or a clone node {K BLOCK}).
proc hir::coroutines::BlockOf {n} {
    return [lindex $n end]
}

# The specialization of call-graph node N, or "" for a block's own node.
proc hir::coroutines::ContextOf {n} {
    if {[llength $n] == 2} {
        return [lindex $n 0]
    }
    return ""
}

# What call C calls in context CTX ("" for the program as written: live
# code and every function's own body; a specialization K for K's clone),
# for analyze's resolver RES: {KIND TARGETS}, TARGETS a list of {NODE
# OFFSET}. KIND is
#
#   impl   a trait operation: the implementation the program binds it to --
#          a context trait's the installed context the program selected, an
#          ordinary trait's its witness's (Implementations); OFFSET is the
#          implementation's parameter index of the call's first argument
#   spec   a call of a trait-polymorphic function: the clone node of the
#          specialization it calls (OFFSET 0)
#   exact  any other call: its exact callee (Target), in CTX's region a
#          node of CTX
#   none   no callee the analysis can see (a call through a function value,
#          a trait operation whose implementation is not known here)
proc hir::coroutines::Resolve {hir res ctx c} {
    set key [list $ctx $c]
    set graph [dict get $res graph]
    if {[dict exists $graph impl $key]} {
        return [list impl [dict get $graph impl $key]]
    }
    if {[dict exists $graph spec $key]} {
        return [list spec [lmap n [dict get $graph spec $key] {list $n 0}]]
    }
    set t [Target $hir $c [dict get $res excluded]]
    if {$t eq ""} {
        return {none {}}
    }
    if {$ctx ne "" && [dict get $res regionRoot $t] eq [dict get $res clones $ctx function]} {
        set t [list $ctx $t]
    }
    return [list exact [list [list $t 0]]]
}

# The root of the coroutine whose thunk's call is C, in context CTX (Resolve):
# {NODE READ}, NODE "" when the call is not a direct call of a function (a
# trait operation never is: no coroutine's root), READ 1 when NODE is the
# call's written callee.
proc hir::coroutines::Root {hir res ctx c} {
    lassign [Resolve $hir $res $ctx $c] kind targets
    if {$kind ni {spec exact}} {
        return {{} 0}
    }
    return [list [lindex $targets 0 0] [expr {$kind eq "exact"}]]
}

# The block call C calls for this analysis (hir::contexts::Callee), or ""
# when C is in EXCLUDED: a method-style call a typing of this HIR made a
# trait operation. analyze runs before the types are inferred (they read the
# protocols it infers), so a trait operation that resolution stood in with a
# visible function of the operation's name -- `d.wait(5)` with a function
# `wait` visible, the operation's receiver typed only later -- still names
# that function as its callee here; that function is not the operation's
# implementation, and its yields, protocol and parameters are no part of the
# call (CONTEXT-TRAIT-YIELD-EDGE-CORRECTNESS-MILESTONE-1.md). hir::check
# tells analyze which calls those are, from the typing of a check that read
# them (TraitOperations).
proc hir::coroutines::Target {hir c excluded} {
    if {[dict exists $excluded $c]} {
        return ""
    }
    return [hir::contexts::Callee $hir $c]
}

# Records method-style call C in the caller's CONSULTEDVAR: its written
# callee decided part of the analysis (a coroutine's root, an edge into a
# yield-capable function, a use-site protocol constraint). Only a
# method-style call can turn out to be a trait operation.
proc hir::coroutines::Consulted {hir c consultedVar} {
    upvar 1 $consultedVar consulted
    if {[dict exists $hir exprs $c method]} {
        dict set consulted $c 1
    }
}

# The method-style calls analyze must set aside as trait operations, read
# from HIR, a checked HIR whose protocols analyze inferred: every call among
# the ones it was told (`operations`) and the ones whose written callee it
# read (`consulted`) that the typing made a trait operation (`traitCall`).
# Sorted. hir::check checks again, from the same input, until the calls it
# set aside are exactly these: then no protocol, yield type, coroutine root
# or edge of the checked HIR came from a trait operation's written callee.
proc hir::coroutines::TraitOperations {hir} {
    if {![dict exists $hir coroutines operations]} {
        return {}
    }
    set found {}
    foreach c [concat [dict get $hir coroutines operations] [dict get $hir coroutines consulted]] {
        if {[dict exists $hir exprs $c traitCall]} {
            lappend found $c
        }
    }
    return [lsort -unique $found]
}

# ---------------------------------------------------------------------------
# Implementation effects (TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md)
#
# A trait operation calls no function the code names: its implementation is
# the selected installed context's (a context trait: CONTEXT-TRAITS.md, one
# provider per trait for the whole program) or its receiver's witness's (an
# ordinary trait: TRAITS.md), bound by the monomorphization's plan
# (hir::traits::PlanCalls). That implementation's yields are the call's:
# the coroutine call graph has an edge from the operation to it, and to
# nothing else -- never to a visible function of the operation's name
# (Target), never to another witness's implementation.
#
# Which implementation that is, the typing decides, and the protocols
# analyze infers type every yield first: so hir::check checks again with
# what the typing of the previous check bound (the graph below), as it does
# for the operations it sets aside. An ordinary trait's implementation may
# differ per witness, so a trait-polymorphic function's region has, besides
# its own node per block (the function as written, checked against its
# traits alone: an operation on a view whose witness is a parameter's binds
# nothing there), one node per specialization the plan makes of it (the
# function as its clone for those witnesses is, every operation bound): a
# call passing concrete witnesses calls that specialization. A context
# trait's provider is the program's, so its operations are edges of the
# function's own nodes.
#
# The graph (the feedback's `graph`):
#   impl    {CTX CALL} -> {{NODE OFFSET} ...}: trait operation CALL calls
#           implementation NODE in context CTX (Resolve); OFFSET is the
#           implementation's parameter index of the call's first argument
#   spec    {CTX CALL} -> {NODE ...}: CALL calls the specialization NODE
#   clones  K -> {function H params P binding B witnesses TEXT}: the
#           specializations (the plan's clone keys) the graph names
#   via     {CTX CALL} -> {trait T operation R witness TEXT}: what a chain
#           says of an operation's edge
# CTX is "" (the program as written) or a specialization K. Only edges into
# a node that may yield are kept, and an operation's edges where it receives
# a yield's value (use-site inference reads the implementation's declared
# parameter); any other changes no protocol, no yield effect and no
# diagnostic. Nor is a specialization kept that equals its function as
# written (Distinct). So a program none of whose implementations yields or
# receives a yield's value keeps an empty graph and is checked once.

# The trait-operation edges a typing found in checked HIR, given the
# feedback GIVEN the check was made with: {} when there is nothing to bind
# (no coroutine, no trait operation, or nothing the plan could bind would
# be kept: MayBind), else the graph above, its edges kept as it says (the
# yield-capable nodes those of GIVEN's graph with these edges added).
proc hir::coroutines::Implementations {hir given} {
    if {![dict exists $hir coroutines blocks]} {
        return {}
    }
    if {[dict exists $hir resolutionDiagnostics] || [dict exists $hir syntaxRecovery]} {
        # (A program that did not resolve plans nothing: what its checks find
        # in code that depends on a resolution failure is not reported.)
        return {}
    }
    set operations {}
    set binds {}
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            call {
                if {[dict exists $node traitCall] && ![dict exists $node traitCall unknown]} {
                    lappend operations $e
                }
            }
            bind {
                lappend binds $e
            }
        }
    }
    if {$operations eq {} || ![MayBind $hir $operations $binds $given]} {
        return {}
    }
    # The calls by their syntax (the plan's actions are per syntax node) and
    # the references of each binding.
    set bySid [dict create]
    set refs [dict create]
    dict for {e node} [dict get $hir exprs] {
        switch -- [dict get $node kind] {
            call {
                if {[dict exists $node sid]} {
                    dict lappend bySid [dict get $node sid] $e
                }
            }
            ref {
                dict lappend refs [dict get $node binding] $e
            }
        }
    }
    dict incr ::hir::buildStats effectPlans
    set walk [hir::traits::PlanCalls $hir {}]
    if {![dict exists $walk actions]} {
        return {}
    }
    set polys [dict get $walk polys]
    set home [dict get $walk home]
    set impls [dict create]
    foreach use [dict get $walk implUses] {
        lassign $use ckey impl e
        dict set impls [list $ckey $e] $impl
    }
    set candidate [dict create impl {} spec {} clones {} via {}]
    dict for {key action} [dict get $walk actions] {
        lassign $key ckey sid
        set kind [lindex $action 0]
        if {$kind ni {trait context redirect}} continue
        if {$ckey eq "live"} {
            set h ""
        } else {
            set h [lindex $ckey 0]
        }
        # A specialization of a trait-polymorphic (or per-binding) function
        # has nodes of its own; every other context the plan walks -- live
        # code, the one clone of a function requiring a context trait, an
        # affine argument's -- binds what the function as written does.
        set specialized [expr {$h ne "" && ([dict get $polys $h trait] || [dict get $polys $h imprint])}]
        foreach e [dict getdef $bySid $sid {}] {
            if {![dict exists $home $e] || [dict get $home $e] ne $h} continue
            set contexts [list [if {$specialized} {set ckey} else {string cat ""}]]
            if {$kind eq "redirect"} {
                set k [lindex $action 1]
                set tb [lindex $k 0]
                if {![dict exists $polys $tb] || (![dict get $polys $tb trait] && ![dict get $polys $tb imprint])} continue
                AddClone hir $k candidate
                foreach ctx $contexts {
                    dict set candidate spec [list $ctx $e] [list [list $k $tb]]
                }
            } else {
                set op [lindex $action 1]
                if {[llength $action] > 2} {
                    # A context-trait implementation that requires a context
                    # trait itself: its own clone, the function's one node.
                    set target [lindex $action 2 0]
                } elseif {[dict exists $impls [list $ckey $e]] && [dict get $impls [list $ckey $e] kind] eq "block"} {
                    set target [dict get $impls [list $ckey $e] block]
                } else {
                    # (A native implementation never yields.)
                    continue
                }
                if {$kind eq "context"} {
                    # The program's provider: the same for every context.
                    lappend contexts ""
                    set offset 0
                    set witness "the installed context [lindex [dict get $op witness] 1]"
                } else {
                    set offset [expr {[dict get $hir exprs $e traitCall shape] eq "field"}]
                    set witness [hir::types::show [dict get $op witness]]
                }
                foreach ctx [lsort -unique $contexts] {
                    dict set candidate impl [list $ctx $e] [list [list $target $offset]]
                    dict set candidate via [list $ctx $e] [dict create trait [dict get $op trait] \
                        operation [dict get $op requirement] witness $witness]
                }
            }
            if {$specialized} {
                AddClone hir $ckey candidate
                if {[WitnessFree $hir $e $kind $action]} {
                    # Bound alike in every specialization: the function as
                    # written makes this call too.
                    foreach field {impl spec via} {
                        if {[dict exists $candidate $field [list $ckey $e]]} {
                            dict set candidate $field [list "" $e] [dict get $candidate $field [list $ckey $e]]
                        }
                    }
                }
            }
        }
    }
    if {[dict size [dict get $candidate impl]] == 0 && [dict size [dict get $candidate spec]] == 0} {
        return {}
    }
    set graph [dict getdef $given graph {}]
    set excluded [dict create]
    foreach c [concat [dict getdef $given operations {}] [TraitOperations $hir]] {
        dict set excluded $c 1
    }
    set walkResult [hir::contexts::Walk $hir]
    set built [Build $hir $walkResult $excluded [UnionGraph $graph $candidate]]
    set capable [dict get $built capable]
    # Keep the edges into yield-capable nodes, and an operation's edges where
    # it receives a yield's value: its implementation's declared parameter
    # may fix the protocol (use-site inference), yielding or not. (Which
    # calls receive one is asked only when an implementation cannot yield.)
    set receives [dict create]
    set asks 0
    dict for {key targets} [dict get $candidate impl] {
        foreach t $targets {
            if {![dict exists $capable [lindex $t 0]]} {
                set asks 1
            }
        }
    }
    if {$asks} {
        lassign $walkResult owner parent
        dict for {y o} [dict get $hir coroutines yields] {
            if {$o eq ""} continue
            foreach q [UseCalls $hir $parent $y $refs] {
                dict set receives $q 1
            }
        }
    }
    set kept [dict create impl {} spec {} clones {} via {}]
    foreach field {impl spec} {
        dict for {key targets} [dict get $candidate $field] {
            # (An implementation's target is {NODE OFFSET}, a
            # specialization's its NODE.)
            set live {}
            set specs [list [lindex $key 0]]
            foreach t $targets {
                set n [if {$field eq "impl"} {lindex $t 0} else {set t}]
                if {[dict exists $capable $n] || ($field eq "impl" && [dict exists $receives [lindex $key 1]])} {
                    lappend live $t
                    lappend specs [ContextOf $n]
                }
            }
            if {$live eq {}} continue
            dict set kept $field $key $live
            if {[dict exists $candidate via $key]} {
                dict set kept via $key [dict get $candidate via $key]
            }
            foreach k $specs {
                if {$k ne ""} {
                    dict set kept clones $k [dict get $candidate clones $k]
                }
            }
        }
    }
    return [CanonicalGraph [Distinct $hir $kept $excluded]]
}

# GRAPH without the specializations that are their function as written: a
# specialization is distinct when one of its calls resolves otherwise than
# the same call of the function's own node does -- an operation bound to an
# implementation, a call of a distinct specialization. Any other one has
# exactly its function's nodes (every call of them resolves alike), so its
# nodes, and a check to find them, would only repeat the function's: an
# edge into it becomes an edge into the function's own node (the call's
# exact callee, which needs no entry), and its own entries go. (A
# trait-polymorphic function that yields by itself, whatever its witness,
# is the common case.)
proc hir::coroutines::Distinct {hir graph excluded} {
    set distinct [dict create]
    set changed 1
    while {$changed} {
        set changed 0
        foreach field {impl spec} {
            dict for {key targets} [dict get $graph $field] {
                lassign $key k c
                if {$k eq "" || [dict exists $distinct $k]} continue
                set own [dict getdef [dict get $graph $field] [list "" $c] {}]
                if {[lsort -unique $own] eq [lsort -unique $targets]} continue
                if {$field eq "spec"} {
                    set reaches 0
                    foreach n $targets {
                        if {[dict exists $distinct [ContextOf $n]]} {
                            set reaches 1
                        }
                    }
                    if {!$reaches} continue
                }
                dict set distinct $k 1
                set changed 1
            }
        }
    }
    set result [dict create impl {} spec {} clones {} via {}]
    dict for {key targets} [dict get $graph impl] {
        set k [lindex $key 0]
        if {$k eq "" || [dict exists $distinct $k]} {
            dict set result impl $key $targets
        }
    }
    dict for {key targets} [dict get $graph spec] {
        lassign $key k c
        if {$k ne "" && ![dict exists $distinct $k]} continue
        set mapped [lsort -unique [lmap n $targets {
            if {[dict exists $distinct [ContextOf $n]]} {set n} else {BlockOf $n}
        }]]
        if {$mapped eq [list [Target $hir $c $excluded]]} continue
        dict set result spec $key $mapped
    }
    foreach field {impl spec} {
        dict for {key targets} [dict get $result $field] {
            if {[dict exists $graph via $key]} {
                dict set result via $key [dict get $graph via $key]
            }
            set k [lindex $key 0]
            foreach ctx [concat [list $k] [lmap t $targets {
                ContextOf [if {$field eq "impl"} {lindex $t 0} else {set t}]
            }]] {
                if {$ctx ne ""} {
                    dict set result clones $ctx [dict get $graph clones $ctx]
                }
            }
        }
    }
    return $result
}

# 1 if the trait plan can give checked HIR an edge Implementations keeps,
# by what its typing and its coroutine analysis (`coroutines blocks`, the
# yield-capable blocks) already found; OPERATIONS are its trait operations,
# BINDS its bind expressions, GIVEN the feedback its check was made with.
#
# A kept edge needs an operation that receives a yield's value or an
# implementation that may yield (an edge into a specialization needs one
# inside it: Distinct). An implementation that may yield reaches a yield,
# and after the last operation on the way only through ordinary calls and
# calls of specializations: the target of that operation, an
# implementation, reaches it through calls the analysis made with no
# trait-operation edge saw as ordinary calls (a specialization's calls
# being its function's), so the analysis found it yield-capable. So one of
# these is needed:
#
#   * a yield-capable implementation: a function of the implementation
#     index (hir::traits::ImplInfo, which conformance and context-trait
#     satisfaction read) under the name of a declared trait's requirement;
#   * an operation with a yield, or a binding of one, as an argument.
#
# When an earlier check found edges, the analysis saw those instead of some
# ordinary calls: the plan is asked again. Deciding that neither holds
# needs no plan: a program whose yields are all elsewhere (a test runner,
# ordinary functions' coroutines, a trait-polymorphic function that yields
# by itself) pays only this scan.
proc hir::coroutines::MayBind {hir operations binds given} {
    if {[dict getdef $given graph {}] ne {}} {
        return 1
    }
    set capable [dict get $hir coroutines blocks]
    if {[dict size $capable] == 0} {
        return 0
    }
    set yieldNative [core::coroutines::yieldNative]
    set yielded [dict create]
    foreach b $binds {
        if {[NativeOf $hir [dict get $hir exprs $b value]] eq $yieldNative} {
            dict set yielded [dict get $hir exprs $b binding] 1
        }
    }
    foreach e $operations {
        foreach a [dict get $hir exprs $e args] {
            set node [dict get $hir exprs $a]
            if {[NativeOf $hir $a] eq $yieldNative
                    || ([dict get $node kind] eq "ref" && [dict exists $yielded [dict get $node binding]])} {
                return 1
            }
        }
    }
    foreach id [hir::traits::declaredIds] {
        foreach name [hir::traits::requirementNames $id] {
            foreach info [hir::traits::ImplInfos $name] {
                if {[dict get $info kind] eq "block" && [dict exists $capable [dict get $info block]]} {
                    return 1
                }
            }
        }
    }
    return 0
}

# 1 if call E of a trait-polymorphic function's body, which the plan binds
# by ACTION (of KIND trait, context or redirect) in one of its
# specializations, is bound so whatever the function's witnesses are: the
# function's own analysis (the checked HIR) already has the binding -- a
# context trait's operation (the program's provider), an operation on a
# view whose witness is concrete, a call of a trait-polymorphic function
# with concrete witnesses (the specialization the plan makes for it).
proc hir::coroutines::WitnessFree {hir e kind action} {
    switch -- $kind {
        context {
            return 1
        }
        trait {
            set record [dict get $hir exprs $e traitCall]
            if {[dict exists $record imprint]} {
                return 0
            }
            set type [hir::typeOf $hir [dict get $record receiver]]
            return [expr {[hir::types::IsView $type] && [hir::traits::IsConcreteWitness [hir::types::ViewWitness $type]]}]
        }
        redirect {
            set k [lindex $action 1]
            if {[llength $k] > 3 || ![dict exists $hir semantic calls [list generic $e]]} {
                # (A specialization per binding depends on the imprint.)
                return 0
            }
            set id [dict get $hir semantic calls [list generic $e]]
            set params [hir::traits::CloneWitnesses $hir [lindex $k 0] [dict get $hir semantic instances $id args]]
            return [expr {$params ne "" && $params eq [lindex $k 1]}]
        }
    }
    return 0
}

# Records specialization K (a clone key of the plan: {FUNCTION PARAMS
# SELECTION ?BINDING?}) in the graph CANDIDATEVAR, with the text that names
# its witnesses.
proc hir::coroutines::AddClone {hirVar k candidateVar} {
    upvar 1 $hirVar hir $candidateVar candidate
    if {[dict exists $candidate clones $k]} {
        return
    }
    lassign $k h params selection binding
    set parts [lmap {i w} $params {hir::types::show $w}]
    dict for {v t} $binding {
        lappend parts "$v = [hir::types::show $t]"
    }
    dict set candidate clones $k [dict create function $h params $params binding $binding \
        witnesses [join $parts {, }]]
}

# The union of graphs A and B (each target list a set).
proc hir::coroutines::UnionGraph {a b} {
    set result [dict create impl {} spec {} clones {} via {}]
    foreach g [list $a $b] {
        if {$g eq {}} continue
        foreach field {impl spec} {
            dict for {key targets} [dict get $g $field] {
                dict set result $field $key [lsort -unique [concat [dict getdef [dict get $result $field] $key {}] $targets]]
            }
        }
        foreach field {clones via} {
            dict for {key value} [dict get $g $field] {
                if {![dict exists $result $field $key]} {
                    dict set result $field $key $value
                }
            }
        }
    }
    return [CanonicalGraph $result]
}

# GRAPH in its one spelling (every field sorted by key), {} when it has no
# edge.
proc hir::coroutines::CanonicalGraph {graph} {
    if {$graph eq {} || ([dict size [dict get $graph impl]] == 0 && [dict size [dict get $graph spec]] == 0)} {
        return {}
    }
    set result [dict create]
    foreach field {impl spec clones via} {
        set sorted [dict create]
        foreach key [lsort [dict keys [dict get $graph $field]]] {
            set value [dict get $graph $field $key]
            if {$field in {impl spec}} {
                set value [lsort -unique $value]
            }
            dict set sorted $key $value
        }
        dict set result $field $sorted
    }
    return $result
}

# What the coroutine analysis of hir::check's next check is told, from
# checked HIR and the feedback GIVEN its check was made with: GIVEN with the
# trait operations it would read (TraitOperations) and the trait-operation
# edges the typing found (Implementations) added -- {} when both are empty,
# else {operations OPS graph GRAPH}. Only ever grows: hir::check checks
# again until it is GIVEN.
proc hir::coroutines::Feedback {hir given} {
    set operations [lsort -unique [concat [dict getdef $given operations {}] [TraitOperations $hir]]]
    set graph [UnionGraph [dict getdef $given graph {}] [Implementations $hir $given]]
    if {$operations eq {} && $graph eq {}} {
        return {}
    }
    return [dict create operations $operations graph $graph]
}

# The implementation blocks each trait operation of checked HIR calls in
# some context, as the coroutine analysis bound them (the graph's `impl`:
# those that may yield, or receive a yield's value): call -> {BLOCK ...}. hir/staticdeps.tcl reads
# them as the operation's call targets, whose yield effect is the call's.
proc hir::coroutines::ImplementationTargets {hir} {
    set result [dict create]
    if {![dict exists $hir coroutines graph impl]} {
        return $result
    }
    dict for {key targets} [dict get $hir coroutines graph impl] {
        set c [lindex $key 1]
        foreach t $targets {
            set b [BlockOf [lindex $t 0]]
            if {$b ni [dict getdef $result $c {}]} {
                dict lappend result $c $b
            }
        }
    }
    return $result
}

# The declared `resume T` protocol of block E, or "".
proc hir::coroutines::DeclaredResume {hir e} {
    return [dict getdef $hir exprs $e declaredResume ""]
}

# The protocol a coroutine whose root has inferred protocol P is resumed
# with: an unconstrained root is zero-message; a conflict (already
# COROUTINE-RESUME-CONFLICT) is any, so that no resume of it is diagnosed
# again.
proc hir::coroutines::Resolved {p} {
    return [switch -- $p {
        none { expr {"unit"} }
        conflict { expr {"any"} }
        default { set p }
    }]
}

# The yield-capable functions reachable from ROOT (itself included) over
# EDGES.
proc hir::coroutines::Closure {root edges capable} {
    set seen [dict create $root 1]
    set work [list $root]
    while {$work ne {}} {
        set b [lindex $work 0]
        set work [lrange $work 1 end]
        if {![dict exists $edges $b]} continue
        foreach edge [dict get $edges $b] {
            set target [lindex $edge 1]
            if {[dict exists $capable $target] && ![dict exists $seen $target]} {
                dict set seen $target 1
                lappend work $target
            }
        }
    }
    return [dict keys $seen]
}

# The protocol fixed point over the yield-capable functions CAPABLE: each
# one's protocol is the join of its LOCAL constraints and its yielding
# callees' protocols. Updates PROTOCOLSVAR (b -> {protocol P reason R}) and
# records each function where two different protocols first meet in
# CONFLICTSVAR (b -> {P1 R1 P2 R2}).
proc hir::coroutines::Solve {hir capable local edges protocolsVar conflictsVar} {
    upvar 1 $protocolsVar protocols $conflictsVar conflicts
    set changed 1
    while {$changed} {
        set changed 0
        foreach b [dict keys $capable] {
            set current [dict get $protocols $b]
            set p [dict get $current protocol]
            set reason [dict get $current reason]
            set inputs [dict get $local $b]
            foreach edge [dict get $edges $b] {
                lassign $edge c target
                if {![dict exists $capable $target]} continue
                set why [list call $c $target]
                if {[ContextOf $b] ne ""} {
                    # (A specialization's call: what explains it is its own.)
                    lappend why [ContextOf $b]
                }
                lappend inputs [list [dict get $protocols $target protocol] $why]
            }
            foreach input $inputs {
                lassign $input q why
                if {$q eq "none" || $q eq $p} continue
                if {$p eq "conflict"} break
                if {$q eq "conflict"} {
                    set p conflict
                    set reason $why
                    break
                }
                if {$p eq "none"} {
                    set p $q
                    set reason $why
                    continue
                }
                if {![dict exists $conflicts $b]} {
                    dict set conflicts $b [list $p $reason $q $why]
                }
                set p conflict
                break
            }
            if {$p ne [dict get $current protocol]} {
                dict set protocols $b [dict create protocol $p reason $reason]
                set changed 1
            }
        }
    }
}

# Why a function has a protocol, as text: its own declaration, a use of a
# yield's value, the zero-message default, or a callee (followed to where
# that callee's protocol comes from).
proc hir::coroutines::ExplainReason {hir reason protocols} {
    set steps {}
    for {set i 0} {$i < 64} {incr i} {
        switch -- [lindex $reason 0] {
            declared {
                lappend steps [expr {$steps eq {} ? "[Name $hir [lindex $reason 1]] declares it" : "which declares it"}]
                break
            }
            use {
                lassign $reason _ y at
                lappend steps "[expr {$steps eq {} ? "" : "where "}]the value of the yield at [Where $hir $y] is passed to a parameter declared [hir::types::show [lindex $at 1]] ([Where $hir [lindex $at 0]])"
                break
            }
            default {
                lappend steps "[expr {$steps eq {} ? "" : "where "}][Name $hir [lindex $reason 1]] uses the value of a yield without a declared protocol (zero-message)"
                break
            }
            call {
                lassign $reason _ c target ctx
                lappend steps "[expr {$steps eq {} ? "it calls" : "which calls"}] [Name $hir $target][string trimright [Via $hir $ctx $c] ,] ([Where $hir $c])"
                if {![dict exists $protocols $target]} break
                set reason [dict get $protocols $target reason]
            }
            default {
                break
            }
        }
    }
    return [join $steps {, }]
}

# How the value of yield call Y is used, from the parent map PARENT
# (hir::contexts::Walk): {USED TYPES PROJECTIONS}. USED is 0 when the value is
# discarded (a statement whose value is dropped, or a binding nothing refers
# to). TYPES is a flat list of {TYPE AT} -- struct types its uses require as
# the argument of a call with a declared struct parameter, the call resolved
# in context CTX for analyze's resolver RES (Resolve: an exact callee, a
# specialization, or a trait operation's implementation; AT {CALL TYPE
# KIND}); PROJECTIONS the field projections of it (a struct use whose type a
# projection cannot determine).
proc hir::coroutines::YieldUses {hir parent y res ctx} {
    set uses {}
    lassign [dict get $parent $y] p role
    if {[Discarded $hir $parent $y]} {
        return {0 {} {}}
    }
    if {$p ne "" && [dict get $hir exprs $p kind] eq "bind" && $role eq "operand"} {
        set b [dict get $hir exprs $p binding]
        set refs [RefsOf $hir $b]
        if {$refs eq {}} {
            return {0 {} {}}
        }
        set uses $refs
    } else {
        set uses [list $y]
    }
    set types {}
    set projections {}
    foreach u $uses {
        if {![dict exists $parent $u]} continue
        lassign [dict get $parent $u] q qrole
        if {$q eq ""} continue
        set node [dict get $hir exprs $q]
        switch -- [dict get $node kind] {
            project {
                lappend projections $q
            }
            call {
                set index [lsearch -exact [dict get $node args] $u]
                if {$index < 0} continue
                lassign [Resolve $hir $res $ctx $q] kind targets
                foreach target $targets {
                    lassign $target t offset
                    set declared [lindex [dict get $hir exprs [BlockOf $t] declaredParamTypes] [expr {$index + $offset}]]
                    if {[IsStructProtocol $declared]} {
                        lappend types $declared [list $q $declared $kind]
                    }
                }
            }
        }
    }
    return [list 1 $types $projections]
}

# The calls the value of yield call Y is an argument of (YieldUses' uses),
# by the parent map PARENT and the references of each binding, REFS
# (binding -> its ref expressions, as RefsOf finds them).
proc hir::coroutines::UseCalls {hir parent y refs} {
    lassign [dict get $parent $y] p role
    if {[Discarded $hir $parent $y]} {
        return {}
    }
    if {$p ne "" && [dict get $hir exprs $p kind] eq "bind" && $role eq "operand"} {
        set uses [dict getdef $refs [dict get $hir exprs $p binding] {}]
    } else {
        set uses [list $y]
    }
    set calls {}
    foreach u $uses {
        if {![dict exists $parent $u]} continue
        set q [lindex [dict get $parent $u] 0]
        if {$q ne "" && [dict get $hir exprs $q kind] eq "call" && $u in [dict get $hir exprs $q args]} {
            lappend calls $q
        }
    }
    return $calls
}

# 1 if the value of expression E is discarded, by the parent map PARENT
# (hir::contexts::Walk): a statement that is not the last of its body, or the
# last statement of an if branch, a handler or a collecting loop's body
# (COLLECTING-LOOPS.md: an element of the loop's List) whose own value is
# discarded, or of a plain `loop:` body (whose value is never the loop's).
# The last statement of a function body is its result, of the top level the
# program's result.
proc hir::coroutines::Discarded {hir parent e} {
    for {set i 0} {$i < 4096} {incr i} {
        if {![dict exists $parent $e]} {
            return 0
        }
        lassign [dict get $parent $e] p role
        if {$role eq "seq 0"} {
            return 1
        }
        if {$role ne "seq 1" || $p eq ""} {
            return 0
        }
        switch -- [dict get $hir exprs $p kind] {
            if - handle - listloop - countloop - lockloop { set e $p }
            loop { return 1 }
            default { return 0 }
        }
    }
    return 0
}

# The reference ExprIds of binding B, in id order.
proc hir::coroutines::RefsOf {hir b} {
    set refs {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] eq "ref" && [dict get $node binding] eq $b} {
            lappend refs $e
        }
    }
    return $refs
}

# ---------------------------------------------------------------------------
# Types (hir/types.tcl's ShapeResult)

proc hir::coroutines::ShapeResult {hir shape argExprs argTypes {ctx {}}} {
    if {![dict exists $hir coroutines] || [dict size [dict get $hir coroutines]] == 0} {
        return any
    }
    set table [dict get $hir coroutines]
    switch -- $shape {
        coroutine-yield {
            set arg [lindex $argExprs 0]
            if {$arg eq ""} {
                return any
            }
            set scope [dict get $hir exprs $arg scope]
            set b [dict get $hir scopes $scope invocation]
            if {$b eq ""} {
                return any
            }
            set n [SpecializedNode $hir $ctx $b]
            if {$n ne "" && [dict exists $table specialized $n]} {
                # A yield of a trait-polymorphic function, typed in one of its
                # semantic instances: its specialization's protocol.
                return [dict get $table specialized $n yieldType]
            }
            if {[dict exists $table blocks $b]} {
                return [dict get $table blocks $b yieldType]
            }
            return any
        }
        coroutine-create {
            set thunk [lindex $argExprs 0]
            if {$thunk eq "" || ![dict exists $table thunks $thunk]} {
                return [hir::types::MakeCoroutine unit any {}]
            }
            set root [dict get $table thunks $thunk root]
            set n [SpecializedNode $hir $ctx $thunk]
            if {$n ne "" && [dict exists $table cloneThunks $n]} {
                # A construction in a trait-polymorphic function, typed in one
                # of its semantic instances: the root its specialization has.
                set root [dict get $table cloneThunks $n]
            }
            set info [NodeInfo $hir $root]
            if {$root eq "" || $info eq ""} {
                return [hir::types::MakeCoroutine unit any {}]
            }
            return [hir::types::MakeCoroutine [Resolved [dict get $info protocol]] \
                [Outward $hir $root] [dict get $hir exprs [BlockOf $root] declaredErrors]]
        }
        coroutine-outward {
            set handle [lindex $argTypes 0]
            if {[hir::types::IsCoroutine $handle]} {
                return [hir::types::CoroutineOutward $handle]
            }
            return any
        }
    }
    return any
}

# The protocol entry {protocol P yieldType T reason R} of yield-capable
# call-graph node N, or "".
proc hir::coroutines::NodeInfo {hir n} {
    if {[dict exists $hir coroutines blocks $n]} {
        return [dict get $hir coroutines blocks $n]
    }
    if {[dict exists $hir coroutines specialized $n]} {
        return [dict get $hir coroutines specialized $n]
    }
    return ""
}

# The yield-capable call-graph nodes of HIR: blocks and specializations.
proc hir::coroutines::CapableNodes {hir} {
    return [dict merge [dict get $hir coroutines blocks] [dict getdef $hir coroutines specialized {}]]
}

# The clone node {K B} of block B in the specialization K that the semantic
# instance typing context CTX (hir/types.tcl) is a walk of, or "": a walk of an
# instance of a trait-polymorphic function F (hir/semantic.tcl) types F's
# region as the monomorphized program's clone of F for the instance's
# witnesses does (TRAIT-IMPLEMENTATION-YIELD-INFERENCE-MILESTONE-1.md).
proc hir::coroutines::SpecializedNode {hir ctx b} {
    if {![dict exists $ctx inst] || ![dict exists $hir coroutines cloneOf]} {
        return ""
    }
    set inst [hir::semantic::Instance [dict get $ctx inst]]
    if {$inst eq ""} {
        return ""
    }
    set h [dict get $inst block]
    set args [dict get $inst args]
    set params [hir::traits::CloneWitnesses $hir $h $args]
    set binding [hir::traits::InstanceBinding $hir $h $args]
    foreach key [list [list $h $params $binding] [list $h $params {}]] {
        if {[dict exists $hir coroutines cloneOf $key]} {
            return [list [dict get $hir coroutines cloneOf $key] $b]
        }
    }
    return ""
}

# The outward type of a coroutine rooted at call-graph node ROOT: its
# function's declared result, else the join of its result and of every value
# a yield its coroutine can reach sends (as typed so far).
proc hir::coroutines::Outward {hir root} {
    set block [BlockOf $root]
    set declared [dict get $hir exprs $block declaredResult]
    if {$declared ne ""} {
        return $declared
    }
    set result never
    if {[dict get $hir exprs $block resultType] ne ""} {
        set result [hir::type $hir [dict get $hir exprs $block resultType]]
    } else {
        return any
    }
    foreach {y type} [YieldTypes $hir $root 0] {
        set result [hir::types::lub $result $type]
    }
    return $result
}

# {YIELD TYPE ...}: every yield the coroutine rooted at node ROOT can reach
# (over the syntactic call graph; with REACHABLE 1, only reachable yields of
# functions that may yield), with the static type of the value it sends.
proc hir::coroutines::YieldTypes {hir root reachable} {
    set table [dict get $hir coroutines]
    set capable [CapableNodes $hir]
    set edges [dict get $table edges]
    set result {}
    set seen [dict create]
    foreach b [lsort -dictionary [Closure $root $edges $capable]] {
        if {$reachable && ![MayYield $hir $b]} continue
        foreach y [dict get $table direct [BlockOf $b]] {
            if {[dict exists $seen $y]} continue
            dict set seen $y 1
            if {$reachable && ![dict get $hir exprs $y reachable]} continue
            set value [lindex [dict get $hir exprs $y args] 0]
            if {$value eq "" || [dict get $hir exprs $value type] eq ""} continue
            set type [hir::typeOf $hir $value]
            if {$type eq "never"} continue
            lappend result $y $type
        }
    }
    return $result
}

proc hir::coroutines::MayYield {hir b} {
    return [expr {[dict exists $hir coroutines mayYield $b]}]
}

# The protocol of a coroutine handle type, for messages.
proc hir::coroutines::HandleProtocol {type} {
    return [hir::types::CoroutineResume $type]
}

# ---------------------------------------------------------------------------
# verify (after type inference)

proc hir::coroutines::verify {hirVar} {
    upvar 1 $hirVar hir
    if {![dict exists $hir coroutines] || [dict size [dict get $hir coroutines]] == 0} {
        return
    }
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    set table [dict get $hir coroutines]
    set thunks [dict get $table thunks]
    # The call graph's nodes: every block's own, then the specializations'
    # (analyze).
    set nodes [concat $blocks [dict getdef $table cloneNodes {}]]
    set clonesOf [dict create]
    foreach n [dict getdef $table cloneNodes {}] {
        dict lappend clonesOf [BlockOf $n] $n
    }
    # Yields outside every function.
    dict for {y o} [dict get $table yields] {
        if {$o eq ""} {
            hir::Diagnose hir YIELD-OUTSIDE-FUNCTION \
                "yield outside a function: a yield suspends the coroutine whose function it is written in, and top-level code is not in a function (move it into a function and start that function with \"coroutine {step, first} = f(...)\")" $y
        }
    }
    # The reachable yield effect, with each node's next step towards a
    # direct yield (breadth-first: the shortest chain, in call order).
    set next [dict create]
    set mayYield [dict create]
    foreach n $nodes {
        foreach y [dict get $table direct [BlockOf $n]] {
            if {[dict get $hir exprs $y reachable]} {
                dict set mayYield $n 1
                dict set next $n [list direct $y]
                break
            }
        }
    }
    set frontier [dict keys $mayYield]
    while {$frontier ne {}} {
        set layer [dict create]
        foreach n $frontier {
            dict set layer $n 1
        }
        set added {}
        foreach n $nodes {
            if {[dict exists $mayYield $n] || [dict exists $thunks [BlockOf $n]]} continue
            foreach edge [dict get $table edges $n] {
                lassign $edge c target
                if {[dict exists $layer $target] && [dict get $hir exprs $c reachable]} {
                    dict set next $n [list call $c $target]
                    lappend added $n
                    break
                }
            }
        }
        foreach n $added {
            dict set mayYield $n 1
        }
        set frontier $added
    }
    dict set hir coroutines mayYield $mayYield
    dict set hir coroutines next $next
    # Entering a yielding call graph without a coroutine boundary: a call of
    # a function, a specialization or a trait operation whose
    # implementation may yield.
    if {[dict exists $calls ""]} {
        foreach c [dict get $calls ""] {
            if {![dict get $hir exprs $c reachable] || [NativeOf $hir $c] ne ""} continue
            lassign [CallTargets $hir "" $c] kind targets
            if {$kind eq "spec"} {
                # (The function's own node first: what it may do whatever
                # its witnesses are is said of the function as written.)
                set targets [concat [lmap t $targets {BlockOf $t}] $targets]
            }
            foreach target $targets {
                if {$target eq "" || ![dict exists $mayYield $target]} continue
                if {$kind eq "impl"} {
                    set via [dict get $hir coroutines graph via [list "" $c]]
                    hir::Diagnose hir UNWRAPPED-YIELD \
                        "this call of [dict get $via trait]'s operation [dict get $via operation] may suspend, because [Name $hir $target], its implementation for [dict get $via witness], may; but it does not start a coroutine, and an operation is no coroutine's root (call it from a function that runs inside a coroutine):\n[Chain $hir $target $next]" $c
                } else {
                    hir::Diagnose hir UNWRAPPED-YIELD \
                        "[Name $hir $target] may suspend, but this call does not start a coroutine (start it with \"coroutine {step, first} = [hir::contexts::BlockName $hir [BlockOf $target]](...)\", or call it from a function that runs inside a coroutine):\n[Chain $hir $target $next]" $c
                }
                break
            }
        }
    }
    dict for {e node} [dict get $hir exprs] {
        set kind [dict get $node kind]
        if {$kind eq "ref"} {
            set target [hir::contexts::Denotes $hir [dict get $node binding]]
        } elseif {$kind eq "block"} {
            set target $e
        } else {
            continue
        }
        if {$target eq "" || ![dict exists $parent $e]} continue
        # The function's own node, else a specialization of it (a function
        # nested in a trait-polymorphic one: each clone has one).
        set n ""
        foreach m [concat [list $target] [dict getdef $clonesOf $target {}]] {
            if {[dict exists $mayYield $m]} {
                set n $m
                break
            }
        }
        if {$n eq ""} continue
        if {![dict get $node reachable] || ![hir::contexts::Observed $hir $parent $e]} continue
        hir::Diagnose hir UNWRAPPED-YIELD \
            "[Name $hir $n] may suspend, so it cannot become a function value: a call through an unknown function value could run it outside every coroutine (call it directly, or start it with \"coroutine {step, first} = [hir::contexts::BlockName $hir $target](...)\"):\n[Chain $hir $n $next]" $e
    }
    # Constructions: judged as written (a construction's root as the
    # program's own code calls it -- a specialization when the root call
    # passes concrete witnesses); in a trait-polymorphic function, also each
    # specialization's root, as its clone's construction.
    set cloneThunks [dict getdef $table cloneThunks {}]
    dict for {thunk info} $thunks {
        set create [dict get $info create]
        if {![dict get $hir exprs $create reachable]} continue
        set root [dict get $info root]
        if {$root eq ""} {
            hir::Diagnose hir COROUTINE-RHS-NOT-YIELDING \
                "the right side of a coroutine binding must be a direct call of a function that may yield (a named function, not a function value or another expression)" $create
            continue
        }
        if {![dict exists $mayYield $root]} {
            if {[Unselected $hir [BlockOf $root]] ne {} && [SelectionRejected $hir $create]} {
                # Whether it yields depends on the implementation of a
                # context trait it requires, and no one installed context
                # provides it here: the construction's MISSING-CONTEXT or
                # AMBIGUOUS-CONTEXT-IMPLEMENTATION is what is wrong, and
                # "never yields" would be a guess.
                continue
            }
            hir::Diagnose hir COROUTINE-RHS-NOT-YIELDING \
                "[Name $hir $root] never yields (it has no reachable yield and calls no function that may yield), so there is no coroutine to start: call it directly" $create
            continue
        }
        if {![ResultMismatch hir $create $root]} {
            foreach n [dict getdef $clonesOf $thunk {}] {
                if {![dict exists $cloneThunks $n]} continue
                set r [dict get $cloneThunks $n]
                if {$r eq "" || $r eq $root || ![dict exists $mayYield $r]} continue
                if {[ResultMismatch hir $create $r]} break
            }
        }
        AffineProtocol hir $create $root
    }
    # Resume calls are checked by the shared callable contract check
    # (hir::range::VerifyStructuralCall, AFFINE-VALUES.md): arity
    # (COROUTINE-RESUME-ARITY) and the message's type (TYPE); ownership by
    # hir::affine::verify.
}

# The context traits block B requires (hir::contexts::verify's requirement)
# for which the program has selected no installed context, sorted: the
# operations whose implementation, and so whose yield effect, no analysis
# can know.
proc hir::coroutines::Unselected {hir b} {
    set result {}
    foreach id [hir::contexts::required $hir $b] {
        if {[hir::contexts::isTrait $id] && ![dict exists $hir contexts selected $id]} {
            lappend result $id
        }
    }
    return $result
}

# 1 if HIR reports call C's context selection as failed (hir::contexts::
# Obligations: a context it requires no installed context, or more than one,
# provides).
proc hir::coroutines::SelectionRejected {hir c} {
    foreach d [dict get $hir diagnostics] {
        if {[dict get $d expr] eq $c && [dict get $d kind] in {MISSING-CONTEXT AMBIGUOUS-CONTEXT-IMPLEMENTATION}} {
            return 1
        }
    }
    return 0
}

# What call C calls in context CTX ("" or a specialization) of checked HIR,
# for the yield effect: {KIND NODES} -- impl (a trait operation: its
# implementations), spec (a call of a trait-polymorphic function: its
# specialization) or exact (hir::contexts::Callee; NODES {""} when none).
proc hir::coroutines::CallTargets {hir ctx c} {
    set key [list $ctx $c]
    if {[dict exists $hir coroutines graph impl $key]} {
        return [list impl [lmap t [dict get $hir coroutines graph impl $key] {lindex $t 0}]]
    }
    if {[dict exists $hir coroutines graph spec $key]} {
        return [list spec [dict get $hir coroutines graph spec $key]]
    }
    return [list exact [list [hir::contexts::Callee $hir $c]]]
}

# COROUTINE-CONTRACT at construction CREATE of root ROOT when the coroutine's
# outward type, its resume message or the payload of an error it may fail
# with (ERROR-PAYLOADS.md) is affine (AFFINE-VALUES.md): a
# completed coroutine returns its cached final result again on every later
# resume, which would make several owners of one affine result; and a message
# sent to a coroutine that has already completed is never received, so
# nothing would own (or release) it. Both stay unrestricted for now.
proc hir::coroutines::AffineProtocol {hirVar create root} {
    upvar 1 $hirVar hir
    set type [hir::typeOf $hir $create]
    if {![hir::types::IsCoroutine $type]} {
        return
    }
    if {[hir::types::IsAffine [hir::types::CoroutineOutward $type]]} {
        hir::Diagnose hir COROUTINE-CONTRACT [format \
            {%s's coroutine would end its segments with an affine %s: a completed coroutine returns its cached final result again on every later resume, which would give one affine value several owners (yield and return unrestricted values; pass affine values in at construction)} \
            [Name $hir $root] [hir::types::show [hir::types::CoroutineOutward $type]]] $create
    }
    set protocol [hir::types::CoroutineResume $type]
    if {$protocol ni {unit any} && [hir::types::IsAffine $protocol]} {
        hir::Diagnose hir COROUTINE-CONTRACT [format \
            {%s's coroutine is resumed with the affine message %s: a message sent to a coroutine that has already completed is never received, so nothing would own or release it (resume with an unrestricted message; pass affine values in at construction)} \
            [Name $hir $root] [hir::types::show $protocol]] $create
    }
    foreach name [hir::types::CoroutineErrors $type] {
        # ERROR-PAYLOADS.md: a failed coroutine raises its cached error again
        # on every later resume -- for the same reason as a cached final
        # result, the payload of an error a coroutine can fail with stays
        # unrestricted (one affine payload raised twice would have two
        # owners).
        set payload [hir::errordecls::payloadType $name]
        if {$payload ne "" && [hir::types::IsAffine $payload]} {
            hir::Diagnose hir COROUTINE-CONTRACT [format \
                {%s's coroutine may fail with %s, whose payload %s is affine: a failed coroutine raises its cached error again on every later resume, which would give the one affine payload several owners (fail a coroutine only with errors whose payload is unrestricted; handle %s inside the coroutine)} \
                [Name $hir $root] $name [hir::types::show $payload] $name] $create
        }
    }
}

# The deterministic call chain from function B to a direct yield, as
# diagnostic lines.
proc hir::coroutines::Chain {hir b next} {
    set lines {}
    set first 1
    for {set i 0} {$i < 256 && $b ne ""} {incr i} {
        set step [dict get $next $b]
        set prefix [expr {$first ? "    " : "     -> "}]
        if {[lindex $step 0] eq "direct"} {
            lappend lines "$prefix[Name $hir $b], which yields directly at [Where $hir [lindex $step 1]]"
            break
        }
        lappend lines "$prefix[Name $hir $b], which calls [Name $hir [lindex $step 2]][Via $hir [ContextOf $b] [lindex $step 1]] at [Where $hir [lindex $step 1]]"
        set b [lindex $step 2]
        set first 0
    }
    return [join $lines \n]
}

# COROUTINE-RESULT-MISMATCH at construction CREATE of root ROOT (a call-graph
# node): every value a segment of the coroutine can end with must have one
# common outward type. 1 if it reported one.
proc hir::coroutines::ResultMismatch {hirVar create root} {
    upvar 1 $hirVar hir
    set yields [YieldTypes $hir $root 1]
    set block [BlockOf $root]
    set declared [dict get $hir exprs $block declaredResult]
    set name [Name $hir $root]
    if {$declared ne ""} {
        foreach {y type} $yields {
            if {![hir::types::subtype $type $declared]} {
                hir::Diagnose hir COROUTINE-RESULT-MISMATCH \
                    "a coroutine's yields and its return share one outward type, $name's declared result [hir::types::show $declared]; the yield at [Where $hir $y] sends a [hir::types::show $type] (yield a [hir::types::show $declared], or declare a result type both are)" $create
                return 1
            }
        }
        return 0
    }
    set components {}
    if {[dict get $hir exprs $block resultType] ne ""} {
        set result [hir::type $hir [dict get $hir exprs $block resultType]]
        if {$result ne "never"} {
            lappend components $result
        }
    }
    foreach {y type} $yields {
        if {$type ni $components} {
            lappend components $type
        }
    }
    foreach candidate $components {
        set all 1
        foreach other $components {
            if {![hir::types::subtype $other $candidate]} {
                set all 0
                break
            }
        }
        if {$all} {
            return 0
        }
    }
    hir::Diagnose hir COROUTINE-RESULT-MISMATCH \
        "a coroutine's yields and its return share one outward type, but $name's do not: it can end a segment with [join [lmap t $components {hir::types::show $t}] {, }] (declare $name's result type, and yield and return values of it)" $create
    return 1
}

# ---------------------------------------------------------------------------
# Ownership
#
# A coroutine handle is affine; the ownership discipline -- moves, uses,
# releases at the last use and on every exit -- is no longer coroutine-
# specific: hir/affine.tcl decides it for every affine value (AFFINE-
# VALUES.md), the coroutine handle being its one primitive affine root.

# The sequence (a list of ExprIds) of parent P that holds statement E: a body
# of a block, branch, loop or handler, or the top level (P "").
proc hir::coroutines::SequenceOf {hir p e} {
    if {$p eq ""} {
        return [dict get $hir roots]
    }
    set node [dict get $hir exprs $p]
    set lists {}
    switch -- [dict get $node kind] {
        block - loop - listloop - countloop - lockloop { set lists [list [dict get $node body]] }
        if { set lists [list [dict get $node thenBody] [dict get $node elseBody]] }
        handle { set lists [dict get $node handlerBodies] }
    }
    foreach list $lists {
        if {$e in $list} {
            return $list
        }
    }
    return ""
}

# The coroutine effect of block E as HIR text shows it ("" if E may not
# yield): `yields TYPE, resume PROTOCOL` -- the join of what its own and its
# callees' reachable yields send, and the resume protocol they evaluate to.
proc hir::coroutines::EffectText {hir e} {
    if {![dict exists $hir coroutines mayYield]} {
        # HIR read from text (hir/read.tcl): the effect as it was printed.
        return [dict getdef $hir exprs $e coroutineEffect ""]
    }
    if {![MayYield $hir $e] || ![dict exists $hir coroutines blocks $e]} {
        return ""
    }
    set sent never
    foreach {y type} [YieldTypes $hir $e 1] {
        set sent [hir::types::lub $sent $type]
    }
    set protocol [dict get $hir coroutines blocks $e protocol]
    set shown [switch -- $protocol {
        none { expr {"none"} }
        unit { expr {"unit"} }
        conflict { expr {"conflict"} }
        default { hir::types::show $protocol }
    }]
    return "yields [hir::types::show $sent], resume $shown"
}

# The thunk block expressions (the coroutine boundaries) of HIR.
proc hir::coroutines::thunks {hir} {
    if {![dict exists $hir coroutines thunks]} {
        return {}
    }
    return [dict keys [dict get $hir coroutines thunks]]
}

# The declared errors a thunk lets escape (its root's), or "" if E is not a
# thunk: a coroutine segment ends with whatever its body does not handle.
proc hir::coroutines::thunkErrors {hir e} {
    if {![dict exists $hir coroutines thunks $e]} {
        return ""
    }
    set root [dict get $hir coroutines thunks $e root]
    if {$root eq ""} {
        return {}
    }
    return [dict get $hir exprs [BlockOf $root] declaredErrors]
}

# The thunk of the coroutine handle expression E denotes (a reference to the
# handle's binding, or to a binding it was moved to), or "": a handle is
# only ever a local binding of a construction (or a move of one), so the
# chain always ends at one construction.
proc hir::coroutines::thunkOfHandle {hir e {seen {}}} {
    if {![dict exists $hir coroutines thunks] || ![dict exists $hir exprs $e]} {
        return ""
    }
    set node [dict get $hir exprs $e]
    if {[dict get $node kind] ne "ref" || [dict get $node binding] eq ""} {
        return ""
    }
    set b [dict get $node binding]
    if {$b in $seen || ![dict exists $hir bindings $b]} {
        return ""
    }
    set by [dict get $hir bindings $b declaredBy]
    if {$by eq "" || ![dict exists $hir exprs $by] || [dict get $hir exprs $by kind] ne "bind"
            || ![dict exists $hir exprs $by value] || [dict get $hir exprs $by value] eq ""} {
        return ""
    }
    set value [dict get $hir exprs $by value]
    if {[NativeOf $hir $value] eq [core::coroutines::createNative]} {
        set thunk [lindex [dict get $hir exprs $value args] 0]
        if {[dict exists $hir coroutines thunks $thunk]} {
            return $thunk
        }
        return ""
    }
    return [thunkOfHandle $hir $value [concat $seen [list $b]]]
}

# 1 if call E is a thunk's boundary call: the call of a coroutine's root. Its
# completion is the coroutine's last segment's, never the construction's:
# that it can never complete normally (a root that always fails after
# yielding) is no statically known failure of any one call
# (hir/completions.tcl's KNOWN-ERROR rule does not apply).
proc hir::coroutines::isBoundaryCall {hir e} {
    return [dict exists $hir coroutines boundaries $e]
}

# Writes out every call of a coroutine handle that type inference typed as a
# resume but whose callee is not the internal native yet -- a handle reached
# through a parameter, a function result, a destructuring, a join
# (AFFINE-VALUES.md) -- as the resume operation `coroutine#resume(HANDLE,
# MESSAGE...)`, the form resolution gives a construction's own handle
# (hir/resolve.tcl's CoroutineResume): shared callable checking decided the
# call (hir::types::Call's coroutine kind), and this is its lowering. Every
# backend then sees one resume form and needs nothing new. The call keeps its
# type, its declared errors and its completion facts; semantic instances
# that typed it get the same target.
proc hir::coroutines::ElaborateResumes {hirVar} {
    upvar 1 $hirVar hir
    if {[hir::mode $hir] ne "program"} {
        return
    }
    set calls {}
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call" || [dict get $node target] ne ""} continue
        if {[dict get $node type] eq ""} continue
        if {![hir::types::IsCoroutine [hir::typeOf $hir [dict get $node callee]]]} continue
        lappend calls $e
    }
    if {$calls eq {}} {
        return
    }
    set native [core::coroutines::resumeNative]
    set root [dict get $hir scopes [dict get $hir top] parent]
    set b [dict get $hir scopes $root names $native]
    set y [dict get $hir bindings $b symbol]
    set nativeType [hir::types::intern hir [list native $native]]
    foreach e $calls {
        set node [dict get $hir exprs $e]
        set callee [dict get $node callee]
        set r [hir::NewId hir expr]
        dict set hir exprs $r [dict create id $r kind ref origin [dict get $hir exprs $callee origin] \
            scope [dict get $node scope] type $nativeType reachable [dict get $node reachable] \
            name $native binding $b init yes]
        dict set hir exprs $e callee $r
        dict set hir exprs $e args [concat [list $callee] [dict get $node args]]
        dict set hir exprs $e target [list native $y]
        if {[dict exists $hir semantic instances]} {
            dict for {id inst} [dict get $hir semantic instances] {
                if {[dict exists $inst snapshot exprs $e]} {
                    dict set hir semantic instances $id snapshot exprs $e target [list native $y]
                }
            }
        }
    }
}
