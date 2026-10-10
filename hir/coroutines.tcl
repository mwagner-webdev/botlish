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
#   step(m)                     call ^coroutine#resume (ref step) m
#   coroutine::done?(step)      call ^coroutine::done? (ref step)
#
# A THUNK is the *coroutine boundary*: the one call in its body (the
# construction's call) is the root of a coroutine's execution, and its yield
# effect stops there. Everything else is ordinary code.
#
# What this file decides
# ----------------------
# analyze (before type inference; hir::CheckOnce):
#
#   call graph    the exact, syntactic call edges of every function region
#                 (hir::contexts::Callee: a block literal, a binding denoting
#                 one, a module function), excluding the thunks' boundary
#                 calls. A call through a function value is no edge: a
#                 function that may yield never becomes a value (below).
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
# and yield type), thunks (thunk -> its create call and root function),
# boundaries (a thunk's boundary call -> the thunk), yields (yield call -> its
# function), and, after verify, mayYield (the functions that may yield),
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
    return [expr {$name in [core::coroutines::natives] ? $name : ""}]
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

# The display name of block E (hir::contexts::BlockName's convention).
proc hir::coroutines::Name {hir e} {
    return [hir::contexts::BlockName $hir $e]
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

proc hir::coroutines::analyze {hirVar} {
    upvar 1 $hirVar hir
    if {![Used $hir]} {
        dict set hir coroutines [dict create]
        return
    }
    lassign [hir::contexts::Walk $hir] owner parent rootOf calls blocks
    # Thunks: the block literal argument of every create call.
    set thunks [dict create]
    dict for {o list} $calls {
        foreach c $list {
            if {[NativeOf $hir $c] ne [core::coroutines::createNative]} continue
            set arg [lindex [dict get $hir exprs $c args] 0]
            if {$arg eq "" || [dict get $hir exprs $arg kind] ne "block"} continue
            set body [dict get $hir exprs $arg body]
            set inner [expr {[llength $body] == 1 && [dict get $hir exprs [lindex $body 0] kind] eq "call"
                ? [lindex $body 0] : ""}]
            set root [expr {$inner eq "" ? "" : [hir::contexts::Callee $hir $inner]}]
            dict set thunks $arg [dict create create $c root $root call $inner]
        }
    }
    # Per function: direct yields and exact call edges.
    set yields [dict create]
    set direct [dict create]
    set edges [dict create]
    foreach b $blocks {
        dict set direct $b {}
        dict set edges $b {}
    }
    dict for {o list} $calls {
        foreach c $list {
            set native [NativeOf $hir $c]
            if {$native eq [core::coroutines::yieldNative]} {
                dict set yields $c $o
                if {$o ne ""} {
                    dict lappend direct $o $c
                }
                continue
            }
            if {$native ne "" || $o eq "" || [dict exists $thunks $o]} continue
            set target [hir::contexts::Callee $hir $c]
            if {$target ne "" && ![dict exists $thunks $target]} {
                dict lappend edges $o [list $c $target]
            }
        }
    }
    # The syntactically yield-capable functions (protocol inference's domain).
    set capable [dict create]
    foreach b $blocks {
        if {[dict get $direct $b] ne {}} {
            dict set capable $b 1
        }
    }
    set changed 1
    while {$changed} {
        set changed 0
        foreach b $blocks {
            if {[dict exists $capable $b]} continue
            foreach edge [dict get $edges $b] {
                if {[dict exists $capable [lindex $edge 1]]} {
                    dict set capable $b 1
                    set changed 1
                    break
                }
            }
        }
    }
    # Local constraints: declared protocols and use-site inference.
    set local [dict create]
    set used [dict create]
    set needsStruct [dict create]
    foreach b [dict keys $capable] {
        set constraints {}
        set declared [DeclaredResume $hir $b]
        if {$declared ne ""} {
            lappend constraints [list $declared [list declared $b]]
        }
        foreach y [dict get $direct $b] {
            lassign [YieldUses $hir $parent $y] isUsed types projections
            if {$isUsed} {
                dict set used $b 1
            }
            foreach {type at} $types {
                lappend constraints [list $type [list use $y $at]]
            }
            if {$projections ne {}} {
                dict lappend needsStruct $b [list $y [lindex $projections 0]]
            }
        }
        dict set local $b $constraints
    }
    # The protocol fixed point, then the zero-message default, then again.
    set protocols [dict create]
    set conflicts [dict create]
    foreach b [dict keys $capable] {
        dict set protocols $b [dict create protocol none reason {}]
    }
    Solve $hir $capable $local $edges protocols conflicts
    foreach b [dict keys $capable] {
        if {[dict get $protocols $b protocol] eq "none" && [dict exists $used $b]} {
            dict set local $b [concat [dict get $local $b] [list [list unit [list default $b]]]]
        }
    }
    Solve $hir $capable $local $edges protocols conflicts
    # Diagnostics of the protocols themselves.
    foreach b [lsort -dictionary [dict keys $conflicts]] {
        lassign [dict get $conflicts $b] p1 r1 p2 r2
        hir::Diagnose hir COROUTINE-RESUME-CONFLICT \
            [::format "%s needs two different resume protocols, and one coroutine has exactly one (no union is inferred: declare a struct with the fields both need, or split the coroutine):\n    %s: %s\n    %s: %s" \
                [Name $hir $b] [ShowProtocol $p1] [ExplainReason $hir $r1 $protocols] \
                [ShowProtocol $p2] [ExplainReason $hir $r2 $protocols]] $b
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
    dict for {t info} $thunks {
        set root [dict get $info root]
        if {$root ne "" && [dict exists $protocols $root]} {
            dict set roots $root [Resolved [dict get $protocols $root protocol]]
        }
    }
    set reachedByStruct [dict create]
    dict for {root protocol} $roots {
        if {![IsStructProtocol $protocol]} continue
        foreach b [Closure $root $edges $capable] {
            dict set reachedByStruct $b 1
        }
    }
    set table [dict create]
    foreach b [dict keys $capable] {
        set p [dict get $protocols $b protocol]
        switch -- $p {
            none {
                set yieldType [expr {[dict exists $reachedByStruct $b] ? "any" : "unit"}]
            }
            unit { set yieldType unit }
            conflict { set yieldType any }
            default { set yieldType $p }
        }
        dict set table $b [dict create protocol $p yieldType $yieldType \
            reason [dict get $protocols $b reason]]
    }
    set boundaries [dict create]
    dict for {t info} $thunks {
        if {[dict get $info call] ne ""} {
            dict set boundaries [dict get $info call] $t
        }
    }
    dict set hir coroutines [dict create blocks $table thunks $thunks yields $yields \
        edges $edges direct $direct boundaries $boundaries]
}

# The declared `resume T` protocol of block E, or "".
proc hir::coroutines::DeclaredResume {hir e} {
    return [expr {[dict exists $hir exprs $e declaredResume] ? [dict get $hir exprs $e declaredResume] : ""}]
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
                lappend inputs [list [dict get $protocols $target protocol] [list call $c $target]]
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
                lassign $reason _ c target
                lappend steps "[expr {$steps eq {} ? "it calls" : "which calls"}] [Name $hir $target] ([Where $hir $c])"
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
# the argument of an exact call with a declared struct parameter (AT {CALL
# TYPE}); PROJECTIONS the field projections of it (a struct use whose type a
# projection cannot determine).
proc hir::coroutines::YieldUses {hir parent y} {
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
                set target [hir::contexts::Callee $hir $q]
                if {$target eq ""} continue
                set declared [lindex [dict get $hir exprs $target declaredParamTypes] $index]
                if {[IsStructProtocol $declared]} {
                    lappend types $declared [list $q $declared]
                }
            }
        }
    }
    return [list 1 $types $projections]
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

proc hir::coroutines::ShapeResult {hir shape argExprs argTypes} {
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
            if {$b ne "" && [dict exists $table blocks $b]} {
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
            if {$root eq "" || ![dict exists $table blocks $root]} {
                return [hir::types::MakeCoroutine unit any {}]
            }
            return [hir::types::MakeCoroutine [Resolved [dict get $table blocks $root protocol]] \
                [Outward $hir $root] [dict get $hir exprs $root declaredErrors]]
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

# The outward type of a coroutine rooted at function ROOT: its declared
# result, else the join of its result and of every value a yield its
# coroutine can reach sends (as typed so far).
proc hir::coroutines::Outward {hir root} {
    set declared [dict get $hir exprs $root declaredResult]
    if {$declared ne ""} {
        return $declared
    }
    set result never
    if {[dict get $hir exprs $root resultType] ne ""} {
        set result [hir::type $hir [dict get $hir exprs $root resultType]]
    } else {
        return any
    }
    foreach {y type} [YieldTypes $hir $root 0] {
        set result [hir::types::lub $result $type]
    }
    return $result
}

# {YIELD TYPE ...}: every yield the coroutine rooted at ROOT can reach (over
# the syntactic call graph; with REACHABLE 1, only reachable yields of
# functions that may yield), with the static type of the value it sends.
proc hir::coroutines::YieldTypes {hir root reachable} {
    set table [dict get $hir coroutines]
    set capable [dict get $table blocks]
    set edges [dict get $table edges]
    set result {}
    foreach b [lsort -dictionary [Closure $root $edges $capable]] {
        if {$reachable && ![MayYield $hir $b]} continue
        foreach y [dict get $table direct $b] {
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
    # Yields outside every function.
    dict for {y o} [dict get $table yields] {
        if {$o eq ""} {
            hir::Diagnose hir YIELD-OUTSIDE-FUNCTION \
                "yield outside a function: a yield suspends the coroutine whose function it is written in, and top-level code is not in a function (move it into a function and start that function with \"coroutine {step, first} = f(...)\")" $y
        }
    }
    # The reachable yield effect, with each function's next step towards a
    # direct yield (breadth-first: the shortest chain, in call order).
    set next [dict create]
    set mayYield [dict create]
    dict for {b ys} [dict get $table direct] {
        foreach y $ys {
            if {[dict get $hir exprs $y reachable]} {
                dict set mayYield $b 1
                dict set next $b [list direct $y]
                break
            }
        }
    }
    set frontier [dict keys $mayYield]
    while {$frontier ne {}} {
        set added {}
        foreach b $blocks {
            if {[dict exists $mayYield $b] || [dict exists $thunks $b]} continue
            foreach edge [dict get $table edges $b] {
                lassign $edge c target
                if {[dict exists $mayYield $target] && [lsearch -exact $frontier $target] >= 0
                        && [dict get $hir exprs $c reachable]} {
                    dict set next $b [list call $c $target]
                    lappend added $b
                    break
                }
            }
        }
        foreach b $added {
            dict set mayYield $b 1
        }
        set frontier $added
    }
    dict set hir coroutines mayYield $mayYield
    dict set hir coroutines next $next
    # Entering a yielding call graph without a coroutine boundary.
    if {[dict exists $calls ""]} {
        foreach c [dict get $calls ""] {
            if {![dict get $hir exprs $c reachable] || [NativeOf $hir $c] ne ""} continue
            set target [hir::contexts::Callee $hir $c]
            if {$target eq "" || ![dict exists $mayYield $target]} continue
            hir::Diagnose hir UNWRAPPED-YIELD \
                "[Name $hir $target] may suspend, but this call does not start a coroutine (start it with \"coroutine {step, first} = [Name $hir $target](...)\", or call it from a function that runs inside a coroutine):\n[Chain $hir $target $next]" $c
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
        if {$target eq "" || ![dict exists $mayYield $target] || ![dict exists $parent $e]} continue
        if {![dict get $node reachable] || ![hir::contexts::Observed $hir $parent $e]} continue
        hir::Diagnose hir UNWRAPPED-YIELD \
            "[Name $hir $target] may suspend, so it cannot become a function value: a call through an unknown function value could run it outside every coroutine (call it directly, or start it with \"coroutine {step, first} = [Name $hir $target](...)\"):\n[Chain $hir $target $next]" $e
    }
    # Constructions.
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
            hir::Diagnose hir COROUTINE-RHS-NOT-YIELDING \
                "[Name $hir $root] never yields (it has no reachable yield and calls no function that may yield), so there is no coroutine to start: call it directly" $create
            continue
        }
        ResultMismatch hir $create $root
        AffineProtocol hir $create $root
    }
    # Resume calls are checked by the shared callable contract check
    # (hir::range::VerifyStructuralCall, AFFINE-VALUES.md): arity
    # (COROUTINE-RESUME-ARITY) and the message's type (TYPE); ownership by
    # hir::affine::verify.
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
        lappend lines "$prefix[Name $hir $b], which calls [Name $hir [lindex $step 2]] at [Where $hir [lindex $step 1]]"
        set b [lindex $step 2]
        set first 0
    }
    return [join $lines \n]
}

# COROUTINE-RESULT-MISMATCH at construction CREATE of root ROOT: every value a
# segment of the coroutine can end with must have one common outward type.
proc hir::coroutines::ResultMismatch {hirVar create root} {
    upvar 1 $hirVar hir
    set yields [YieldTypes $hir $root 1]
    set declared [dict get $hir exprs $root declaredResult]
    set name [Name $hir $root]
    if {$declared ne ""} {
        foreach {y type} $yields {
            if {![hir::types::subtype $type $declared]} {
                hir::Diagnose hir COROUTINE-RESULT-MISMATCH \
                    "a coroutine's yields and its return share one outward type, $name's declared result [hir::types::show $declared]; the yield at [Where $hir $y] sends a [hir::types::show $type] (yield a [hir::types::show $declared], or declare a result type both are)" $create
                return
            }
        }
        return
    }
    set components {}
    if {[dict get $hir exprs $root resultType] ne ""} {
        set result [hir::type $hir [dict get $hir exprs $root resultType]]
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
            return
        }
    }
    hir::Diagnose hir COROUTINE-RESULT-MISMATCH \
        "a coroutine's yields and its return share one outward type, but $name's do not: it can end a segment with [join [lmap t $components {hir::types::show $t}] {, }] (declare $name's result type, and yield and return values of it)" $create
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
        return [expr {[dict exists $hir exprs $e coroutineEffect] ? [dict get $hir exprs $e coroutineEffect] : ""}]
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
    return [dict get $hir exprs $root declaredErrors]
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
        return [expr {[dict exists $hir coroutines thunks $thunk] ? $thunk : ""}]
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
